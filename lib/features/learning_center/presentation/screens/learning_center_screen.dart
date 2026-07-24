import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LearningCenterScreen extends StatelessWidget {
  const LearningCenterScreen({super.key});

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
        title: Text('Learning Center', style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // Ongoing Course Banner
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFF6B21A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9333EA).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text("IN PROGRESS", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                    Text("65% Completed", style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE9D5FF), fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 12.h),
                Text("Cybersecurity & Data Privacy 2026", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 4.h),
                Text("Module 3: Identifying Phishing & Malware", style: TextStyle(fontSize: 12.sp, color: const Color(0xFFF3E8FF))),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 8.h,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Text("Recommended Courses", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          SizedBox(height: 12.h),

          _buildCourseCard("Corporate Governance & Compliance", "2.5 Hours", "142 Enrolled", "Mandatory", const Color(0xFF2563EB)),
          _buildCourseCard("Effective Workplace Communication", "1.5 Hours", "98 Enrolled", "Soft Skills", const Color(0xFF059669)),
          _buildCourseCard("Agile Project Management Basics", "4.0 Hours", "210 Enrolled", "Technical", const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(String title, String duration, String enrolled, String category, Color tagColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(category, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: tagColor)),
              ),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 14.sp, color: const Color(0xFF64748B)),
                  SizedBox(width: 4.w),
                  Text(duration, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(enrolled, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8))),
              Text("Start Course ➔", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF9333EA))),
            ],
          ),
        ],
      ),
    );
  }
}