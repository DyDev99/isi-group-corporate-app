import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';

/// Domain-level error type. Sealed so presentation code can exhaustively
/// map each variant to a user-facing message if it wants to.
sealed class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}

/// Invalid credentials, expired token, or no active session.
final class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.statusCode});
}

/// A biometric operation could not be completed.
///
/// Lives here rather than in `core/security/biometric/biometric_failure.dart`
/// (where its [code] and all the recovery semantics do live) because [Failure]
/// is `sealed`: Dart only permits subtypes inside this library. The security
/// module owns the taxonomy; this class is the thin adapter that lets it
/// travel through the app's shared `Result`/`Failure` channel.
///
/// [message] is developer-facing. Presentation renders [localizationKey].
///
/// **Invariant:** every [BiometricFailure] is recoverable by signing in with
/// credentials. Biometrics augment the credential form; they never gate it.
final class BiometricFailure extends Failure {
  const BiometricFailure({required this.code, required super.message});

  final BiometricFailureCode code;

  /// Localization key presentation should render for this failure.
  String get localizationKey => code.localizationKey;

  /// The user can resolve this by enrolling a biometric in device settings.
  bool get requiresEnrollment => code.requiresEnrollment;

  /// Retrying the same prompt could plausibly succeed.
  bool get isRetryable => code.isRetryable;

  /// The user dismissed the prompt — not worth an error dialog.
  bool get isUserDismissal => code.isUserDismissal;

  @override
  List<Object?> get props => [message, statusCode, code];
}
