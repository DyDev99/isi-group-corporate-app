import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/biometric_unlock_gate.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/repositories/auth_repository.dart';

/// Evaluates the three-term login gate: the device can do it **and** the user
/// has a stored credential-login session **and** they completed biometric
/// onboarding.
///
/// This is the single place the rule is expressed, so no surface can end up
/// offering biometric sign-in on two of the three terms.
///
/// Entirely local — `AuthRepository.getCurrentUser()` reads secure storage and
/// `BiometricRepository` reads the device and secure storage, so the gate
/// resolves identically offline and online (`ARCHITECTURE.md` §1).
class CanOfferBiometricUnlock extends UseCase<BiometricUnlockGate, NoParams> {
  const CanOfferBiometricUnlock({
    required BiometricRepository biometricRepository,
    required AuthRepository authRepository,
  })  : _biometrics = biometricRepository,
        _auth = authRepository;

  final BiometricRepository _biometrics;
  final AuthRepository _auth;

  @override
  ResultFuture<BiometricUnlockGate> call(NoParams params) async {
    final capability = await _biometrics.checkCapability();
    final deviceUsable = capability.when(
      success: (c) => c.isReady,
      failure: (_) => false,
    );

    final session = await _auth.getCurrentUser();
    final hasStoredSession =
        session.when(success: (_) => true, failure: (_) => false);

    final settingsResult = await _biometrics.readSettings();
    // Fails closed: an unreadable secure store means "not enabled", so a
    // corrupt keystore entry can never strand the user behind a lock.
    final settings = settingsResult.when(
      success: (s) => s,
      failure: (_) => const BiometricSettings.disabled(),
    );

    return Success(
      BiometricUnlockGate(
        deviceUsable: deviceUsable,
        hasStoredSession: hasStoredSession,
        // `isUsable` requires enabled + registered + a chosen modality +
        // biometric-first preference — the full result of onboarding, not just
        // a boolean someone could flip.
        preferenceEnabled: settings.isUsable,
      ),
    );
  }
}
