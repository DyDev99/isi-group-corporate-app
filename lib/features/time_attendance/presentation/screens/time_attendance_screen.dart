import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimeAttendanceScreen extends StatefulWidget {
  const TimeAttendanceScreen({super.key});

  @override
  State<TimeAttendanceScreen> createState() => _TimeAttendanceScreenState();
}

class _TimeAttendanceScreenState extends State<TimeAttendanceScreen> {
  bool isClockedIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Time & Attendance',
          style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10.r,
                            height: 10.r,
                            decoration: BoxDecoration(
                              color: isClockedIn ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isClockedIn ? "CLOCKED IN" : "CLOCKED OUT",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: isClockedIn ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 12.sp, color: const Color(0xFF2563EB)),
                            SizedBox(width: 4.w),
                            Text("HQ Office", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "08:15:42 AM",
                    style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: -1),
                  ),
                  SizedBox(height: 4.h),
                  Text("Logged in since 08:00 AM", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                  SizedBox(height: 24.h),
                  
                  // Big Interactive Toggle Button
                  GestureDetector(
                    onTap: () => setState(() => isClockedIn = !isClockedIn),
                    child: Container(
                      height: 52.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isClockedIn ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: (isClockedIn ? const Color(0xFFEF4444) : const Color(0xFF2563EB)).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isClockedIn ? "Clock Out" : "Clock In",
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            Text("Today's Breakdown", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            SizedBox(height: 12.h),

            // Daily Summary Metrics Grid
            Row(
              children: [
                _buildStatCard("Working Hours", "6h 15m", Icons.timer_outlined, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                SizedBox(width: 12.w),
                _buildStatCard("Break Time", "0h 45m", Icons.coffee_rounded, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                SizedBox(width: 12.w),
                _buildStatCard("Overtime", "+1h 20m", Icons.trending_up_rounded, const Color(0xFF059669), const Color(0xFFECFDF5)),
              ],
            ),

            SizedBox(height: 24.h),
            Text("Activity Timeline", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            SizedBox(height: 12.h),

            // Timeline Items
            _buildTimelineTile("Clock In", "08:00 AM", "Main Entrance NFC Reader", Icons.login_rounded, true),
            _buildTimelineTile("Lunch Break", "12:00 PM - 12:45 PM", "Cafeteria Zone B", Icons.restaurant_rounded, false),
            _buildTimelineTile("Clock Out", "Pending", "Awaiting shift completion", Icons.logout_rounded, false, isPending: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: 16.sp, color: color),
            ),
            SizedBox(height: 12.h),
            Text(val, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(String title, String time, String location, IconData icon, bool isDone, {bool isPending = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isPending ? const Color(0xFFF1F5F9) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 18.sp, color: isPending ? const Color(0xFF94A3B8) : const Color(0xFF2563EB)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text(location, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
        ],
      ),
    );
  }
}