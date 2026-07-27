import 'package:equatable/equatable.dart';

/// The complete, pure decision for "may we offer biometric unlock?".
///
/// All three terms must hold. Keeping them in one immutable value object (and
/// not scattered across a bloc and a widget) is what makes the rule testable
/// and makes it impossible for a surface to show the affordance on two of
/// three conditions.
///
/// **Load-bearing invariant:** [canOffer] being `false` never blocks sign-in.
/// It only hides an *extra* affordance — the credential form is always
/// present on the same surface. Biometrics can never be the sole way in.
class BiometricUnlockGate extends Equatable {
  const BiometricUnlockGate({
    required this.deviceUsable,
    required this.hasStoredSession,
    required this.preferenceEnabled,
  });

  /// Nothing on offer: no device support, no session, no opt-in.
  const BiometricUnlockGate.closed()
      : deviceUsable = false,
        hasStoredSession = false,
        preferenceEnabled = false;

  /// The device supports biometrics *and* the user has enrolled at least one.
  final bool deviceUsable;

  /// The user has completed a credential login before and that session is
  /// still cached locally. Read from local storage only — never the network.
  final bool hasStoredSession;

  /// The user opted in to biometric unlock. Defaults to `false`; biometrics
  /// are never switched on for someone.
  final bool preferenceEnabled;

  /// Show the biometric unlock affordance only when every term holds.
  bool get canOffer => deviceUsable && hasStoredSession && preferenceEnabled;

  /// Whether the user may be *invited* to switch biometrics on. Requires a
  /// usable device and a session they just proved with credentials, and is
  /// pointless once they already said yes.
  bool get canOfferEnrollment =>
      deviceUsable && hasStoredSession && !preferenceEnabled;

  BiometricUnlockGate copyWith({
    bool? deviceUsable,
    bool? hasStoredSession,
    bool? preferenceEnabled,
  }) =>
      BiometricUnlockGate(
        deviceUsable: deviceUsable ?? this.deviceUsable,
        hasStoredSession: hasStoredSession ?? this.hasStoredSession,
        preferenceEnabled: preferenceEnabled ?? this.preferenceEnabled,
      );

  @override
  List<Object?> get props =>
      [deviceUsable, hasStoredSession, preferenceEnabled];
}
