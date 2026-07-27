import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isi_group_corporate_app/features/digital_docs/presentation/screens/digital_docs_screen.dart';
import 'package:isi_group_corporate_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:isi_group_corporate_app/features/leave_request/presentation/screens/leave_request_screen.dart';
import 'package:isi_group_corporate_app/features/time_attendance/presentation/screens/time_attendance_screen.dart';

// --- REUSABLE PRESSABLE ANIMATION WRAPPER ---
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
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// --- KPI PERFORMANCE CARD ---
class UserPerformanceCardWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final double progress;

  const UserPerformanceCardWidget({
    super.key,
    this.onTap,
    this.progress = .85,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedPressable(
      onTap: onTap,
      child: _DashboardCard(
        padding: EdgeInsets.all(16.r),
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
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: const Color(0xFF4F46E5),
                        size: 15.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Q3 Performance KPI',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const _Pill(
                  label: 'ON TRACK',
                  color: Color(0xFF059669),
                  background: Color(0xFFECFDF5),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Target Text Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quarterly Completion',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: const Color(0xFF4F46E5),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Compact Gauge
            Center(
              child: SizedBox(
                height: 70.h,
                width: 150.w,
                child: CustomPaint(
                  painter: DashboardGaugePainter(progress: progress),
                ),
              ),
            ),

            SizedBox(height: 10.h),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            SizedBox(height: 10.h),

            // Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _Metric(value: '18 / 20', label: 'Tasks Done'),
                _Metric(value: '94.5%', label: 'Quality Score'),
                _Metric(value: '4.9 ★', label: 'Peer Feedback'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- SLEEK COMPACT GAUGE PAINTER ---
class DashboardGaugePainter extends CustomPainter {
  final double progress;
  DashboardGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .92);
    final radius = math.min(size.width / 2, size.height * .92);

    // Ticks Arc
    for (var i = 0; i < 36; i++) {
      final p = i / 35;
      final angle = math.pi + p * math.pi;
      final isFilled = p <= progress;

      final paint = Paint()
        ..color = isFilled ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx + (radius - 10) * math.cos(angle),
          center.dy + (radius - 10) * math.sin(angle),
        ),
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        paint,
      );
    }

    // Pointer Needle
    final pointerLength = radius * .55;
    final pointerAngle = math.pi + (progress * math.pi);

    final pointerPath = Path()
      ..moveTo(0, -pointerLength)
      ..lineTo(-5, 0)
      ..lineTo(5, 0)
      ..close();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pointerAngle + (math.pi / 2));

    canvas.drawPath(
      pointerPath,
      Paint()..color = const Color(0xFF4338CA),
    );

    // Center Pin
    canvas.drawCircle(
      Offset.zero,
      4,
      Paint()..color = const Color(0xFF4338CA),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(DashboardGaugePainter old) => old.progress != progress;
}

// --- COMPACT 2x2 FOCUS GRID ---
class YourFocusGrid extends StatelessWidget {
  const YourFocusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35, // More compact horizontal cards
      children: [
        _FocusCard(
          icon: Icons.location_on_outlined,
          badge: 'CHECK IN',
          title: 'Attendance',
          value: 'Not Started',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimeAttendanceScreen()),
          ),
        ),
        _FocusCard(
          icon: Icons.calendar_today_outlined,
          badge: 'APPLY',
          title: 'Leave Balance',
          value: '12 Days',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LeaveRequestScreen()),
          ),
        ),
        _FocusCard(
          icon: Icons.check_circle_outline_rounded,
          badge: 'REVIEW',
          title: 'Approvals',
          value: '3 Pending',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpensesScreen()),
          ),
        ),
        _FocusCard(
          icon: Icons.description_outlined,
          badge: 'VIEW',
          title: 'Payslip',
          value: 'July Ready',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DigitalDocsScreen()),
          ),
        ),
      ],
    );
  }
}

// --- FOCUS CARD ---
class _FocusCard extends StatelessWidget {
  final IconData icon;
  final String badge;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _FocusCard({
    required this.icon,
    required this.badge,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedPressable(
      onTap: onTap,
      child: _DashboardCard(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
                _Pill(
                  label: badge,
                  color: const Color(0xFF475569),
                  background: const Color(0xFFF1F5F9),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- UP NEXT ITEM CARD ---
class UpNextCard extends StatelessWidget {
  const UpNextCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnimatedPressable(
      child: _DashboardCard(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'JUL',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '24',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q3 Planning Strategy',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '2:30 PM - 4:00 PM',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF64748B),
                size: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BASE DASHBOARD CARD STYLING ---
class _DashboardCard extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;

  const _DashboardCard({required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// --- SOFT PILL BADGE ---
class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _Pill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// --- COMPACT METRIC ITEM ---
class _Metric extends StatelessWidget {
  final String value;
  final String label;

  const _Metric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}