import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => const [];
}

/// Idle, before any auth check has run.
final class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// A request is in flight (LoginScreen maps this to `verifying`).
final class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// Signed in (LoginScreen maps this to `success`).
final class AuthenticatedState extends AuthState {
  const AuthenticatedState(this.user, {this.biometricUnlockEnabled = false});

  final User user;

  /// Whether biometric unlock is switched on for this device. Informational
  /// only — it never grants access, and it is written exclusively by the
  /// onboarding flow in `BiometricBloc`.
  final bool biometricUnlockEnabled;

  @override
  List<Object?> get props => [user, biometricUnlockEnabled];
}

/// A credential session exists in secure storage but the user opted in to
/// biometric unlock, so it has **not** been promoted yet.
///
/// This is not a lockout. `SessionManager` stays cleared, so the app behaves
/// exactly as it does for a guest — the whole shell is browsable — and every
/// surface that reaches this state also renders the credential form. The
/// biometric prompt is an accelerator on top of it, never a gate in front of
/// it.
final class AuthBiometricLockedState extends AuthState {
  const AuthBiometricLockedState({
    required this.user,
    required this.canUseBiometrics,
    this.noticeKey,
  });

  /// The cached user, kept so the surface can greet them by name and so a
  /// failed prompt can return to this same state instead of losing context.
  final User user;

  /// Whether to render the unlock affordance at all. `false` when the sensor
  /// is gone or nothing is enrolled — the credential form is then the only
  /// thing shown, which is the required fallback.
  final bool canUseBiometrics;

  /// Localization key explaining the last failed attempt (cancelled, locked
  /// out, not enrolled…), or null on first entry.
  final String? noticeKey;

  @override
  List<Object?> get props => [user, canUseBiometrics, noticeKey];
}

/// No session / signed out (LoginScreen treats this as idle).
final class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

/// Browsing without an account. This is the *default* resting state for a
/// user who finished onboarding but never signed in — the app is fully
/// usable, and protected features prompt for login on demand (see
/// `AuthGuard`). Distinct from [UnauthenticatedState] (a transient
/// "must re-authenticate" signal), a guest is a first-class, expected user.
final class AuthGuestState extends AuthState {
  const AuthGuestState();
}

/// A request failed (LoginScreen maps this to `error`).
final class AuthFailureState extends AuthState {
  const AuthFailureState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
