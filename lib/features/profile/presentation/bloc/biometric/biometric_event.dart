import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';

/// Events driving the biometric onboarding state machine.
///
/// Named as imperative requests per `AI_ENGINEERING_PLAYBOOK.md` §2.
sealed class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => const [];
}

/// Load persisted settings + device capability. Fired when the Password &
/// Security screen opens, so the switches render their true state rather than
/// a hardcoded default.
final class BiometricStarted extends BiometricEvent {
  const BiometricStarted();
}

/// The user moved a switch to ON. Does **not** enable anything — it starts the
/// onboarding flow at Step 1.
final class BiometricEnableRequested extends BiometricEvent {
  const BiometricEnableRequested({required this.modality});
  final BiometricModality modality;

  @override
  List<Object?> get props => [modality];
}

/// Step 1 → Step 2: the user accepted the welcome screen.
final class BiometricOnboardingContinued extends BiometricEvent {
  const BiometricOnboardingContinued();
}

/// The user asked to open device settings (Step 3).
final class BiometricEnrollmentSettingsRequested extends BiometricEvent {
  const BiometricEnrollmentSettingsRequested();
}

/// Re-check enrolment. Fired automatically when the app returns to the
/// foreground during Step 3 — this is what makes "enrol, come back, continue"
/// work without the user pressing anything.
final class BiometricEnrollmentRechecked extends BiometricEvent {
  const BiometricEnrollmentRechecked();
}

/// Step 4: run the native prompt. [copy] carries already-localized strings
/// because the OS renders them verbatim.
final class BiometricVerificationRequested extends BiometricEvent {
  const BiometricVerificationRequested({required this.copy});
  final BiometricPromptCopy copy;

  @override
  List<Object?> get props => [copy.reason, copy.signInTitle];
}

/// The user abandoned onboarding. Guarantees the switch returns to OFF.
final class BiometricOnboardingCancelled extends BiometricEvent {
  const BiometricOnboardingCancelled();
}

/// The user moved a switch to OFF.
final class BiometricDisableRequested extends BiometricEvent {
  const BiometricDisableRequested({required this.modality});
  final BiometricModality modality;

  @override
  List<Object?> get props => [modality];
}

/// Dismiss a terminal error/success step and return to the settings list.
final class BiometricFlowDismissed extends BiometricEvent {
  const BiometricFlowDismissed();
}
