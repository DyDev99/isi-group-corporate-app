import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/biometric_usecases.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_bloc.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_event.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/biometric_mocks.dart';

void main() {
  late MockCheckBiometricCapabilityUseCase checkCapability;
  late MockCheckEnrollmentUseCase checkEnrollment;
  late MockAuthenticateBiometricUseCase authenticate;
  late MockEnableBiometricUseCase enable;
  late MockDisableBiometricUseCase disable;
  late MockGetBiometricSettingsUseCase getSettings;
  late MockDeviceSettingsLauncher launcher;

  const readyDevice = BiometricCapability(
    hasHardware: true,
    isDeviceSecure: true,
    enrolled: [BiometricType.fingerprint, BiometricType.face],
  );
  const noEnrollment = BiometricCapability(
    hasHardware: true,
    isDeviceSecure: true,
    enrolled: [],
  );
  const noHardware =
      BiometricCapability.unsupported(BiometricFailureCode.noHardware);

  const enabledSettings = BiometricSettings(
    biometricEnabled: true,
    biometricType: {BiometricModality.fingerprint},
    biometricRegistered: true,
    lastVerifiedAt: null,
    authenticationPreference: AuthenticationPreference.biometricFirst,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const BiometricModalityParams(modality: BiometricModality.fingerprint),
    );
    registerFallbackValue(
      const AuthenticateBiometricParams(copy: testPromptCopy),
    );
  });

  setUp(() {
    checkCapability = MockCheckBiometricCapabilityUseCase();
    checkEnrollment = MockCheckEnrollmentUseCase();
    authenticate = MockAuthenticateBiometricUseCase();
    enable = MockEnableBiometricUseCase();
    disable = MockDisableBiometricUseCase();
    getSettings = MockGetBiometricSettingsUseCase();
    launcher = MockDeviceSettingsLauncher();

    when(() => launcher.canDeepLinkToEnrollment).thenReturn(true);
    when(() => launcher.openBiometricEnrollment()).thenAnswer((_) async => true);
    when(() => checkEnrollment(any())).thenAnswer(
      (_) async => const Success(BiometricEnrollmentStatus.notEnrolled),
    );
  });

  BiometricBloc build() => BiometricBloc(
        checkCapability: checkCapability,
        checkEnrollment: checkEnrollment,
        authenticate: authenticate,
        enable: enable,
        disable: disable,
        getSettings: getSettings,
        settingsLauncher: launcher,
      );

  void stubDevice(BiometricCapability capability) {
    when(() => checkCapability(any()))
        .thenAnswer((_) async => Success(capability));
  }

  void stubSettings(BiometricSettings settings) {
    when(() => getSettings(any())).thenAnswer((_) async => Success(settings));
  }

  // ════════════════════════════════════════════════════════════════════
  // THE CENTRAL SECURITY RULE
  // ════════════════════════════════════════════════════════════════════

  group('SECURITY: a switch cannot turn on without the full flow', () {
    blocTest<BiometricBloc, BiometricState>(
      'flipping the switch ON only opens the welcome step — it enables nothing',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc.add(
        const BiometricEnableRequested(modality: BiometricModality.fingerprint),
      ),
      verify: (bloc) {
        expect(bloc.state.step, BiometricFlowStep.welcome);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        // Nothing was persisted.
        verifyNever(() => enable(any()));
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'cancelling at the welcome step leaves the switch OFF',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc
        ..add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint))
        ..add(const BiometricOnboardingCancelled()),
      verify: (bloc) {
        expect(bloc.state.step, BiometricFlowStep.idle);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        verifyNever(() => enable(any()));
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'a FAILED OS verification never enables the switch',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(const BiometricSettings.disabled());
        when(() => authenticate(any())).thenAnswer(
          (_) async => const Failed(
            BiometricFailure(
              code: BiometricFailureCode.notRecognized,
              message: 'x',
            ),
          ),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint));
        bloc.add(const BiometricOnboardingContinued());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const BiometricVerificationRequested(copy: testPromptCopy));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.step, BiometricFlowStep.error);
        expect(bloc.state.failureCode, BiometricFailureCode.notRecognized);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        // The load-bearing assertion: no persistence on a failed verification.
        verifyNever(() => enable(any()));
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'a CANCELLED OS prompt never enables the switch',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(const BiometricSettings.disabled());
        when(() => authenticate(any())).thenAnswer(
          (_) async => const Failed(
            BiometricFailure(
              code: BiometricFailureCode.userCanceled,
              message: 'UserCancel',
            ),
          ),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint));
        bloc.add(const BiometricOnboardingContinued());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const BiometricVerificationRequested(copy: testPromptCopy));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        verifyNever(() => enable(any()));
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'only a SUCCESSFUL OS verification enables the switch',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(const BiometricSettings.disabled());
        when(() => authenticate(any()))
            .thenAnswer((_) async => const Success(true));
        when(() => enable(any()))
            .thenAnswer((_) async => const Success(enabledSettings));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint));
        bloc.add(const BiometricOnboardingContinued());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const BiometricVerificationRequested(copy: testPromptCopy));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.step, BiometricFlowStep.success);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isTrue);
        verify(() => enable(any())).called(1);
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'verification cannot run without a pending modality',
      setUp: () => stubDevice(readyDevice),
      build: build,
      // No BiometricEnableRequested first — nothing is being onboarded.
      act: (bloc) =>
          bloc.add(const BiometricVerificationRequested(copy: testPromptCopy)),
      expect: () => const <BiometricState>[],
      verify: (_) {
        verifyNever(() => authenticate(any()));
        verifyNever(() => enable(any()));
      },
    );
  });

  // ════════════════════════════════════════════════════════════════════
  // Step 2 routing
  // ════════════════════════════════════════════════════════════════════

  group('Step 2 — device validation routes to one of three destinations', () {
    blocTest<BiometricBloc, BiometricState>(
      'no hardware → unsupported, switch stays off',
      setUp: () {
        stubDevice(noHardware);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc
        ..add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint))
        ..add(const BiometricOnboardingContinued()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.step, BiometricFlowStep.unsupported);
        expect(bloc.state.failureCode, BiometricFailureCode.noHardware);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        verifyNever(() => authenticate(any()));
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'hardware but nothing enrolled → enrollment guidance, not an error',
      setUp: () {
        stubDevice(noEnrollment);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc
        ..add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint))
        ..add(const BiometricOnboardingContinued()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.step, BiometricFlowStep.enrollmentRequired);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        verifyNever(() => authenticate(any()));
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'Face ID on a fingerprint-only device → enrollment guidance',
      setUp: () {
        stubDevice(const BiometricCapability(
          hasHardware: true,
          isDeviceSecure: true,
          enrolled: [BiometricType.fingerprint],
        ));
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc
        ..add(const BiometricEnableRequested(modality: BiometricModality.face))
        ..add(const BiometricOnboardingContinued()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) =>
          expect(bloc.state.step, BiometricFlowStep.enrollmentRequired),
    );

    blocTest<BiometricBloc, BiometricState>(
      'ready device → verification',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc
        ..add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint))
        ..add(const BiometricOnboardingContinued()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.state.step, BiometricFlowStep.verifying),
    );
  });

  // ════════════════════════════════════════════════════════════════════
  // Step 3 — enrol, return, auto-advance
  // ════════════════════════════════════════════════════════════════════

  group('Step 3 — device enrollment', () {
    blocTest<BiometricBloc, BiometricState>(
      'asks the platform to open device settings',
      setUp: () {
        stubDevice(noEnrollment);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc.add(const BiometricEnrollmentSettingsRequested()),
      verify: (_) =>
          verify(() => launcher.openBiometricEnrollment()).called(1),
    );

    blocTest<BiometricBloc, BiometricState>(
      'returning WITH an enrolment advances to verification automatically',
      setUp: () {
        stubSettings(const BiometricSettings.disabled());
        // Probe 1 (Step 2): nothing enrolled → Step 3.
        // Probe 2 (on resume): the user enrolled while away → advance.
        var call = 0;
        when(() => checkCapability(any())).thenAnswer((_) async {
          call++;
          return Success(call <= 1 ? noEnrollment : readyDevice);
        });
        when(() => checkEnrollment(any())).thenAnswer(
          (_) async => const Success(BiometricEnrollmentStatus.enrolled),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint));
        bloc.add(const BiometricOnboardingContinued());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BiometricEnrollmentRechecked());
      },
      wait: const Duration(milliseconds: 60),
      verify: (bloc) => expect(bloc.state.step, BiometricFlowStep.verifying),
    );

    blocTest<BiometricBloc, BiometricState>(
      'returning WITHOUT enrolling keeps the switch OFF and stays on Step 3',
      setUp: () {
        stubDevice(noEnrollment);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) async {
        bloc.add(const BiometricEnableRequested(
            modality: BiometricModality.fingerprint));
        bloc.add(const BiometricOnboardingContinued());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BiometricEnrollmentRechecked());
      },
      wait: const Duration(milliseconds: 60),
      verify: (bloc) {
        expect(bloc.state.step, BiometricFlowStep.enrollmentRequired);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        verifyNever(() => enable(any()));
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'a resume outside Step 3 is ignored — no wasted probe',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc.add(const BiometricEnrollmentRechecked()),
      expect: () => const <BiometricState>[],
    );
  });

  // ════════════════════════════════════════════════════════════════════
  // Load + disable
  // ════════════════════════════════════════════════════════════════════

  group('BiometricStarted', () {
    blocTest<BiometricBloc, BiometricState>(
      'renders the switch from persisted settings, not a default',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(enabledSettings);
      },
      build: build,
      act: (bloc) => bloc.add(const BiometricStarted()),
      verify: (bloc) {
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isTrue);
        expect(bloc.state.isEnabled(BiometricModality.face), isFalse);
        expect(bloc.state.step, BiometricFlowStep.idle);
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'an unreadable secure store fails closed to OFF',
      setUp: () {
        stubDevice(readyDevice);
        when(() => getSettings(any())).thenAnswer(
          (_) async => const Failed(CacheFailure(message: 'keystore down')),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const BiometricStarted()),
      verify: (bloc) {
        expect(bloc.state.settings.biometricEnabled, isFalse);
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
      },
    );

    blocTest<BiometricBloc, BiometricState>(
      'an unreadable device probe fails closed to unsupported',
      setUp: () {
        when(() => checkCapability(any())).thenAnswer(
          (_) async => const Failed(
            BiometricFailure(
              code: BiometricFailureCode.unknown,
              message: 'probe failed',
            ),
          ),
        );
        stubSettings(const BiometricSettings.disabled());
      },
      build: build,
      act: (bloc) => bloc.add(const BiometricStarted()),
      verify: (bloc) {
        expect(bloc.state.isDeviceCapable, isFalse);
        expect(bloc.state.isSupported(BiometricModality.fingerprint), isFalse);
      },
    );
  });

  group('BiometricDisableRequested', () {
    blocTest<BiometricBloc, BiometricState>(
      'turns the switch off immediately, with no verification',
      setUp: () {
        stubDevice(readyDevice);
        stubSettings(enabledSettings);
        when(() => disable(any())).thenAnswer(
          (_) async => const Success(BiometricSettings.disabled()),
        );
      },
      build: build,
      seed: () => const BiometricState(settings: enabledSettings),
      act: (bloc) => bloc.add(const BiometricDisableRequested(
        modality: BiometricModality.fingerprint,
      )),
      wait: const Duration(milliseconds: 30),
      verify: (bloc) {
        expect(bloc.state.isEnabled(BiometricModality.fingerprint), isFalse);
        // Turning a security feature OFF is never gated behind the sensor that
        // might be the reason the user wants it off.
        verifyNever(() => authenticate(any()));
        verify(() => disable(any())).called(1);
      },
    );
  });
}
