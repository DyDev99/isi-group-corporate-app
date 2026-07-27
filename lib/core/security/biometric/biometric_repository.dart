import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';

/// The application-facing contract for everything biometric.
///
/// Lives in `core/security/` rather than under a feature because more than one
/// feature depends on it — Profile owns the settings UI, Authentication owns
/// login, and Payments/Approvals will own confirmation prompts
/// (`SECURITY.md` §2: security logic is never duplicated per feature).
///
/// Every method returns a typed `Result`; no exception crosses this boundary.
abstract interface class BiometricRepository {
  /// Step 2 of onboarding — what this device can do right now.
  ResultFuture<BiometricCapability> checkCapability();

  /// Coarse enrolment state, for deciding between "verify", "enrol" and
  /// "unsupported" without re-deriving it at each call site.
  ResultFuture<BiometricEnrollmentStatus> checkEnrollment();

  /// Runs the native prompt for [copy]'s reason.
  ///
  /// Returns `Success(true)` only on a positive match. Dismissal, lockout and
  /// unsupported hardware are typed `BiometricFailure`s — never exceptions,
  /// and never a silent `false`.
  ResultFuture<bool> authenticate({required BiometricPromptCopy copy});

  /// Cancels an in-flight prompt.
  Future<void> cancelAuthentication();

  /// The persisted settings. Fails closed to
  /// [BiometricSettings.disabled] when the store is unreadable.
  ResultFuture<BiometricSettings> readSettings();

  /// Completes onboarding for [modality].
  ///
  /// **Only ever called after the OS has returned a positive match.** The
  /// repository re-checks capability and refuses to persist an enabled state
  /// for a device that cannot satisfy the modality, so a UI bug cannot leave a
  /// half-enabled switch behind.
  ResultFuture<BiometricSettings> enable(BiometricModality modality);

  /// Turns [modality] off. Always permitted and never validated against the
  /// sensor — a broken reader must not be able to trap the user with the
  /// setting stuck on.
  ResultFuture<BiometricSettings> disable(BiometricModality modality);

  /// Records a successful verification timestamp (audit + future
  /// re-verification interval).
  ResultFuture<BiometricSettings> markVerified();

  /// Wipes registration completely — account deletion or device unbinding.
  /// **Not** called on logout: see [BiometricSettings.clearedForLogout].
  ResultFuture<void> clearRegistration();
}
