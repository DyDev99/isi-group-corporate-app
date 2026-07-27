import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';

/// Thrown by data sources. Repositories catch these and translate them
/// into [Failure]s so exceptions never leak past the data layer.
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error.'});
  final String message;
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection.'});
  final String message;
}

class AuthenticationException implements Exception {
  const AuthenticationException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
}

/// Thrown by `BiometricService` when the platform refuses or the user dismisses
/// the prompt. The repository translates it into a `BiometricFailure` so no
/// `PlatformException`/`LocalAuthException` ever reaches the domain.
class BiometricException implements Exception {
  const BiometricException({required this.code, required this.message});

  /// Normalised platform reason; drives every UI recovery decision.
  final BiometricFailureCode code;

  /// Developer-facing detail (the raw platform code). Never shown to a user —
  /// presentation renders `code.localizationKey` instead.
  final String message;
}
