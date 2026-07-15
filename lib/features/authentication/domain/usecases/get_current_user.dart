import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/repositories/auth_repository.dart';

/// Resolves the active session on app start (splash / auth-gate).
class GetCurrentUser extends UseCase<User, NoParams> {
  const GetCurrentUser(this._repository);
  final AuthRepository _repository;

  @override
  ResultFuture<User> call(NoParams params) => _repository.getCurrentUser();
}

