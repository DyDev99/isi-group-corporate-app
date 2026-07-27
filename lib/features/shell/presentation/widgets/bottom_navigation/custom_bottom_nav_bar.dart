import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shell navigation with the raised assistant destination.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(padding: EdgeInsets.only(bottom: 24.h, left: 16.w, right: 16.w), child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
    Container(height: 72.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(36.r), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 20, offset: const Offset(0, 10))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', selected: currentIndex == 0, onTap: () => onTap(0)),
      _NavItem(icon: Icons.apps_outlined, activeIcon: Icons.apps_rounded, label: 'Hub', selected: currentIndex == 1, onTap: () => onTap(1)), SizedBox(width: 50.w),
      _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Team', selected: currentIndex == 3, onTap: () => onTap(3)),
      _NavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile', selected: currentIndex == 4, onTap: () => onTap(4)),
    ])),
    Positioned(bottom: 30.h, child: GestureDetector(onTap: () => onTap(2), child: Container(width: 64.r, height: 64.r, decoration: BoxDecoration(color: const Color(0xFF1B3673), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF1B3673).withValues(alpha: currentIndex == 2 ? .42 : .30), blurRadius: currentIndex == 2 ? 22 : 16, offset: const Offset(0, 8))]), child: Icon(currentIndex == 2 ? Icons.chat_bubble : Icons.chat_bubble_rounded, color: Colors.white, size: 26.sp)))),
  ]));
}
class _NavItem extends StatelessWidget { final IconData icon; final IconData activeIcon; final String label; final bool selected; final VoidCallback onTap; const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.selected, required this.onTap}); @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: SizedBox(width: 56.w, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(selected ? activeIcon : icon, color: selected ? const Color(0xFF1B3673) : const Color(0xFF64748B), size: 28.sp), if (selected) Text(label, style: TextStyle(color: const Color(0xFF1B3673), fontSize: 11.sp, fontWeight: FontWeight.w600))]))); }
