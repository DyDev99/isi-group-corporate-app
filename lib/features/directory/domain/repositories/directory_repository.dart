import '../entities/employee.dart';
import '../entities/org_tree.dart';

abstract class DirectoryRepository {
  Future<OrgTree> orgTree();

  Future<List<Company>> companies();

  Future<List<Department>> departments();
}
