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
  State<EditFastActionsBottomSheet> createState() => _EditFastActionsBottomSheetState();
}

class _EditFastActionsBottomSheetState extends State<EditFastActionsBottomSheet> {
  late List<FastActionTool> _tools;

  @override
  void initState() {
    super.initState();
    // Create a local copy to modify during edits
    _tools = List.from(widget.initialTools);
  }

  // Move item to exact position (1, 2, or 3)
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
          // Drag Handle bar
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header Row
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
                ElevatedButton(
                  onPressed: () {
                    widget.onSaved(_tools);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3673),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    elevation: 0,
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
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9)),

          // Reorderable List
          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              itemCount: _tools.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _tools.removeAt(oldIndex);
                  _tools.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final tool = _tools[index];
                return Container(
                  key: ValueKey(tool.id),
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: tool.isEnabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: tool.isEnabled ? const Color(0xFFE2E8F0) : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Drag Handle Icon
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Tool Icon
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: tool.isEnabled ? Colors.white : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              tool.icon,
                              color: tool.isEnabled ? const Color(0xFF1B3673) : const Color(0xFF94A3B8),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),

                          // Tool Title & Position
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tool.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: tool.isEnabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
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

                          // Enable/Disable Switch
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
                      
                      // Quick Order Position Selector (1, 2, 3)
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
    return GestureDetector(
      onTap: () => _moveToPosition(currentIndex, targetPosition),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFF1B3673) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(8.r),
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