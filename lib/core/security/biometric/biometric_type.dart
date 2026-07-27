/// Biometric vocabulary shared by every layer.
///
/// Pure Dart on purpose: `package:local_auth`'s own `BiometricType` stops at
/// [BiometricService]'s implementation and is mapped onto [BiometricType]
/// below, so nothing above the infrastructure layer depends on the plugin.
library;

/// A kind of biometric the OS reports as enrolled.
///
/// Mirrors `local_auth`'s enum, but is ours so the plugin can be swapped or
/// upgraded without a change rippling into domain or presentation code.
enum BiometricType {
  face,
  fingerprint,
  iris,

  /// Platform-classified "strong" sensor of unspecified kind (Android Class 3).
  strong,

  /// Platform-classified "weak" sensor of unspecified kind (Android Class 2).
  weak,
}

/// The two modalities the product exposes as independent user-facing switches
/// on the Password & Security screen.
///
/// ## An honest note on what this can and cannot mean
///
/// Neither Android's `BiometricPrompt` nor iOS's `LocalAuthentication` lets an
/// app demand "fingerprint only" or "Face ID only" — the OS presents whatever
/// the user has enrolled and considers strong enough. So this enum does **not**
/// constrain the OS prompt. What it does control is:
///
///  * whether ISI Corporate *offers* that modality at all,
///  * which icon, title and prompt copy the user sees, and
///  * whether the enrolment gate for that modality has been satisfied.
///
/// This is documented rather than hidden because a future engineer will
/// otherwise assume the toggle restricts the sensor, and build a security
/// control on top of an assumption the platform never guaranteed.
enum BiometricModality {
  fingerprint,
  face;

  /// Localization key for this modality's display name.
  String get labelKey => switch (this) {
        BiometricModality.fingerprint => 'auth.biometric.modality.fingerprint',
        BiometricModality.face => 'auth.biometric.modality.face',
      };

  /// Stable token used as the secure-storage value. Never `index` — reordering
  /// the enum would silently re-map every user's stored preference.
  String get storageKey => name;

  static BiometricModality? fromStorageKey(String value) {
    for (final modality in BiometricModality.values) {
      if (modality.storageKey == value) return modality;
    }
    return null;
  }

  /// The OS-reported types that satisfy this modality's enrolment gate.
  ///
  /// `strong`/`weak` are deliberately accepted by both: Android frequently
  /// reports only a strength class rather than naming the sensor, and refusing
  /// to enable in that case would block enrolment on a large share of real
  /// devices for no security gain.
  Set<BiometricType> get satisfyingTypes => switch (this) {
        BiometricModality.fingerprint => const {
            BiometricType.fingerprint,
            BiometricType.strong,
            BiometricType.weak,
          },
        BiometricModality.face => const {
            BiometricType.face,
            BiometricType.iris,
            BiometricType.strong,
            BiometricType.weak,
          },
      };

  /// Whether the device's [enrolled] types can satisfy this modality.
  bool isSatisfiedBy(Iterable<BiometricType> enrolled) =>
      enrolled.any(satisfyingTypes.contains);
}
