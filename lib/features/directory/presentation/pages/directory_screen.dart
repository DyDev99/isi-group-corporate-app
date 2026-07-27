import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/employee.dart';
import '../../domain/entities/directory_filter.dart';
import '../bloc/directory_bloc.dart';
import '../theme/directory_tokens.dart';
import '../widgets/directory_top_bar.dart';
import '../widgets/employee_directory_sheet.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/match_carousel.dart';
import '../widgets/org_chart_canvas.dart';
import '../widgets/people_list_view.dart';

/// Gesture map:
///   • pinch / double-tap / ± buttons → zoom the chart (25% – 250%)
///   • drag                           → pan; "fit" recentres everything
///   • tap a card                     → profile sheet
///   • swipe inside the profile sheet → move through teammates
///   • long-press a card              → quick actions
///   • tap the reports pill           → expand or collapse that branch
///   • swipe a list row               → right to call, left to email
///   • swipe the results carousel     → chart pans to each hit
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: DirColors.ink,
          duration: const Duration(seconds: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _openProfile(BuildContext context, DirectoryState state, String id) {
    final tree = state.tree;
    final employee = tree?.findNode(id)?.employee;
    if (tree == null || employee == null) return;

    final bloc = context.read<DirectoryBloc>();
    bloc.add(DirectoryNodeSelected(id));

    showEmployeeSheet(
      context: context,
      tree: tree,
      employee: employee,
      departmentOf: state.departmentOf,
      companyOf: state.companyOf,
      onShowInChart: (targetId) {
        bloc
          ..add(const DirectoryViewModeChanged(DirectoryViewMode.chart))
          ..add(DirectoryFocusRequested(targetId));
      },
    ).then((_) => bloc.add(const DirectoryNodeSelected(null)));
  }

  Future<void> _openFilters(
    BuildContext context,
    DirectoryState state,
  ) async {
    final tree = state.tree;
    if (tree == null) return;
    final bloc = context.read<DirectoryBloc>();

    final result = await showDirectoryFilterSheet(
      context: context,
      current: state.filter,
      tree: tree,
      companies: state.companies,
      departments: state.departments,
    );

    if (result != null) bloc.add(DirectoryFilterApplied(result));
  }

  Future<void> _openQuickActions(
    BuildContext context,
    DirectoryState state,
    String id,
  ) async {
    final node = state.tree?.findNode(id);
    if (node == null) return;
    final employee = node.employee;
    final bloc = context.read<DirectoryBloc>();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: DirColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DirRadius.sheet)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: DirColors.connector,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              employee.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: DirColors.ink,
              ),
            ),
            Text(
              employee.role,
              style: const TextStyle(fontSize: 12.5, color: DirColors.inkMuted),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.call_rounded, color: DirColors.online),
              title: const Text('Call'),
              subtitle: Text(employee.phone),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _toast('Calling ${employee.name}…');
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline_rounded,
                  color: DirColors.brand),
              title: const Text('Email'),
              subtitle: Text(employee.email),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _toast('Composing to ${employee.email}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: DirColors.inkBody),
              title: const Text('Copy contact details'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Clipboard.setData(ClipboardData(
                  text: '${employee.name}\n${employee.role}\n'
                      '${employee.email}\n${employee.phone}',
                ));
                _toast('Contact copied');
              },
            ),
            if (node.hasChildren)
              ListTile(
                leading: const Icon(Icons.account_tree_rounded,
                    color: DirColors.inkBody),
                title: Text(
                  state.expandedIds.contains(id)
                      ? 'Collapse ${node.directReports} reports'
                      : 'Expand ${node.directReports} reports',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  bloc.add(DirectoryNodeToggled(id));
                },
              ),
            ListTile(
              leading: const Icon(Icons.my_location_rounded,
                  color: DirColors.inkBody),
              title: const Text('Centre in chart'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                bloc
                  ..add(const DirectoryViewModeChanged(DirectoryViewMode.chart))
                  ..add(DirectoryFocusRequested(id));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectoryBloc, DirectoryState>(
      builder: (context, state) {
        final bloc = context.read<DirectoryBloc>();
        final topInset = MediaQuery.of(context).padding.top + 118;

        return Scaffold(
          backgroundColor: DirColors.canvas,
          body: Stack(
            children: [
              // 1. Subtle Grid Pattern Background Layer
              const Positioned.fill(
                child: CleanGridBackground(),
              ),

              // 2. Main Content
              Positioned.fill(
                top: 0,
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: state.status != DirectoryStatus.ready
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: DirMotion.base,
                          switchInCurve: DirMotion.settle,
                          child: state.viewMode == DirectoryViewMode.chart
                              ? _chart(context, state)
                              : _list(context, state),
                        ),
                ),
              ),

              // 3. Top Navigation Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: DirectoryTopBar(
                  controller: _searchController,
                  matchCount: state.matchCount,
                  headcount: state.headcount,
                  isFiltering: state.isFiltering,
                  activeFilterCount: state.filter.activeCount,
                  viewMode: state.viewMode,
                  onQueryChanged: (value) =>
                      bloc.add(DirectorySearchChanged(value)),
                  onFilterTap: () => _openFilters(context, state),
                  onClearFilters: () {
                    _searchController.clear();
                    bloc.add(const DirectoryFilterApplied(
                        DirectoryFilter.empty));
                  },
                  onViewModeChanged: (mode) =>
                      bloc.add(DirectoryViewModeChanged(mode)),
                  onExpandAll: () =>
                      bloc.add(const DirectoryBranchExpandedAll()),
                  onCollapseAll: () =>
                      bloc.add(const DirectoryBranchCollapsedAll()),
                ),
              ),

              // 4. Match Carousel overlay when filtering
              if (state.isFiltering &&
                  state.viewMode == DirectoryViewMode.chart &&
                  state.matches.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                  child: MatchCarousel(
                    matches: state.matches,
                    departmentOf: state.departmentOf,
                    onFocus: (id) => bloc.add(DirectoryFocusRequested(id)),
                    onOpen: (id) => _openProfile(context, state, id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _chart(BuildContext context, DirectoryState state) {
    final bloc = context.read<DirectoryBloc>();

    return OrgChartCanvas(
      key: const ValueKey('chart'),
      root: state.visibleRoot,
      expandedIds: state.expandedIds,
      matchedIds: state.matchedIds,
      isFiltering: state.isFiltering,
      selectedId: state.selectedId,
      focusId: state.focusId,
      departmentOf: state.departmentOf,
      companyOf: state.companyOf,
      onToggle: (id) => bloc.add(DirectoryNodeToggled(id)),
      onOpen: (id) => _openProfile(context, state, id),
      onQuickActions: (id) => _openQuickActions(context, state, id),
      onFocusHandled: () => bloc.add(const DirectoryFocusHandled()),
    );
  }

  Widget _list(BuildContext context, DirectoryState state) {
    return PeopleListView(
      key: const ValueKey('list'),
      people: state.matches,
      departmentOf: state.departmentOf,
      companyOf: state.companyOf,
      onOpen: (id) => _openProfile(context, state, id),
      onCall: (Employee employee) => _toast('Calling ${employee.name}…'),
      onEmail: (Employee employee) =>
          _toast('Composing to ${employee.email}'),
    );
  }
}

// ============================================================================
// CLEAN GRID BACKGROUND PATTERN
// ============================================================================

class CleanGridBackground extends StatelessWidget {
  const CleanGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPatternPainter(),
      child: Container(),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFF6F8FA), BlendMode.srcOver);

    final Paint linePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSize = 24.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}