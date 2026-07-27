import 'package:flutter/material.dart';

import '../../domain/entities/employee.dart';
import '../theme/directory_tokens.dart';
import 'appear_once.dart';
import 'employee_avatar.dart';

/// Flat list of everyone currently matching, grouped by department.
/// Swipe a row right to call, left to email — the row springs back rather than
/// disappearing, because the action is a contact, not a delete.
class PeopleListView extends StatelessWidget {
  final List<Employee> people;
  final Department? Function(String departmentId) departmentOf;
  final Company? Function(String companyId) companyOf;
  final ValueChanged<String> onOpen;
  final ValueChanged<Employee> onCall;
  final ValueChanged<Employee> onEmail;

  const PeopleListView({
    super.key,
    required this.people,
    required this.departmentOf,
    required this.companyOf,
    required this.onOpen,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Nobody matches these filters.',
            style: TextStyle(fontSize: 13.5, color: DirColors.inkMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: people.length,
      itemBuilder: (context, index) {
        final employee = people[index];
        final department = departmentOf(employee.departmentId);
        final accent = DirColors.accent(department?.accent ?? 1);

        return AppearOnce(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Dismissible(
              key: ValueKey('row_${employee.id}'),
              background: _swipeBackground(
                alignment: Alignment.centerLeft,
                icon: Icons.call_rounded,
                label: 'Call',
                color: DirColors.online,
              ),
              secondaryBackground: _swipeBackground(
                alignment: Alignment.centerRight,
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                color: DirColors.brand,
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  onCall(employee);
                } else {
                  onEmail(employee);
                }
                return false;
              },
              child: _PersonRow(
                employee: employee,
                department: department,
                company: companyOf(employee.companyId),
                accent: accent,
                onTap: () => onOpen(employee.id),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required IconData icon,
    required String label,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: alignment,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      );
}

class _PersonRow extends StatelessWidget {
  final Employee employee;
  final Department? department;
  final Company? company;
  final Color accent;
  final VoidCallback onTap;

  const _PersonRow({
    required this.employee,
    required this.department,
    required this.company,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DirColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DirColors.hairline),
          boxShadow: DirShadows.soft(),
        ),
        child: Row(
          children: [
            _EmployeePhoto(
              employee: employee,
              accent: accent,
              size: 44,
              radius: 14,
              showPresence: true,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: DirColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (department != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: DirColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            department!.name,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: DirColors.inkMuted,
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${employee.location} · ${company?.name ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: DirColors.inkFaint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: DirColors.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _EmployeePhoto extends StatelessWidget {
  final Employee employee;
  final Color accent;
  final double size;
  final double radius;
  final bool showPresence;

  const _EmployeePhoto({
    required this.employee,
    required this.accent,
    required this.size,
    required this.radius,
    this.showPresence = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          EmployeeAvatar(
            employee: employee,
            accent: accent,
            size: size,
            radius: radius,
          ),
          if (showPresence)
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
