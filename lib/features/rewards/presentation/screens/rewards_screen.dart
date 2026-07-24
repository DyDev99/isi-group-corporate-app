import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
        title: Text('Rewards & Rec.', style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Point Balance Header
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [BoxShadow(color: const Color(0xFFE11D48).withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("AVAILABLE BALANCE", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFFFECDD3), letterSpacing: 0.5)),
                      SizedBox(height: 6.h),
                      Text("1,450 pts", style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
                    child: Text("Redeem Store", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFFBE123C))),
                  )
                ],
              ),
            ),

            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Kudos Wall", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                Text("+ Send High-Five", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFFE11D48))),
              ],
            ),
            SizedBox(height: 12.h),

            _buildKudosCard("Sarah Jenkins", "Michael Chen", "Outstanding support on the Q2 mobile app deployment launch!", "🙌 Team Player", "+50 pts"),
            _buildKudosCard("Alex Rivera", "David Smith", "Exceptional leadership during client presentation strategy.", "💡 Innovation", "+100 pts"),
          ],
        ),
      ),
    );
  }

  Widget _buildKudosCard(String sender, String receiver, String msg, String badge, String pts) {
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
              Text("$sender ➔ $receiver", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(6.r)),
                child: Text(pts, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFFE11D48))),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(msg, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF475569), height: 1.3)),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)),
            child: Text(badge, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
          )
        ],
      ),
    );
  }
}