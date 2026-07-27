import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';

/// Where the user is in the biometric onboarding flow.
///
/// A single enum rather than a state subclass per step, because the settings
/// (switch positions) and capability must remain visible at *every* step — the
/// screen underneath the flow keeps rendering. Splitting into sibling state
/// classes would mean re-carrying those fields five times.
enum BiometricFlowStep {
  /// Not in the flow. The settings screen is idle.
  idle,

  /// Step 1 — welcome / value proposition.
  welcome,

  /// Step 2 — probing the device.
  validating,

  /// Step 3 — nothing enrolled; guide the user to device settings.
  enrollmentRequired,

  /// Step 4 — awaiting the native prompt's verdict.
  verifying,

  /// Step 5 — verified and persisted.
  success,

  /// Terminal: this device cannot do biometrics at all.
  unsupported,

  /// Recoverable failure; the flow offers Retry and Cancel.
  error,
}

/// Immutable state of the biometric settings surface and its onboarding flow.
class BiometricState extends Equatable {
  const BiometricState({
    this.settings = const BiometricSettings.disabled(),
    this.capability,
    this.step = BiometricFlowStep.idle,
    this.pendingModality,
    this.failureCode,
    this.isBusy = false,
    this.enrollmentStatus,
  });

  /// Persisted opt-in. **The switches render from this and nothing else** —
  /// which is what makes it impossible for a switch to appear ON before
  /// onboarding has actually completed.
  final BiometricSettings settings;

  /// Last device probe. Null until [BiometricStarted] resolves.
  final BiometricCapability? capability;

  final BiometricFlowStep step;

  /// The modality being onboarded right now. Held so Step 5 knows which switch
  /// to turn on, and so a cancel knows which one to leave off.
  final BiometricModality? pendingModality;

  /// Why the flow failed, when [step] is
  /// [BiometricFlowStep.error] or [BiometricFlowStep.unsupported].
  final BiometricFailureCode? failureCode;

  /// A repository call is in flight; disables controls to prevent double-taps
  /// (the OS allows only one prompt at a time).
  final bool isBusy;

  final BiometricEnrollmentStatus? enrollmentStatus;

  /// Whether [modality]'s switch should render as ON.
  ///
  /// Reads the persisted set only. An in-progress onboarding never shows as
  /// enabled — the core requirement of this feature.
  bool isEnabled(BiometricModality modality) =>
      settings.biometricEnabled && settings.biometricType.contains(modality);

  /// Whether the device can offer [modality] at all. Drives whether the switch
  /// is interactive or shown disabled with an explanation.
  bool isSupported(BiometricModality modality) =>
      capability?.supports(modality) ?? false;

  /// The device has hardware but no enrolment — the switch stays interactive
  /// (tapping it starts the flow, which routes to enrolment guidance) rather
  /// than being greyed out with no way forward.
  bool get needsEnrollment => capability?.needsEnrollment ?? false;

  /// No biometric hardware: hide the switches entirely rather than presenting
  /// a permanently broken control.
  bool get isDeviceCapable => capability?.hasHardware ?? false;

  /// The onboarding flow is on screen.
  bool get isFlowActive => step != BiometricFlowStep.idle;

  /// Localization key for the current failure, if any.
  String? get failureKey => failureCode?.localizationKey;

  BiometricState copyWith({
    BiometricSettings? settings,
    BiometricCapability? capability,
    BiometricFlowStep? step,
    BiometricModality? pendingModality,
    BiometricFailureCode? failureCode,
    bool? isBusy,
    BiometricEnrollmentStatus? enrollmentStatus,
    bool clearPendingModality = false,
    bool clearFailure = false,
  }) =>
      BiometricState(
        settings: settings ?? this.settings,
        capability: capability ?? this.capability,
        step: step ?? this.step,
        pendingModality:
            clearPendingModality ? null : pendingModality ?? this.pendingModality,
        failureCode: clearFailure ? null : failureCode ?? this.failureCode,
        isBusy: isBusy ?? this.isBusy,
        enrollmentStatus: enrollmentStatus ?? this.enrollmentStatus,
      );

  @override
  List<Object?> get props => [
        settings,
        capability,
        step,
        pendingModality,
        failureCode,
        isBusy,
        enrollmentStatus,
      ];
}
