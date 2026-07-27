import 'directory_filter.dart';
import 'employee.dart';

/// A node in the reporting tree. `directReports` is *derived* from the tree —
/// the original model carried a hand-written `childrenCount` that disagreed
/// with the actual children (a manager labelled "12" with 2 children, and
/// expand buttons on nodes with nothing to expand).
class OrgNode {
  final Employee employee;
  final List<OrgNode> children;

  const OrgNode({required this.employee, this.children = const []});

  String get id => employee.id;

  int get directReports => children.length;

  int get descendantCount =>
      children.fold(0, (sum, child) => sum + 1 + child.descendantCount);

  bool get hasChildren => children.isNotEmpty;
}

/// Result of applying a filter: the pruned tree plus which nodes actually
/// matched versus which are only kept because a descendant matched.
class FilteredOrg {
  final OrgNode? root;
  final Set<String> matchedIds;
  final Set<String> ancestorIds;

  const FilteredOrg({
    required this.root,
    required this.matchedIds,
    required this.ancestorIds,
  });

  int get matchCount => matchedIds.length;

  bool get isEmpty => root == null;
}

class OrgTree {
  final OrgNode root;

  const OrgTree(this.root);

  int get headcount => 1 + root.descendantCount;

  List<Employee> get everyone {
    final result = <Employee>[];
    void walk(OrgNode node) {
      result.add(node.employee);
      for (final child in node.children) {
        walk(child);
      }
    }

    walk(root);
    return result;
  }

  OrgNode? findNode(String id) {
    OrgNode? search(OrgNode node) {
      if (node.id == id) return node;
      for (final child in node.children) {
        final found = search(child);
        if (found != null) return found;
      }
      return null;
    }

    return search(root);
  }

  /// Root → node, inclusive. Used for the reporting-line breadcrumb and to
  /// auto-expand the branch that contains a search hit.
  List<Employee> pathTo(String id) {
    final path = <Employee>[];

    bool search(OrgNode node) {
      path.add(node.employee);
      if (node.id == id) return true;
      for (final child in node.children) {
        if (search(child)) return true;
      }
      path.removeLast();
      return false;
    }

    return search(root) ? path : const [];
  }

  /// Peers a detail sheet can swipe between: the manager's other reports,
  /// or the person's own reports when they are the root.
  List<Employee> peersOf(String id) {
    List<Employee>? search(OrgNode node) {
      for (final child in node.children) {
        if (child.id == id) {
          return node.children.map((c) => c.employee).toList();
        }
        final found = search(child);
        if (found != null) return found;
      }
      return null;
    }

    if (root.id == id) {
      return [root.employee, ...root.children.map((c) => c.employee)];
    }
    return search(root) ?? [root.employee];
  }

  FilteredOrg applyFilter(DirectoryFilter filter) {
    if (filter.isEmpty) {
      return FilteredOrg(
        root: root,
        matchedIds: const {},
        ancestorIds: const {},
      );
    }

    final matched = <String>{};
    final ancestors = <String>{};

    OrgNode? prune(OrgNode node) {
      final keptChildren = <OrgNode>[];
      for (final child in node.children) {
        final kept = prune(child);
        if (kept != null) keptChildren.add(kept);
      }

      final selfMatches = filter.matches(node.employee);
      if (selfMatches) matched.add(node.id);

      if (selfMatches || keptChildren.isNotEmpty) {
        if (!selfMatches) ancestors.add(node.id);
        return OrgNode(employee: node.employee, children: keptChildren);
      }
      return null;
    }

    return FilteredOrg(
      root: prune(root),
      matchedIds: matched,
      ancestorIds: ancestors,
    );
  }
}
