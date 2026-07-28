import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FastActionTool {
  final String id;
  final String title;
  final IconData icon;
  bool isEnabled;

  FastActionTool({
    required this.id,
    required this.title,
    required this.icon,
    this.isEnabled = true,
  });
}

class EditFastActionsBottomSheet extends StatefulWidget {
  final List<FastActionTool> initialTools;
  final Function(List<FastActionTool>) onSaved;

  const EditFastActionsBottomSheet({
    super.key,
    required this.initialTools,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required List<FastActionTool> currentTools,
    required Function(List<FastActionTool>) onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditFastActionsBottomSheet(
        initialTools: currentTools,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<EditFastActionsBottomSheet> createState() =>
      _EditFastActionsBottomSheetState();
}

class _EditFastActionsBottomSheetState
    extends State<EditFastActionsBottomSheet> {
  late List<FastActionTool> _tools;

  @override
  void initState() {
    super.initState();
    _tools = List.from(widget.initialTools);
  }

  void _moveToPosition(int currentIndex, int targetPosition) {
    if (targetPosition < 1 || targetPosition > _tools.length) return;
    final targetIndex = targetPosition - 1;
    if (currentIndex == targetIndex) return;

    setState(() {
      final item = _tools.removeAt(currentIndex);
      _tools.insert(targetIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customize Fast Actions',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Drag or tap #1, #2, #3 to set order quickly',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                _PressHoverWrapper(
                  onTap: () {
                    widget.onSaved(_tools);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3673),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B3673).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9)),

          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              itemCount: _tools.length,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final animValue =
                        Curves.easeOutCubic.transform(animation.value);
                    final scale = lerpDouble(1, 1.03, animValue)!;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.12 * animValue),
                              blurRadius: 18 * animValue,
                              spreadRadius: 2 * animValue,
                              offset: Offset(0, 8 * animValue),
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _tools.removeAt(oldIndex);
                  _tools.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final tool = _tools[index];
                return AnimatedContainer(
                  key: ValueKey(tool.id),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: tool.isEnabled
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: tool.isEnabled
                          ? const Color(0xFFE2E8F0)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: _PressHoverWrapper(
                              hoverScale: 1.15,
                              child: Container(
                                padding: EdgeInsets.all(4.r),
                                child: Icon(
                                  Icons.drag_indicator_rounded,
                                  color: const Color(0xFF94A3B8),
                                  size: 22.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: tool.isEnabled
                                  ? Colors.white
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              tool.icon,
                              color: tool.isEnabled
                                  ? const Color(0xFF1B3673)
                                  : const Color(0xFF94A3B8),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tool.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: tool.isEnabled
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                Text(
                                  'Current Position: #${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: tool.isEnabled,
                            activeColor: const Color(0xFF1B3673),
                            onChanged: (bool value) {
                              setState(() {
                                tool.isEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            'Quick Move to:',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildPositionChip(index, 1),
                          SizedBox(width: 6.w),
                          _buildPositionChip(index, 2),
                          SizedBox(width: 6.w),
                          _buildPositionChip(index, 3),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionChip(int currentIndex, int targetPosition) {
    final isCurrent = (currentIndex == targetPosition - 1);
    return _PressHoverWrapper(
      onTap: () => _moveToPosition(currentIndex, targetPosition),
      pressScale: 0.9,
      hoverScale: 1.08,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFF1B3673) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: const Color(0xFF1B3673).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          '#$targetPosition',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: isCurrent ? Colors.white : const Color(0xFF334155),
          ),
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