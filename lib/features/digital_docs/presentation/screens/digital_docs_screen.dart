import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DigitalDocsScreen extends StatelessWidget {
  const DigitalDocsScreen({super.key});

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
        title: Text('Digital Documents', style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // Action Banner
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14.r)),
                  child: Icon(Icons.upload_file_rounded, size: 22.sp, color: const Color(0xFF475569)),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Upload New Document", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                      SizedBox(height: 2.h),
                      Text("PDF, PNG, JPEG up to 10MB", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                Icon(Icons.add_circle_outline_rounded, size: 24.sp, color: const Color(0xFF2563EB)),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Text("My Document Vault", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          SizedBox(height: 12.h),

          _buildDocItem("Employment Contract 2026.pdf", "Updated Jan 15, 2026", "2.4 MB", "Signed", const Color(0xFF059669)),
          _buildDocItem("Non-Disclosure Agreement (NDA)", "Updated Feb 01, 2026", "1.1 MB", "Signed", const Color(0xFF059669)),
          _buildDocItem("Tax Deduction Certificate 2025", "Updated Mar 10, 2026", "850 KB", "Action Needed", const Color(0xFFDC2626)),
          _buildDocItem("Passport Copy Verification", "Updated Apr 04, 2026", "3.8 MB", "Verified", const Color(0xFF2563EB)),
        ],
      ),
    );
  }

  Widget _buildDocItem(String name, String date, String size, String status, Color statusColor) {
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
          Icon(Icons.picture_as_pdf_rounded, size: 28.sp, color: const Color(0xFFEF4444)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text("$date • $size", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(status, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: statusColor)),
          )
        ],
      ),
    );
  }
}