import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isi_group_corporate_app/core/security/biometric/authentication_reason.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/sensitive_screen_guard.dart';

// --- ENUMS & MODELS ---
enum UserRole {
  staff('Staff Member', Icons.person_outline_rounded),
  manager('Manager', Icons.supervisor_account_rounded),
  hrbp('HRBP', Icons.badge_outlined),
  hr('HR Specialist', Icons.manage_accounts_outlined),
  headOfHr('Head of HR', Icons.verified_user_outlined),
  ceo('CEO', Icons.workspace_premium_rounded);

  final String label;
  final IconData icon;
  const UserRole(this.label, this.icon);

  bool get isApprover => this != UserRole.staff;
}

enum LeaveStatus { pending, approved, rejected }

class StaffLeaveRequest {
  final String id;
  final String staffName;
  final String staffRole;
  final String leaveType;
  final String dateRange;
  final int daysCount;
  final String reason;
  final bool hasAttachment;
  LeaveStatus status;

  StaffLeaveRequest({
    required this.id,
    required this.staffName,
    required this.staffRole,
    required this.leaveType,
    required this.dateRange,
    required this.daysCount,
    required this.reason,
    this.hasAttachment = false,
    this.status = LeaveStatus.pending,
  });
}

class LeaveQuota {
  final String title;
  final int remaining;
  final int total;
  final Color accentColor;
  final IconData icon;

  const LeaveQuota({
    required this.title,
    required this.remaining,
    required this.total,
    required this.accentColor,
    required this.icon,
  });
}

class AttachmentFile {
  final String name;
  final String size;
  final bool isImage;

  AttachmentFile({
    required this.name,
    required this.size,
    this.isImage = false,
  });
}

// --- MAIN SCREEN ---

/// Leave records and approvals — gated behind a fresh identity check.
///
/// Wrapping the screen (not the `Navigator.push` calls) means all three entry
/// points — the Hubs grid, the dashboard shortcut and the shell tab — are
/// covered by one gate that cannot be forgotten at a new call site.
class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SensitiveScreenGuard(
      reason: AuthenticationReason.viewSecureDocument,
      titleKey: 'profile.leave.title',
      descriptionKey: 'auth.biometric.gate.leave_body',
      child: _LeaveRequestView(),
    );
  }
}

class _LeaveRequestView extends StatefulWidget {
  const _LeaveRequestView();

  @override
  State<_LeaveRequestView> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<_LeaveRequestView> {
  // Reactive State
  UserRole _currentRole = UserRole.manager; // Default to Approver view
  LeaveStatus _filterStatus = LeaveStatus.pending;

  // Personal Quotas (Staff View)
  final List<LeaveQuota> _quotas = const [
    LeaveQuota(
      title: 'Annual',
      remaining: 12,
      total: 18,
      accentColor: Color(0xFF10B981),
      icon: Icons.beach_access_rounded,
    ),
    LeaveQuota(
      title: 'Sick',
      remaining: 5,
      total: 7,
      accentColor: Color(0xFF3B82F6),
      icon: Icons.health_and_safety_rounded,
    ),
    LeaveQuota(
      title: 'Casual',
      remaining: 3,
      total: 5,
      accentColor: Color(0xFFF59E0B),
      icon: Icons.time_to_leave_rounded,
    ),
  ];

  // Team Requests Data (Approver View)
  final List<StaffLeaveRequest> _teamRequests = [
    StaffLeaveRequest(
      id: 'REQ-001',
      staffName: 'Sophea Chan',
      staffRole: 'Mobile Developer',
      leaveType: 'Annual Leave',
      dateRange: 'Apr 28, 2026 - May 02, 2026',
      daysCount: 5,
      reason: 'Family vacation trip to Siem Reap.',
      hasAttachment: false,
      status: LeaveStatus.pending,
    ),
    StaffLeaveRequest(
      id: 'REQ-002',
      staffName: 'Vandeth Meng',
      staffRole: 'UI/UX Designer',
      leaveType: 'Sick Leave',
      dateRange: 'Apr 27, 2026',
      daysCount: 1,
      reason: 'High fever and doctor consultation.',
      hasAttachment: true,
      status: LeaveStatus.pending,
    ),
    StaffLeaveRequest(
      id: 'REQ-003',
      staffName: 'Dara Boun',
      staffRole: 'Backend Engineer',
      leaveType: 'Casual Leave',
      dateRange: 'Apr 20, 2026',
      daysCount: 1,
      reason: 'Personal home utility setup.',
      hasAttachment: false,
      status: LeaveStatus.approved,
    ),
    StaffLeaveRequest(
      id: 'REQ-004',
      staffName: 'Bona Rath',
      staffRole: 'QA Tester',
      leaveType: 'Annual Leave',
      dateRange: 'Apr 15, 2026 - Apr 18, 2026',
      daysCount: 4,
      reason: 'Urgent family emergency.',
      hasAttachment: true,
      status: LeaveStatus.rejected,
    ),
  ];

  void _updateRequestStatus(String reqId, LeaveStatus newStatus) {
    setState(() {
      final req = _teamRequests.firstWhere((r) => r.id == reqId);
      req.status = newStatus;
    });

    final actionText = newStatus == LeaveStatus.approved ? 'Approved' : 'Rejected';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request $reqId has been $actionText.'),
        backgroundColor: newStatus == LeaveStatus.approved
            ? const Color(0xFF059669)
            : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openApplyLeaveDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ApplyLeaveDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curve),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0F172A), size: 16),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Leave Management',
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _currentRole.isApprover
                  ? 'Approver Portal (${_currentRole.label})'
                  : 'Employee Portal',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ROLE SELECTOR SWITCHER BAR ---
            _buildRoleSwitcherBar(),

            SizedBox(height: 18.h),

            // --- REACTIVE VIEW SWITCHING ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentRole.isApprover
                  ? _buildApproverDashboard()
                  : _buildStaffDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  // Role Switcher Header
  Widget _buildRoleSwitcherBar() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz_rounded,
                      size: 16.sp, color: const Color(0xFF6366F1)),
                  SizedBox(width: 6.w),
                  Text(
                    "ACTIVE USER ROLE",
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _currentRole.isApprover
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _currentRole.isApprover ? "Management View" : "Personal View",
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: _currentRole.isApprover
                        ? const Color(0xFF4338CA)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: UserRole.values.map((role) {
                final isSelected = _currentRole == role;
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Icon(
                      role.icon,
                      size: 13.sp,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                    label: Text(role.label),
                    labelStyle: TextStyle(
                      fontSize: 10.sp,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                    selectedColor: const Color(0xFF1E1B4B),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    onSelected: (val) {
                      setState(() => _currentRole = role);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // STAFF VIEW DASHBOARD
  Widget _buildStaffDashboard() {
    return Column(
      key: const ValueKey("StaffView"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("LEAVE BALANCE"),
            Text(
              "2026 Quota",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: List.generate(_quotas.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == _quotas.length - 1 ? 0 : 8.w,
                ),
                child: _LeaveQuotaCard(quota: _quotas[index]),
              ),
            );
          }),
        ),
        SizedBox(height: 22.h),

        // Apply Leave Trigger Card
        Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFEEF2F6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.note_add_rounded,
                  color: const Color(0xFF4338CA),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Need Time Off?",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Submit a leave request for HR review.",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () => _openApplyLeaveDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1B4B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Apply Leave",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.add_rounded, size: 14.sp),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),
        _buildSectionHeader("MY RECENT REQUESTS"),
        SizedBox(height: 10.h),
        const _HistoryItem(
          title: "Annual Leave",
          dates: "Apr 10, 2026 - Apr 12, 2026 (3 Days)",
          status: "APPROVED",
          statusColor: Color(0xFF059669),
          statusBg: Color(0xFFECFDF5),
          hasAttachment: true,
        ),
        const _HistoryItem(
          title: "Sick Leave",
          dates: "Mar 22, 2026 (1 Day)",
          status: "APPROVED",
          statusColor: Color(0xFF059669),
          statusBg: Color(0xFFECFDF5),
          hasAttachment: false,
        ),
      ],
    );
  }

  // APPROVER / MANAGER / HR VIEW DASHBOARD
  Widget _buildApproverDashboard() {
    final pendingCount =
        _teamRequests.where((r) => r.status == LeaveStatus.pending).length;
    final approvedCount =
        _teamRequests.where((r) => r.status == LeaveStatus.approved).length;
    final rejectedCount =
        _teamRequests.where((r) => r.status == LeaveStatus.rejected).length;

    final filteredList =
        _teamRequests.where((r) => r.status == _filterStatus).toList();

    return Column(
      key: const ValueKey("ApproverView"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Approver Metrics Summary Row
        Row(
          children: [
            Expanded(
              child: _buildMetricMiniCard(
                "Pending",
                "$pendingCount",
                const Color(0xFFF59E0B),
                Icons.pending_actions_rounded,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildMetricMiniCard(
                "Approved",
                "$approvedCount",
                const Color(0xFF10B981),
                Icons.task_alt_rounded,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildMetricMiniCard(
                "Rejected",
                "$rejectedCount",
                const Color(0xFFEF4444),
                Icons.cancel_outlined,
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Status Filter Segmented Control
        _buildSectionHeader("STAFF LEAVE REQUESTS"),
        SizedBox(height: 10.h),

        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              _buildFilterTab("Pending ($pendingCount)", LeaveStatus.pending),
              _buildFilterTab("Approved ($approvedCount)", LeaveStatus.approved),
              _buildFilterTab("Rejected ($rejectedCount)", LeaveStatus.rejected),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // Filtered Request List
        if (filteredList.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 36.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEEF2F6)),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_rounded,
                    size: 32.sp, color: const Color(0xFFCBD5E1)),
                SizedBox(height: 8.h),
                Text(
                  "No ${_filterStatus.name} requests found.",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final request = filteredList[index];
              return _StaffRequestCard(
                request: request,
                onApprove: () =>
                    _updateRequestStatus(request.id, LeaveStatus.approved),
                onReject: () =>
                    _updateRequestStatus(request.id, LeaveStatus.rejected),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMetricMiniCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: color),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, LeaveStatus status) {
    final isSelected = _filterStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterStatus = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF64748B),
        letterSpacing: 0.8,
      ),
    );
  }
}

// --- STAFF REQUEST CARD FOR APPROVERS ---
class _StaffRequestCard extends StatelessWidget {
  final StaffLeaveRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _StaffRequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Staff Header
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  request.staffName.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4338CA),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.staffName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      request.staffRole,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  request.leaveType,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Date & Duration Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13.sp, color: const Color(0xFF4F46E5)),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    request.dateRange,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    "${request.daysCount} ${request.daysCount == 1 ? 'Day' : 'Days'}",
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Reason Text
          Text(
            request.reason,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF475569),
            ),
          ),

          if (request.hasAttachment) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.attach_file_rounded,
                    size: 12.sp, color: const Color(0xFF6366F1)),
                SizedBox(width: 4.w),
                Text(
                  "Attachment provided",
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 12.h),

          // Reactive Action Row
          if (request.status == LeaveStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: Icon(Icons.close_rounded,
                        size: 14.sp, color: const Color(0xFFEF4444)),
                    label: const Text("Reject"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      textStyle: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: Icon(Icons.check_rounded,
                        size: 14.sp, color: Colors.white),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      textStyle: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: request.status == LeaveStatus.approved
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  request.status == LeaveStatus.approved
                      ? "APPROVED"
                      : "REJECTED",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: request.status == LeaveStatus.approved
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- CLEAN LEAVE QUOTA CARD ---
class _LeaveQuotaCard extends StatelessWidget {
  final LeaveQuota quota;

  const _LeaveQuotaCard({required this.quota});

  @override
  Widget build(BuildContext context) {
    final double progressRatio =
        quota.total > 0 ? (quota.remaining / quota.total).clamp(0.0, 1.0) : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: quota.accentColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: quota.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(quota.icon, size: 14.sp, color: quota.accentColor),
              ),
              Text(
                '${(progressRatio * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            quota.title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${quota.remaining}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  height: 1,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '/${quota.total}d',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Stack(
            children: [
              Container(
                height: 5.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progressRatio,
                child: Container(
                  height: 5.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        quota.accentColor,
                        quota.accentColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- POP-UP DIALOG FOR LEAVE APPLICATION ---
class ApplyLeaveDialog extends StatefulWidget {
  const ApplyLeaveDialog({super.key});

  @override
  State<ApplyLeaveDialog> createState() => _ApplyLeaveDialogState();
}

class _ApplyLeaveDialogState extends State<ApplyLeaveDialog> {
  int _selectedTypeIndex = 0;
  DateTimeRange? _selectedDateRange;
  bool _isHalfDay = false;
  final TextEditingController _reasonController = TextEditingController();
  final List<AttachmentFile> _attachments = [];

  final List<Map<String, dynamic>> _leaveTypes = [
    {'name': 'Annual', 'icon': Icons.beach_access_outlined},
    {'name': 'Sick', 'icon': Icons.medical_services_outlined},
    {'name': 'Casual', 'icon': Icons.event_available_outlined},
    {'name': 'Unpaid', 'icon': Icons.money_off_outlined},
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _calculatedDays {
    if (_selectedDateRange == null) return 0;
    return _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E1B4B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _addAttachment(bool isImage) {
    setState(() {
      _attachments.add(
        AttachmentFile(
          name: isImage
              ? 'Medical_Doc_${_attachments.length + 1}.png'
              : 'Support_Doc_${_attachments.length + 1}.pdf',
          size: isImage ? '1.8 MB' : '420 KB',
          isImage: isImage,
        ),
      );
    });
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for Leave',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Fill out the form below',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEF2F6)),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("SELECT LEAVE TYPE"),
                    SizedBox(height: 10.h),
                    Row(
                      children: List.generate(_leaveTypes.length, (index) {
                        final isSelected = _selectedTypeIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTypeIndex = index),
                            child: AnimatedScale(
                              scale: isSelected ? 1.02 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                margin: EdgeInsets.only(
                                  right: index == _leaveTypes.length - 1
                                      ? 0
                                      : 6.w,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF1E1B4B),
                                            Color(0xFF312E81)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      _leaveTypes[index]['icon'] as IconData,
                                      size: 16.sp,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _leaveTypes[index]['name'] as String,
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader("DATE RANGE"),
                        if (_calculatedDays > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              "$_calculatedDays ${_calculatedDays == 1 ? 'Day' : 'Days'}",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => _selectDateRange(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: Color(0xFF4F46E5), size: 18),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                _selectedDateRange == null
                                    ? "Select leave dates..."
                                    : "${_selectedDateRange!.start.toString().split(' ')[0]} → ${_selectedDateRange!.end.toString().split(' ')[0]}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: _selectedDateRange == null
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: _selectedDateRange == null
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                color: const Color(0xFF64748B), size: 18.sp),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_filled_rounded,
                                  size: 15.sp, color: const Color(0xFF64748B)),
                              SizedBox(width: 8.w),
                              Text(
                                "Half-day application",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isHalfDay,
                            activeTrackColor: const Color(0xFF312E81),
                            activeThumbColor: Colors.white,
                            onChanged: (val) =>
                                setState(() => _isHalfDay = val),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSectionHeader("REASON FOR LEAVE"),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      maxLength: 250,
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: "State purpose for HR approval...",
                        hintStyle: TextStyle(
                            color: const Color(0xFF94A3B8), fontSize: 11.sp),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: EdgeInsets.all(12.r),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildSectionHeader("ATTACHMENTS & PROOF"),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _addAttachment(true),
                            icon:
                                const Icon(Icons.add_a_photo_rounded, size: 14),
                            label: const Text("Add Photo"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              textStyle: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _addAttachment(false),
                            icon: const Icon(Icons.picture_as_pdf_rounded,
                                size: 14),
                            label: const Text("Add Doc"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              textStyle: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: _attachments.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 10.h),
                              child: Column(
                                children: List.generate(
                                  _attachments.length,
                                  (index) => Container(
                                    margin: EdgeInsets.only(bottom: 6.h),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _attachments[index].isImage
                                              ? Icons.image_rounded
                                              : Icons.insert_drive_file_rounded,
                                          size: 14.sp,
                                          color: const Color(0xFF4F46E5),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            _attachments[index].name,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1E293B),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          _attachments[index].size,
                                          style: TextStyle(
                                              fontSize: 8.sp,
                                              color: const Color(0xFF64748B)),
                                        ),
                                        SizedBox(width: 6.w),
                                        GestureDetector(
                                          onTap: () => _removeAttachment(index),
                                          child: Icon(Icons.close_rounded,
                                              size: 14.sp,
                                              color: const Color(0xFFEF4444)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      height: 46.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Leave Application Submitted Successfully'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          "Submit Request",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF64748B),
        letterSpacing: 0.8,
      ),
    );
  }
}

// --- STAFF HISTORY ITEM WIDGET ---
class _HistoryItem extends StatelessWidget {
  final String title;
  final String dates;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final bool hasAttachment;

  const _HistoryItem({
    required this.title,
    required this.dates,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.hasAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.event_note_rounded,
                size: 16.sp, color: const Color(0xFF475569)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (hasAttachment) ...[
                      SizedBox(width: 6.w),
                      Icon(Icons.attach_file_rounded,
                          size: 12.sp, color: const Color(0xFF64748B)),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  dates,
                  style: TextStyle(
                      fontSize: 10.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: statusColor,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}