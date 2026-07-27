import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => const [];
}

/// Fired once on app start to resolve any persisted session.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Enter guest browsing explicitly (e.g. after onboarding completes, or when
/// the user dismisses a login prompt with "Later"). Idempotent — safe to fire
/// even if already a guest.
final class AuthGuestRequested extends AuthEvent {
  const AuthGuestRequested();
}

/// Fired by the login form. Name + shape must match LoginScreen.
final class LoginSubmittedEvent extends AuthEvent {
  const LoginSubmittedEvent({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Fired by a surface that shows the biometric affordance (the login form, or
/// the biometric lock on boot). Runs the OS prompt and promotes the *already
/// stored* session — it never mints one, and never touches the network.
///
/// [copy] carries already-localized native dialog strings, built by
/// presentation via `buildPromptCopy(AuthenticationReason.login)`: the OS
/// renders them verbatim and the domain holds no display text.
///
/// Enabling/disabling biometrics is deliberately **not** an AuthBloc concern.
/// That is onboarding, it lives in `BiometricBloc` behind the Profile →
/// Password & Security screen, and it is the only path that can turn the
/// feature on.
final class BiometricUnlockRequested extends AuthEvent {
  const BiometricUnlockRequested({required this.copy});
  final BiometricPromptCopy copy;

  @override
  List<Object?> get props => [copy.reason, copy.signInTitle];
}

/// Re-evaluates the three-term unlock gate (device usable + stored session +
/// onboarding completed) and folds the answer into the current state. Surfaces
/// fire this on resume, since the user may have enrolled or removed a
/// fingerprint in system settings while the app was backgrounded.
final class BiometricGateRefreshed extends AuthEvent {
  const BiometricGateRefreshed();
}
