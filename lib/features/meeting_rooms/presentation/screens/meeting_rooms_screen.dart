import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Activity / Scheduled Meeting Model
class MeetingActivity {
  final DateTime date;
  final String time;
  final String title;
  final String roomName;
  final String floor;

  MeetingActivity({
    required this.date,
    required this.time,
    required this.title,
    required this.roomName,
    required this.floor,
  });
}

class MeetingRoomsScreen extends StatefulWidget {
  const MeetingRoomsScreen({super.key});

  @override
  State<MeetingRoomsScreen> createState() => _MeetingRoomsScreenState();
}

class _MeetingRoomsScreenState extends State<MeetingRoomsScreen> {
  DateTime _selectedDate = DateTime.now();

  // Mock list of user's scheduled activities across days
  final List<MeetingActivity> _userActivities = [
    MeetingActivity(
      date: DateTime(DateTime.now().year, DateTime.now().month, 16),
      time: "03:00 PM - 04:00 PM",
      title: "Q3 Strategy Planning",
      roomName: "Boardroom Alpha",
      floor: "Floor 2",
    ),
    MeetingActivity(
      date: DateTime(DateTime.now().year, DateTime.now().month, 16),
      time: "10:00 AM - 11:30 AM",
      title: "Sprint Review & Tech Sync",
      roomName: "Innovation Hub",
      floor: "Floor 3",
    ),
    MeetingActivity(
      date: DateTime(DateTime.now().year, DateTime.now().month, 24),
      time: "02:30 PM - 03:30 PM",
      title: "Client Pitch Session",
      roomName: "Focus Room B",
      floor: "Floor 2",
    ),
    MeetingActivity(
      date: DateTime(DateTime.now().year, DateTime.now().month, 28),
      time: "09:00 AM - 10:00 AM",
      title: "HR Monthly Catchup",
      roomName: "Boardroom Alpha",
      floor: "Floor 2",
    ),
  ];

  // Mock data structure for rooms with time slot schedules
  final List<RoomModel> _rooms = [
    RoomModel(
      id: 'r1',
      name: "Boardroom Alpha",
      floor: "Floor 2",
      capacity: "12 People",
      features: ["TV Display", "Video Conf", "Whiteboard"],
      slots: [
        TimeSlot("08:00 AM - 09:00 AM", isAvailable: true),
        TimeSlot("09:00 AM - 10:30 AM", isAvailable: false, bookedBy: "Executive Standup"),
        TimeSlot("10:30 AM - 12:00 PM", isAvailable: true),
        TimeSlot("03:00 PM - 04:00 PM", isAvailable: false, bookedBy: "Q3 Strategy Planning"),
        TimeSlot("04:00 PM - 05:00 PM", isAvailable: true),
      ],
    ),
    RoomModel(
      id: 'r2',
      name: "Innovation Hub",
      floor: "Floor 3",
      capacity: "6 People",
      features: ["TV Display", "Whiteboard"],
      slots: [
        TimeSlot("08:00 AM - 11:00 AM", isAvailable: true),
        TimeSlot("11:00 AM - 03:00 PM", isAvailable: false, bookedBy: "Design Sprint"),
        TimeSlot("03:00 PM - 05:00 PM", isAvailable: true),
      ],
    ),
    RoomModel(
      id: 'r3',
      name: "Focus Room B",
      floor: "Floor 2",
      capacity: "4 People",
      features: ["Acoustic Pod", "Monitors"],
      slots: [
        TimeSlot("08:00 AM - 10:00 AM", isAvailable: true),
        TimeSlot("10:00 AM - 11:30 AM", isAvailable: true),
        TimeSlot("01:00 PM - 03:00 PM", isAvailable: false, bookedBy: "Client Call"),
        TimeSlot("03:00 PM - 05:00 PM", isAvailable: true),
      ],
    ),
  ];

  // Open Full Month Calendar Dialog with Activity Filtering
  void _openFullCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FullCalendarMonthDialog(
          initialDate: _selectedDate,
          activities: _userActivities,
          onDateSelected: (newDate) {
            setState(() {
              _selectedDate = newDate;
            });
          },
        );
      },
    );
  }

  // Show detailed Schedule & Time Slot Viewer for specific room
  void _showRoomScheduleBottomSheet(RoomModel room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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

              // BottomSheet Header
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${_formatDateFormatted(_selectedDate)} • ${room.floor}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Time Slots Timeline List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  itemCount: room.slots.length,
                  itemBuilder: (context, index) {
                    final slot = room.slots[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: slot.isAvailable ? const Color(0xFFF8FAFC) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: slot.isAvailable ? const Color(0xFFE2E8F0) : const Color(0xFFFFEDD5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            color: slot.isAvailable ? const Color(0xFF059669) : const Color(0xFFEA580C),
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.timeRange,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  slot.isAvailable ? "Available for booking" : (slot.bookedBy ?? "Busy"),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: slot.isAvailable ? const Color(0xFF059669) : const Color(0xFFC2410C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: slot.isAvailable
                                ? () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Reserved ${room.name} for ${slot.timeRange}'),
                                        backgroundColor: const Color(0xFF1B3673),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B3673),
                              disabledBackgroundColor: const Color(0xFFE2E8F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              slot.isAvailable ? 'Book' : 'Busy',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: slot.isAvailable ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meeting Rooms',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          // Open Full Month Calendar Filter Button
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF1B3673)),
            ),
            onPressed: _openFullCalendarDialog,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        children: [
          // Header Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find & Book a Space",
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                ),
                SizedBox(height: 4.h),
                Text(
                  "HQ Building • Floor 2 & 3",
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Modern Horizontal Date Strip Selector
          _buildModernDateStrip(),

          SizedBox(height: 20.h),

          // Room List Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: _rooms.map((room) {
                final bool isAnyAvailable = room.slots.any((s) => s.isAvailable);
                return _buildRoomCard(room, isAnyAvailable);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Modern Date Ribbon Widget
  Widget _buildModernDateStrip() {
    final DateTime today = DateTime.now();
    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1B3673) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1B3673) : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1B3673).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getWeekdayShort(date.weekday),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room, bool isAvailable) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${room.floor} • Capacity: ${room.capacity}",
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  isAvailable ? "Slots Open" : "Occupied Today",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: isAvailable ? const Color(0xFF059669) : const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: room.features
                .map((f) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _showRoomScheduleBottomSheet(room),
            child: Container(
              height: 44.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isAvailable ? const Color(0xFF1B3673) : const Color(0xFF64748B),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isAvailable ? "Reserve Slot" : "View Schedule",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getWeekdayShort(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  String _formatDateFormatted(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ============================================================================
// FULL MONTH CALENDAR DIALOG WITH ACTIVITY FILTERING
// ============================================================================

class FullCalendarMonthDialog extends StatefulWidget {
  final DateTime initialDate;
  final List<MeetingActivity> activities;
  final ValueChanged<DateTime> onDateSelected;

  const FullCalendarMonthDialog({
    super.key,
    required this.initialDate,
    required this.activities,
    required this.onDateSelected,
  });

  @override
  State<FullCalendarMonthDialog> createState() => _FullCalendarMonthDialogState();
}

class _FullCalendarMonthDialogState extends State<FullCalendarMonthDialog> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDay = widget.initialDate;
  }

  // Helper methods for Calendar Grid
  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  int _firstWeekdayOffset(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday - 1; // 0 = Monday
  }

  bool _hasActivityOnDate(DateTime date) {
    return widget.activities.any((a) =>
        a.date.day == date.day &&
        a.date.month == date.month &&
        a.date.year == date.year);
  }

  List<MeetingActivity> _getActivitiesForDate(DateTime date) {
    return widget.activities
        .where((a) =>
            a.date.day == date.day &&
            a.date.month == date.month &&
            a.date.year == date.year)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _daysInMonth(_focusedMonth);
    final offset = _firstWeekdayOffset(_focusedMonth);
    final filteredActivities = _getActivitiesForDate(_selectedDay);

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: const Color(0xFF64748B),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: const Color(0xFF64748B),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 12.h),

            // Days of the Week Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((day) => SizedBox(
                        width: 36.w,
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 8.h),

            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offset + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                if (index < offset) {
                  return const SizedBox.shrink();
                }

                final dayNum = index - offset + 1;
                final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
                final isSelected = cellDate.day == _selectedDay.day &&
                    cellDate.month == _selectedDay.month &&
                    cellDate.year == _selectedDay.year;
                final hasActivity = _hasActivityOnDate(cellDate);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = cellDate;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1B3673) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1B3673) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (hasActivity)
                          Positioned(
                            bottom: 4.h,
                            child: Container(
                              width: 5.r,
                              height: 5.r,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : const Color(0xFFEA580C),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 16.h),
            const Divider(color: Color(0xFFF1F5F9)),

            // Filtered Activity List Header
            Text(
              'Activities on ${_selectedDay.day} ${monthNames[_selectedDay.month - 1]}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 10.h),

            // Activities for Selected Date
            SizedBox(
              height: 120.h,
              child: filteredActivities.isEmpty
                  ? Center(
                      child: Text(
                        'No meetings scheduled for this day',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredActivities.length,
                      itemBuilder: (context, index) {
                        final act = filteredActivities[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFFFEDD5)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_seat_rounded,
                                color: const Color(0xFFEA580C),
                                size: 18.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      act.title,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${act.time} • ${act.roomName} (${act.floor})',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: const Color(0xFFC2410C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: 12.h),

            // Dialog Apply Action Button
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDateSelected(_selectedDay);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3673),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Apply Filter Date',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

// Data models
class RoomModel {
  final String id;
  final String name;
  final String floor;
  final String capacity;
  final List<String> features;
  final List<TimeSlot> slots;

  RoomModel({
    required this.id,
    required this.name,
    required this.floor,
    required this.capacity,
    required this.features,
    required this.slots,
  });
}

class TimeSlot {
  final String timeRange;
  final bool isAvailable;
  final String? bookedBy;

  TimeSlot(this.timeRange, {required this.isAvailable, this.bookedBy});
}