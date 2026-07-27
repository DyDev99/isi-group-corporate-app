import 'package:flutter/services.dart';
import 'package:isi_group_corporate_app/core/error/exceptions.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart'
    as app;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

/// Localized strings for the **native** OS dialog.
///
/// Android and iOS render these themselves, so they cannot be styled or
/// translated by Flutter's localization at draw time — they have to be handed
/// to the platform as already-resolved strings. Presentation builds this;
/// infrastructure just forwards it.
class BiometricPromptCopy {
  const BiometricPromptCopy({
    required this.reason,
    required this.signInTitle,
    required this.cancelButton,
    required this.goToSettingsButton,
    required this.goToSettingsDescription,
    required this.biometricRequiredTitle,
    required this.deviceCredentialsRequiredTitle,
  });

  final String reason;
  final String signInTitle;
  final String cancelButton;
  final String goToSettingsButton;
  final String goToSettingsDescription;
  final String biometricRequiredTitle;
  final String deviceCredentialsRequiredTitle;
}

/// The single seam onto the platform biometric APIs.
///
/// **This interface's implementation below is the only file in the application
/// permitted to import `package:local_auth`.** Everything above it speaks
/// [app.BiometricType], [BiometricCapability] and [BiometricException]; no
/// `PlatformException`, `LocalAuthException` or plugin enum escapes it.
///
/// Every method is local-only. Nothing here touches the network, so biometric
/// unlock behaves identically offline (`ARCHITECTURE.md` §1).
abstract interface class BiometricService {
  /// Hardware + device-security probe. Never throws — an unreadable platform
  /// reports an unsupported capability, because a failed *probe* must not
  /// break the login screen.
  Future<BiometricCapability> readCapability();

  /// Runs the native prompt.
  ///
  /// Returns `true` only on a positive match. Throws [BiometricException] for
  /// every platform refusal, dismissal or lockout.
  Future<bool> authenticate({required BiometricPromptCopy copy});

  /// Cancels an in-flight prompt, e.g. when the user navigates away.
  Future<void> cancelAuthentication();
}

/// `local_auth`-backed implementation.
class LocalAuthBiometricService implements BiometricService {
  /// [localAuth] is injectable only so tests can supply a fake. It is
  /// defaulted here rather than registered in DI so that no composition root
  /// needs to import `package:local_auth` — keeping this file the single seam.
  LocalAuthBiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<BiometricCapability> readCapability() async {
    try {
      // `isDeviceSupported` answers "hardware + OS version"; it is also the
      // signal that a device credential is set, because both platforms report
      // unsupported when there is no screen lock.
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        return const BiometricCapability.unsupported(
          BiometricFailureCode.noHardware,
        );
      }

      // `canCheckBiometrics` answers "is the sensor usable right now".
      final canCheck = await _localAuth.canCheckBiometrics;
      final enrolled = await _localAuth.getAvailableBiometrics();

      return BiometricCapability(
        hasHardware: true,
        isDeviceSecure: true,
        enrolled: enrolled.map(_mapType).toList(growable: false),
        unsupportedReason:
            canCheck ? null : BiometricFailureCode.hardwareUnavailable,
      );
    } on PlatformException catch (e) {
      return BiometricCapability.unsupported(
        biometricFailureCodeFromPlatform(e.code),
      );
    } on LocalAuthException catch (e) {
      return BiometricCapability.unsupported(
        biometricFailureCodeFromPlatform(e.code.name),
      );
    } catch (_) {
      // A probe must never take the screen down with it.
      return const BiometricCapability.unsupported(BiometricFailureCode.unknown);
    }
  }

  @override
  Future<bool> authenticate({required BiometricPromptCopy copy}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: copy.reason,
        options: const AuthenticationOptions(
          // Biometrics only: the device PIN is deliberately not accepted as a
          // substitute. The fallback for a failed biometric is ISI Corporate's
          // own credential form, which is a stronger identity check than a
          // device PIN and keeps the session bound to a real login.
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: copy.signInTitle,
            cancelButton: copy.cancelButton,
            goToSettingsButton: copy.goToSettingsButton,
            goToSettingsDescription: copy.goToSettingsDescription,
            biometricRequiredTitle: copy.biometricRequiredTitle,
            deviceCredentialsRequiredTitle: copy.deviceCredentialsRequiredTitle,
          ),
          IOSAuthMessages(
            cancelButton: copy.cancelButton,
            goToSettingsButton: copy.goToSettingsButton,
            goToSettingsDescription: copy.goToSettingsDescription,
          ),
        ],
      );
    } on PlatformException catch (e) {
      throw BiometricException(
        code: biometricFailureCodeFromPlatform(e.code),
        message: e.code,
      );
    } on LocalAuthException catch (e) {
      // The structured API newer plugin versions are migrating to. Handled now
      // so a dependency bump cannot silently degrade every error to `unknown`.
      throw BiometricException(
        code: biometricFailureCodeFromPlatform(e.code.name),
        message: e.code.name,
      );
    }
  }

  @override
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException catch (_) {
      // Best-effort: not every platform implements cancellation, and failing
      // to cancel a prompt the user already dismissed is not an error worth
      // propagating.
    }
  }

  /// Maps the plugin's enum onto ours. Exhaustive by design — a new plugin
  /// value becomes a compile error here rather than a silent mis-classification
  /// somewhere upstream.
  app.BiometricType _mapType(BiometricType type) => switch (type) {
        BiometricType.face => app.BiometricType.face,
        BiometricType.fingerprint => app.BiometricType.fingerprint,
        BiometricType.iris => app.BiometricType.iris,
        BiometricType.strong => app.BiometricType.strong,
        BiometricType.weak => app.BiometricType.weak,
      };
}
