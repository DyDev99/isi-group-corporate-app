import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['Popular', 'Recent', 'Pinned SOPs', 'Bookmarked'];

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Knowledge Base',
          style: TextStyle(color: const Color(0xFF0F172A), fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.all(20.r),
          children: [
            // Search Input Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: "Search SOPs, policies, guides...",
                  hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 20.sp),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18.sp, color: const Color(0xFF64748B)),
                          onPressed: () => setState(() => _searchController.clear()),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            SizedBox(height: 20.h),

            // Pinned SOPs / Quick Help Callout
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Company Policy Update 2026",
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E1B4B)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "New IT Security and Remote Work guidelines active.",
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF4338CA)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF4F46E5), size: 14.sp),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Categories Section
            Text("Browse Departments", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
            SizedBox(height: 12.h),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.0,
              children: [
                _buildCategoryTile("IT Support", "18 SOPs", Icons.computer_rounded, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                _buildCategoryTile("HR Policies", "24 Guides", Icons.badge_rounded, const Color(0xFF0891B2), const Color(0xFFECFEFF)),
                _buildCategoryTile("Finance", "12 SOPs", Icons.account_balance_rounded, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                _buildCategoryTile("Operations", "15 SOPs", Icons.precision_manufacturing_rounded, const Color(0xFF059669), const Color(0xFFECFDF5)),
                _buildCategoryTile("Safety", "9 Guides", Icons.health_and_safety_rounded, const Color(0xFFE11D48), const Color(0xFFFFE4E6)),
                _buildCategoryTile("Legal & Risk", "7 SOPs", Icons.gavel_rounded, const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
              ],
            ),

            SizedBox(height: 24.h),

            // Filter Tabs Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 16.h),

            // Articles List
            _buildArticleItem(
              title: "How to request VPN access for remote work",
              category: "IT & Infrastructure",
              views: "1.2k views",
              readTime: "3 min read",
              isPinned: true,
            ),
            _buildArticleItem(
              title: "Employee health insurance claim procedure",
              category: "Human Resources",
              views: "850 views",
              readTime: "5 min read",
              isPinned: false,
            ),
            _buildArticleItem(
              title: "Travel expense approval workflow and limits",
              category: "Finance Department",
              views: "640 views",
              readTime: "4 min read",
              isPinned: false,
            ),
            _buildArticleItem(
              title: "Incident reporting & workplace safety SOP",
              category: "Operations & Safety",
              views: "420 views",
              readTime: "6 min read",
              isPinned: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String title, String count, IconData icon, Color color, Color bg) {
    return _AnimatedPressable(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22.sp, color: color),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(count, style: TextStyle(fontSize: 9.5.sp, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem({
    required String title,
    required String category,
    required String views,
    required String readTime,
    required bool isPinned,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: _AnimatedPressable(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.article_outlined,
                  size: 18.sp,
                  color: isPinned ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), height: 1.25),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(category, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5))),
                        Text(" • ", style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF94A3B8))),
                        Text(readTime, style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF64748B))),
                        Text(" • ", style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF94A3B8))),
                        Text(views, style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFFCBD5E1), size: 20.sp),
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