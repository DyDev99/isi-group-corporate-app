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

class AppHubScreen extends StatelessWidget {
  const AppHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> hubItems = [
      {
        'title': 'Time & Attendance',
        'icon': Icons.access_time_rounded,
        'iconColor': const Color(0xFF2563EB),
        'bgColor': const Color(0xFFEFF6FF),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TimeAttendanceScreen()),
          );
        },
      },
      {
        'title': 'Leave Request',
        'icon': Icons.calendar_month_rounded,
        'iconColor': const Color(0xFF059669),
        'bgColor': const Color(0xFFECFDF5),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaveRequestScreen()),
          );
        },
      },
      {
        'title': 'Expenses',
        'icon': Icons.credit_card_rounded,
        'iconColor': const Color(0xFFD97706),
        'bgColor': const Color(0xFFFFFBEB),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpensesScreen()),
          );
        },
      },
      {
        'title': 'Learning Center',
        'icon': Icons.school_rounded,
        'iconColor': const Color(0xFF9333EA),
        'bgColor': const Color(0xFFF3E8FF),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LearningCenterScreen()),
          );
        },
      },
      {
        'title': 'Knowledge Base',
        'icon': Icons.menu_book_rounded,
        'iconColor': const Color(0xFF4F46E5),
        'bgColor': const Color(0xFFEEF2FF),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KnowledgeBaseScreen()),
          );
        },
      },
      {
        'title': 'Travel',
        'icon': Icons.airplane_ticket_sharp,
        'iconColor': const Color(0xFF0891B2),
        'bgColor': const Color(0xFFECFEFF),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TravelScreen()),
          );
        },
      },
      {
        'title': 'Rewards & Rec.',
        'icon': Icons.workspace_premium_outlined,
        'iconColor': const Color(0xFFE11D48),
        'bgColor': const Color(0xFFFFE4E6),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RewardsScreen()),
          );
        },
      },
      {
        'title': 'Digital Docs',
        'icon': Icons.description_outlined,
        'iconColor': const Color(0xFF475569),
        'bgColor': const Color(0xFFF1F5F9),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DigitalDocsScreen()),
          );
        },
      },
      {
        'title': 'Performance',
        'icon': Icons.work_outline_rounded,
        'iconColor': const Color(0xFF0D9488),
        'bgColor': const Color(0xFFCCFBF1),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PerformanceScreen()),
          );
        },
      },
      {
        'title': 'Meeting Rooms',
        'icon': Icons.edit_calendar_outlined,
        'iconColor': const Color(0xFFEA580C),
        'bgColor': const Color(0xFFFFEDD5),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeetingRoomsScreen()),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Subtle Grid Pattern Background Layer
          const Positioned.fill(
            child: CleanGridBackground(),
          ),

          // 2. Main Scrollable Content
          Positioned.fill(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 60.h, bottom: 120.h),
              children: [
                // Header Title & Classic Shadowed Search Action
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Hub',
                            style: TextStyle(
                              color: const Color(0xFF0F172A),
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'All your employee tools in one place',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF475569),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Section Header Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Modules & Workflows',
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${hubItems.length} TOOLS',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Grid of Modules with Classic Tile Styling & Shadow
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.95,
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

                SizedBox(height: 24.h),

                // AI Assistance Card with Classic Elevation
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60.r,
            width: 60.r,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14.r), // Classic rounded shape
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08), // Rich classic drop shadow
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 26.sp,
              color: iconColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
              height: 1.2,
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
// AI ASSISTANCE CARD WIDGET (CLASSIC ELEVATED STYLE)
// ============================================================================

class AiAssistanceCard extends StatelessWidget {
  const AiAssistanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Classic navy slate tone
        borderRadius: BorderRadius.circular(16.r), // Classic card radius
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18), // Deeper classic shadow
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
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
                color: const Color(0xFF60A5FA),
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                "AI ASSISTANT",
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF93C5FD),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "Need help finding something?",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Ask the AI Assistant for company policies or quick links to modules.",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E293B),
              elevation: 2,
              shadowColor: Colors.black38,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 10.h,
              ),
            ),
            child: Text(
              "Try AI Assistant",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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