/// The complete biometric error taxonomy, plus the recovery semantics each
/// code implies.
///
/// Every platform error — `PlatformException` from `local_auth`'s current
/// Android/iOS implementations, or `LocalAuthException` from the newer
/// structured API — is normalised into a [BiometricFailureCode] at the
/// infrastructure boundary. Nothing above [BiometricService] ever sees a raw
/// platform error (`ENGINEERING_STANDARD.md` §7).
///
/// The semantics on each code ([requiresEnrollment], [isRetryable],
/// [requiresDeviceUnlock]) are what drive the UI: the onboarding flow decides
/// whether to show "Open Device Settings", a retry button, or an unsupported
/// dialog by reading these, never by string-matching a message.
library;

/// Normalised reason a biometric operation did not succeed.
///
/// Ordered roughly from "device can never do this" to "transient".
enum BiometricFailureCode {
  /// No biometric sensor exists on this device.
  noHardware,

  /// Hardware exists but is not usable right now (in use by another app,
  /// unpaired removable sensor).
  hardwareUnavailable,

  /// Hardware exists; the user has not enrolled a fingerprint or face.
  /// **This is the code that triggers the Step 3 enrolment guidance.**
  notEnrolled,

  /// No device passcode/PIN/pattern is set, so the OS refuses to trust
  /// biometrics at all. The user must set a screen lock first.
  passcodeNotSet,

  /// Too many failed attempts; the sensor is disabled for a cool-down period.
  temporaryLockout,

  /// Too many failed attempts; the OS requires a device-credential unlock
  /// before biometrics work again.
  permanentLockout,

  /// The user dismissed the system prompt. Not an error — a choice.
  userCanceled,

  /// The user explicitly asked for the non-biometric fallback.
  userFallback,

  /// A system event (incoming call, app backgrounded) cancelled the prompt.
  systemCanceled,

  /// The prompt ran and the user was not recognised.
  notRecognized,

  /// A prompt is already in flight; a second cannot be started.
  authInProgress,

  /// The app itself is misconfigured — no foreground activity, or
  /// `MainActivity` is not a `FlutterFragmentActivity`. A developer bug, not a
  /// user problem; it must be loud in debug and graceful in release.
  platformMisconfigured,

  /// Anything the platform reported that is not modelled above.
  unknown;

  /// Localization key for the user-facing explanation.
  String get localizationKey => 'auth.biometric.error.$name';

  /// The user can fix this by enrolling a biometric in device settings, so the
  /// UI should offer "Open Device Settings".
  bool get requiresEnrollment =>
      this == BiometricFailureCode.notEnrolled ||
      this == BiometricFailureCode.passcodeNotSet;

  /// The user must unlock the device with their PIN/pattern/password before
  /// biometrics will work again.
  bool get requiresDeviceUnlock =>
      this == BiometricFailureCode.permanentLockout;

  /// Retrying the same prompt could plausibly succeed. Distinguishes "offer a
  /// Try Again button" from "this device will never do this".
  bool get isRetryable => switch (this) {
        BiometricFailureCode.userCanceled ||
        BiometricFailureCode.userFallback ||
        BiometricFailureCode.systemCanceled ||
        BiometricFailureCode.notRecognized ||
        BiometricFailureCode.authInProgress ||
        BiometricFailureCode.hardwareUnavailable ||
        BiometricFailureCode.temporaryLockout =>
          true,
        BiometricFailureCode.noHardware ||
        BiometricFailureCode.notEnrolled ||
        BiometricFailureCode.passcodeNotSet ||
        BiometricFailureCode.permanentLockout ||
        BiometricFailureCode.platformMisconfigured ||
        BiometricFailureCode.unknown =>
          false,
      };

  /// This device cannot do biometrics at all, so the feature should be hidden
  /// rather than presented as broken.
  bool get isPermanentlyUnsupported =>
      this == BiometricFailureCode.noHardware ||
      this == BiometricFailureCode.platformMisconfigured;

  /// The user chose to stop — not a failure worth showing an error dialog for.
  bool get isUserDismissal =>
      this == BiometricFailureCode.userCanceled ||
      this == BiometricFailureCode.userFallback ||
      this == BiometricFailureCode.systemCanceled;
}

/// Maps a raw platform error code string onto a [BiometricFailureCode].
///
/// Handles both spellings the plugin can produce:
///
///  * `local_auth_android` 1.0.56 and `local_auth_darwin` 1.6.1 throw
///    `PlatformException` with the string codes below (kept, per the plugin's
///    own source comment, "for compatibility with the previous Java
///    implementation").
///  * `local_auth_platform_interface` 1.1.0 additionally declares the
///    structured `LocalAuthException`/`LocalAuthExceptionCode` API that newer
///    implementations are migrating to.
///
/// Both are mapped so a plugin upgrade does not silently degrade every error
/// to [BiometricFailureCode.unknown].
BiometricFailureCode biometricFailureCodeFromPlatform(String rawCode) =>
    switch (rawCode) {
      // ── PlatformException codes (current Android/iOS implementations) ──
      'NotAvailable' => BiometricFailureCode.hardwareUnavailable,
      'NotEnrolled' => BiometricFailureCode.notEnrolled,
      'PasscodeNotSet' => BiometricFailureCode.passcodeNotSet,
      'LockedOut' => BiometricFailureCode.temporaryLockout,
      'PermanentlyLockedOut' => BiometricFailureCode.permanentLockout,
      'OtherOperatingSystem' => BiometricFailureCode.noHardware,
      'biometricOnlyNotSupported' => BiometricFailureCode.hardwareUnavailable,
      'auth_in_progress' => BiometricFailureCode.authInProgress,
      // Developer misconfiguration — see BiometricFailureCode.platformMisconfigured.
      'no_activity' ||
      'no_fragment_activity' =>
        BiometricFailureCode.platformMisconfigured,
      'UserCancel' => BiometricFailureCode.userCanceled,
      'UserFallback' => BiometricFailureCode.userFallback,
      'SystemCancel' => BiometricFailureCode.systemCanceled,

      // ── LocalAuthExceptionCode.name values (structured API) ──
      'noBiometricHardware' => BiometricFailureCode.noHardware,
      'biometricHardwareTemporarilyUnavailable' =>
        BiometricFailureCode.hardwareUnavailable,
      'noBiometricsEnrolled' => BiometricFailureCode.notEnrolled,
      'noCredentialsSet' => BiometricFailureCode.passcodeNotSet,
      'temporaryLockout' => BiometricFailureCode.temporaryLockout,
      'biometricLockout' => BiometricFailureCode.permanentLockout,
      'userCanceled' => BiometricFailureCode.userCanceled,
      'userRequestedFallback' => BiometricFailureCode.userFallback,
      'systemCanceled' || 'timeout' => BiometricFailureCode.systemCanceled,
      'authInProgress' => BiometricFailureCode.authInProgress,
      'uiUnavailable' => BiometricFailureCode.platformMisconfigured,
      'deviceError' || 'unknownError' => BiometricFailureCode.unknown,
      _ => BiometricFailureCode.unknown,
    };
