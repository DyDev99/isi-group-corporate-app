import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/can_offer_biometric_unlock.dart';

/// Signs in with the OS biometric prompt and resolves the cached session —
/// the biometric counterpart of `Login`.
///
/// Four properties this use case guarantees:
///
///  1. **It never mints a session.** Gate first, then prompt, then read back
///     the *already stored* session. A device that was never signed in on
///     cannot be unlocked into an account.
///  2. **It never touches the network.** Every step reads local state, so
///     unlock works with no signal (`ARCHITECTURE.md` §1).
///  3. **It reuses the existing token flow.** On success it returns the same
///     `User` that `AuthCheckRequested` would have, and the stored access /
///     refresh tokens continue to serve the SAP-bound Dio interceptor
///     untouched — biometrics gate *access to* the session, they never become
///     a credential and never mint or exchange a token themselves.
///  4. **Failure is always recoverable by credentials.** Every unhappy path
///     returns a typed failure and leaves the stored session intact.
class AuthenticateWithBiometrics
    extends UseCase<User, AuthenticateWithBiometricsParams> {
  const AuthenticateWithBiometrics({
    required BiometricRepository biometricRepository,
    required CanOfferBiometricUnlock canOffer,
    required AuthRepository authRepository,
  })  : _biometrics = biometricRepository,
        _canOffer = canOffer,
        _auth = authRepository;

  final BiometricRepository _biometrics;
  final CanOfferBiometricUnlock _canOffer;
  final AuthRepository _auth;

  @override
  ResultFuture<User> call(AuthenticateWithBiometricsParams params) async {
    final gate = await _canOffer(const NoParams());
    final open = gate.when(success: (g) => g.canOffer, failure: (_) => false);
    if (!open) {
      // Not a user-caused error — the caller falls back to the form.
      return const Failed(
        BiometricFailure(
          code: BiometricFailureCode.noHardware,
          message: 'biometric_unlock_gate_closed',
        ),
      );
    }

    final prompt = await _biometrics.authenticate(copy: params.copy);

    return prompt.when(
      success: (_) async {
        // Best-effort audit timestamp; a failure to record it must not cost
        // the user their sign-in.
        await _biometrics.markVerified();
        // Local read only — the same offline-first path AuthCheckRequested uses.
        return _auth.getCurrentUser();
      },
      failure: (f) async => Failed<User>(f),
    );
  }
}

class AuthenticateWithBiometricsParams extends Equatable {
  const AuthenticateWithBiometricsParams({required this.copy});

  /// Already-localized native dialog strings, built by presentation via
  /// `buildPromptCopy(AuthenticationReason.login)`. The domain holds no
  /// display text.
  final BiometricPromptCopy copy;

  @override
  List<Object?> get props => [copy.reason, copy.signInTitle];
}
