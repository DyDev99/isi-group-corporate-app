import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isi_group_corporate_app/core/auth/auth_guard.dart';
import 'package:isi_group_corporate_app/core/di/injection_container.dart';
import 'dart:math' as math;
import 'package:isi_group_corporate_app/core/localization/localized_builder.dart';
import 'package:isi_group_corporate_app/features/directory/presentation/bloc/directory_bloc.dart';
import 'package:isi_group_corporate_app/features/directory/presentation/pages/directory_screen.dart';

// Screens & Sheet Imports
import 'package:isi_group_corporate_app/features/hr_assistant/presentation/bloc/hr_chat_bloc.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/presentation/pages/hr_ai_assistant_screen.dart';
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
import 'package:isi_group_corporate_app/shared/widgets/appear_once.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  /// Drives the fade-through between tabs. Starts settled so the first frame
  /// after boot is not animated in from nothing.
  late final AnimationController _tabTransition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );

  @override
  void dispose() {
    _tabTransition.dispose();
    super.dispose();
  }

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

  /// Tabs the user has opened at least once. An IndexedStack keeps every
  /// child alive, so build a tab the first time it is shown rather than
  /// building all five on boot.
  final Set<int> _visitedTabs = {0};

  void _handleNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _visitedTabs.add(index);
    });
    _tabTransition.forward(from: 0);
  }

  Widget _tab(int index, Widget Function() build) =>
      _visitedTabs.contains(index) ? build() : const SizedBox.shrink();

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
        // Directory and HR Assistant blocs sit at shell level so filters,
        // expanded branches and chat history survive a tab switch. Both are
        // lazy — nothing is constructed until the tab is first opened.
        BlocProvider(
          create: (_) => sl<DirectoryBloc>()..add(const DirectoryStarted()),
        ),
        BlocProvider(
          create: (_) => sl<HrChatBloc>()..add(const HrChatStarted()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          // Fade-through between tabs. The IndexedStack keeps every tab alive,
          // so this animates the swap without discarding any tab's state.
          child: AnimatedBuilder(
            animation: _tabTransition,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(_tabTransition.value);
              return Opacity(
                opacity: 0.4 + 0.6 * t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 14),
                  child: Transform.scale(
                    scale: 0.985 + 0.015 * t,
                    child: child,
                  ),
                ),
              );
            },
            child: IndexedStack(
              index: _currentIndex,
              sizing: StackFit.expand,
              children: [
                _tab(0, () => _buildHomeTab(context)),
                _tab(1, () => const AppHubScreen()),
                _tab(2, () => const HrAiAssistantScreen()),
                _tab(3, () => const DirectoryScreen()),
                _tab(
                  4,
                  () => BlocProvider(
                    create: (_) => sl<ProfileCubit>(),
                    child: const ProfileScreen(),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleNavTap,
        ),
      ),
    );
  }

  /// Wraps each dashboard section in a staggered entrance. Spacers are left
  /// alone so the delay steps track visible sections, not gaps.
  List<Widget> _stagger(List<Widget> sections) {
    var step = 0;
    return [
      for (final section in sections)
        if (section is SizedBox)
          section
        else
          AppearOnce(index: step++, child: section),
    ];
  }

  /// The dashboard tab. Extracted from the old nested ternary so the body
  /// can be an IndexedStack — tabs keep their state instead of being rebuilt
  /// from scratch on every switch.
  Widget _buildHomeTab(BuildContext context) {
    return Stack(
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
            children: _stagger([
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
            ]),
          ),
        ),
      ],
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
  final VoidCallback? onTap;
  final double progress; // Range 0.0 to 1.0 (e.g., 0.85 for 85%)

  const UserPerformanceCardWidget({
    super.key,
    this.onTap,
    this.progress = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            // Replace with your Performance Screen route navigation
            // Navigator.push(context, MaterialPageRoute(builder: (_) => const PerformanceScreen()));
          },
      child: Container(
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
            // Header Row
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
            SizedBox(height: 16.h),

            // Target Text + Percentage
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
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: const Color(0xFF6D28D9),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Screenshot Gauge Progress Indicator
            Center(
              child: SizedBox(
                height: 110.h,
                width: 200.w,
                child: CustomPaint(
                  painter: DashboardGaugePainter(
                    progress: progress,
                    activeColor: const Color(0xFF7C3AED),
                    inactiveColor: const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 14.h),
            Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
            SizedBox(height: 14.h),

            // Bottom Metrics
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

// ── Custom Painter for the Speedometer Ticks & Arrow ─────────────────────

class DashboardGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  DashboardGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final outerRadius = math.min(size.width / 2, size.height * 0.9);
    const totalTicks = 45;
    const startAngle = math.pi; // 180°
    const sweepAngle = math.pi; // 180° arch

    // 1. Draw dashed radial ticks around the arc
    for (int i = 0; i < totalTicks; i++) {
      final tickPercent = i / (totalTicks - 1);
      final angle = startAngle + (tickPercent * sweepAngle);
      final isFilled = tickPercent <= progress;

      final paint = Paint()
        ..color = isFilled ? activeColor : inactiveColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final innerR = outerRadius - 14;
      final outerR = outerRadius;

      final x1 = center.dx + innerR * math.cos(angle);
      final y1 = center.dy + innerR * math.sin(angle);
      final x2 = center.dx + outerR * math.cos(angle);
      final y2 = center.dy + outerR * math.sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // 2. Draw 3D Pointer Arrow in the center pointing to current progress
    final pointerAngle = startAngle + (progress * sweepAngle);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pointerAngle + (math.pi / 2)); // Align arrow head upward

    final pointerLength = outerRadius * 0.58;

    // Pointer shadow / back depth
    final shadowPaint = Paint()
      ..color = const Color(0xFF4C1D95)
      ..style = PaintingStyle.fill;

    final shadowPath = Path()
      ..moveTo(2, -pointerLength + 2)
      ..lineTo(-12 + 2, 2)
      ..lineTo(-5 + 2, 2)
      ..lineTo(-5 + 2, 14)
      ..lineTo(5 + 2, 14)
      ..lineTo(5 + 2, 2)
      ..lineTo(12 + 2, 2)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Pointer body
    final arrowPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(0, -pointerLength)
      ..lineTo(-12, 0)
      ..lineTo(-5, 0)
      ..lineTo(-5, 12)
      ..lineTo(5, 12)
      ..lineTo(5, 0)
      ..lineTo(12, 0)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DashboardGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
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
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.apps_outlined,
                  activeIcon: Icons.apps_rounded,
                  label: 'Hub',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                SizedBox(width: 50.w),
                _NavItem(
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  label: 'Team',
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  icon: Icons.account_circle_outlined,
                  activeIcon: Icons.account_circle_rounded,
                  label: 'Profile',
                  selected: currentIndex == 4,
                  hasDot: true,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30.h,
            child: _AssistantButton(
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// A nav destination that reacts to touch and to selection: the icon swaps to
/// its filled variant, tints and grows, the label expands into place, and the
/// whole item dips under the finger.
class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final bool hasDot;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.hasDot = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  static const Color _brand = Color(0xFF1B3673);
  static const Color _idle = Color(0xFF64748B);
  static const Duration _duration = Duration(milliseconds: 260);
  static const Curve _curve = Curves.easeOutCubic;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1,
        duration: const Duration(milliseconds: 120),
        curve: _curve,
        child: SizedBox(
          width: 56.w,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedSlide(
                offset: Offset(0, widget.selected ? -0.05 : 0),
                duration: _duration,
                curve: _curve,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: widget.selected ? 1 : 0,
                      ),
                      duration: _duration,
                      curve: _curve,
                      builder: (context, t, _) => Transform.scale(
                        scale: 1 + 0.10 * t,
                        child: Icon(
                          widget.selected ? widget.activeIcon : widget.icon,
                          color: Color.lerp(_idle, _brand, t),
                          size: 28.sp,
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: _duration,
                      curve: _curve,
                      alignment: Alignment.topCenter,
                      child: widget.selected
                          ? Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                widget.label,
                                style: TextStyle(
                                  color: _brand,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              if (widget.hasDot)
                Positioned(
                  top: -2.h,
                  right: 8.w,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutBack,
                    builder: (context, t, child) =>
                        Transform.scale(scale: t, child: child),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The raised HR Assistant button. It presses in under the finger and breathes
/// a soft halo only while its tab is open — an always-on pulse would burn
/// frames on every screen.
class _AssistantButton extends StatefulWidget {
  final bool selected;
  final VoidCallback onTap;

  const _AssistantButton({required this.selected, required this.onTap});

  @override
  State<_AssistantButton> createState() => _AssistantButtonState();
}

class _AssistantButtonState extends State<_AssistantButton>
    with SingleTickerProviderStateMixin {
  static const Color _brand = Color(0xFF1B3673);

  late final AnimationController _halo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.selected) _halo.repeat();
  }

  @override
  void didUpdateWidget(covariant _AssistantButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !_halo.isAnimating) {
      _halo.repeat();
    } else if (!widget.selected && _halo.isAnimating) {
      _halo.stop();
      _halo.value = 0;
    }
  }

  @override
  void dispose() {
    _halo.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: 92.r,
          height: 92.r,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _halo,
                builder: (context, _) => Container(
                  width: 64.r + (24.r * _halo.value),
                  height: 64.r + (24.r * _halo.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _brand.withValues(
                      alpha: 0.18 * (1 - _halo.value),
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: _brand,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _brand.withValues(
                        alpha: widget.selected ? 0.42 : 0.30,
                      ),
                      blurRadius: widget.selected ? 22 : 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedRotation(
                  turns: widget.selected ? 0.04 : 0,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  child: Center(
                    child: Icon(
                      widget.selected
                          ? Icons.chat_bubble
                          : Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}