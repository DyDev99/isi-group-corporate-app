import 'package:flutter/material.dart';

import '../../domain/entities/directory_filter.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/org_tree.dart';
import '../theme/directory_tokens.dart';

/// Faceted filter over company, department and presence.
///
/// The original sheet kept its selection in widget state, showed a hardcoded
/// "1,243 Employees" preview, had two search fields that filtered nothing, and
/// handed the result to `debugPrint`. Every number here is computed from the
/// tree against the draft filter, and Apply returns it to the bloc.
Future<DirectoryFilter?> showDirectoryFilterSheet({
  required BuildContext context,
  required DirectoryFilter current,
  required OrgTree tree,
  required List<Company> companies,
  required List<Department> departments,
}) {
  return showModalBottomSheet<DirectoryFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: DirColors.ink.withValues(alpha: 0.45),
    builder: (_) => _FilterSheet(
      current: current,
      tree: tree,
      companies: companies,
      departments: departments,
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  final DirectoryFilter current;
  final OrgTree tree;
  final List<Company> companies;
  final List<Department> departments;

  const _FilterSheet({
    required this.current,
    required this.tree,
    required this.companies,
    required this.departments,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DirectoryFilter _draft = widget.current;
  final TextEditingController _companySearch = TextEditingController();
  final TextEditingController _departmentSearch = TextEditingController();

  @override
  void dispose() {
    _companySearch.dispose();
    _departmentSearch.dispose();
    super.dispose();
  }

  int get _previewCount => widget.tree.applyFilter(_draft).matchCount;

  /// Headcount per company/department, so a facet that would return nothing is
  /// visible before it is tapped.
  int _countFor({String? companyId, String? departmentId}) {
    return widget.tree.everyone.where((employee) {
      if (companyId != null && employee.companyId != companyId) return false;
      if (departmentId != null && employee.departmentId != departmentId) {
        return false;
      }
      return true;
    }).length;
  }

  List<Company> get _visibleCompanies {
    final needle = _companySearch.text.trim().toLowerCase();
    if (needle.isEmpty) return widget.companies;
    return widget.companies
        .where((c) =>
            c.name.toLowerCase().contains(needle) ||
            c.tagline.toLowerCase().contains(needle))
        .toList();
  }

  List<Department> get _visibleDepartments {
    final needle = _departmentSearch.text.trim().toLowerCase();
    if (needle.isEmpty) return widget.departments;
    return widget.departments
        .where((d) => d.name.toLowerCase().contains(needle))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: const BoxDecoration(
          color: DirColors.canvas,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(DirRadius.sheet)),
        ),
        child: Column(
          children: [
            _grabber(),
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _activeChips(),
                  const SizedBox(height: 20),
                  _sectionTitle('Presence'),
                  const SizedBox(height: 10),
                  _statusRow(),
                  const SizedBox(height: 24),
                  _sectionTitle('Company'),
                  const SizedBox(height: 10),
                  _searchField(
                    controller: _companySearch,
                    hint: 'Search companies',
                  ),
                  const SizedBox(height: 12),
                  for (final company in _visibleCompanies) _companyTile(company),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _sectionTitle('Department'),
                      const Spacer(),
                      if (_draft.departmentIds.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: DirColors.brandWash,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '${_draft.departmentIds.length} selected',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: DirColors.brand,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _searchField(
                    controller: _departmentSearch,
                    hint: 'Search departments',
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      for (final department in _visibleDepartments)
                        _departmentTile(department),
                    ],
                  ),
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _grabber() => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        width: 46,
        height: 5,
        decoration: BoxDecoration(
          color: DirColors.connector,
          borderRadius: BorderRadius.circular(3),
        ),
      );

  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 14),
        decoration: const BoxDecoration(
          color: DirColors.surface,
          border: Border(bottom: BorderSide(color: DirColors.surfaceMuted)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter organization',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: DirColors.ink,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Narrow the chart by company, department or presence.',
                    style: TextStyle(fontSize: 12.5, color: DirColors.inkMuted),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _draft = _draft.clearedFacets()),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: DirColors.brand,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          color: DirColors.ink,
        ),
      );

  Widget _activeChips() {
    if (_draft.activeCount == 0) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DirColors.surfaceMuted.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DirColors.hairline),
        ),
        child: const Center(
          child: Text(
            'No filters applied — showing the whole organization.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: DirColors.inkMuted,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_draft.companyId != null)
          _chip(
            label: widget.companies
                .firstWhere((c) => c.id == _draft.companyId)
                .name,
            onRemove: () =>
                setState(() => _draft = _draft.copyWith(clearCompany: true)),
          ),
        for (final id in _draft.departmentIds)
          _chip(
            label: widget.departments.firstWhere((d) => d.id == id).name,
            onRemove: () =>
                setState(() => _draft = _draft.toggleDepartment(id)),
          ),
        for (final status in _draft.statuses)
          _chip(
            label: status.label,
            onRemove: () => setState(() => _draft = _draft.toggleStatus(status)),
          ),
      ],
    );
  }

  Widget _chip({required String label, required VoidCallback onRemove}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: DirColors.brandWash,
          borderRadius: BorderRadius.circular(DirRadius.chip),
          border: Border.all(color: DirColors.brand.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: DirColors.brandDeep,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 14, color: DirColors.brandDeep),
            ),
          ],
        ),
      );

  Widget _statusRow() => Row(
        children: [
          for (final status in PresenceStatus.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _draft = _draft.toggleStatus(status)),
                child: AnimatedContainer(
                  duration: DirMotion.fast,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _draft.statuses.contains(status)
                        ? DirColors.ink
                        : DirColors.surface,
                    borderRadius: BorderRadius.circular(DirRadius.chip),
                    border: Border.all(color: DirColors.hairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: DirColors.presence(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _draft.statuses.contains(status)
                              ? Colors.white
                              : DirColors.inkBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );

  Widget _searchField({
    required TextEditingController controller,
    required String hint,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: DirColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DirColors.hairline),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                size: 18, color: DirColors.inkFaint),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: DirColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: DirColors.inkFaint),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () => setState(controller.clear),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: DirColors.inkMuted),
              ),
          ],
        ),
      );

  Widget _companyTile(Company company) {
    final selected = _draft.companyId == company.id;
    final headcount = _countFor(companyId: company.id);

    return GestureDetector(
      onTap: () => setState(() {
        _draft = selected
            ? _draft.copyWith(clearCompany: true)
            : _draft.copyWith(companyId: company.id);
      }),
      child: AnimatedContainer(
        duration: DirMotion.fast,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? DirColors.brandWash : DirColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? DirColors.brand.withValues(alpha: 0.4)
                : DirColors.hairline,
          ),
        ),
        child: Row(
          children: [
            Text(company.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: DirColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${company.tagline} · $headcount in chart',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: DirColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: DirMotion.fast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? DirColors.brand : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? DirColors.brand : DirColors.hairline,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _departmentTile(Department department) {
    final selected = _draft.departmentIds.contains(department.id);
    final accent = DirColors.accent(department.accent);
    final headcount = _countFor(departmentId: department.id);

    return GestureDetector(
      onTap: () =>
          setState(() => _draft = _draft.toggleDepartment(department.id)),
      child: AnimatedContainer(
        duration: DirMotion.fast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? DirColors.ink : DirColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? DirColors.ink : DirColors.hairline,
          ),
          boxShadow: selected ? DirShadows.lifted() : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(department.emoji, style: const TextStyle(fontSize: 18)),
                AnimatedContainer(
                  duration: DirMotion.fast,
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: selected ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: selected ? accent : DirColors.connector,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : DirColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$headcount people',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? DirColors.inkFaint : DirColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    final count = _previewCount;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: DirColors.surface,
        border: const Border(top: BorderSide(color: DirColors.hairline)),
        boxShadow: DirShadows.lifted(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RESULTS PREVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: DirColors.inkMuted,
                ),
              ),
              AnimatedSwitcher(
                duration: DirMotion.fast,
                child: Text(
                  '$count of ${widget.tree.headcount} people',
                  key: ValueKey(count),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: count == 0 ? DirColors.danger : DirColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(_draft),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: DirColors.ink,
                borderRadius: BorderRadius.circular(16),
                boxShadow: DirShadows.soft(),
              ),
              child: Center(
                child: Text(
                  count == 0 ? 'Apply anyway' : 'Show $count people',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
