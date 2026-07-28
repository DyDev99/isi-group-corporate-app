import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Feature Screen Imports
import 'package:isi_group_corporate_app/features/time_attendance/presentation/screens/time_attendance_screen.dart';
import 'package:isi_group_corporate_app/features/leave_request/presentation/screens/leave_request_screen.dart';
import 'package:isi_group_corporate_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:isi_group_corporate_app/features/meeting_rooms/presentation/screens/meeting_rooms_screen.dart';
import 'package:isi_group_corporate_app/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:isi_group_corporate_app/features/learning_center/presentation/screens/learning_center_screen.dart';
import 'package:isi_group_corporate_app/features/knowledge_base/presentation/screens/knowledge_base_screen.dart';
import 'package:isi_group_corporate_app/features/digital_docs/presentation/screens/digital_docs_screen.dart';
import 'package:isi_group_corporate_app/features/performance/presentation/screens/performance_screen.dart';
import 'package:isi_group_corporate_app/features/travel/presentation/screens/travel_screen.dart';

// Import or include GridBackground widget
// import 'package:isi_group_corporate_app/shared/widgets/grid_background.dart';

class AppHubScreen extends StatelessWidget {
  const AppHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> hubItems = [
      {
        'title': 'Time & Attendance',
        'icon': Icons.access_time_rounded,
        'iconColor': const Color(0xFF3B82F6),
        'bgColor': const Color(0xFFEFF6FF),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimeAttendanceScreen()),
            ),
      },
      {
        'title': 'Leave Request',
        'icon': Icons.calendar_month_rounded,
        'iconColor': const Color(0xFF10B981),
        'bgColor': const Color(0xFFECFDF5),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaveRequestScreen()),
            ),
      },
      {
        'title': 'Expenses',
        'icon': Icons.credit_card_rounded,
        'iconColor': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFFFBEB),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpensesScreen()),
            ),
      },
      {
        'title': 'Learning Center',
        'icon': Icons.school_rounded,
        'iconColor': const Color(0xFFA855F7),
        'bgColor': const Color(0xFFFAF5FF),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LearningCenterScreen()),
            ),
      },
      {
        'title': 'Knowledge Base',
        'icon': Icons.menu_book_rounded,
        'iconColor': const Color(0xFF6366F1),
        'bgColor': const Color(0xFFEEF2FF),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KnowledgeBaseScreen()),
            ),
      },
      {
        'title': 'Travel',
        'icon': Icons.airplane_ticket_rounded,
        'iconColor': const Color(0xFF06B6D4),
        'bgColor': const Color(0xFFECFEFF),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TravelScreen()),
            ),
      },
      {
        'title': 'Rewards & Rec.',
        'icon': Icons.workspace_premium_rounded,
        'iconColor': const Color(0xFFF43F5E),
        'bgColor': const Color(0xFFFFF1F2),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RewardsScreen()),
            ),
      },
      {
        'title': 'Digital Docs',
        'icon': Icons.description_rounded,
        'iconColor': const Color(0xFF64748B),
        'bgColor': const Color(0xFFF8FAFC),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DigitalDocsScreen()),
            ),
      },
      {
        'title': 'Performance',
        'icon': Icons.work_rounded,
        'iconColor': const Color(0xFF14B8A6),
        'bgColor': const Color(0xFFF0FDFA),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerformanceScreen()),
            ),
      },
      {
        'title': 'Meeting Rooms',
        'icon': Icons.edit_calendar_rounded,
        'iconColor': const Color(0xFFF97316),
        'bgColor': const Color(0xFFFFF7ED),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeetingRoomsScreen()),
            ),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Stack(
        children: [
          // Grid Backdrop
          const Positioned.fill(
            child: GridBackground(),
          ),

          // Main Content
          Positioned.fill(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 52.h, bottom: 100.h),
              children: [
                // Soft Header & Search Action
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Hub',
                            style: TextStyle(
                              color: const Color(0xFF1E293B),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'All your employee tools in one place',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      _AnimatedPressable(
                        onTap: () {},
                        child: Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF64748B),
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Section Title & Pill Badge
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Modules & Workflows',
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          '${hubItems.length} TOOLS',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // Grid of Modules
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14.h,
                      crossAxisSpacing: 14.w,
                      childAspectRatio: 0.98,
                    ),
                    itemCount: hubItems.length,
                    itemBuilder: (context, index) {
                      final item = hubItems[index];
                      return _buildHubTile(
                        title: item['title'],
                        icon: item['icon'],
                        iconColor: item['iconColor'],
                        bgColor: item['bgColor'],
                        onTap: item['onTap'],
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Soft Gradient AI Assistance Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const AiAssistanceCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return _AnimatedPressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 52.r,
            width: 52.r,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: iconColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REUSABLE PRESSABLE ANIMATION WRAPPER
// ============================================================================

class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedPressable({required this.child, this.onTap});

  @override
  State<_AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<_AnimatedPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// SOFT AI ASSISTANCE CARD
// ============================================================================

class AiAssistanceCard extends StatelessWidget {
  const AiAssistanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFC7D2FE).withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: const Color(0xFF6366F1),
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                "AI ASSISTANT",
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4F46E5),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "Need help finding something?",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            "Ask the AI Assistant for company policies or quick links to modules.",
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          _AnimatedPressable(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "Try AI Assistant",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GRID BACKGROUND WIDGET
// ============================================================================

class GridBackground extends StatelessWidget {
  final Color background;
  final Color line;
  final double cell;
  final double strokeWidth;
  final Offset offset;

  const GridBackground({
    super.key,
    this.background = const Color(0xFFF6F8FA),
    this.line = const Color(0x99E2E8F0),
    this.cell = 24,
    this.strokeWidth = 1,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(
          background: background,
          line: line,
          cell: cell,
          strokeWidth: strokeWidth,
          offset: offset,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color background;
  final Color line;
  final double cell;
  final double strokeWidth;
  final Offset offset;

  const _GridPainter({
    required this.background,
    required this.line,
    required this.cell,
    required this.strokeWidth,
    required this.offset,
  });

  double _phase(double value) => ((value % cell) + cell) % cell;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(background, BlendMode.srcOver);

    final paint = Paint()
      ..color = line
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (var x = _phase(offset.dx); x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = _phase(offset.dy); y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.line != line ||
      oldDelegate.cell != cell ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.offset != offset;
}