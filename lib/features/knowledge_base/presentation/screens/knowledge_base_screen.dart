import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

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
        title: Text('Knowledge Base', style: TextStyle(color: const Color(0xFF0F172A), fontSize: 18.sp, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // Search Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 20.sp),
                SizedBox(width: 10.w),
                Text("Search SOPs, policies, guides...", style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          Text("Browse Categories", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          SizedBox(height: 12.h),

          Row(
            children: [
              _buildCategoryTile("IT Support", Icons.computer_rounded, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
              SizedBox(width: 12.w),
              _buildCategoryTile("HR Policies", Icons.badge_rounded, const Color(0xFF0891B2), const Color(0xFFECFEFF)),
              SizedBox(width: 12.w),
              _buildCategoryTile("Finance SOPs", Icons.account_balance_rounded, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
            ],
          ),

          SizedBox(height: 24.h),
          Text("Popular Articles", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          SizedBox(height: 12.h),

          _buildArticleItem("How to request VPN access for remote work", "IT & Infrastructure", "1.2k views"),
          _buildArticleItem("Employee health insurance claim procedure", "Human Resources", "850 views"),
          _buildArticleItem("Travel expense approval workflow", "Finance Department", "640 views"),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String title, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: color),
            SizedBox(height: 8.h),
            Text(title, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(String title, String category, String views) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
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
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.article_outlined, size: 18.sp, color: const Color(0xFF4F46E5)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text("$category • $views", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
        ],
      ),
    );
  }
}