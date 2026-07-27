import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../bloc/directory_bloc.dart';
import '../theme/directory_tokens.dart';

/// Search + facets + view mode. Unlike the original bar, the field is bound to
/// a controller and every keystroke reaches the bloc.
class DirectoryTopBar extends StatelessWidget {
  final TextEditingController controller;
  final int matchCount;
  final int headcount;
  final bool isFiltering;
  final int activeFilterCount;
  final DirectoryViewMode viewMode;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onClearFilters;
  final ValueChanged<DirectoryViewMode> onViewModeChanged;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;

  const DirectoryTopBar({
    super.key,
    required this.controller,
    required this.matchCount,
    required this.headcount,
    required this.isFiltering,
    required this.activeFilterCount,
    required this.viewMode,
    required this.onQueryChanged,
    required this.onFilterTap,
    required this.onClearFilters,
    required this.onViewModeChanged,
    required this.onExpandAll,
    required this.onCollapseAll,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 10,
            16,
            10,
          ),
          decoration: BoxDecoration(
            color: DirColors.canvas.withValues(alpha: 0.82),
            border: const Border(
              bottom: BorderSide(color: DirColors.hairline),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _searchField()),
                  const SizedBox(width: 10),
                  _filterButton(),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _viewToggle(),
                  const Spacer(),
                  if (viewMode == DirectoryViewMode.chart) ...[
                    _iconButton(
                      icon: Icons.unfold_more_rounded,
                      tooltip: 'Expand everything',
                      onTap: onExpandAll,
                    ),
                    const SizedBox(width: 6),
                    _iconButton(
                      icon: Icons.unfold_less_rounded,
                      tooltip: 'Collapse to the top',
                      onTap: onCollapseAll,
                    ),
                    const SizedBox(width: 10),
                  ],
                  _countPill(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField() => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: DirColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DirColors.hairline),
          boxShadow: DirShadows.soft(),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                size: 19, color: DirColors.inkFaint),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onQueryChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: DirColors.ink,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search name, role or location',
                  hintStyle: TextStyle(
                    color: DirColors.inkFaint,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clear();
                  onQueryChanged('');
                },
                child: const Icon(Icons.cancel_rounded,
                    size: 17, color: DirColors.inkFaint),
              ),
          ],
        ),
      );

  Widget _filterButton() => GestureDetector(
        onTap: onFilterTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: DirMotion.fast,
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: activeFilterCount > 0
                    ? DirColors.ink
                    : DirColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: activeFilterCount > 0
                      ? DirColors.ink
                      : DirColors.hairline,
                ),
                boxShadow: DirShadows.soft(),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: activeFilterCount > 0
                    ? Colors.white
                    : DirColors.inkBody,
              ),
            ),
            if (activeFilterCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: DirColors.brand,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DirColors.canvas, width: 2),
                  ),
                  child: Text(
                    '$activeFilterCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _viewToggle() => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: DirColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleTab(
              icon: Icons.account_tree_rounded,
              label: 'Chart',
              selected: viewMode == DirectoryViewMode.chart,
              onTap: () => onViewModeChanged(DirectoryViewMode.chart),
            ),
            _toggleTab(
              icon: Icons.view_list_rounded,
              label: 'List',
              selected: viewMode == DirectoryViewMode.list,
              onTap: () => onViewModeChanged(DirectoryViewMode.list),
            ),
          ],
        ),
      );

  Widget _toggleTab({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: DirMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? DirColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected ? DirShadows.soft() : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? DirColors.ink : DirColors.inkMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? DirColors.ink : DirColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) =>
      Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DirColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DirColors.hairline),
            ),
            child: Icon(icon, size: 17, color: DirColors.inkBody),
          ),
        ),
      );

  Widget _countPill() => GestureDetector(
        onTap: isFiltering ? onClearFilters : null,
        child: AnimatedContainer(
          duration: DirMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isFiltering ? DirColors.brandWash : DirColors.surface,
            borderRadius: BorderRadius.circular(DirRadius.chip),
            border: Border.all(
              color: isFiltering
                  ? DirColors.brand.withValues(alpha: 0.25)
                  : DirColors.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: DirMotion.fast,
                child: Text(
                  isFiltering
                      ? '$matchCount of $headcount'
                      : '$headcount people',
                  key: ValueKey('$matchCount-$isFiltering'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isFiltering
                        ? DirColors.brandDeep
                        : DirColors.inkBody,
                  ),
                ),
              ),
              if (isFiltering) ...[
                const SizedBox(width: 6),
                const Icon(Icons.close_rounded,
                    size: 13, color: DirColors.brandDeep),
              ],
            ],
          ),
        ),
      );
}
