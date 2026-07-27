part of 'directory_bloc.dart';

enum DirectoryStatus { initial, loading, ready }

enum DirectoryViewMode { chart, list }

class DirectoryState {
  final DirectoryStatus status;
  final OrgTree? tree;
  final FilteredOrg? filtered;
  final DirectoryFilter filter;
  final Set<String> expandedIds;
  final DirectoryViewMode viewMode;

  /// Whose detail sheet is open (null = none).
  final String? selectedId;

  /// One-shot request for the chart to animate to a node.
  final String? focusId;

  final List<Company> companies;
  final List<Department> departments;

  const DirectoryState({
    this.status = DirectoryStatus.initial,
    this.tree,
    this.filtered,
    this.filter = DirectoryFilter.empty,
    this.expandedIds = const {},
    this.viewMode = DirectoryViewMode.chart,
    this.selectedId,
    this.focusId,
    this.companies = const [],
    this.departments = const [],
  });

  int get headcount => tree?.headcount ?? 0;

  bool get isFiltering => !filter.isEmpty;

  OrgNode? get visibleRoot => isFiltering ? filtered?.root : tree?.root;

  Set<String> get matchedIds => filtered?.matchedIds ?? const {};

  int get matchCount => isFiltering ? (filtered?.matchCount ?? 0) : headcount;

  /// Matching people in reading order — backs the swipeable results carousel
  /// and the list view.
  List<Employee> get matches {
    final root = visibleRoot;
    if (root == null) return const [];
    final result = <Employee>[];
    void walk(OrgNode node) {
      if (!isFiltering || matchedIds.contains(node.id)) {
        result.add(node.employee);
      }
      for (final child in node.children) {
        walk(child);
      }
    }

    walk(root);
    return result;
  }

  Department? departmentOf(String id) {
    for (final department in departments) {
      if (department.id == id) return department;
    }
    return null;
  }

  Company? companyOf(String id) {
    for (final company in companies) {
      if (company.id == id) return company;
    }
    return null;
  }

  Employee? get selectedEmployee =>
      selectedId == null ? null : tree?.findNode(selectedId!)?.employee;

  DirectoryState copyWith({
    DirectoryStatus? status,
    OrgTree? tree,
    FilteredOrg? filtered,
    DirectoryFilter? filter,
    Set<String>? expandedIds,
    DirectoryViewMode? viewMode,
    String? selectedId,
    String? focusId,
    List<Company>? companies,
    List<Department>? departments,
    bool clearSelection = false,
    bool clearFocus = false,
  }) =>
      DirectoryState(
        status: status ?? this.status,
        tree: tree ?? this.tree,
        filtered: filtered ?? this.filtered,
        filter: filter ?? this.filter,
        expandedIds: expandedIds ?? this.expandedIds,
        viewMode: viewMode ?? this.viewMode,
        selectedId: clearSelection ? null : (selectedId ?? this.selectedId),
        focusId: clearFocus ? null : (focusId ?? this.focusId),
        companies: companies ?? this.companies,
        departments: departments ?? this.departments,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryState &&
          other.status == status &&
          other.tree == tree &&
          other.filtered == filtered &&
          other.filter == filter &&
          other.expandedIds == expandedIds &&
          other.viewMode == viewMode &&
          other.selectedId == selectedId &&
          other.focusId == focusId &&
          other.companies == companies &&
          other.departments == departments;

  @override
  int get hashCode => Object.hash(
        status,
        tree,
        filtered,
        filter,
        expandedIds,
        viewMode,
        selectedId,
        focusId,
        companies,
        departments,
      );
}
