import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with SingleTickerProviderStateMixin {
  String _selectedQuarter = 'Q2 2026';
  String _activeFilter = 'All'; // 'All', 'In Progress', 'Completed'

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _availableQuarters = ['Q2 2026', 'Q1 2026', 'Q4 2025'];

  final List<OkrItem> _allOkrs = [
    OkrItem(
      title: "Deliver CashGrow App Hub v2.0 Architecture",
      category: "Architecture",
      progress: 0.85,
      dueDate: "Jun 30, 2026",
      status: "In Progress",
      keyResults: [
        "Implement Flutter Clean Architecture with Bloc",
        "Achieve > 80% unit test coverage for domain layer",
        "Refactor legacy SQLCipher database migration script",
      ],
    ),
    OkrItem(
      title: "Mobile App Security Audit & Jailbreak Refactoring",
      category: "Security",
      progress: 0.60,
      dueDate: "Jul 15, 2026",
      status: "In Progress",
      keyResults: [
        "Integrate Jailbreak & Root detection mechanisms",
        "Enforce SSL Pinning for backend REST endpoints",
        "Redact PII logs in release builds",
      ],
    ),
    OkrItem(
      title: "Onboard 3 Junior Mobile Developers",
      category: "Leadership",
      progress: 1.0,
      dueDate: "May 20, 2026",
      status: "Completed",
      keyResults: [
        "Conduct Flutter technical onboarding workshops",
        "Assign mentorship buddies for codebase PR reviews",
        "Complete 30-day performance check-ins",
      ],
    ),
    OkrItem(
      title: "Optimize App Launch Time & Rendering FPS",
      category: "Performance",
      progress: 0.35,
      dueDate: "Aug 10, 2026",
      status: "In Progress",
      keyResults: [
        "Reduce cold start time under 1.2 seconds",
        "Eliminate jank frames on heavy ListView renders",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<OkrItem> get _filteredOkrs {
    if (_activeFilter == 'In Progress') {
      return _allOkrs.where((okr) => okr.progress < 1.0).toList();
    } else if (_activeFilter == 'Completed') {
      return _allOkrs.where((okr) => okr.progress == 1.0).toList();
    }
    return _allOkrs;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Performance & Goals',
          style: TextStyle(
            color: titleColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          _buildQuarterDropdown(isDark),
          SizedBox(width: 12.w),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.r),
            children: [
              // 1. Rating Card
              _buildRatingHeroCard(isDark),
              SizedBox(height: 20.h),

              // 2. Engineering KPIs Section
              Text(
                "ENGINEERING KPIS",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 10.h),
              _buildKpiGrid(cardBg, borderColor, titleColor),
              SizedBox(height: 24.h),

              // 3. OKR Header & Smooth Filter Control
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "OBJECTIVES & KEY RESULTS",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildFilterSegmentedControl(isDark),
                ],
              ),
              SizedBox(height: 12.h),

              // 4. Animated OKR Cards List
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey<String>(_activeFilter),
                  children: _filteredOkrs
                      .map(
                        (okr) => _buildOkrCard(
                          context: context,
                          okr: okr,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          isDark: isDark,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header Quarter Selector Dropdown
  Widget _buildQuarterDropdown(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQuarter,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: const Color(0xFF0D9488)),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0D9488),
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedQuarter = newValue);
            }
          },
          items: _availableQuarters.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Hero Rating Card with Modern Gradient
  Widget _buildRatingHeroCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PERFORMANCE RATING ($_selectedQuarter)",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF99F6E4),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Exceeds Expectations",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                  ],
                ),
                child: Text(
                  "4.8",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0D9488),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Expanded(child: _CompetencyStat(label: "Code Quality", value: "4.9 / 5.0")),
                Expanded(child: _CompetencyStat(label: "Architecture", value: "4.8 / 5.0")),
                Expanded(child: _CompetencyStat(label: "Leadership", value: "4.7 / 5.0")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Engineering KPIs Grid
  Widget _buildKpiGrid(Color bg, Color borderColor, Color titleColor) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 2.1,
      children: [
        _KpiTile(title: "Crash-Free Rate", value: "99.94%", status: "+0.02%", icon: Icons.bug_report_outlined, bg: bg, borderColor: borderColor, titleColor: titleColor),
        _KpiTile(title: "PR Review Time", value: "< 2.4 hrs", status: "Top 5%", icon: Icons.rate_review_outlined, bg: bg, borderColor: borderColor, titleColor: titleColor),
        _KpiTile(title: "Sprint Velocity", value: "48 pts", status: "On Target", icon: Icons.speed_rounded, bg: bg, borderColor: borderColor, titleColor: titleColor),
        _KpiTile(title: "Security Score", value: "A+ Grade", status: "Verified", icon: Icons.shield_outlined, bg: bg, borderColor: borderColor, titleColor: titleColor),
      ],
    );
  }

  // Filter Segmented Control with Smooth Micro Animations
  Widget _buildFilterSegmentedControl(bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['All', 'In Progress', 'Completed'].map((tab) {
          final isSelected = _activeFilter == tab;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF334155) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        )
                      ]
                    : [],
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Interactive OKR Card (Fixed Material & Ink Splash Assertions)
  Widget _buildOkrCard({
    required BuildContext context,
    required OkrItem okr,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required bool isDark,
  }) {
    final isDone = okr.progress >= 1.0;
    final percentage = (okr.progress * 100).toInt();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent, // ✅ Prevents hiding Ink Splash / Assertion error
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias, // ✅ Clips touch ripple inside rounded corners
        child: InkWell(
          onTap: () => _showOkrDetailModal(context, okr, isDark),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        okr.category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isDone ? "Completed" : "$percentage% Completed",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: isDone ? const Color(0xFF059669) : const Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  okr.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // ✅ Prevents horizontal/vertical overflow
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 12.h),

                // Smooth Progress Bar Animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: okr.progress),
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6.h,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFCCFBF1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDone ? const Color(0xFF059669) : const Color(0xFF0D9488),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Target: ${okr.dueDate}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B)),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Key Results (${okr.keyResults.length})",
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 16.sp, color: const Color(0xFF2563EB)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Smooth Bottom Sheet Modal
  void _showOkrDetailModal(BuildContext context, OkrItem okr, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    okr.category,
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488)),
                  ),
                ),
                Text(
                  "Due: ${okr.dueDate}",
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              okr.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "KEY RESULTS BREAKDOWN",
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 0.8),
            ),
            SizedBox(height: 10.h),
            ...okr.keyResults.map(
              (kr) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16.sp,
                      color: const Color(0xFF0D9488),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        kr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Text("Close Details", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Model
class OkrItem {
  final String title;
  final String category;
  final double progress;
  final String dueDate;
  final String status;
  final List<String> keyResults;

  OkrItem({
    required this.title,
    required this.category,
    required this.progress,
    required this.dueDate,
    required this.status,
    required this.keyResults,
  });
}

// Helper Widget: Hero Card Competency Stat
class _CompetencyStat extends StatelessWidget {
  final String label;
  final String value;

  const _CompetencyStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.sp, color: const Color(0xFF99F6E4)),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}

// Helper Widget: KPI Grid Card Tile
class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final IconData icon;
  final Color bg;
  final Color borderColor;
  final Color titleColor;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    required this.bg,
    required this.borderColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B)),
                ),
              ),
              Icon(icon, size: 14.sp, color: const Color(0xFF0D9488)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: titleColor),
                ),
              ),
              Text(
                status,
                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}