import '../entities/employee.dart';
import '../entities/org_tree.dart';
import '../repositories/directory_repository.dart';

/// One usecase per business action (ENGINEERING_STANDARD §6). Each is a thin
/// delegation today; split into separate files if any grows real logic.

class GetOrgTree {
  final DirectoryRepository _repository;

  const GetOrgTree(this._repository);

  Future<OrgTree> call() => _repository.orgTree();
}

class GetCompanies {
  final DirectoryRepository _repository;

  const GetCompanies(this._repository);

  Future<List<Company>> call() => _repository.companies();
}

class GetDepartments {
  final DirectoryRepository _repository;

  const GetDepartments(this._repository);

  Future<List<Department>> call() => _repository.departments();
}
