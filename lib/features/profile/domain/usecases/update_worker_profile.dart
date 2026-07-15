import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/features/profile/domain/entities/worker_profile.dart';
import 'package:isi_group_corporate_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateWorkerProfile implements UseCase<WorkerProfile, WorkerProfile> {
  const UpdateWorkerProfile(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Result<WorkerProfile>> call(WorkerProfile params) =>
      _repository.updateProfile(params);
}

