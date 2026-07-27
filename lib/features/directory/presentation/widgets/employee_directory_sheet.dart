import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/employee.dart';
import '../../domain/entities/org_tree.dart';
import '../theme/directory_tokens.dart';
import 'employee_avatar.dart';

/// Profile sheet. Swipe left/right to move through the person's teammates
/// (their manager's other reports) without going back to the chart.
Future<void> showEmployeeSheet({
  required BuildContext context,
  required OrgTree tree,
  required Employee employee,
  required Department? Function(String departmentId) departmentOf,
  required Company? Function(String companyId) companyOf,
  required void Function(String employeeId) onShowInChart,
}) {
  final peers = tree.peersOf(employee.id);
  final initialIndex = peers.indexWhere((p) => p.id == employee.id);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: DirColors.ink.withValues(alpha: 0.45),
    builder: (_) => _EmployeeSheet(
      tree: tree,
      peers: peers.isEmpty ? [employee] : peers,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
      departmentOf: departmentOf,
      companyOf: companyOf,
      onShowInChart: onShowInChart,
    ),
  );
}

class _EmployeeSheet extends StatefulWidget {
  final OrgTree tree;
  final List<Employee> peers;
  final int initialIndex;
  final Department? Function(String departmentId) departmentOf;
  final Company? Function(String companyId) companyOf;
  final void Function(String employeeId) onShowInChart;

  const _EmployeeSheet({
    required this.tree,
    required this.peers,
    required this.initialIndex,
    required this.departmentOf,
    required this.companyOf,
    required this.onShowInChart,
  });

  @override
  State<_EmployeeSheet> createState() => _EmployeeSheetState();
}

class _EmployeeSheetState extends State<_EmployeeSheet> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
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

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Container(
        decoration: const BoxDecoration(
          color: DirColors.canvas,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(DirRadius.sheet)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: DirColors.connector,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            if (widget.peers.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.swipe_rounded,
                        size: 13, color: DirColors.inkFaint),
                    const SizedBox(width: 6),
                    Text(
                      'Swipe for teammates · ${_index + 1} of ${widget.peers.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DirColors.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _index = index),
                itemCount: widget.peers.length,
                itemBuilder: (context, index) =>
                    _profile(widget.peers[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profile(Employee employee) {
    final department = widget.departmentOf(employee.departmentId);
    final company = widget.companyOf(employee.companyId);
    final accent = DirColors.accent(department?.accent ?? 1);
    final node = widget.tree.findNode(employee.id);
    final reportingLine = widget.tree.pathTo(employee.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DirColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: DirColors.hairline),
            boxShadow: DirShadows.soft(),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  EmployeeAvatar(
                    employee: employee,
                    accent: accent,
                    size: 78,
                    radius: 24,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: DirColors.presence(employee.status),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: DirColors.surface, width: 3.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                employee.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: DirColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                employee.role,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (department != null)
                    _tag('${department.emoji} ${department.name}', accent),
                  if (company != null) _tag(company.name, DirColors.inkMuted),
                  _tag(employee.status.label,
                      DirColors.presence(employee.status)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _actionButton(
                    icon: Icons.call_rounded,
                    label: 'Call',
                    color: DirColors.online,
                    onTap: () => _toast('Calling ${employee.name}…'),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    color: DirColors.brand,
                    onTap: () => _toast('Composing to ${employee.email}'),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Message',
                    color: DirColors.accent(4),
                    onTap: () => _toast('Opening chat with ${employee.name}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          title: 'Contact',
          child: Column(
            children: [
              _infoRow(
                icon: Icons.alternate_email_rounded,
                label: 'Email',
                value: employee.email,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: employee.email));
                  _toast('Email copied');
                },
              ),
              _infoRow(
                icon: Icons.phone_iphone_rounded,
                label: 'Phone',
                value: employee.phone,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: employee.phone));
                  _toast('Phone copied');
                },
              ),
              _infoRow(
                icon: Icons.place_outlined,
                label: 'Based in',
                value: employee.location,
              ),
              _infoRow(
                icon: Icons.badge_outlined,
                label: 'Joined',
                value: _formatJoined(employee.joinedAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          title: 'Reporting line',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < reportingLine.length; i++) ...[
                  if (i != 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.chevron_right_rounded,
                          size: 16, color: DirColors.inkFaint),
                    ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onShowInChart(reportingLine[i].id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: i == reportingLine.length - 1
                            ? DirColors.brandWash
                            : DirColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(DirRadius.chip),
                      ),
                      child: Text(
                        reportingLine[i].name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: i == reportingLine.length - 1
                              ? DirColors.brandDeep
                              : DirColors.inkBody,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (node != null && node.hasChildren) ...[
          const SizedBox(height: 16),
          _card(
            title: 'Direct reports · ${node.directReports}',
            child: Column(
              children: [
                for (final child in node.children)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onShowInChart(child.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          EmployeeAvatar(
                            employee: child.employee,
                            accent: DirColors.accent(
                              widget
                                      .departmentOf(child.employee.departmentId)
                                      ?.accent ??
                                  1,
                            ),
                            size: 34,
                            radius: 11,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.employee.name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: DirColors.ink,
                                  ),
                                ),
                                Text(
                                  child.employee.role,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: DirColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: DirColors.inkFaint),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            widget.onShowInChart(employee.id);
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: DirColors.ink,
              borderRadius: BorderRadius.circular(16),
              boxShadow: DirShadows.soft(),
            ),
            child: const Center(
              child: Text(
                'Show in org chart',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(DirRadius.chip),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _card({required String title, required Widget child}) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: DirColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DirColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: DirColors.inkMuted,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: DirColors.inkFaint),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DirColors.inkMuted,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: DirColors.ink,
                ),
              ),
            ),
            if (onCopy != null)
              GestureDetector(
                onTap: onCopy,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.copy_rounded,
                      size: 14, color: DirColors.inkFaint),
                ),
              ),
          ],
        ),
      );
}

String _formatJoined(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final years = DateTime(2026, 7, 24).difference(date).inDays ~/ 365;
  final tenure = years <= 0 ? 'under a year' : '$years yr${years == 1 ? '' : 's'}';
  return '${months[date.month - 1]} ${date.year} · $tenure';
}
