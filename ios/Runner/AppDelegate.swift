import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Must match `DeviceSettingsLauncherImpl._channelName`.
  private static let deviceSettingsChannel = "isi.corporate/device_settings"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerDeviceSettingsChannel(with: engineBridge.binaryMessenger)
  }

  /// Biometric-enrolment settings bridge.
  ///
  /// iOS deliberately exposes **no** public deep link to the Face ID / Touch ID
  /// enrolment pane. `App-Prefs:PASSCODE` is a private URL scheme and shipping
  /// it is grounds for App Store rejection. `UIApplication.openSettingsURLString`
  /// — this app's own settings page — is the only sanctioned destination, so
  /// that is what we open, and the Flutter enrolment screen shows the user
  /// written directions to Settings › Face ID & Passcode.
  ///
  /// `DeviceSettingsLauncher.canDeepLinkToEnrollment` reports false on iOS for
  /// exactly this reason.
  private func registerDeviceSettingsChannel(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: AppDelegate.deviceSettingsChannel,
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { call, result in
      guard call.method == "openBiometricEnrollment" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
      else {
        result(false)
        return
      }

      UIApplication.shared.open(url, options: [:]) { opened in
        result(opened)
      }
    }
  }
}
