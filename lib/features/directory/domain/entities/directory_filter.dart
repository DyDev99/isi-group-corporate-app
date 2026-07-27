import 'employee.dart';

/// Immutable filter state. The original screen's `FilterBottomSheet` kept this
/// in widget `setState` and threw the result away in a `debugPrint`; here it is
/// a value object the bloc owns and the whole screen reacts to.
class DirectoryFilter {
  final String query;
  final String? companyId;
  final Set<String> departmentIds;
  final Set<PresenceStatus> statuses;

  const DirectoryFilter({
    this.query = '',
    this.companyId,
    this.departmentIds = const {},
    this.statuses = const {},
  });

  static const DirectoryFilter empty = DirectoryFilter();

  bool get isEmpty =>
      query.trim().isEmpty &&
      companyId == null &&
      departmentIds.isEmpty &&
      statuses.isEmpty;

  /// Number of active facets, shown as the badge on the filter button.
  int get activeCount =>
      (companyId == null ? 0 : 1) + departmentIds.length + statuses.length;

  bool matches(Employee employee) {
    if (companyId != null && employee.companyId != companyId) return false;
    if (departmentIds.isNotEmpty &&
        !departmentIds.contains(employee.departmentId)) {
      return false;
    }
    if (statuses.isNotEmpty && !statuses.contains(employee.status)) {
      return false;
    }
    return employee.matchesQuery(query);
  }

  DirectoryFilter copyWith({
    String? query,
    String? companyId,
    Set<String>? departmentIds,
    Set<PresenceStatus>? statuses,
    bool clearCompany = false,
  }) =>
      DirectoryFilter(
        query: query ?? this.query,
        companyId: clearCompany ? null : (companyId ?? this.companyId),
        departmentIds: departmentIds ?? this.departmentIds,
        statuses: statuses ?? this.statuses,
      );

  DirectoryFilter toggleDepartment(String id) {
    final next = Set<String>.from(departmentIds);
    next.contains(id) ? next.remove(id) : next.add(id);
    return copyWith(departmentIds: next);
  }

  DirectoryFilter toggleStatus(PresenceStatus status) {
    final next = Set<PresenceStatus>.from(statuses);
    next.contains(status) ? next.remove(status) : next.add(status);
    return copyWith(statuses: next);
  }

  /// Clears the facets but keeps whatever is typed in the search field.
  DirectoryFilter clearedFacets() => DirectoryFilter(query: query);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryFilter &&
          other.query == query &&
          other.companyId == companyId &&
          other.departmentIds.length == departmentIds.length &&
          other.departmentIds.containsAll(departmentIds) &&
          other.statuses.length == statuses.length &&
          other.statuses.containsAll(statuses);

  @override
  int get hashCode => Object.hash(
        query,
        companyId,
        Object.hashAllUnordered(departmentIds),
        Object.hashAllUnordered(statuses),
      );
}
