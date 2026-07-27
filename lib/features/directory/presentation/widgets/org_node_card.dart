import 'package:flutter/material.dart';

import '../../domain/entities/employee.dart';
import '../layout/org_layout.dart';
import '../theme/directory_tokens.dart';
import 'employee_avatar.dart';

/// One person in the chart. Fixed size (`OrgMetrics`) so the layout solver can
/// place it exactly.
///
/// The original card hid its mail/call actions behind `MouseRegion` hover —
/// unreachable on a phone. Actions now live on tap (detail sheet) and
/// long-press (quick menu), and the reports pill is the expand control.
class OrgNodeCard extends StatelessWidget {
  final Employee employee;
  final Department? department;
  final Company? company;
  final int directReports;
  final bool expanded;
  final bool isSelected;
  final bool isMatch;
  final bool isDimmed;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  const OrgNodeCard({
    super.key,
    required this.employee,
    required this.department,
    required this.company,
    required this.directReports,
    required this.expanded,
    required this.isSelected,
    required this.isMatch,
    required this.isDimmed,
    required this.onTap,
    required this.onToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final accent = DirColors.accent(department?.accent ?? 1);
    final borderColor = isSelected
        ? accent
        : isMatch
            ? accent.withValues(alpha: 0.5)
            : DirColors.hairline;

    return AnimatedOpacity(
      duration: DirMotion.base,
      opacity: isDimmed ? 0.45 : 1,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: DirMotion.base,
          curve: DirMotion.settle,
          width: OrgMetrics.nodeWidth,
          height: OrgMetrics.nodeHeight,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: DirColors.surface,
            borderRadius: BorderRadius.circular(DirRadius.card),
            border: Border.all(
              color: borderColor,
              width: isSelected || isMatch ? 1.6 : 1,
            ),
            boxShadow: isSelected || isMatch
                ? DirShadows.focus(accent)
                : DirShadows.soft(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(employee: employee, accent: accent),
                  const Spacer(),
                  if (department != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(department!.emoji,
                              style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(
                            department!.name,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                employee.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: DirColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                employee.role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 11, color: DirColors.inkFaint),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      '${employee.location} · ${company?.name ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: DirColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  if (directReports > 0)
                    _ReportsPill(
                      count: directReports,
                      expanded: expanded,
                      accent: accent,
                      onTap: onToggle,
                    )
                  else
                    const _LeafTag(),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: DirColors.inkFaint.withValues(alpha: 0.9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Employee employee;
  final Color accent;

  const _Avatar({required this.employee, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          EmployeeAvatar(
            employee: employee,
            accent: accent,
            size: 44,
            radius: 14,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: DirColors.presence(employee.status),
                shape: BoxShape.circle,
                border: Border.all(color: DirColors.surface, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsPill extends StatelessWidget {
  final int count;
  final bool expanded;
  final Color accent;
  final VoidCallback onTap;

  const _ReportsPill({
    required this.count,
    required this.expanded,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: DirMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: expanded ? accent : accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              size: 13,
              color: expanded ? Colors.white : accent,
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: expanded ? Colors.white : accent,
              ),
            ),
            const SizedBox(width: 2),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: DirMotion.base,
              curve: DirMotion.settle,
              child: Icon(
                Icons.expand_more_rounded,
                size: 14,
                color: expanded ? Colors.white : accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeafTag extends StatelessWidget {
  const _LeafTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: DirColors.surfaceMuted,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        'No reports',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: DirColors.inkFaint,
        ),
      ),
    );
  }
}
