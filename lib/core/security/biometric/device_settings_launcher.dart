import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Opens the operating system's biometric-enrolment settings — Step 3 of the
/// onboarding flow.
///
/// ## Why a platform channel instead of a package
///
/// This is ~30 lines of native code with an exactly-known surface. Pulling in a
/// third-party settings plugin would add supply-chain surface for no
/// capability we cannot write ourselves, and `SECURITY.md` §14 requires a
/// maintenance/vulnerability review before adopting a dependency. The channel
/// is the smaller, auditable option.
///
/// ## The platform asymmetry that matters
///
/// **Android** can deep-link straight to biometric enrolment
/// (`Settings.ACTION_BIOMETRIC_ENROLL` on API 30+, `ACTION_FINGERPRINT_ENROLL`
/// on 28+, `ACTION_SECURITY_SETTINGS` below that).
///
/// **iOS cannot.** There is no public URL for the Face ID / Touch ID
/// enrolment pane; `App-Prefs:PASSCODE` is a private URL scheme and using it is
/// grounds for App Store rejection. The most iOS permits is opening this app's
/// own settings page via `UIApplication.openSettingsURLString`. So on iOS the
/// user has to be *told* where to go, which is why
/// [canDeepLinkToEnrollment] exists and why the enrolment screen shows
/// step-by-step directions instead of relying on the button alone.
abstract interface class DeviceSettingsLauncher {
  /// Whether this platform can navigate the user directly to biometric
  /// enrolment. `false` on iOS — the UI must show manual directions.
  bool get canDeepLinkToEnrollment;

  /// Opens the closest available settings destination.
  ///
  /// Returns `true` if a settings screen was opened. Never throws: failing to
  /// open settings must degrade to "the user reads the instructions", not to a
  /// crash inside an onboarding flow.
  Future<bool> openBiometricEnrollment();
}

class DeviceSettingsLauncherImpl implements DeviceSettingsLauncher {
  const DeviceSettingsLauncherImpl({
    MethodChannel channel = const MethodChannel(_channelName),
    TargetPlatform? platformOverride,
  })  : _channel = channel,
        _platformOverride = platformOverride;

  static const String _channelName = 'isi.corporate/device_settings';

  final MethodChannel _channel;

  /// Test seam — production reads [defaultTargetPlatform].
  final TargetPlatform? _platformOverride;

  TargetPlatform get _platform => _platformOverride ?? defaultTargetPlatform;

  @override
  bool get canDeepLinkToEnrollment => _platform == TargetPlatform.android;

  @override
  Future<bool> openBiometricEnrollment() async {
    try {
      final opened =
          await _channel.invokeMethod<bool>('openBiometricEnrollment');
      return opened ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // Desktop/test hosts have no handler registered. Not an error — the
      // enrolment screen's written instructions still apply.
      return false;
    }
  }
}
