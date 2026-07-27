import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isi_group_corporate_app/core/error/biometric_reason.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/session/session_manager.dart';
import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/biometric_unlock_gate.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/authenticate_with_biometrics.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/login.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/set_biometric_enabled.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/biometric_mocks.dart';

void main() {
  late MockLogin login;
  late MockLogout logout;
  late MockGetCurrentUser getCurrentUser;
  late MockAuthenticateWithBiometrics authenticateWithBiometrics;
  late MockCanOfferBiometricUnlock canOffer;
  late MockSetBiometricEnabled setBiometricEnabled;
  late SessionManager session;

  const user = User(
    id: 'user_001',
    email: 'tester@gmail.com',
    fullName: 'Test Tester',
    roles: {},
  );

  const openGate = BiometricUnlockGate(
    deviceUsable: true,
    hasStoredSession: true,
    preferenceEnabled: true,
  );
  const notOptedIn = BiometricUnlockGate(
    deviceUsable: true,
    hasStoredSession: true,
    preferenceEnabled: false,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(
      const AuthenticateWithBiometricsParams(localizedReason: ''),
    );
    registerFallbackValue(const SetBiometricEnabledParams(enabled: false));
  });

  setUp(() {
    login = MockLogin();
    logout = MockLogout();
    getCurrentUser = MockGetCurrentUser();
    authenticateWithBiometrics = MockAuthenticateWithBiometrics();
    canOffer = MockCanOfferBiometricUnlock();
    setBiometricEnabled = MockSetBiometricEnabled();
    session = SessionManager();
  });

  tearDown(() => session.dispose());

  AuthBloc build() => AuthBloc(
        login: login,
        logout: logout,
        getCurrentUser: getCurrentUser,
        sessionManager: session,
        authenticateWithBiometrics: authenticateWithBiometrics,
        canOfferBiometricUnlock: canOffer,
        setBiometricEnabled: setBiometricEnabled,
      );

  void stubGate(BiometricUnlockGate gate) {
    when(() => canOffer(any())).thenAnswer((_) async => Success(gate));
  }

  // ───────────────────────────── boot resolution ───────────────────────────

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'promotes the cached session directly when biometrics are off '
      '(behaviour is unchanged for everyone who never opted in)',
      setUp: () {
        when(() => getCurrentUser(any()))
            .thenAnswer((_) async => const Success(user));
        stubGate(notOptedIn);
      },
      build: build,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoadingState(),
        const AuthenticatedState(user, canEnrollBiometrics: true),
      ],
      verify: (_) => expect(session.isAuthenticated, isTrue),
    );

    blocTest<AuthBloc, AuthState>(
      'holds the session behind the lock when the user opted in',
      setUp: () {
        when(() => getCurrentUser(any()))
            .thenAnswer((_) async => const Success(user));
        stubGate(openGate);
      },
      build: build,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoadingState(),
        const AuthBiometricLockedState(user: user, canUseBiometrics: true),
      ],
      verify: (_) {
        // The session is NOT promoted — guards see a guest, so the whole app
        // stays browsable and nothing is "locked out".
        expect(session.isAuthenticated, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'still shows the lock surface when the sensor disappeared, so the '
      'credential form is reachable rather than auto-authenticating',
      setUp: () {
        when(() => getCurrentUser(any()))
            .thenAnswer((_) async => const Success(user));
        stubGate(const BiometricUnlockGate(
          deviceUsable: false,
          hasStoredSession: true,
          preferenceEnabled: true,
        ));
      },
      build: build,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoadingState(),
        // canUseBiometrics false ⇒ no unlock button, only the password form.
        const AuthBiometricLockedState(user: user, canUseBiometrics: false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'no cached session is still a guest, never a biometric lock',
      setUp: () {
        when(() => getCurrentUser(any())).thenAnswer(
          (_) async => const Failed(
              AuthenticationFailure(message: 'No active session.')),
        );
        stubGate(openGate);
      },
      build: build,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoadingState(), const AuthGuestState()],
    );
  });

  // ──────────────────────────── biometric unlock ───────────────────────────

  group('BiometricUnlockRequested', () {
    blocTest<AuthBloc, AuthState>(
      'a match promotes the held session',
      setUp: () {
        when(() => getCurrentUser(any()))
            .thenAnswer((_) async => const Success(user));
        when(() => authenticateWithBiometrics(any()))
            .thenAnswer((_) async => const Success(user));
        stubGate(openGate);
      },
      build: build,
      seed: () => const AuthBiometricLockedState(
        user: user,
        canUseBiometrics: true,
      ),
      act: (bloc) =>
          bloc.add(const BiometricUnlockRequested(localizedReason: 'Unlock')),
      expect: () => [
        const AuthLoadingState(),
        const AuthenticatedState(user, biometricUnlockEnabled: true),
      ],
      verify: (_) => expect(session.isAuthenticated, isTrue),
    );

    // Each unhappy path must return to a surface that still shows the form.
    for (final entry in const <String, BiometricReason>{
      'cancellation': BiometricReason.cancelled,
      'lockout': BiometricReason.lockedOut,
      'no enrolment': BiometricReason.notEnrolled,
      'unavailable hardware': BiometricReason.notAvailable,
      'a non-match': BiometricReason.notRecognised,
    }.entries) {
      blocTest<AuthBloc, AuthState>(
        '${entry.key} falls back to the lock surface with an explanation, '
        'never blocking the user',
        setUp: () {
          when(() => authenticateWithBiometrics(any())).thenAnswer(
            (_) async => Failed(
              BiometricFailure(reason: entry.value, message: 'x'),
            ),
          );
          stubGate(openGate);
        },
        build: build,
        seed: () => const AuthBiometricLockedState(
          user: user,
          canUseBiometrics: true,
        ),
        act: (bloc) =>
            bloc.add(const BiometricUnlockRequested(localizedReason: 'Unlock')),
        expect: () => [
          const AuthLoadingState(),
          AuthBiometricLockedState(
            user: user,
            canUseBiometrics: true,
            noticeKey: entry.value.localizationKey,
          ),
        ],
        verify: (_) {
          // No session was granted, and nothing was wiped either — the
          // password form still has a session to fall back on.
          expect(session.isAuthenticated, isFalse);
        },
      );
    }

    blocTest<AuthBloc, AuthState>(
      'a failure carries a localization key, never raw exception text',
      setUp: () {
        when(() => authenticateWithBiometrics(any())).thenAnswer(
          (_) async => const Failed(
            BiometricFailure(
              reason: BiometricReason.lockedOut,
              message: 'PlatformException(LockedOut, ...)',
            ),
          ),
        );
        stubGate(openGate);
      },
      build: build,
      seed: () =>
          const AuthBiometricLockedState(user: user, canUseBiometrics: true),
      act: (bloc) =>
          bloc.add(const BiometricUnlockRequested(localizedReason: 'Unlock')),
      verify: (bloc) {
        final state = bloc.state as AuthBiometricLockedState;
        expect(state.noticeKey, 'auth.biometric.error.locked_out');
        expect(state.noticeKey, isNot(contains('PlatformException')));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a request with no cached session degrades to guest + the login form',
      setUp: () {
        when(() => authenticateWithBiometrics(any())).thenAnswer(
          (_) async => const Failed(
            BiometricFailure(
              reason: BiometricReason.notAvailable,
              message: 'x',
            ),
          ),
        );
        stubGate(const BiometricUnlockGate.closed());
      },
      build: build,
      seed: () => const AuthGuestState(),
      act: (bloc) =>
          bloc.add(const BiometricUnlockRequested(localizedReason: 'Unlock')),
      expect: () => [const AuthLoadingState(), const AuthGuestState()],
    );
  });

  // ─────────────────────────── the opt-in preference ───────────────────────

  group('BiometricPreferenceToggled', () {
    blocTest<AuthBloc, AuthState>(
      'enabling reflects on the authenticated state',
      setUp: () {
        when(() => setBiometricEnabled(any()))
            .thenAnswer((_) async => const Success(null));
        stubGate(openGate);
      },
      build: build,
      seed: () => const AuthenticatedState(user, canEnrollBiometrics: true),
      act: (bloc) => bloc.add(const BiometricPreferenceToggled(enabled: true)),
      expect: () => [
        const AuthenticatedState(user, biometricUnlockEnabled: true),
      ],
      verify: (_) => verify(() => setBiometricEnabled(
            const SetBiometricEnabledParams(enabled: true),
          )).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'a refused enable keeps the user signed in and explains why',
      setUp: () {
        when(() => setBiometricEnabled(any())).thenAnswer(
          (_) async => const Failed(
            BiometricFailure(
              reason: BiometricReason.notEnrolled,
              message: 'x',
            ),
          ),
        );
        stubGate(notOptedIn);
      },
      build: build,
      seed: () => const AuthenticatedState(user, canEnrollBiometrics: true),
      act: (bloc) => bloc.add(const BiometricPreferenceToggled(enabled: true)),
      expect: () => [
        const AuthenticatedState(
          user,
          canEnrollBiometrics: true,
          biometricNoticeKey: 'auth.biometric.error.not_enrolled',
        ),
      ],
      verify: (_) {
        // Declining or failing the opt-in never costs them the session.
        expect(session.isAuthenticated, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'disabling is always applied',
      setUp: () {
        when(() => setBiometricEnabled(any()))
            .thenAnswer((_) async => const Success(null));
        stubGate(notOptedIn);
      },
      build: build,
      seed: () => const AuthenticatedState(user, biometricUnlockEnabled: true),
      act: (bloc) => bloc.add(const BiometricPreferenceToggled(enabled: false)),
      expect: () => [
        const AuthenticatedState(user, canEnrollBiometrics: true),
      ],
    );
  });

  // ──────────────────────────── the core invariant ─────────────────────────

  group('INVARIANT: biometrics can never be the sole way in', () {
    blocTest<AuthBloc, AuthState>(
      'credential login works untouched while biometrics are enabled',
      setUp: () {
        when(() => login(any())).thenAnswer((_) async => const Success(user));
        stubGate(openGate);
      },
      build: build,
      // Start from the biometric lock: the user ignores the prompt entirely.
      seed: () =>
          const AuthBiometricLockedState(user: user, canUseBiometrics: true),
      act: (bloc) => bloc.add(
        const LoginSubmittedEvent(email: 'a@b.com', password: 'secret1'),
      ),
      expect: () => [
        const AuthLoadingState(),
        const AuthenticatedState(user, biometricUnlockEnabled: true),
      ],
      verify: (_) {
        expect(session.isAuthenticated, isTrue);
        // The password path never consults the biometric prompt.
        verifyNever(() => authenticateWithBiometrics(any()));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'credential login works with no biometric hardware at all',
      setUp: () {
        when(() => login(any())).thenAnswer((_) async => const Success(user));
        stubGate(const BiometricUnlockGate.closed());
      },
      build: build,
      act: (bloc) => bloc.add(
        const LoginSubmittedEvent(email: 'a@b.com', password: 'secret1'),
      ),
      expect: () => [
        const AuthLoadingState(),
        const AuthenticatedState(user),
      ],
      verify: (_) => expect(session.isAuthenticated, isTrue),
    );

    blocTest<AuthBloc, AuthState>(
      'a permanently locked-out sensor still leaves the credential form '
      'reachable — no state blocks sign-in',
      setUp: () {
        when(() => authenticateWithBiometrics(any())).thenAnswer(
          (_) async => const Failed(
            BiometricFailure(
              reason: BiometricReason.permanentlyLockedOut,
              message: 'x',
            ),
          ),
        );
        when(() => login(any())).thenAnswer((_) async => const Success(user));
        stubGate(openGate);
      },
      build: build,
      seed: () =>
          const AuthBiometricLockedState(user: user, canUseBiometrics: true),
      act: (bloc) async {
        bloc.add(const BiometricUnlockRequested(localizedReason: 'Unlock'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const LoginSubmittedEvent(email: 'a@b.com', password: 'secret1'),
        );
      },
      verify: (bloc) {
        expect(bloc.state, isA<AuthenticatedState>());
        expect(session.isAuthenticated, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'logout leaves the preference alone but closes the gate with the session',
      setUp: () {
        when(() => logout(any())).thenAnswer((_) async => const Success(null));
        stubGate(openGate);
      },
      build: build,
      seed: () => const AuthenticatedState(user, biometricUnlockEnabled: true),
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthGuestState()],
      verify: (_) {
        expect(session.isAuthenticated, isFalse);
        // The opt-in is a device preference, not session state — clearing it on
        // every logout would silently opt the user out.
        verifyNever(() => setBiometricEnabled(any()));
      },
    );
  });
}
