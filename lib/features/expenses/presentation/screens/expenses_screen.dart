import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

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
        title: Text('Expense Claims', style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense Overview Card
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("MONTHLY REIMBURSEMENT", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.8)),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("\$482.50", style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text("Limit: \$1,000.00", style: TextStyle(fontSize: 11.sp, color: const Color(0xFFCBD5E1))),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: 0.482,
                      minHeight: 8.h,
                      backgroundColor: const Color(0xFF334155),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Submit New Claim Action Trigger Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle),
                    child: Icon(Icons.add_a_photo_rounded, size: 20.sp, color: Colors.white),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("New Expense Claim", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF78350F))),
                        SizedBox(height: 2.h),
                        Text("Scan receipt & auto-fill claim details", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF92400E))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: const Color(0xFFD97706), size: 22.sp),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            Text("Recent Claims", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            SizedBox(height: 12.h),

            _buildExpenseTile("Client Lunch Meeting", "Apr 28, 2026", "\$124.00", "Meals", Icons.restaurant_rounded, "Approved", const Color(0xFF059669)),
            _buildExpenseTile("Taxi to Airport", "Apr 25, 2026", "\$45.50", "Travel", Icons.local_taxi_rounded, "In Review", const Color(0xFFD97706)),
            _buildExpenseTile("Office Monitor Stand", "Apr 18, 2026", "\$313.00", "Supplies", Icons.devices_rounded, "Approved", const Color(0xFF059669)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile(String title, String date, String amount, String tag, IconData icon, String status, Color statusColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, size: 20.sp, color: const Color(0xFF475569)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text("$date • $tag", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              SizedBox(height: 2.h),
              Text(status, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: statusColor)),
            ],
          )
        ],
      ),
    );
  }
}