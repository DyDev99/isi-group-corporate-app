import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LearningCenterScreen extends StatefulWidget {
  const LearningCenterScreen({super.key});

  @override
  State<LearningCenterScreen> createState() => _LearningCenterScreenState();
}

class _LearningCenterScreenState extends State<LearningCenterScreen> {
  String _selectedCategory = 'All';

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Learning Center',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline_rounded, color: const Color(0xFF64748B), size: 22.sp),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF9333EA),
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.all(20.r),
          children: [
            // Quick Metric Stats Bar
            Row(
              children: [
                _buildStatMetric('1 Course', 'In Progress', Icons.play_circle_fill_rounded, const Color(0xFF9333EA)),
                SizedBox(width: 12.w),
                _buildStatMetric('12 Modules', 'Completed', Icons.check_circle_rounded, const Color(0xFF10B981)),
                SizedBox(width: 12.w),
                _buildStatMetric('8.5 Hrs', 'Spent Learning', Icons.stars_rounded, const Color(0xFFF59E0B)),
              ],
            ),

            SizedBox(height: 20.h),

            // Ongoing Course Visual Banner
            _AnimatedPressable(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7E22CE), Color(0xFF581C87)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7E22CE).withValues(alpha: 0.25),
                      blurRadius: 16,
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
                          child: Row(
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "IN PROGRESS",
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "65% Complete",
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFFF3E8FF), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      "Cybersecurity & Data Privacy 2026",
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Module 3: Identifying Phishing & Social Engineering",
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFFE9D5FF)),
                    ),
                    SizedBox(height: 16.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: LinearProgressIndicator(
                        value: 0.65,
                        minHeight: 7.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Est. 25 mins remaining",
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFFD8B4FE)),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "Resume Lesson ➔",
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF581C87)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Section Header & Category Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recommended Courses", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                Text("View All", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF9333EA))),
              ],
            ),

            SizedBox(height: 12.h),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['All', 'Mandatory', 'Technical', 'Soft Skills'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      selectedColor: const Color(0xFF9333EA),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF9333EA) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 16.h),

            // Course Cards
            _buildCourseCard(
              title: "Corporate Governance & Compliance",
              duration: "2.5 Hours",
              enrolled: "142 Enrolled",
              category: "Mandatory",
              instructor: "Legal & Risk Dept",
              tagColor: const Color(0xFF2563EB),
              icon: Icons.gavel_rounded,
            ),
            _buildCourseCard(
              title: "Effective Workplace Communication",
              duration: "1.5 Hours",
              enrolled: "98 Enrolled",
              category: "Soft Skills",
              instructor: "HR Learning Team",
              tagColor: const Color(0xFF059669),
              icon: Icons.forum_rounded,
            ),
            _buildCourseCard(
              title: "Agile Project Management Basics",
              duration: "4.0 Hours",
              enrolled: "210 Enrolled",
              category: "Technical",
              instructor: "PMO Division",
              tagColor: const Color(0xFFD97706),
              icon: Icons.developer_board_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric(String count, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(height: 8.h),
            Text(count, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
            Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String duration,
    required String enrolled,
    required String category,
    required String instructor,
    required Color tagColor,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: _AnimatedPressable(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 22.sp, color: tagColor),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: tagColor, letterSpacing: 0.4),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 12.sp, color: const Color(0xFF64748B)),
                            SizedBox(width: 3.w),
                            Text(duration, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(title, style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), height: 1.25)),
                    SizedBox(height: 4.h),
                    Text("By $instructor", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_alt_outlined, size: 13.sp, color: const Color(0xFF94A3B8)),
                            SizedBox(width: 4.w),
                            Text(enrolled, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8))),
                          ],
                        ),
                        Text("Start ➔", style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF9333EA))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedPressable({required this.child, this.onTap});

  @override
  State<_AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<_AnimatedPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}