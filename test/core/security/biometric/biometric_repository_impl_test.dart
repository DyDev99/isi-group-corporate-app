import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isi_group_corporate_app/core/error/exceptions.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository_impl.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_secure_store.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:local_auth/local_auth.dart' as plugin;
// `show` rather than a bare import: these packages also export their own
// `BiometricType`, which would collide with ours.
import 'package:local_auth_android/local_auth_android.dart'
    show AndroidAuthMessages;
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart'
    show AuthMessages;
import 'package:mocktail/mocktail.dart';

import '../../../helpers/biometric_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const BiometricSettings.disabled());
    registerFallbackValue(testPromptCopy);
    // Needed for `any(named: 'options' / 'authMessages')` on the plugin mock.
    registerFallbackValue(const plugin.AuthenticationOptions());
    registerFallbackValue(<AuthMessages>[]);
  });

  // ══════════════════════════════════════════════════════════════════════
  // LocalAuthBiometricService — the only place local_auth is touched
  // ══════════════════════════════════════════════════════════════════════

  group('LocalAuthBiometricService', () {
    late MockLocalAuthentication localAuth;
    late LocalAuthBiometricService service;

    setUp(() {
      localAuth = MockLocalAuthentication();
      service = LocalAuthBiometricService(localAuth: localAuth);
    });

    void stubReady() {
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => localAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [plugin.BiometricType.fingerprint]);
    }

    test('maps every plugin BiometricType onto a domain type', () async {
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => localAuth.getAvailableBiometrics())
          .thenAnswer((_) async => plugin.BiometricType.values);

      final capability = await service.readCapability();

      expect(capability.enrolled, [
        BiometricType.face,
        BiometricType.fingerprint,
        BiometricType.iris,
        BiometricType.strong,
        BiometricType.weak,
      ]);
    });

    test('an unsupported device reports noHardware', () async {
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => false);

      final capability = await service.readCapability();

      expect(capability.hasHardware, isFalse);
      expect(capability.unsupportedReason, BiometricFailureCode.noHardware);
      // Short-circuits — no point asking about enrolments.
      verifyNever(() => localAuth.getAvailableBiometrics());
    });

    test('a throwing probe degrades to unsupported, never throws', () async {
      when(() => localAuth.isDeviceSupported())
          .thenThrow(PlatformException(code: 'NotAvailable'));

      final capability = await service.readCapability();

      expect(capability.hasHardware, isFalse);
      expect(
        capability.unsupportedReason,
        BiometricFailureCode.hardwareUnavailable,
      );
    });

    test('an unmodelled throwable in the probe still degrades safely',
        () async {
      when(() => localAuth.isDeviceSupported()).thenThrow(StateError('boom'));

      final capability = await service.readCapability();

      expect(capability.hasHardware, isFalse);
      expect(capability.unsupportedReason, BiometricFailureCode.unknown);
    });

    test('requests biometricOnly + stickyAuth', () async {
      stubReady();
      when(() => localAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
            authMessages: any(named: 'authMessages'),
          )).thenAnswer((_) async => true);

      await service.authenticate(copy: testPromptCopy);

      final options = verify(() => localAuth.authenticate(
            localizedReason: testPromptCopy.reason,
            options: captureAny(named: 'options'),
            authMessages: any(named: 'authMessages'),
          )).captured.single as plugin.AuthenticationOptions;

      // The device PIN is deliberately NOT accepted as a substitute: the
      // fallback for a failed biometric is the app's own credential form.
      expect(options.biometricOnly, isTrue);
      expect(options.stickyAuth, isTrue);
    });

    test('forwards the localized native dialog strings to the OS', () async {
      stubReady();
      when(() => localAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
            authMessages: any(named: 'authMessages'),
          )).thenAnswer((_) async => true);

      await service.authenticate(copy: testPromptCopy);

      final captured = verify(() => localAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
            authMessages: captureAny(named: 'authMessages'),
          )).captured.single as List<AuthMessages>;
      final android = captured.whereType<AndroidAuthMessages>().single;

      expect(android.signInTitle, testPromptCopy.signInTitle);
      expect(android.cancelButton, testPromptCopy.cancelButton);
    });

    // Every platform failure the taxonomy models, end to end through the
    // service boundary.
    const failureCases = <String, BiometricFailureCode>{
      'NotEnrolled': BiometricFailureCode.notEnrolled,
      'LockedOut': BiometricFailureCode.temporaryLockout,
      'PermanentlyLockedOut': BiometricFailureCode.permanentLockout,
      'PasscodeNotSet': BiometricFailureCode.passcodeNotSet,
      'UserCancel': BiometricFailureCode.userCanceled,
      'no_fragment_activity': BiometricFailureCode.platformMisconfigured,
      'WhoKnows': BiometricFailureCode.unknown,
    };

    failureCases.forEach((raw, expected) {
      test('$raw becomes a BiometricException carrying $expected', () async {
        stubReady();
        when(() => localAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
              authMessages: any(named: 'authMessages'),
            )).thenThrow(PlatformException(code: raw));

        await expectLater(
          () => service.authenticate(copy: testPromptCopy),
          throwsA(
            isA<BiometricException>().having((e) => e.code, 'code', expected),
          ),
        );
      });
    });

    test('no PlatformException escapes the service as itself', () async {
      stubReady();
      when(() => localAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
            authMessages: any(named: 'authMessages'),
          )).thenThrow(PlatformException(code: 'NotEnrolled'));

      await expectLater(
        () => service.authenticate(copy: testPromptCopy),
        throwsA(isNot(isA<PlatformException>())),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // BiometricRepositoryImpl
  // ══════════════════════════════════════════════════════════════════════

  group('BiometricRepositoryImpl', () {
    late MockBiometricService service;
    late MockBiometricSecureStore store;
    late BiometricRepositoryImpl repository;

    const readyDevice = BiometricCapability(
      hasHardware: true,
      isDeviceSecure: true,
      enrolled: [BiometricType.fingerprint, BiometricType.face],
    );

    setUp(() {
      service = MockBiometricService();
      store = MockBiometricSecureStore();
      repository = BiometricRepositoryImpl(service: service, store: store);
    });

    group('authenticate', () {
      test('a match succeeds', () async {
        when(() => service.authenticate(copy: any(named: 'copy')))
            .thenAnswer((_) async => true);

        final result = await repository.authenticate(copy: testPromptCopy);

        expect(result.when(success: (v) => v, failure: (_) => null), isTrue);
      });

      test('a plugin `false` is a typed notRecognized failure, not a silent no',
          () async {
        when(() => service.authenticate(copy: any(named: 'copy')))
            .thenAnswer((_) async => false);

        final result = await repository.authenticate(copy: testPromptCopy);
        final failure = result.when(success: (_) => null, failure: (f) => f);

        expect((failure! as BiometricFailure).code,
            BiometricFailureCode.notRecognized);
      });

      test('a BiometricException becomes a typed BiometricFailure', () async {
        when(() => service.authenticate(copy: any(named: 'copy'))).thenThrow(
          const BiometricException(
            code: BiometricFailureCode.temporaryLockout,
            message: 'LockedOut',
          ),
        );

        final result = await repository.authenticate(copy: testPromptCopy);
        final failure = result.when(success: (_) => null, failure: (f) => f);

        expect((failure! as BiometricFailure).code,
            BiometricFailureCode.temporaryLockout);
        expect((failure as BiometricFailure).localizationKey,
            startsWith('auth.biometric.error.'));
      });

      test('an unmodelled throwable still becomes a typed failure', () async {
        when(() => service.authenticate(copy: any(named: 'copy')))
            .thenThrow(StateError('boom'));

        final result = await repository.authenticate(copy: testPromptCopy);
        final failure = result.when(success: (_) => null, failure: (f) => f);

        expect((failure! as BiometricFailure).code,
            BiometricFailureCode.unknown);
      });
    });

    group('enable — the defence-in-depth check', () {
      test('persists an enabled modality on a ready device', () async {
        when(() => service.readCapability())
            .thenAnswer((_) async => readyDevice);
        when(() => store.read())
            .thenAnswer((_) async => const BiometricSettings.disabled());
        when(() => store.write(any())).thenAnswer((_) async {});

        final result = await repository.enable(BiometricModality.fingerprint);
        final settings = result.when(success: (s) => s, failure: (_) => null)!;

        expect(settings.biometricEnabled, isTrue);
        expect(settings.biometricRegistered, isTrue);
        expect(settings.biometricType, {BiometricModality.fingerprint});
        expect(settings.lastVerifiedAt, isNotNull);
        expect(settings.authenticationPreference,
            AuthenticationPreference.biometricFirst);
        verify(() => store.write(any())).called(1);
      });

      test('REFUSES to enable when nothing is enrolled — a UI bug cannot '
          'leave a half-enabled switch', () async {
        when(() => service.readCapability()).thenAnswer(
          (_) async => const BiometricCapability(
            hasHardware: true,
            isDeviceSecure: true,
            enrolled: [],
          ),
        );

        final result = await repository.enable(BiometricModality.fingerprint);
        final failure = result.when(success: (_) => null, failure: (f) => f);

        expect((failure! as BiometricFailure).code,
            BiometricFailureCode.notEnrolled);
        verifyNever(() => store.write(any()));
      });

      test('REFUSES to enable on hardware that cannot do the modality',
          () async {
        when(() => service.readCapability()).thenAnswer(
          (_) async => const BiometricCapability(
            hasHardware: true,
            isDeviceSecure: true,
            enrolled: [BiometricType.fingerprint],
          ),
        );

        // Face ID asked for on a fingerprint-only device.
        final result = await repository.enable(BiometricModality.face);

        expect(
          result.when(success: (_) => null, failure: (f) => f),
          isA<BiometricFailure>(),
        );
        verifyNever(() => store.write(any()));
      });

      test('REFUSES to enable on a device with no hardware at all', () async {
        when(() => service.readCapability()).thenAnswer(
          (_) async =>
              const BiometricCapability.unsupported(BiometricFailureCode.noHardware),
        );

        final result = await repository.enable(BiometricModality.fingerprint);
        final failure = result.when(success: (_) => null, failure: (f) => f);

        expect((failure! as BiometricFailure).code,
            BiometricFailureCode.noHardware);
        verifyNever(() => store.write(any()));
      });

      test('adds to, rather than replaces, an existing modality', () async {
        when(() => service.readCapability())
            .thenAnswer((_) async => readyDevice);
        when(() => store.read()).thenAnswer(
          (_) async => const BiometricSettings(
            biometricEnabled: true,
            biometricType: {BiometricModality.fingerprint},
            biometricRegistered: true,
            lastVerifiedAt: null,
            authenticationPreference: AuthenticationPreference.biometricFirst,
          ),
        );
        when(() => store.write(any())).thenAnswer((_) async {});

        final result = await repository.enable(BiometricModality.face);
        final settings = result.when(success: (s) => s, failure: (_) => null)!;

        expect(settings.biometricType, {
          BiometricModality.fingerprint,
          BiometricModality.face,
        });
      });

      test('a secure-storage write failure surfaces as CacheFailure', () async {
        when(() => service.readCapability())
            .thenAnswer((_) async => readyDevice);
        when(() => store.read())
            .thenAnswer((_) async => const BiometricSettings.disabled());
        when(() => store.write(any()))
            .thenThrow(const CacheException(message: 'keystore down'));

        final result = await repository.enable(BiometricModality.fingerprint);

        expect(
          result.when(success: (_) => null, failure: (f) => f),
          isA<CacheFailure>(),
        );
      });
    });

    group('disable — must always work', () {
      test('turns the modality off without consulting the sensor', () async {
        when(() => store.read()).thenAnswer(
          (_) async => const BiometricSettings(
            biometricEnabled: true,
            biometricType: {BiometricModality.fingerprint},
            biometricRegistered: true,
            lastVerifiedAt: null,
            authenticationPreference: AuthenticationPreference.biometricFirst,
          ),
        );
        when(() => store.write(any())).thenAnswer((_) async {});

        final result = await repository.disable(BiometricModality.fingerprint);
        final settings = result.when(success: (s) => s, failure: (_) => null)!;

        expect(settings.biometricEnabled, isFalse);
        expect(settings.biometricType, isEmpty);
        // A broken reader must never be able to trap the user with the setting
        // stuck on, so the capability probe is not consulted at all.
        verifyNever(() => service.readCapability());
      });

      test('keeps registration so the switch can be re-enabled later',
          () async {
        when(() => store.read()).thenAnswer(
          (_) async => const BiometricSettings(
            biometricEnabled: true,
            biometricType: {BiometricModality.face},
            biometricRegistered: true,
            lastVerifiedAt: null,
            authenticationPreference: AuthenticationPreference.biometricFirst,
          ),
        );
        when(() => store.write(any())).thenAnswer((_) async {});

        final result = await repository.disable(BiometricModality.face);
        final settings = result.when(success: (s) => s, failure: (_) => null)!;

        expect(settings.biometricRegistered, isTrue);
        expect(settings.authenticationPreference,
            AuthenticationPreference.passwordOnly);
      });

      test('disabling one of two modalities leaves the other enabled',
          () async {
        when(() => store.read()).thenAnswer(
          (_) async => const BiometricSettings(
            biometricEnabled: true,
            biometricType: {
              BiometricModality.fingerprint,
              BiometricModality.face,
            },
            biometricRegistered: true,
            lastVerifiedAt: null,
            authenticationPreference: AuthenticationPreference.biometricFirst,
          ),
        );
        when(() => store.write(any())).thenAnswer((_) async {});

        final result = await repository.disable(BiometricModality.face);
        final settings = result.when(success: (s) => s, failure: (_) => null)!;

        expect(settings.biometricEnabled, isTrue);
        expect(settings.biometricType, {BiometricModality.fingerprint});
      });
    });

    group('readSettings', () {
      test('returns the persisted settings', () async {
        when(() => store.read())
            .thenAnswer((_) async => const BiometricSettings.disabled());

        final result = await repository.readSettings();

        expect(result, isA<Success<BiometricSettings>>());
      });

      test('an unreadable store is a typed CacheFailure (fail closed)',
          () async {
        when(() => store.read())
            .thenThrow(const CacheException(message: 'unreadable'));

        final result = await repository.readSettings();

        expect(
          result.when(success: (_) => null, failure: (f) => f),
          isA<CacheFailure>(),
        );
      });
    });

    test('checkEnrollment derives the status from the live capability',
        () async {
      when(() => service.readCapability()).thenAnswer(
        (_) async => const BiometricCapability(
          hasHardware: true,
          isDeviceSecure: true,
          enrolled: [],
        ),
      );

      final result = await repository.checkEnrollment();

      expect(
        result.when(success: (s) => s, failure: (_) => null),
        BiometricEnrollmentStatus.notEnrolled,
      );
    });

    test('clearRegistration wipes the store (account deletion path)', () async {
      when(() => store.clear()).thenAnswer((_) async {});

      final result = await repository.clearRegistration();

      expect(result, isA<Success<void>>());
      verify(() => store.clear()).called(1);
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // BiometricSecureStoreImpl — secure storage only
  // ══════════════════════════════════════════════════════════════════════

  group('BiometricSecureStoreImpl', () {
    late MockFlutterSecureStorage storage;
    late BiometricSecureStoreImpl store;

    setUp(() {
      storage = MockFlutterSecureStorage();
      store = BiometricSecureStoreImpl(storage);
    });

    test('round-trips settings through secure storage', () async {
      final written = <String, String?>{};
      when(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((invocation) async {
        written[invocation.namedArguments[#key] as String] =
            invocation.namedArguments[#value] as String?;
      });

      final verifiedAt = DateTime.utc(2026, 7, 27, 10, 30);
      await store.write(
        BiometricSettings(
          biometricEnabled: true,
          biometricType: const {
            BiometricModality.fingerprint,
            BiometricModality.face,
          },
          biometricRegistered: true,
          lastVerifiedAt: verifiedAt,
          authenticationPreference: AuthenticationPreference.biometricFirst,
        ),
      );

      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async =>
              written[invocation.namedArguments[#key] as String]);

      final read = await store.read();

      expect(read.biometricEnabled, isTrue);
      expect(read.biometricRegistered, isTrue);
      expect(read.biometricType, {
        BiometricModality.fingerprint,
        BiometricModality.face,
      });
      expect(read.lastVerifiedAt, verifiedAt);
      expect(read.authenticationPreference,
          AuthenticationPreference.biometricFirst);
    });

    test('writes exactly five keys and nothing resembling biometric material',
        () async {
      final written = <String, String?>{};
      when(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((invocation) async {
        written[invocation.namedArguments[#key] as String] =
            invocation.namedArguments[#value] as String?;
      });

      await store.write(const BiometricSettings.disabled());

      expect(written.keys.toSet(), {
        'isi.biometric.enabled',
        'isi.biometric.type',
        'isi.biometric.registered',
        'isi.biometric.last_verified_at',
        'isi.biometric.auth_preference',
      });
      // No template, image, hash or key is representable, let alone written.
      for (final key in written.keys) {
        expect(key, isNot(contains('template')));
        expect(key, isNot(contains('image')));
      }
    });

    test('an empty store reads as fully disabled', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final read = await store.read();

      expect(read, const BiometricSettings.disabled());
    });

    test('a garbage modality token is dropped, not misread', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        if (key == 'isi.biometric.type') return 'fingerprint,retina';
        if (key == 'isi.biometric.enabled') return 'true';
        return null;
      });

      final read = await store.read();

      expect(read.biometricType, {BiometricModality.fingerprint});
    });

    test('a storage blow-up becomes a CacheException, never a raw error',
        () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenThrow(PlatformException(code: 'keystore_unavailable'));

      await expectLater(() => store.read(), throwsA(isA<CacheException>()));
    });

    test('clear removes all five keys', () async {
      final deleted = <String>[];
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        deleted.add(invocation.namedArguments[#key] as String);
      });

      await store.clear();

      expect(deleted.length, 5);
    });
  });
}
