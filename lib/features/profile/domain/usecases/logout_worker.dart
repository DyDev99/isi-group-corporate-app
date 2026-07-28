import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/features/profile/domain/repositories/profile_repository.dart';

class LogoutWorker implements UseCase<void, NoParams> {
  const LogoutWorker(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.logout();
}
