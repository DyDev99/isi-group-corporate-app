/// Why the app is asking the user to prove who they are.
///
/// The OS renders the reason string verbatim inside its own prompt, so it must
/// be localized and it must be specific — "Authenticate" tells the user
/// nothing about what they are about to approve. Modelling the reason as an
/// enum (rather than passing raw strings around) means every call site picks
/// from a reviewed set of prompts, and the copy for each lives in one place.
///
/// This is the extension point that makes the biometric stack reusable: adding
/// payment confirmation or a document unlock is a new enum value plus two
/// localization strings, not a new service.
enum AuthenticationReason {
  /// Signing in on app launch with a stored session.
  login,

  /// Finishing biometric onboarding (Step 4 of the setup flow).
  enableBiometric,

  /// Turning biometric unlock back off — a security-sensitive change, so it is
  /// itself protected.
  disableBiometric,

  /// Re-entering the app after it was locked or backgrounded.
  unlockApp,

  /// Approving a SAP action that mutates business data.
  approveSapAction,

  /// Confirming a payment or payroll operation.
  confirmPayment,

  /// Opening a document classified as confidential.
  viewSecureDocument,

  /// Changing security-sensitive settings (password, 2FA, device binding).
  changeSecuritySettings;

  /// Localization key for the sentence shown inside the OS prompt.
  String get localizationKey => 'auth.biometric.reason.$name';

  /// Localization key for the native dialog's title (Android renders a title
  /// above the reason; iOS does not).
  String get titleKey => 'auth.biometric.prompt_title.$name';
}
