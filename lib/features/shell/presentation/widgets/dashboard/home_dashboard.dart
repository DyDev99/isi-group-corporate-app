import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/dashboard/clean_grid_background.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/dashboard/dashboard_sections.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/dashboard/fast_actions_row.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/dashboard/profile_header.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/dashboard/section_header.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/fast_actions/edit_fast_actions_bottom_sheet.dart';
import 'package:isi_group_corporate_app/shared/widgets/appear_once.dart';

/// The home tab layout. Stateful shell concerns remain in [MainShell].
class HomeDashboard extends StatelessWidget {
  final List<FastActionTool> fastActions;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onEditFastActions;
  final VoidCallback onDashboardTap;
  final ValueChanged<String> onToolTap;

  const HomeDashboard({
    super.key,
    required this.fastActions,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.onDashboardTap,
    required this.onEditFastActions,
    required this.onToolTap,
  });

  @override
  Widget build(BuildContext context) => Stack(children: [
    const Positioned.fill(child: CleanGridBackground()),
    Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 220.h,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B3673),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
      ),
    ),
    Positioned.fill(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 60.h, bottom: 120.h),
        children: _stagger([
          ProfileHeader(
            name: "Christano Ronaldo",
            onProfileTap: onOpenProfile,
            onNotificationTap: onOpenNotifications,
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child:  UserPerformanceCardWidget(onTap: onDashboardTap,),
          ),
          SizedBox(height: 24.h),
          SectionHeader(
            title: 'Fast Actions',
            action: 'Edit',
            icon: Icons.edit_outlined,
            onTap: onEditFastActions,
          ),
          SizedBox(height: 12.h),
          FastActionsRow(
            tools: fastActions.where((tool) => tool.isEnabled).toList(),
            onToolTap: onToolTap,
          ),
          SizedBox(height: 24.h),
          const SectionHeader(
            title: 'Your Focus',
            action: 'Customize',
            icon: Icons.grid_view_rounded,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: const YourFocusGrid(),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Up Next',
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: const UpNextCard(),
          ),
          SizedBox(height: 16.h),
        ]),
      ),
    ),
  ]);

  List<Widget> _stagger(List<Widget> sections) {
    var index = 0;
    return [
      for (final section in sections)
        if (section is SizedBox)
          section
        else
          AppearOnce(index: index++, child: section)
    ];
  }
}