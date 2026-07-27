/// Biometric business actions for the Profile feature — one class per action
/// (`ENGINEERING_STANDARD.md` §6), each callable as `call(...)`.
///
/// They depend on the shared `BiometricRepository` in `core/security/`
/// directly rather than on a Profile-local repository interface. `core/` is
/// infrastructure that features inject (`ENGINEERING_STANDARD.md` §5), and
/// wrapping it in a second, identical interface owned by Profile would add an
/// indirection with no seam behind it — and would tempt a future feature to
/// declare a third.
library;

import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';

/// Step 2 of onboarding: what can this device do?
class CheckBiometricCapabilityUseCase
    extends UseCase<BiometricCapability, NoParams> {
  const CheckBiometricCapabilityUseCase(this._repository);
  final BiometricRepository _repository;

  @override
  ResultFuture<BiometricCapability> call(NoParams params) =>
      _repository.checkCapability();
}

/// Step 3 gate: has the user enrolled anything in device settings yet?
///
/// Called again every time the app returns to the foreground during
/// onboarding, which is how "enrol, come back, continue automatically" works.
class CheckEnrollmentUseCase
    extends UseCase<BiometricEnrollmentStatus, NoParams> {
  const CheckEnrollmentUseCase(this._repository);
  final BiometricRepository _repository;

  @override
  ResultFuture<BiometricEnrollmentStatus> call(NoParams params) =>
      _repository.checkEnrollment();
}

/// Step 4: prove identity with the OS.
///
/// The only way a biometric verdict enters the application. Used by onboarding,
/// by login, and by any future sensitive-action confirmation — the caller just
/// supplies a different [AuthenticationReason] via [copy].
class AuthenticateBiometricUseCase
    extends UseCase<bool, AuthenticateBiometricParams> {
  const AuthenticateBiometricUseCase(this._repository);
  final BiometricRepository _repository;

  @override
  ResultFuture<bool> call(AuthenticateBiometricParams params) =>
      _repository.authenticate(copy: params.copy);
}

class AuthenticateBiometricParams extends Equatable {
  const AuthenticateBiometricParams({required this.copy});

  /// Already-localized native dialog strings. Presentation resolves these,
  /// because the domain holds no display copy.
  final BiometricPromptCopy copy;

  @override
  List<Object?> get props => [copy.reason, copy.signInTitle];
}

/// Step 5: persist the opt-in for [BiometricModality].
///
/// **Contract: call this only after [AuthenticateBiometricUseCase] returned a
/// positive match.** The repository independently re-checks the device before
/// writing, so a caller that ignores this contract still cannot enable a
/// switch on a device that cannot honour it — but the ordering is the design,
/// and the defence is the backstop.
class EnableBiometricUseCase
    extends UseCase<BiometricSettings, BiometricModalityParams> {
  const EnableBiometricUseCase(this._repository);
  final BiometricRepository _repository;

  @override
  ResultFuture<BiometricSettings> call(BiometricModalityParams params) =>
      _repository.enable(params.modality);
}

/// Turns a modality off.
///
/// Never validated against the sensor: a user whose fingerprint reader has
/// broken must always be able to switch the feature off, otherwise the setting
/// is stuck on for a device that can no longer satisfy it.
class DisableBiometricUseCase
    extends UseCase<BiometricSettings, BiometricModalityParams> {
  const DisableBiometricUseCase(this._repository);
  final BiometricRepository _repository;

  @override
  ResultFuture<BiometricSettings> call(BiometricModalityParams params) =>
      _repository.disable(params.modality);
}

class BiometricModalityParams extends Equatable {
  const BiometricModalityParams({required this.modality});
  final BiometricModality modality;

  @override
  List<Object?> get props => [modality];
}

/// Reads the persisted settings (secure storage only).
class GetBiometricSettingsUseCase
    extends UseCase<BiometricSettings, NoParams> {
  const GetBiometricSettingsUseCase(this._repository);
  final BiometricRepository _repository;

  @override
  ResultFuture<BiometricSettings> call(NoParams params) =>
      _repository.readSettings();
}
