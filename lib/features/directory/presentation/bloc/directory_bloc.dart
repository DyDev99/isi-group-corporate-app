import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/directory_filter.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/org_tree.dart';
import '../../domain/usecases/directory_usecases.dart';

part 'directory_event.dart';
part 'directory_state.dart';

/// Owns every piece of directory logic: search, faceted filtering, expansion,
/// selection and view mode. Widgets render this state and dispatch events —
/// the original screen kept all of it in `setState` and dropped applied
/// filters into a `debugPrint`.
class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  final GetOrgTree _getOrgTree;
  final GetCompanies _getCompanies;
  final GetDepartments _getDepartments;

  DirectoryBloc({
    required GetOrgTree getOrgTree,
    required GetCompanies getCompanies,
    required GetDepartments getDepartments,
  })  : _getOrgTree = getOrgTree,
        _getCompanies = getCompanies,
        _getDepartments = getDepartments,
        super(const DirectoryState()) {
    on<DirectoryStarted>(_onStarted);
    on<DirectorySearchChanged>(_onSearchChanged);
    on<DirectoryFilterApplied>(_onFilterApplied);
    on<DirectoryFiltersCleared>(_onFiltersCleared);
    on<DirectoryNodeToggled>(_onNodeToggled);
    on<DirectoryNodeSelected>(_onNodeSelected);
    on<DirectoryViewModeChanged>(_onViewModeChanged);
    on<DirectoryBranchExpandedAll>(_onExpandedAll);
    on<DirectoryBranchCollapsedAll>(_onCollapsedAll);
    on<DirectoryFocusRequested>(_onFocusRequested);
    on<DirectoryFocusHandled>(_onFocusHandled);
  }

  Future<void> _onStarted(
    DirectoryStarted event,
    Emitter<DirectoryState> emit,
  ) async {
    emit(state.copyWith(status: DirectoryStatus.loading));

    final tree = await _getOrgTree();
    final companies = await _getCompanies();
    final departments = await _getDepartments();

    emit(state.copyWith(
      status: DirectoryStatus.ready,
      tree: tree,
      companies: companies,
      departments: departments,
      filtered: tree.applyFilter(DirectoryFilter.empty),
      // Open on the CEO plus their direct reports — deeper levels are a tap
      // away rather than an unreadable wall of cards.
      expandedIds: {tree.root.id},
    ));
  }

  void _onSearchChanged(
    DirectorySearchChanged event,
    Emitter<DirectoryState> emit,
  ) {
    _applyFilter(state.filter.copyWith(query: event.query), emit);
  }

  void _onFilterApplied(
    DirectoryFilterApplied event,
    Emitter<DirectoryState> emit,
  ) {
    _applyFilter(event.filter, emit);
  }

  void _onFiltersCleared(
    DirectoryFiltersCleared event,
    Emitter<DirectoryState> emit,
  ) {
    _applyFilter(state.filter.clearedFacets(), emit);
  }

  /// Recomputes the pruned tree and opens exactly the branches needed to show
  /// every hit — a match five levels down is useless if it stays collapsed.
  void _applyFilter(DirectoryFilter filter, Emitter<DirectoryState> emit) {
    final tree = state.tree;
    if (tree == null) return;

    final filtered = tree.applyFilter(filter);

    final expanded = filter.isEmpty
        ? {tree.root.id}
        : _allNodeIds(filtered.root);

    emit(state.copyWith(
      filter: filter,
      filtered: filtered,
      expandedIds: expanded,
      clearFocus: true,
    ));
  }

  Set<String> _allNodeIds(OrgNode? node) {
    if (node == null) return const {};
    final ids = <String>{};
    void walk(OrgNode current) {
      ids.add(current.id);
      for (final child in current.children) {
        walk(child);
      }
    }

    walk(node);
    return ids;
  }

  void _onNodeToggled(
    DirectoryNodeToggled event,
    Emitter<DirectoryState> emit,
  ) {
    final next = Set<String>.from(state.expandedIds);
    if (!next.remove(event.nodeId)) next.add(event.nodeId);
    emit(state.copyWith(expandedIds: next));
  }

  void _onNodeSelected(
    DirectoryNodeSelected event,
    Emitter<DirectoryState> emit,
  ) {
    if (event.nodeId == null) {
      emit(state.copyWith(clearSelection: true));
      return;
    }
    emit(state.copyWith(selectedId: event.nodeId));
  }

  void _onViewModeChanged(
    DirectoryViewModeChanged event,
    Emitter<DirectoryState> emit,
  ) {
    emit(state.copyWith(viewMode: event.mode));
  }

  void _onExpandedAll(
    DirectoryBranchExpandedAll event,
    Emitter<DirectoryState> emit,
  ) {
    emit(state.copyWith(expandedIds: _allNodeIds(state.visibleRoot)));
  }

  void _onCollapsedAll(
    DirectoryBranchCollapsedAll event,
    Emitter<DirectoryState> emit,
  ) {
    final root = state.visibleRoot;
    emit(state.copyWith(expandedIds: root == null ? <String>{} : {root.id}));
  }

  void _onFocusRequested(
    DirectoryFocusRequested event,
    Emitter<DirectoryState> emit,
  ) {
    // Make sure the branch containing the target is open before centring.
    final tree = state.tree;
    final expanded = Set<String>.from(state.expandedIds);
    if (tree != null) {
      for (final ancestor in tree.pathTo(event.nodeId)) {
        expanded.add(ancestor.id);
      }
    }
    emit(state.copyWith(expandedIds: expanded, focusId: event.nodeId));
  }

  void _onFocusHandled(
    DirectoryFocusHandled event,
    Emitter<DirectoryState> emit,
  ) {
    emit(state.copyWith(clearFocus: true));
  }
}
