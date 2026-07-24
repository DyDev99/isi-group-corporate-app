import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  int selectedCategory = 0;
  final List<String> categories = ["Annual", "Sick", "Unpaid", "Special"];

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
        title: Text('Leave Request', style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quota Cards
            SizedBox(
              height: 110.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildQuotaCard("Annual Leave", "12 Left", "18 Total", const Color(0xFF059669), const Color(0xFFECFDF5)),
                  SizedBox(width: 12.w),
                  _buildQuotaCard("Sick Leave", "5 Left", "7 Total", const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                  SizedBox(width: 12.w),
                  _buildQuotaCard("Casual Leave", "3 Left", "5 Total", const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            Text("Apply for Leave", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            SizedBox(height: 12.h),

            // Application Form Container
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("LEAVE TYPE", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 0.5)),
                  SizedBox(height: 8.h),
                  Row(
                    children: List.generate(
                      categories.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedCategory = index),
                          child: Container(
                            margin: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 6.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: selectedCategory == index ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: selectedCategory == index ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),
                  Text("DATE RANGE", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 0.5)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(child: _buildDatePickerInput("Start Date", "May 12, 2026")),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildDatePickerInput("End Date", "May 14, 2026")),
                    ],
                  ),

                  SizedBox(height: 16.h),
                  Text("REASON / REMARKS", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 0.5)),
                  SizedBox(height: 8.h),
                  TextField(
                    maxLines: 3,
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: "Briefly explain the reason for leave...",
                      hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.all(12.r),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Container(
                    height: 48.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Text("Submit Leave Request", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            Text("Recent History", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            SizedBox(height: 12.h),

            _buildHistoryItem("Annual Leave", "Apr 10 - Apr 12 (3 Days)", "Approved", const Color(0xFF059669), const Color(0xFFECFDF5)),
            _buildHistoryItem("Sick Leave", "Mar 22 (1 Day)", "Approved", const Color(0xFF059669), const Color(0xFFECFDF5)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaCard(String title, String left, String total, Color color, Color bg) {
    return Container(
      width: 140.w,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: color)),
          SizedBox(height: 6.h),
          Text(left, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
          SizedBox(height: 2.h),
          Text(total, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildDatePickerInput(String label, String val) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text(val, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
            ],
          ),
          Icon(Icons.calendar_today_rounded, size: 14.sp, color: const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String dates, String status, Color statusColor, Color statusBg) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              SizedBox(height: 2.h),
              Text(dates, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8.r)),
            child: Text(status, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: statusColor)),
          )
        ],
      ),
    );
  }
}