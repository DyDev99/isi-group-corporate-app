import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';

/// How the user prefers to be asked for identity on app launch.
enum AuthenticationPreference {
  /// Offer the biometric prompt first, with the credential form behind it.
  biometricFirst,

  /// Never prompt; go straight to the credential form.
  passwordOnly;

  String get storageKey => name;

  static AuthenticationPreference fromStorageKey(String? value) {
    for (final preference in AuthenticationPreference.values) {
      if (preference.storageKey == value) return preference;
    }
    return AuthenticationPreference.passwordOnly;
  }
}

/// Everything ISI Corporate persists about biometrics — and, just as
/// importantly, the complete list of what it is allowed to persist.
///
/// ## What is stored
///
/// `biometricEnabled`, `biometricType`, `biometricRegistered`,
/// `lastVerifiedAt`, `authenticationPreference`. All of it lives in
/// `flutter_secure_storage` (hardware-backed Keychain / Android Keystore) per
/// `SECURITY.md` §3 — never `SharedPreferences`, Hive, SQLite or Drift.
///
/// ## What is never stored
///
/// No fingerprint, no face image, no biometric template, no derived hash, no
/// authentication key. **The application is incapable of reading biometric
/// material in the first place** — Android's `BiometricPrompt` and iOS's
/// `LocalAuthentication` return a boolean verdict and nothing else; the
/// template never leaves the Secure Enclave / TEE. This class exists to make
/// that boundary explicit and auditable, so a future change that tries to add
/// a `faceTemplate` field is obviously wrong at review time.
class BiometricSettings extends Equatable {
  const BiometricSettings({
    required this.biometricEnabled,
    required this.biometricType,
    required this.biometricRegistered,
    required this.lastVerifiedAt,
    required this.authenticationPreference,
  });

  /// The state of a device that has never completed onboarding.
  const BiometricSettings.disabled()
      : biometricEnabled = false,
        biometricType = const {},
        biometricRegistered = false,
        lastVerifiedAt = null,
        authenticationPreference = AuthenticationPreference.passwordOnly;

  /// Master switch. True only when at least one modality survived the full
  /// onboarding flow including OS verification.
  final bool biometricEnabled;

  /// Which of the two user-facing switches are on. See [BiometricModality] for
  /// why this does not (and cannot) constrain the OS prompt itself.
  final Set<BiometricModality> biometricType;

  /// The user completed onboarding at least once on this device and proved
  /// their identity to the OS. Survives logout on purpose — see
  /// [BiometricSettings.clearedForLogout].
  final bool biometricRegistered;

  /// When the OS last returned a positive match. Useful for audit and for a
  /// future re-verification interval; never used as a substitute for an
  /// actual prompt.
  final DateTime? lastVerifiedAt;

  final AuthenticationPreference authenticationPreference;

  /// Whether biometric unlock may be offered right now, from the stored side
  /// of the decision. The device side is [BiometricCapability.isReady] and the
  /// session side is "a credential login is cached"; all three must hold.
  bool get isUsable =>
      biometricEnabled &&
      biometricRegistered &&
      biometricType.isNotEmpty &&
      authenticationPreference == AuthenticationPreference.biometricFirst;

  /// What logging out leaves behind.
  ///
  /// Deliberately **returns `this` unchanged**. Signing out clears tokens, not
  /// the user's registration: this device is still their device, and the next
  /// launch must immediately offer "Sign in with Fingerprint / Face ID". A
  /// method that visibly does nothing is better than an absent one — it is the
  /// place this decision is written down, and the place a test can pin it.
  BiometricSettings clearedForLogout() => this;

  BiometricSettings copyWith({
    bool? biometricEnabled,
    Set<BiometricModality>? biometricType,
    bool? biometricRegistered,
    DateTime? lastVerifiedAt,
    AuthenticationPreference? authenticationPreference,
  }) =>
      BiometricSettings(
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        biometricType: biometricType ?? this.biometricType,
        biometricRegistered: biometricRegistered ?? this.biometricRegistered,
        lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
        authenticationPreference:
            authenticationPreference ?? this.authenticationPreference,
      );

  @override
  List<Object?> get props => [
        biometricEnabled,
        biometricType,
        biometricRegistered,
        lastVerifiedAt,
        authenticationPreference,
      ];
}
