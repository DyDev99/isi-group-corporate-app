import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/core/auth/auth_guard.dart';
import 'package:isi_group_corporate_app/core/di/injection_container.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/fast_actions/edit_fast_actions_bottom_sheet.dart' hide CustomBottomNavBar;
import 'package:isi_group_corporate_app/features/digital_docs/presentation/screens/digital_docs_screen.dart';
import 'package:isi_group_corporate_app/features/directory/presentation/bloc/directory_bloc.dart';
import 'package:isi_group_corporate_app/features/directory/presentation/pages/directory_screen.dart';
import 'package:isi_group_corporate_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/presentation/bloc/hr_chat_bloc.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/presentation/pages/hr_ai_assistant_screen.dart';
import 'package:isi_group_corporate_app/features/hubs/presentation/bloc/cubit/resumable_visit_cubit.dart';
import 'package:isi_group_corporate_app/features/hubs/presentation/screens/hubs_screen.dart';
import 'package:isi_group_corporate_app/features/it_help/presentation/screens/it_help_screen.dart';
import 'package:isi_group_corporate_app/features/leave_request/presentation/screens/leave_request_screen.dart';
import 'package:isi_group_corporate_app/features/meeting_rooms/presentation/screens/meeting_rooms_screen.dart';
import 'package:isi_group_corporate_app/features/notification/domain/usecases/fetch_notifications.dart';
import 'package:isi_group_corporate_app/features/notification/presentation/screen/notifications_sheet.dart';
import 'package:isi_group_corporate_app/features/performance/presentation/screens/performance_screen.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/bottom_navigation/custom_bottom_nav_bar.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/dashboard/home_dashboard.dart';
import 'package:isi_group_corporate_app/features/shell/presentation/widgets/fast_actions/edit_fast_actions_bottom_sheet.dart';
import 'package:isi_group_corporate_app/features/time_attendance/presentation/screens/time_attendance_screen.dart';
import 'package:isi_group_corporate_app/features/travel/presentation/screens/travel_screen.dart';

// Assuming GridBackground is accessible here based on your previous file structure
// import 'package:isi_group_corporate_app/shared/widgets/grid_background.dart';

/// Coordinates the persistent shell state and delegates dashboard UI to widgets.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};
  
  // 1. INCREASED DURATION FOR SMOOTHER SETTLE
  late final AnimationController _tabTransition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400), 
    value: 1,
  );
  
  List<FastActionTool> _userFastActions = [
    FastActionTool(id: 'leave', title: 'Apply Leave', icon: Icons.calendar_month_outlined, isEnabled: true),
    FastActionTool(id: 'expense', title: 'Expense', icon: Icons.receipt_long_outlined, isEnabled: true),
    FastActionTool(id: 'room', title: 'Book Room', icon: Icons.local_cafe_outlined, isEnabled: true),
    FastActionTool(id: 'it_help', title: 'IT Help', icon: Icons.support_outlined, isEnabled: true),
    FastActionTool(id: 'performance', title: 'Performance', icon: Icons.percent_rounded, isEnabled: true),
    FastActionTool(id: 'docs', title: 'Digital Docs', icon: Icons.description_outlined, isEnabled: true),
    FastActionTool(id: 'time_attendance', title: 'Attendance', icon: Icons.access_time_filled_outlined, isEnabled: true),
    FastActionTool(id: 'travel', title: 'Travel', icon: Icons.airplane_ticket_sharp, isEnabled: true),
  ];

  @override
  void dispose() {
    _tabTransition.dispose();
    super.dispose();
  }

  void _handleNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _visitedTabs.add(index);
    });
    _tabTransition.forward(from: 0);
  }

  Widget _tab(int index, Widget Function() builder) =>
      _visitedTabs.contains(index) ? builder() : const SizedBox.shrink();

  /// Handles opening the profile by switching the main tab to index 4
  Future<void> _openProfile() async {
    final allowed = await AuthGuard.requireAuthentication(context);
    if (!allowed || !mounted) return;
    _handleNavTap(4); // Switches directly to Profile tab in bottom nav
  }

  void _openNotifications() {
    showNotificationsSheet(
      context: context,
      fetchNotifications: sl<FetchNotifications>(),
    );
  }

  void _onDashboardTap() {
   _navigateToTool('performance');
  }

  void _editFastActions() => EditFastActionsBottomSheet.show(
        context,
        currentTools: _userFastActions,
        onSaved: (tools) => setState(() => _userFastActions = List.of(tools)),
      );

  void _navigateToTool(String id) {
    final screens = <String, Widget>{
      'leave': const LeaveRequestScreen(),
      'expense': const ExpensesScreen(),
      'room': const MeetingRoomsScreen(),
      'it_help': const ITHelpScreen(),
      'performance': const PerformanceScreen(),
      'docs': const DigitalDocsScreen(),
      'time_attendance': const TimeAttendanceScreen(),
      'travel': const TravelScreen(),
    };
    final screen = screens[id];
    if (screen != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ResumableVisitCubit()..refresh()),
          BlocProvider(create: (_) => sl<DirectoryBloc>()..add(const DirectoryStarted())),
          BlocProvider(create: (_) => sl<HrChatBloc>()..add(const HrChatStarted())),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Unified soft background
          body: AnimatedBuilder(
            animation: _tabTransition,
            builder: (context, child) {
              // 2. UPDATED TO EASE_OUT_EXPO FOR PREMIUM FLUID MOTION
              final t = Curves.easeOutExpo.transform(_tabTransition.value);
              return Opacity(
                opacity: 0.2 + 0.8 * t, // Softer fade-in progression
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 24), // Extended glide distance (24px)
                  child: Transform.scale(
                    scale: 0.95 + 0.05 * t, // Slightly deeper zoom effect
                    child: child,
                  ),
                ),
              );
            },
            child: IndexedStack(
              index: _currentIndex,
              sizing: StackFit.expand,
              children: [
                _tab(
                  0,
                  () => HomeDashboard(
                    fastActions: _userFastActions,
                    onDashboardTap: _onDashboardTap,
                    onOpenProfile: _openProfile,
                    onOpenNotifications: _openNotifications,
                    onEditFastActions: _editFastActions,
                    onToolTap: _navigateToTool,
                  ),
                ),
                _tab(1, () => const AppHubScreen()),
                _tab(2, () => const HrAiAssistantScreen()),
                _tab(3, () => const DirectoryScreen()),
                _tab(
                  4,
                  () => BlocProvider(
                    create: (_) => sl<ProfileCubit>(),
                    child: const ProfileScreen(),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _handleNavTap,
          ),
        ),
      );
}