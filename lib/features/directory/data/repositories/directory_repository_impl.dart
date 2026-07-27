import '../../domain/entities/employee.dart';
import '../../domain/entities/org_tree.dart';
import '../../domain/repositories/directory_repository.dart';
import '../datasources/directory_mock_datasource.dart';

class DirectoryRepositoryImpl implements DirectoryRepository {
  final DirectoryMockDatasource _datasource;

  const DirectoryRepositoryImpl(this._datasource);

  static const Duration _demoLatency = Duration(milliseconds: 260);

  @override
  Future<OrgTree> orgTree() async {
    await Future<void>.delayed(_demoLatency);
    return _datasource.orgTree();
  }

  @override
  Future<List<Company>> companies() async => _datasource.companies();

  @override
  Future<List<Department>> departments() async => _datasource.departments();
}
