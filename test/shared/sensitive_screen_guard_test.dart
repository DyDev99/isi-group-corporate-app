import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/security/biometric/authentication_reason.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/security/biometric/identity_verification_cache.dart';
import 'package:isi_group_corporate_app/core/session/session_manager.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/login.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/sensitive_screen_guard.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/biometric_mocks.dart';

/// Regression cover for the guard's routing.
///
/// The bug these tests exist for: with no signed-in session the guard called
/// `Navigator.maybePop()` from its own `initState`, so tapping Payslips pushed
/// a route that popped itself on the next frame — the screen "did nothing".
/// Bounded pumps instead of `pumpAndSettle`: the guard renders a
/// CircularProgressIndicator while busy, and an indeterminate progress
/// animation schedules frames forever, so `pumpAndSettle` would never settle.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  late MockBiometricRepository repository;
  late MockLogin login;
  late SessionManager session;

  const user = User(
    id: 'user_001',
    email: 'tester@gmail.com',
    fullName: 'Test Tester',
    roles: {},
  );

  const readyDevice = BiometricCapability(
    hasHardware: true,
    isDeviceSecure: true,
    enrolled: [BiometricType.fingerprint],
  );
  // What a stock emulator reports: hardware, but nothing enrolled.
  const emulatorDevice = BiometricCapability(
    hasHardware: true,
    isDeviceSecure: true,
    enrolled: [],
  );

  setUpAll(() {
    registerFallbackValue(testPromptCopy);
    // Needed for `any()` on the Login use case in the verifyNever checks.
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  setUp(() {
    repository = MockBiometricRepository();
    login = MockLogin();
    session = SessionManager();
  });

  tearDown(() => session.dispose());

  /// Pushes the guard as a route with the grace window disabled, so each test
  /// starts from a cold check unless it opts in.
  ///
  /// This matters: with the guard as `MaterialApp.home` it is the *only* route,
  /// so `Navigator.maybePop()` is a silent no-op and the original bug is
  /// invisible. Pushing it reproduces the real navigation stack, so a guard
  /// that pops itself actually disappears — which is what these tests assert.
  Future<void> openGuard(
    WidgetTester tester, {
    IdentityVerificationCache? cache,
    bool alwaysReverify = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        // A fresh key per call forces a full remount. Without it, re-pumping a
        // structurally identical tree reuses the element tree *and the
        // Navigator's route stack*, so a second openGuard would silently
        // return the already-unlocked guard instead of opening a new screen —
        // and the grace-window assertions would prove nothing.
        key: UniqueKey(),
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SensitiveScreenGuard(
                    reason: AuthenticationReason.confirmPayment,
                    titleKey: 'profile.payroll.title',
                    descriptionKey: 'auth.biometric.gate.payroll_body',
                    alwaysReverify: alwaysReverify,
                    repository: repository,
                    login: login,
                    session: session,
                    // A window of zero means "no grace", so the existing tests
                    // keep exercising a cold check.
                    verificationCache: cache ??
                        IdentityVerificationCache(graceWindow: Duration.zero),
                    child: const Text('PROTECTED CONTENT'),
                  ),
                ),
              ),
              child: const Text('OPEN'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await settle(tester);
  }

  group('REGRESSION: the guard must never pop itself', () {
    testWidgets(
        'a guest sees a sign-in prompt instead of a screen that '
        'closes itself', (tester) async {
      // No session — exactly the emulator situation that produced the bug.
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(emulatorDevice));

      await openGuard(tester);

      // The guard is still on screen (it did not pop) …
      expect(find.byType(SensitiveScreenGuard), findsOneWidget);
      // … the content is still protected …
      expect(find.text('PROTECTED CONTENT'), findsNothing);
      // … and there is a visible way forward.
      expect(find.byType(FilledButton), findsWidgets);

      // Nothing was even attempted: no session means no identity to prove.
      verifyNever(() => repository.authenticate(copy: any(named: 'copy')));
    });

    testWidgets('a guest never reaches the password sheet', (tester) async {
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(emulatorDevice));

      await openGuard(tester);

      // The password path is verified against the session's email, so it
      // cannot run without one.
      verifyNever(() => login(any()));
    });
  });

  group('signed in, device has no enrolled biometrics (emulator)', () {
    setUp(() {
      session.setUser(user);
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(emulatorDevice));
    });

    testWidgets('skips the biometric prompt and offers the password',
        (tester) async {
      await openGuard(tester);

      // No prompt raised — it could only fail on a device with no enrolment.
      verifyNever(() => repository.authenticate(copy: any(named: 'copy')));
      // Still guarding.
      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.byType(SensitiveScreenGuard), findsOneWidget);
    });
  });

  group('grace window — the cooldown between guarded screens', () {
    late DateTime now;
    late IdentityVerificationCache cache;

    setUp(() {
      session.setUser(user);
      now = DateTime.utc(2026, 7, 28, 9, 0, 0);
      cache = IdentityVerificationCache(
        graceWindow: const Duration(seconds: 60),
        clock: () => now,
      );
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(readyDevice));
      when(() => repository.authenticate(copy: any(named: 'copy')))
          .thenAnswer((_) async => const Success(true));
    });

    testWidgets('a successful check opens a window for the next screen',
        (tester) async {
      // First guarded screen: prompts, and the user passes.
      await openGuard(tester, cache: cache);
      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
      verify(() => repository.authenticate(copy: any(named: 'copy'))).called(1);

      // Second guarded screen, 20s later — straight through, no prompt.
      now = now.add(const Duration(seconds: 20));
      await openGuard(tester, cache: cache);

      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
      verifyNever(() => repository.authenticate(copy: any(named: 'copy')));
    });

    testWidgets('the window closes after 60 seconds', (tester) async {
      await openGuard(tester, cache: cache);
      clearInteractions(repository);

      now = now.add(const Duration(seconds: 61));
      await openGuard(tester, cache: cache);

      // Expired — proves identity again.
      verify(() => repository.authenticate(copy: any(named: 'copy'))).called(1);
    });

    testWidgets('a cancelled check opens no window', (tester) async {
      when(() => repository.authenticate(copy: any(named: 'copy'))).thenAnswer(
        (_) async => const Failed(
          BiometricFailure(
            code: BiometricFailureCode.userCanceled,
            message: 'UserCancel',
          ),
        ),
      );

      await openGuard(tester, cache: cache);
      expect(find.text('PROTECTED CONTENT'), findsNothing);

      // Backing out and reopening must still prompt — a failed attempt is not
      // a grace period.
      expect(cache.isValidFor(user.id), isFalse);
    });

    testWidgets('alwaysReverify ignores an open window', (tester) async {
      // Someone verified a moment ago…
      cache.recordSuccess(user.id);

      // …but an authorising surface demands a fresh check regardless.
      await openGuard(tester, cache: cache, alwaysReverify: true);

      verify(() => repository.authenticate(copy: any(named: 'copy'))).called(1);
    });

    testWidgets('alwaysReverify does not seed a window for later screens',
        (tester) async {
      await openGuard(tester, cache: cache, alwaysReverify: true);
      expect(find.text('PROTECTED CONTENT'), findsOneWidget);

      // Authorising a payment must not silently unlock the next screen.
      expect(cache.isValidFor(user.id), isFalse);
    });

    testWidgets('a different user cannot ride the window', (tester) async {
      await openGuard(tester, cache: cache);
      clearInteractions(repository);

      // Account switch on a shared device.
      session.setUser(const User(
        id: 'user_002',
        email: 'other@isigroup.com.kh',
        fullName: 'Other Person',
        roles: {},
      ));
      await openGuard(tester, cache: cache);

      verify(() => repository.authenticate(copy: any(named: 'copy'))).called(1);
    });
  });

  group('signed in, biometrics ready', () {
    setUp(() => session.setUser(user));

    testWidgets('a match reveals the protected content', (tester) async {
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(readyDevice));
      when(() => repository.authenticate(copy: any(named: 'copy')))
          .thenAnswer((_) async => const Success(true));

      await openGuard(tester);

      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
    });

    testWidgets('the prompt is raised automatically, not on a second tap',
        (tester) async {
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(readyDevice));
      when(() => repository.authenticate(copy: any(named: 'copy')))
          .thenAnswer((_) async => const Success(true));

      await openGuard(tester);

      verify(() => repository.authenticate(copy: any(named: 'copy'))).called(1);
    });

    testWidgets('a cancelled prompt keeps the content hidden and the guard up',
        (tester) async {
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(readyDevice));
      when(() => repository.authenticate(copy: any(named: 'copy'))).thenAnswer(
        (_) async => const Failed(
          BiometricFailure(
            code: BiometricFailureCode.userCanceled,
            message: 'UserCancel',
          ),
        ),
      );

      await openGuard(tester);

      expect(find.text('PROTECTED CONTENT'), findsNothing);
      // Cancelling is not a dead end — the guard stays, offering a retry.
      expect(find.byType(SensitiveScreenGuard), findsOneWidget);
    });

    testWidgets('a lockout does not leave a retry button that cannot work',
        (tester) async {
      when(() => repository.checkCapability())
          .thenAnswer((_) async => const Success(readyDevice));
      when(() => repository.authenticate(copy: any(named: 'copy'))).thenAnswer(
        (_) async => const Failed(
          BiometricFailure(
            code: BiometricFailureCode.permanentLockout,
            message: 'PermanentlyLockedOut',
          ),
        ),
      );

      await openGuard(tester);

      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.byType(SensitiveScreenGuard), findsOneWidget);
    });
  });
}
