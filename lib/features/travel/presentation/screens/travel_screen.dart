import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isi_group_corporate_app/features/travel/presentation/widgets/bottom_sheet/create_travel_request_bottom_sheet.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filterTabs = [
    'All Requests',
    'Approved',
    'Pending',
    'Completed',
  ];

  void _openCreateTravelRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTravelRequestBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Staff Travel Requests',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: const Color(0xFF64748B), size: 22.sp),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),

      // FAB for creating new requests
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateTravelRequestSheet(context),
        backgroundColor: const Color(0xFF8CBE23),
        elevation: 3,
        icon: Icon(Icons.add_rounded, color: Colors.black, size: 22.sp),
        label: Text(
          'Request Travel',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 16.h, bottom: 90.h),
        children: [
          // 1. Quick Stats Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Upcoming Trips',
                    count: '2',
                    icon: Icons.directions_car_filled_rounded,
                    color: const Color(0xFF689F38),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Pending Review',
                    count: '1',
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 2. Status Filter Tabs
          SizedBox(
            height: 38.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filterTabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8CBE23) : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF8CBE23) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _filterTabs[index],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.black : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20.h),

          // 3. Section Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'My Travel Schedule',
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // 4. Staff Travel Item Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                _buildStaffTripCard(
                  title: 'Customer Visit • ABA Bank HQ',
                  type: 'Local Meeting',
                  location: 'Koh Pich, Phnom Penh',
                  date: 'Today • 02:00 PM - 05:00 PM',
                  driverStatus: 'Driver Assigned (Sokha - Ford SUV)',
                  status: 'APPROVED',
                  statusBgColor: const Color(0xFFECFDF5),
                  statusTextColor: const Color(0xFF047857),
                  statusBorderColor: const Color(0xFFA7F3D0),
                  id: '#TRV-2026-041',
                ),
                SizedBox(height: 14.h),
                _buildStaffTripCard(
                  title: 'Branch Audit & Inspection',
                  type: 'Domestic Trip',
                  location: 'Siem Reap Branch Office',
                  date: 'Jul 28 - Jul 30, 2026',
                  driverStatus: 'Self-Drive Company Vehicle',
                  status: 'PENDING',
                  statusBgColor: const Color(0xFFFFFBEB),
                  statusTextColor: const Color(0xFFB45309),
                  statusBorderColor: const Color(0xFFFDE68A),
                  id: '#TRV-2026-048',
                ),
                SizedBox(height: 14.h),
                _buildStaffTripCard(
                  title: 'Technical Support & Hardware Setup',
                  type: 'Site Visit',
                  location: 'Sihanoukville Logistics Hub',
                  date: 'Jul 15, 2026',
                  driverStatus: 'Company Driver (Kimsour)',
                  status: 'COMPLETED',
                  statusBgColor: const Color(0xFFF1F5F9),
                  statusTextColor: const Color(0xFF475569),
                  statusBorderColor: const Color(0xFFE2E8F0),
                  id: '#TRV-2026-012',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Summary Stat Card Widget
  Widget _buildSummaryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
        ],
      ),
    );
  }

  // Staff Travel Request Card
  Widget _buildStaffTripCard({
    required String title,
    required String type,
    required String location,
    required String date,
    required String driverStatus,
    required String status,
    required Color statusBgColor,
    required Color statusTextColor,
    required Color statusBorderColor,
    required String id,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  id,
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: statusBorderColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Title & Type
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),

          // Location
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: const Color(0xFF689F38), size: 15.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Date Time
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: const Color(0xFF64748B), size: 15.sp),
              SizedBox(width: 4.w),
              Text(
                date,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          SizedBox(height: 10.h),

          // Transport / Driver Detail Footer
          Row(
            children: [
              Icon(Icons.directions_car_rounded, color: const Color(0xFF0F172A), size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  driverStatus,
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 18.sp),
            ],
          ),
        ],
      ),
    );
  }
}