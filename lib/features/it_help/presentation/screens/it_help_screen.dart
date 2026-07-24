import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ITHelpScreen extends StatelessWidget {
  const ITHelpScreen({super.key});

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
          'IT Help & Support',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // Active Ticket Banner
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.2),
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
                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFF38BDF8)),
                      ),
                      child: Text(
                        "ACTIVE TICKET #IT-8842",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    Text(
                      "In Progress",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  "MacBook Pro M2 Display Glitch",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Assigned to: Tech Support Team B • ETA 2 hrs",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Text(
            "Quick Request Categories",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),

          // Categories Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              _buildCategoryCard(
                icon: Icons.laptop_chromebook_rounded,
                title: "Hardware Request",
                subtitle: "Laptop, Monitor, Accessories",
                color: const Color(0xFF2563EB),
                bg: const Color(0xFFEFF6FF),
              ),
              _buildCategoryCard(
                icon: Icons.vpn_key_rounded,
                title: "Access & VPN",
                subtitle: "Password Reset, VPN Access",
                color: const Color(0xFF059669),
                bg: const Color(0xFFECFDF5),
              ),
              _buildCategoryCard(
                icon: Icons.code_rounded,
                title: "Software & Tools",
                subtitle: "License Request, Installs",
                color: const Color(0xFFD97706),
                bg: const Color(0xFFFFFBEB),
              ),
              _buildCategoryCard(
                icon: Icons.wifi_off_rounded,
                title: "Network Issue",
                subtitle: "Wi-Fi & Connectivity",
                color: const Color(0xFFDC2626),
                bg: const Color(0xFFFEF2F2),
              ),
            ],
          ),

          SizedBox(height: 24.h),
          Text(
            "Recent Helpdesk Tickets",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),

          _buildTicketTile(
            ticketId: "#IT-8410",
            title: "Figma Professional License Renewal",
            date: "Apr 10, 2026",
            status: "Resolved",
            statusColor: const Color(0xFF059669),
          ),
          _buildTicketTile(
            ticketId: "#IT-7902",
            title: "Request for Dual-Monitor Setup",
            date: "Mar 22, 2026",
            status: "Completed",
            statusColor: const Color(0xFF059669),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTile({
    required String ticketId,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
  }) {
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
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.confirmation_number_outlined, size: 18.sp, color: const Color(0xFF475569)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text("$ticketId • $date", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
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