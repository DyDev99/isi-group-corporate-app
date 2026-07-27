import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';

/// What the *device* can do right now — Step 2 of the onboarding flow.
///
/// Deliberately separates the three questions the flow has to answer
/// independently, because each routes to a different screen:
///
///  * [hasHardware] false            → unsupported dialog, feature hidden.
///  * [hasHardware] true, [hasEnrolledBiometrics] false → enrolment guidance.
///  * both true                      → proceed to verification.
class BiometricCapability extends Equatable {
  const BiometricCapability({
    required this.hasHardware,
    required this.isDeviceSecure,
    required this.enrolled,
    this.unsupportedReason,
  });

  /// Nothing available, with the reason the platform gave.
  const BiometricCapability.unsupported(BiometricFailureCode reason)
      : hasHardware = false,
        isDeviceSecure = false,
        enrolled = const [],
        unsupportedReason = reason;

  /// The device has a biometric sensor the OS is willing to prompt with.
  final bool hasHardware;

  /// A device credential (PIN/pattern/passcode) is set. Android and iOS both
  /// refuse to trust biometrics without one, so this is a hard precondition,
  /// not a nicety.
  final bool isDeviceSecure;

  /// Types the user has actually enrolled. Empty means hardware exists but
  /// nothing is registered — the case Step 3 exists to resolve.
  final List<BiometricType> enrolled;

  /// Why the device is unsupported, when [hasHardware] is false.
  final BiometricFailureCode? unsupportedReason;

  /// Hardware present, device secured, and at least one biometric enrolled.
  /// The only state in which an authentication prompt should be attempted.
  bool get isReady => hasHardware && isDeviceSecure && enrolled.isNotEmpty;

  /// Hardware is there but the user has not enrolled anything yet — route to
  /// the device-enrolment guidance screen rather than showing an error.
  bool get needsEnrollment =>
      hasHardware && (enrolled.isEmpty || !isDeviceSecure);

  /// Whether [modality] can be enabled on this device.
  bool supports(BiometricModality modality) =>
      isReady && modality.isSatisfiedBy(enrolled);

  /// The modalities this device can actually offer, for building the switches.
  Set<BiometricModality> get supportedModalities =>
      BiometricModality.values.where(supports).toSet();

  @override
  List<Object?> get props => [
        hasHardware,
        isDeviceSecure,
        enrolled,
        unsupportedReason,
      ];
}

/// Coarse enrolment state, for the UI to switch on without re-deriving it.
enum BiometricEnrollmentStatus {
  /// Ready to authenticate.
  enrolled,

  /// Hardware present, nothing registered — send the user to device settings.
  notEnrolled,

  /// No screen lock set; the OS will not trust biometrics until there is one.
  deviceNotSecure,

  /// This device has no biometric sensor.
  noHardware,

  /// Hardware exists but is temporarily unusable.
  unavailable;

  /// Localization key for the status explanation.
  String get localizationKey => 'auth.biometric.enrollment.$name';

  /// Derives the status from a [BiometricCapability].
  static BiometricEnrollmentStatus fromCapability(
    BiometricCapability capability,
  ) {
    if (!capability.hasHardware) {
      return capability.unsupportedReason ==
              BiometricFailureCode.hardwareUnavailable
          ? BiometricEnrollmentStatus.unavailable
          : BiometricEnrollmentStatus.noHardware;
    }
    if (!capability.isDeviceSecure) {
      return BiometricEnrollmentStatus.deviceNotSecure;
    }
    return capability.enrolled.isEmpty
        ? BiometricEnrollmentStatus.notEnrolled
        : BiometricEnrollmentStatus.enrolled;
  }
}
