import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatefulWidget {
  final String greeting;
  final String name;
  final String avatarPath;
  final bool hasUnreadNotification;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const ProfileHeader({
    super.key,
    this.greeting = 'Good Morning,',
    required this.name,
    this.avatarPath = 'assets/images/avatar_placeholder.png',
    this.hasUnreadNotification = true,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _isProfilePressed = false;
  bool _isNotifPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar & Information Group
          GestureDetector(
            onTapDown: (_) => setState(() => _isProfilePressed = true),
            onTapUp: (_) => setState(() => _isProfilePressed = false),
            onTapCancel: () => setState(() => _isProfilePressed = false),
            onTap: widget.onProfileTap,
            child: AnimatedScale(
              scale: _isProfilePressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with Soft Glass Border
                  Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5.w,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      backgroundImage: AssetImage(widget.avatarPath),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.greeting,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Notification Button with Press Animation & Unread Dot
          GestureDetector(
            onTapDown: (_) => setState(() => _isNotifPressed = true),
            onTapUp: (_) => setState(() => _isNotifPressed = false),
            onTapCancel: () => setState(() => _isNotifPressed = false),
            onTap: widget.onNotificationTap,
            child: AnimatedScale(
              scale: _isNotifPressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isNotifPressed
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.w,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20.sp,
                    ),
                    if (widget.hasUnreadNotification)
                      Positioned(
                        top: 9.r,
                        right: 10.r,
                        child: Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1), // Soft Accent Indicator
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}