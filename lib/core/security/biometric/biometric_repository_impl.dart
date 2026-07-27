import 'package:isi_group_corporate_app/core/error/exceptions.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_secure_store.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';

/// Composes the platform [BiometricService] with the secure [BiometricSecureStore]
/// and translates every exception into a typed [Failure].
///
/// This is the only class that knows both worlds — the same posture
/// `AuthRepositoryImpl` takes for the credential flow.
class BiometricRepositoryImpl implements BiometricRepository {
  const BiometricRepositoryImpl({
    required BiometricService service,
    required BiometricSecureStore store,
  })  : _service = service,
        _store = store;

  final BiometricService _service;
  final BiometricSecureStore _store;

  @override
  ResultFuture<BiometricCapability> checkCapability() async {
    // readCapability never throws by contract — a failed probe is reported as
    // an unsupported capability, not as an error banner over the login form.
    return Success(await _service.readCapability());
  }

  @override
  ResultFuture<BiometricEnrollmentStatus> checkEnrollment() async {
    final capability = await _service.readCapability();
    return Success(BiometricEnrollmentStatus.fromCapability(capability));
  }

  @override
  ResultFuture<bool> authenticate({required BiometricPromptCopy copy}) async {
    try {
      final matched = await _service.authenticate(copy: copy);
      if (!matched) {
        // The plugin returns false (rather than throwing) when the prompt ran
        // and the user was simply not recognised.
        return const Failed(
          BiometricFailure(
            code: BiometricFailureCode.notRecognized,
            message: 'not_recognized',
          ),
        );
      }
      return const Success(true);
    } on BiometricException catch (e) {
      return Failed(BiometricFailure(code: e.code, message: e.message));
    } catch (e) {
      // Nothing escapes as a raw exception; an unmodelled platform error still
      // has to degrade to "fall back to the credential form".
      return Failed(
        BiometricFailure(
          code: BiometricFailureCode.unknown,
          message: e.runtimeType.toString(),
        ),
      );
    }
  }

  @override
  Future<void> cancelAuthentication() => _service.cancelAuthentication();

  @override
  ResultFuture<BiometricSettings> readSettings() async {
    try {
      return Success(await _store.read());
    } on CacheException catch (e) {
      // Fail closed: callers treat a failure as "biometrics off".
      return Failed(CacheFailure(message: e.message));
    }
  }

  @override
  ResultFuture<BiometricSettings> enable(BiometricModality modality) async {
    // Defence in depth. The onboarding flow already verified the user with the
    // OS before reaching here, but the repository re-checks the device so that
    // no UI path — present or future — can persist an enabled switch on a
    // device that cannot honour it.
    final capability = await _service.readCapability();
    if (!capability.supports(modality)) {
      return Failed(
        BiometricFailure(
          code: capability.needsEnrollment
              ? BiometricFailureCode.notEnrolled
              : BiometricFailureCode.noHardware,
          message: 'enable_refused_unsupported_device',
        ),
      );
    }

    try {
      final current = await _store.read();
      final updated = current.copyWith(
        biometricEnabled: true,
        biometricType: {...current.biometricType, modality},
        biometricRegistered: true,
        lastVerifiedAt: DateTime.now().toUtc(),
        authenticationPreference: AuthenticationPreference.biometricFirst,
      );
      await _store.write(updated);
      return Success(updated);
    } on CacheException catch (e) {
      return Failed(CacheFailure(message: e.message));
    }
  }

  @override
  ResultFuture<BiometricSettings> disable(BiometricModality modality) async {
    try {
      final current = await _store.read();
      final remaining = {...current.biometricType}..remove(modality);
      final updated = current.copyWith(
        biometricEnabled: remaining.isNotEmpty,
        biometricType: remaining,
        // `biometricRegistered` deliberately survives: the user proved their
        // identity on this device once, and turning a switch off does not undo
        // that. It is what lets the switch be re-enabled without a second full
        // onboarding, and what survives logout.
        authenticationPreference: remaining.isEmpty
            ? AuthenticationPreference.passwordOnly
            : AuthenticationPreference.biometricFirst,
      );
      await _store.write(updated);
      return Success(updated);
    } on CacheException catch (e) {
      return Failed(CacheFailure(message: e.message));
    }
  }

  @override
  ResultFuture<BiometricSettings> markVerified() async {
    try {
      final current = await _store.read();
      final updated = current.copyWith(lastVerifiedAt: DateTime.now().toUtc());
      await _store.write(updated);
      return Success(updated);
    } on CacheException catch (e) {
      return Failed(CacheFailure(message: e.message));
    }
  }

  @override
  ResultFuture<void> clearRegistration() async {
    try {
      await _store.clear();
      return const Success(null);
    } on CacheException catch (e) {
      return Failed(CacheFailure(message: e.message));
    }
  }
}
