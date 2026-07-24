import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

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
        title: Text('Performance & Goals', style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // Rating Card
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CURRENT RATING (Q1 2026)", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF99F6E4), letterSpacing: 0.5)),
                    SizedBox(height: 6.h),
                    Text("Exceeds Expectations", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Text("4.8", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0D9488))),
                )
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Text("Q2 Key Objectives (OKRs)", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          SizedBox(height: 12.h),

          _buildOkrTile("Deliver App Hub v2.0 Architecture", 0.85, "85% Completed"),
          _buildOkrTile("Code Security Audit & Refactoring", 0.60, "60% Completed"),
          _buildOkrTile("Onboard 3 Junior Mobile Developers", 1.0, "Completed"),
        ],
      ),
    );
  }

  Widget _buildOkrTile(String title, double progress, String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)))),
              Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488))),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFCCFBF1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
            ),
          ),
        ],
      ),
    );
  }
}