import 'package:flutter_test/flutter_test.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';

void main() {
  group('biometricFailureCodeFromPlatform — PlatformException codes', () {
    // The strings local_auth_android 1.0.56 / local_auth_darwin 1.6.1 actually
    // throw. Verified against the plugin source, not guessed.
    const cases = <String, BiometricFailureCode>{
      'NotAvailable': BiometricFailureCode.hardwareUnavailable,
      'NotEnrolled': BiometricFailureCode.notEnrolled,
      'PasscodeNotSet': BiometricFailureCode.passcodeNotSet,
      'LockedOut': BiometricFailureCode.temporaryLockout,
      'PermanentlyLockedOut': BiometricFailureCode.permanentLockout,
      'OtherOperatingSystem': BiometricFailureCode.noHardware,
      'biometricOnlyNotSupported': BiometricFailureCode.hardwareUnavailable,
      'auth_in_progress': BiometricFailureCode.authInProgress,
      'no_activity': BiometricFailureCode.platformMisconfigured,
      'no_fragment_activity': BiometricFailureCode.platformMisconfigured,
      'UserCancel': BiometricFailureCode.userCanceled,
      'UserFallback': BiometricFailureCode.userFallback,
      'SystemCancel': BiometricFailureCode.systemCanceled,
    };

    cases.forEach((raw, expected) {
      test('$raw → $expected', () {
        expect(biometricFailureCodeFromPlatform(raw), expected);
      });
    });
  });

  group('biometricFailureCodeFromPlatform — LocalAuthExceptionCode names', () {
    // The structured API newer plugin versions are migrating to. Mapped now so
    // a dependency bump cannot silently degrade everything to `unknown`.
    const cases = <String, BiometricFailureCode>{
      'noBiometricHardware': BiometricFailureCode.noHardware,
      'biometricHardwareTemporarilyUnavailable':
          BiometricFailureCode.hardwareUnavailable,
      'noBiometricsEnrolled': BiometricFailureCode.notEnrolled,
      'noCredentialsSet': BiometricFailureCode.passcodeNotSet,
      'temporaryLockout': BiometricFailureCode.temporaryLockout,
      'biometricLockout': BiometricFailureCode.permanentLockout,
      'userCanceled': BiometricFailureCode.userCanceled,
      'userRequestedFallback': BiometricFailureCode.userFallback,
      'systemCanceled': BiometricFailureCode.systemCanceled,
      'timeout': BiometricFailureCode.systemCanceled,
      'authInProgress': BiometricFailureCode.authInProgress,
      'uiUnavailable': BiometricFailureCode.platformMisconfigured,
      'deviceError': BiometricFailureCode.unknown,
      'unknownError': BiometricFailureCode.unknown,
    };

    cases.forEach((raw, expected) {
      test('$raw → $expected', () {
        expect(biometricFailureCodeFromPlatform(raw), expected);
      });
    });

    test('an unrecognised code degrades to unknown, never throws', () {
      expect(
        biometricFailureCodeFromPlatform('SomeFutureCode'),
        BiometricFailureCode.unknown,
      );
      expect(biometricFailureCodeFromPlatform(''), BiometricFailureCode.unknown);
    });
  });

  group('recovery semantics drive the UI, so pin them', () {
    test('every code has a distinct localization key', () {
      final keys =
          BiometricFailureCode.values.map((c) => c.localizationKey).toSet();
      expect(keys.length, BiometricFailureCode.values.length);
      for (final key in keys) {
        expect(key, startsWith('auth.biometric.error.'));
      }
    });

    test('only enrolment-fixable codes route to device settings', () {
      final routes = BiometricFailureCode.values
          .where((c) => c.requiresEnrollment)
          .toSet();
      expect(routes, {
        BiometricFailureCode.notEnrolled,
        BiometricFailureCode.passcodeNotSet,
      });
    });

    test('permanent lockout is the only code demanding a device unlock', () {
      final routes = BiometricFailureCode.values
          .where((c) => c.requiresDeviceUnlock)
          .toSet();
      expect(routes, {BiometricFailureCode.permanentLockout});
    });

    test('hard-unsupported codes are never advertised as retryable', () {
      for (final code in BiometricFailureCode.values) {
        if (code.isPermanentlyUnsupported) {
          expect(code.isRetryable, isFalse, reason: '$code');
        }
      }
    });

    test('user dismissals are retryable and are not "errors"', () {
      for (final code in BiometricFailureCode.values.where(
        (c) => c.isUserDismissal,
      )) {
        expect(code.isRetryable, isTrue, reason: '$code');
      }
      expect(
        BiometricFailureCode.values.where((c) => c.isUserDismissal).toSet(),
        {
          BiometricFailureCode.userCanceled,
          BiometricFailureCode.userFallback,
          BiometricFailureCode.systemCanceled,
        },
      );
    });
  });

  group('BiometricCapability', () {
    test('isReady needs hardware AND a screen lock AND an enrolment', () {
      expect(
        const BiometricCapability(
          hasHardware: true,
          isDeviceSecure: true,
          enrolled: [BiometricType.fingerprint],
        ).isReady,
        isTrue,
      );
      expect(
        const BiometricCapability(
          hasHardware: true,
          isDeviceSecure: true,
          enrolled: [],
        ).isReady,
        isFalse,
      );
      expect(
        const BiometricCapability(
          hasHardware: true,
          isDeviceSecure: false,
          enrolled: [BiometricType.face],
        ).isReady,
        isFalse,
      );
    });

    test('hardware without enrolment routes to enrolment, not to unsupported',
        () {
      const capability = BiometricCapability(
        hasHardware: true,
        isDeviceSecure: true,
        enrolled: [],
      );
      expect(capability.needsEnrollment, isTrue);
      expect(
        BiometricEnrollmentStatus.fromCapability(capability),
        BiometricEnrollmentStatus.notEnrolled,
      );
    });

    test('no screen lock is reported distinctly from no enrolment', () {
      const capability = BiometricCapability(
        hasHardware: true,
        isDeviceSecure: false,
        enrolled: [BiometricType.fingerprint],
      );
      expect(
        BiometricEnrollmentStatus.fromCapability(capability),
        BiometricEnrollmentStatus.deviceNotSecure,
      );
    });

    test('unsupported maps to noHardware or unavailable by reason', () {
      expect(
        BiometricEnrollmentStatus.fromCapability(
          const BiometricCapability.unsupported(BiometricFailureCode.noHardware),
        ),
        BiometricEnrollmentStatus.noHardware,
      );
      expect(
        BiometricEnrollmentStatus.fromCapability(
          const BiometricCapability.unsupported(
            BiometricFailureCode.hardwareUnavailable,
          ),
        ),
        BiometricEnrollmentStatus.unavailable,
      );
    });

    test('a strength-class-only enrolment satisfies both modalities', () {
      // Android often reports `strong` without naming the sensor; refusing
      // would block enrolment on a large share of real devices.
      const capability = BiometricCapability(
        hasHardware: true,
        isDeviceSecure: true,
        enrolled: [BiometricType.strong],
      );
      expect(capability.supports(BiometricModality.fingerprint), isTrue);
      expect(capability.supports(BiometricModality.face), isTrue);
      expect(capability.supportedModalities, BiometricModality.values.toSet());
    });

    test('a fingerprint-only device does not advertise Face ID', () {
      const capability = BiometricCapability(
        hasHardware: true,
        isDeviceSecure: true,
        enrolled: [BiometricType.fingerprint],
      );
      expect(capability.supports(BiometricModality.fingerprint), isTrue);
      expect(capability.supports(BiometricModality.face), isFalse);
    });
  });

  group('BiometricSettings', () {
    test('the default is off — biometrics are never on for someone', () {
      const settings = BiometricSettings.disabled();
      expect(settings.biometricEnabled, isFalse);
      expect(settings.biometricRegistered, isFalse);
      expect(settings.biometricType, isEmpty);
      expect(settings.isUsable, isFalse);
      expect(
        settings.authenticationPreference,
        AuthenticationPreference.passwordOnly,
      );
    });

    test('isUsable requires enabled AND registered AND a modality AND the '
        'biometric-first preference', () {
      const base = BiometricSettings(
        biometricEnabled: true,
        biometricType: {BiometricModality.fingerprint},
        biometricRegistered: true,
        lastVerifiedAt: null,
        authenticationPreference: AuthenticationPreference.biometricFirst,
      );
      expect(base.isUsable, isTrue);

      expect(base.copyWith(biometricEnabled: false).isUsable, isFalse);
      expect(base.copyWith(biometricRegistered: false).isUsable, isFalse);
      expect(base.copyWith(biometricType: {}).isUsable, isFalse);
      expect(
        base
            .copyWith(
              authenticationPreference: AuthenticationPreference.passwordOnly,
            )
            .isUsable,
        isFalse,
      );
    });

    test('LOGOUT INVARIANT: clearedForLogout preserves registration', () {
      // Logging out must not remove biometric registration — only tokens are
      // cleared, so the next launch can immediately offer biometric sign-in.
      const settings = BiometricSettings(
        biometricEnabled: true,
        biometricType: {BiometricModality.face},
        biometricRegistered: true,
        lastVerifiedAt: null,
        authenticationPreference: AuthenticationPreference.biometricFirst,
      );

      expect(settings.clearedForLogout(), equals(settings));
      expect(settings.clearedForLogout().biometricRegistered, isTrue);
      expect(settings.clearedForLogout().biometricType, {BiometricModality.face});
    });

    test('AuthenticationPreference decodes by name and defaults safely', () {
      expect(
        AuthenticationPreference.fromStorageKey('biometricFirst'),
        AuthenticationPreference.biometricFirst,
      );
      // Fails closed for null/garbage rather than assuming biometric-first.
      expect(
        AuthenticationPreference.fromStorageKey(null),
        AuthenticationPreference.passwordOnly,
      );
      expect(
        AuthenticationPreference.fromStorageKey('nonsense'),
        AuthenticationPreference.passwordOnly,
      );
    });
  });

  group('BiometricModality storage encoding', () {
    test('round-trips by stable name, not ordinal', () {
      for (final modality in BiometricModality.values) {
        expect(
          BiometricModality.fromStorageKey(modality.storageKey),
          modality,
        );
        // Guards against a refactor switching to `index`, which would re-map
        // every stored preference if the enum were ever reordered.
        expect(modality.storageKey, isNot(equals(modality.index.toString())));
      }
    });

    test('an unknown token decodes to null rather than a wrong modality', () {
      expect(BiometricModality.fromStorageKey('retina'), isNull);
    });
  });
}
