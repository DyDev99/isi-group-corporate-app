import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isi_group_corporate_app/core/auth/auth_guard.dart';
import 'package:isi_group_corporate_app/core/di/injection_container.dart';
import 'package:isi_group_corporate_app/core/localization/localized_builder.dart';

// Screens & Sheet Imports
import 'package:isi_group_corporate_app/features/directory/presentation/screens/directory_screen.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/hr_assistant_scope.dart';
import 'package:isi_group_corporate_app/features/hubs/presentation/bloc/cubit/resumable_visit_cubit.dart';
import 'package:isi_group_corporate_app/features/hubs/presentation/screens/hubs_screen.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:isi_group_corporate_app/features/time_attendance/presentation/screens/time_attendance_screen.dart';
import 'package:isi_group_corporate_app/features/leave_request/presentation/screens/leave_request_screen.dart';
import 'package:isi_group_corporate_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:isi_group_corporate_app/features/meeting_rooms/presentation/screens/meeting_rooms_screen.dart';
import 'package:isi_group_corporate_app/features/performance/presentation/screens/performance_screen.dart';
import 'package:isi_group_corporate_app/features/digital_docs/presentation/screens/digital_docs_screen.dart';
import 'package:isi_group_corporate_app/features/it_help/presentation/screens/it_help_screen.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/fast_actions/edit_fast_actions_bottom_sheet.dart';
import 'package:isi_group_corporate_app/features/travel/presentation/screens/travel_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Complete state with all 10 unique Fast Action tools
  List<FastActionTool> _userFastActions = [
    FastActionTool(id: 'leave', title: 'Apply Leave', icon: Icons.calendar_month_outlined, isEnabled: true),
    FastActionTool(id: 'expense', title: 'Expense', icon: Icons.receipt_long_outlined, isEnabled: true),
    FastActionTool(id: 'room', title: 'Book Room', icon: Icons.local_cafe_outlined, isEnabled: true),
    FastActionTool(id: 'it_help', title: 'IT Help', icon: Icons.support_outlined, isEnabled: true),
    FastActionTool(id: 'performance', title: 'Performance', icon: Icons.percent_rounded, isEnabled: true),
    FastActionTool(id: 'docs', title: 'Digital Docs', icon: Icons.description_outlined, isEnabled: true),
    FastActionTool(id: 'time_attendance', title: 'Attendance', icon: Icons.access_time_filled_outlined, isEnabled: true),
    FastActionTool(id: 'travel', title: 'Travel', icon: Icons.airplane_ticket_sharp, isEnabled: true),
  ];

  void _handleNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _openProfile(BuildContext context) async {
    final allowed = await AuthGuard.requireAuthentication(context);
    if (!allowed || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<ProfileCubit>(),
        child: LocalizedBuilder(builder: (_) => const ProfileScreen()),
      ),
    ));
  }

  void _onEditFastActions() {
    EditFastActionsBottomSheet.show(
      context,
      currentTools: _userFastActions,
      onSaved: (updatedTools) {
        setState(() {
          _userFastActions = List.from(updatedTools);
        });
      },
    );
  }

  void _navigateToTool(String toolId) {
    Widget? targetScreen;

    switch (toolId) {
      case 'leave':
        targetScreen = const LeaveRequestScreen();
        break;
      case 'expense':
        targetScreen = const ExpensesScreen();
        break;
      case 'room':
        targetScreen = const MeetingRoomsScreen();
        break;
      case 'it_help':
        targetScreen = const ITHelpScreen();
        break;
      case 'performance':
        targetScreen = const PerformanceScreen();
        break;
      case 'docs':
        targetScreen = const DigitalDocsScreen();
        break;
      case 'time_attendance':
        targetScreen = const TimeAttendanceScreen();
        break;
      case 'travel':
        targetScreen = const TravelScreen();
        break;
    }

    if (targetScreen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ResumableVisitCubit()..refresh()),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: _currentIndex == 1
              ? const AppHubScreen()
              : _currentIndex == 2
                  ? const HrAssistantScope()
                  : _currentIndex == 3
                      ? const DirectoryScreen()
                      : _currentIndex == 4
                          ? BlocProvider(
                              create: (_) => sl<ProfileCubit>(),
                              child: const ProfileScreen(),
                            )
                          : Stack(
                              children: [
                                // 1. Grid Background
                                const Positioned.fill(
                                  child: CleanGridBackground(),
                                ),

                                // 2. Header Gradient Card
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 220.h,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B3673),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(32.r),
                                        bottomRight: Radius.circular(32.r),
                                      ),
                                    ),
                                  ),
                                ),

                                // 3. Main Content
                                Positioned.fill(
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(top: 60.h, bottom: 120.h),
                                    children: [
                                      // Top Header User Info
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () => _openProfile(context),
                                                  child: CircleAvatar(
                                                    radius: 24.r,
                                                    backgroundColor: Colors.grey.shade800,
                                                    backgroundImage: const AssetImage('assets/images/avatar_placeholder.png'),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Good Morning,',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Sarah Jenkins',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20.sp,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: -0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(10.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.notifications_none_rounded,
                                                color: Colors.white,
                                                size: 24.sp,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 24.h),

                                      // Performance KPI Card
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: const UserPerformanceCardWidget(),
                                      ),

                                      SizedBox(height: 24.h),

                                      // SECTION 1: Dynamic Fast Actions
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Fast Actions',
                                              style: TextStyle(
                                                color: const Color(0xFF0F172A),
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _onEditFastActions,
                                              behavior: HitTestBehavior.opaque,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_outlined,
                                                    color: const Color(0xFF1B3673),
                                                    size: 16.sp,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                      color: const Color(0xFF1B3673),
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12.h),

                                      // Dynamic Fast Actions List
                                      FastActionsRow(
                                        tools: _userFastActions.where((tool) => tool.isEnabled).toList(),
                                        onToolTap: (toolId) => _navigateToTool(toolId),
                                      ),

                                      SizedBox(height: 24.h),

                                      // SECTION 2: Your Focus
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Your Focus',
                                              style: TextStyle(
                                                color: const Color(0xFF0F172A),
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.grid_view_rounded,
                                                  color: const Color(0xFF475569),
                                                  size: 16.sp,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  'Customize',
                                                  style: TextStyle(
                                                    color: const Color(0xFF475569),
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: const YourFocusGrid(),
                                      ),

                                      SizedBox(height: 24.h),

                                      // SECTION 3: Up Next
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: Text(
                                          'Up Next',
                                          style: TextStyle(
                                            color: const Color(0xFF0F172A),
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: const UpNextCard(),
                                      ),

                                      SizedBox(height: 16.h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleNavTap,
        ),
      ),
    );
  }
}

// ============================================================================
// DYNAMIC FAST ACTIONS ROW
// ============================================================================

class FastActionsRow extends StatelessWidget {
  final List<FastActionTool> tools;
  final Function(String toolId) onToolTap;

  const FastActionsRow({
    super.key,
    required this.tools,
    required this.onToolTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              'No fast actions enabled. Tap Edit to add tools.',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: tools.map((tool) {
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => onToolTap(tool.id),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68.r,
                    height: 68.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      tool.icon,
                      color: const Color(0xFF475569),
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    tool.title,
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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

// ============================================================================
// PERFORMANCE CARD WIDGET
// ============================================================================

class UserPerformanceCardWidget extends StatelessWidget {
  const UserPerformanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: const Color(0xFF2563EB),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Q3 Performance KPI',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'ON TRACK',
                      style: TextStyle(
                        color: const Color(0xFF15803D),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quarterly Target Completion',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '85%',
                style: TextStyle(
                  color: const Color(0xFF1B3673),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B3673)),
            ),
          ),
          SizedBox(height: 18.h),
          Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('18 / 20', 'Tasks Done'),
              _buildVerticalDivider(),
              _buildStatItem('94.5%', 'Quality Score'),
              _buildVerticalDivider(),
              _buildStatItem('4.9 ★', 'Peer Feedback'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24.h,
      width: 1.w,
      color: const Color(0xFFE2E8F0),
    );
  }
}

// ============================================================================
// YOUR FOCUS GRID
// ============================================================================

class YourFocusGrid extends StatelessWidget {
  const YourFocusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14.w,
      mainAxisSpacing: 14.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: [
        _buildFocusCard(
          context,
          icon: Icons.location_on_outlined,
          badgeText: 'CHECK IN',
          title: 'Attendance',
          value: 'Not Started',
          hasDot: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeAttendanceScreen())),
        ),
        _buildFocusCard(
          context,
          icon: Icons.calendar_today_outlined,
          badgeText: 'APPLY',
          title: 'Leave Balance',
          value: '12 Days',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen())),
        ),
        _buildFocusCard(
          context,
          icon: Icons.check_circle_outline_rounded,
          badgeText: 'REVIEW',
          title: 'Approvals',
          value: '3 Pending',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen())),
        ),
        _buildFocusCard(
          context,
          icon: Icons.description_outlined,
          badgeText: 'VIEW',
          title: 'Payslip',
          value: 'July Ready',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalDocsScreen())),
        ),
      ],
    );
  }

  Widget _buildFocusCard(
    BuildContext context, {
    required IconData icon,
    required String badgeText,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool hasDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF475569),
                    size: 20.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (hasDot) ...[
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      value,
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// UP NEXT CARD
// ============================================================================

class UpNextCard extends StatelessWidget {
  const UpNextCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'JUL',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '24',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q3 Planning Strategy',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: const Color(0xFF64748B),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '2:30 PM - 4:00 PM',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36.r,
            height: 36.r,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.north_east_rounded,
              color: const Color(0xFF475569),
              size: 18.sp,
            ),
          )
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM NAV BAR
// ============================================================================

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 24.h, left: 16.w, right: 16.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(Icons.home_outlined, 'Home', 0, currentIndex == 0),
                _buildNavItem(Icons.apps_rounded, 'Hub', 1, currentIndex == 1),
                SizedBox(width: 50.w),
                _buildNavItem(Icons.people_outline_rounded, 'Team', 3, currentIndex == 3),
                _buildNavItem(Icons.account_circle_outlined, 'Profile', 4, currentIndex == 4, hasDot: true),
              ],
            ),
          ),
          Positioned(
            bottom: 30.h,
            child: GestureDetector(
              onTap: () => onTap(2),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3673),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B3673).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isSelected, {bool hasDot = false}) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF1B3673) : const Color(0xFF64748B),
                  size: 28.sp,
                ),
                if (isSelected) ...[
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: TextStyle(
                      color: const Color(0xFF1B3673),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ]
              ],
            ),
            if (hasDot)
              Positioned(
                top: -2.h,
                right: 8.w,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}