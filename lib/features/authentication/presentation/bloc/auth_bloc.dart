import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/session/session_manager.dart';
import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/biometric_unlock_gate.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/authenticate_with_biometrics.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/can_offer_biometric_unlock.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/get_current_user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/login.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/logout.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_state.dart';

/// Orchestrates auth use cases and keeps the app-wide [SessionManager] in sync
/// so guards, role checks, and sync scopes have a single, synchronous source
/// of truth for "who is signed in right now".
///
/// Holds no business logic itself — it only maps events to use-case calls and
/// their [Result] into states (+ the matching session mutation).
///
/// ## Biometrics
///
/// Biometric unlock is handled here rather than in a parallel bloc, because it
/// resolves the *same* session and must not be able to disagree with the
/// credential flow about who is signed in. Two rules are load-bearing:
///
///  * **Never the only way in.** Every state that offers a biometric prompt
///    is rendered on a surface that also shows the credential form, and every
///    biometric failure returns to that surface rather than blocking.
///  * **Never a network dependency.** Unlock reads secure storage only, so it
///    behaves identically offline.
///  * **Never an enabler.** This bloc can *consume* biometrics but cannot turn
///    them on. Enabling is onboarding, and onboarding lives in `BiometricBloc`
///    behind Profile → Password & Security. There is deliberately no event
///    here that writes `biometricEnabled`.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required Login login,
    required Logout logout,
    required GetCurrentUser getCurrentUser,
    required SessionManager sessionManager,
    required AuthenticateWithBiometrics authenticateWithBiometrics,
    required CanOfferBiometricUnlock canOfferBiometricUnlock,
  })  : _login = login,
        _logout = logout,
        _getCurrentUser = getCurrentUser,
        _session = sessionManager,
        _authenticateWithBiometrics = authenticateWithBiometrics,
        _canOfferBiometricUnlock = canOfferBiometricUnlock,
        super(const AuthInitialState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthGuestRequested>(_onGuest);
    // `droppable` guards against double-submits: extra taps while a login
    // is in flight are ignored rather than queued.
    on<LoginSubmittedEvent>(_onLogin, transformer: droppable());
    on<LogoutRequested>(_onLogout);
    // Also droppable: the OS allows one biometric prompt at a time, and a
    // queued second request would surface as `auth_in_progress`.
    on<BiometricUnlockRequested>(_onBiometricUnlock, transformer: droppable());
    on<BiometricGateRefreshed>(_onBiometricGateRefreshed);
  }

  final Login _login;
  final Logout _logout;
  final GetCurrentUser _getCurrentUser;
  final SessionManager _session;
  final AuthenticateWithBiometrics _authenticateWithBiometrics;
  final CanOfferBiometricUnlock _canOfferBiometricUnlock;

  /// Session restore on boot. A cached session promotes to [AuthenticatedState];
  /// its absence is *not* an error here — the user simply continues as a guest,
  /// free to browse until they hit a protected feature.
  ///
  /// When the user opted in to biometric unlock, the cached session is held in
  /// [AuthBiometricLockedState] instead of being promoted. The app stays fully
  /// browsable (the session manager is cleared, so guards treat them as a
  /// guest) — they just confirm with a fingerprint, or with their password,
  /// before their account comes back.
  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _getCurrentUser(const NoParams());

    final user = result.when(success: (u) => u, failure: (_) => null);
    if (user == null) {
      _session.clear();
      emit(const AuthGuestState());
      return;
    }

    final gate = await _gate();
    if (gate.preferenceEnabled) {
      // Held, not promoted: the session manager stays empty until they unlock.
      _session.clear();
      emit(AuthBiometricLockedState(
        user: user,
        canUseBiometrics: gate.canOffer,
      ));
      return;
    }

    _session.setUser(user);
    emit(AuthenticatedState(user, biometricUnlockEnabled: false));
  }

  void _onGuest(AuthGuestRequested event, Emitter<AuthState> emit) {
    _session.clear();
    emit(const AuthGuestState());
  }

  Future<void> _onLogin(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );

    final user = result.when(success: (u) => u, failure: (_) => null);
    if (user == null) {
      emit(AuthFailureState(
        result.when(success: (_) => '', failure: (f) => f.message),
      ));
      return;
    }

    _session.setUser(user);
    // Read after the session lands so `hasStoredSession` is true. This only
    // *reports* whether biometrics are already on — it never enables them.
    final gate = await _gate();
    emit(AuthenticatedState(
      user,
      biometricUnlockEnabled: gate.preferenceEnabled,
    ));
  }

  /// Signing out drops the token/session and returns the user to guest
  /// browsing — the app stays open and usable, matching the guest-first model.
  ///
  /// **Logout must not remove biometric registration.** Only tokens are
  /// cleared. `BiometricSettings` lives in its own secure-storage keys, which
  /// `AuthLocalDataSource.clear()` does not touch, so `biometricRegistered`
  /// and the enabled modalities survive — and the next login immediately
  /// offers "Sign in with Fingerprint / Face ID". There is nothing to unlock
  /// without a stored session, so the gate closes on its own until then.
  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout(const NoParams());
    _session.clear();
    emit(const AuthGuestState());
  }

  /// Runs the OS prompt and promotes the stored session on a match.
  ///
  /// Every failure path lands back on a state whose surface still shows the
  /// credential form, carrying a localization *key* explaining why — the user
  /// is never blocked, only told.
  Future<void> _onBiometricUnlock(
    BiometricUnlockRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(const AuthLoadingState());

    final result = await _authenticateWithBiometrics(
      AuthenticateWithBiometricsParams(copy: event.copy),
    );

    final user = result.when(success: (u) => u, failure: (_) => null);
    if (user != null) {
      _session.setUser(user);
      emit(AuthenticatedState(user, biometricUnlockEnabled: true));
      return;
    }

    final noticeKey = result.when(
      success: (_) => null,
      failure: _noticeKeyFor,
    );

    // Return to the locked surface when we still know who is cached, so the
    // user can retry or type their password. Without a cached user there is
    // nothing to unlock: fall back to plain guest + the login form.
    final cachedUser = _userOf(previous);
    if (cachedUser == null) {
      _session.clear();
      emit(const AuthGuestState());
      return;
    }

    final gate = await _gate();
    emit(AuthBiometricLockedState(
      user: cachedUser,
      canUseBiometrics: gate.canOffer,
      noticeKey: noticeKey,
    ));
  }

  /// Re-reads the gate — e.g. after the user changed their enrolled
  /// fingerprints in system settings while the app was backgrounded.
  Future<void> _onBiometricGateRefreshed(
    BiometricGateRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    final gate = await _gate();

    switch (current) {
      case AuthBiometricLockedState():
        emit(AuthBiometricLockedState(
          user: current.user,
          canUseBiometrics: gate.canOffer,
          noticeKey: current.noticeKey,
        ));
      case AuthenticatedState():
        emit(AuthenticatedState(
          current.user,
          biometricUnlockEnabled: gate.preferenceEnabled,
        ));
      case _:
        // Nothing to refresh: no session means no gate to evaluate.
        break;
    }
  }

  /// Evaluates the three-term gate, treating any failure as "closed". A gate
  /// that cannot be read must hide the affordance, never open it.
  Future<BiometricUnlockGate> _gate() async {
    final result = await _canOfferBiometricUnlock(const NoParams());
    return result.when(
      success: (g) => g,
      failure: (_) => const BiometricUnlockGate.closed(),
    );
  }

  /// The cached user carried by a state, if it has one.
  User? _userOf(AuthState state) => switch (state) {
        AuthBiometricLockedState(user: final u) => u,
        AuthenticatedState(user: final u) => u,
        _ => null,
      };

  /// Localization key for a failure. Biometric failures carry their own
  /// reason-specific key; anything else falls back to the generic message so
  /// presentation never has to render a raw exception.
  String _noticeKeyFor(Failure failure) => switch (failure) {
        BiometricFailure(localizationKey: final key) => key,
        _ => 'auth.biometric.error.unknown',
      };
}
