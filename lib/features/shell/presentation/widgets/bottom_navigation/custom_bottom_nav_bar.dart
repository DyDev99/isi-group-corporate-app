import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 24.h, left: 16.w, right: 16.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.apps_outlined,
                  activeIcon: Icons.apps_rounded,
                  label: 'Hub',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                SizedBox(width: 50.w),
                _NavItem(
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  label: 'Team',
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  icon: Icons.account_circle_outlined,
                  activeIcon: Icons.account_circle_rounded,
                  label: 'Profile',
                  selected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30.h,
            child: _PressHoverWrapper(
              onTap: () => onTap(2),
              pressScale: 0.92,
              hoverScale: 1.08,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3673),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B3673).withValues(
                        alpha: currentIndex == 2 ? 0.45 : 0.30,
                      ),
                      blurRadius: currentIndex == 2 ? 24 : 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    currentIndex == 2
                        ? Icons.chat_bubble
                        : Icons.chat_bubble_rounded,
                    key: ValueKey(currentIndex == 2),
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressHoverWrapper(
      onTap: onTap,
      pressScale: 0.90,
      hoverScale: 1.10,
      child: SizedBox(
        width: 56.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey(selected),
                color: selected
                    ? const Color(0xFF1B3673)
                    : const Color(0xFF64748B),
                size: 28.sp,
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: selected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: selected ? 14.h : 0,
                child: Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF1B3673),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressHoverWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;
  final double hoverScale;

  const _PressHoverWrapper({
    required this.child,
    this.onTap,
    this.pressScale = 0.94,
    this.hoverScale = 1.05,
  });

  @override
  State<_PressHoverWrapper> createState() => _PressHoverWrapperState();
}

class _PressHoverWrapperState extends State<_PressHoverWrapper> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    double scale = 1.0;
    if (_isPressed) {
      scale = widget.pressScale;
    } else if (_isHovered) {
      scale = widget.hoverScale;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}