import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/di/injection_container.dart';
import 'package:mdm_hris/core/services/network_connectivity_service.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/daily_attendance.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_modal_bottom_sheet.dart';
import 'compact_attendance_card.dart';
import 'dashboard/dashboard_attendance_stats_grid.dart';
import 'dashboard/dashboard_header.dart';
import 'dashboard/dashboard_recent_activity_section.dart';
import 'dashboard/dashboard_subheader.dart';
import 'language_swap_button.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.open,
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Widget) open;

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late AppLanguage _currentLanguage = AppLanguageController.currentLanguage;

  ApiClient get api => widget.api;
  Workspace get w => widget.workspace;
  Future<void> Function(Widget) get open => widget.open;

  bool get _isOnline => sl.isRegistered<NetworkConnectivityService>()
      ? sl<NetworkConnectivityService>().isOnline
      : true;

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppLanguageController.currentLanguage;
    AppLanguageController.instance.addListener(_onGlobalLanguageChanged);
    if (sl.isRegistered<NetworkConnectivityService>()) {
      sl<NetworkConnectivityService>().isOnlineNotifier.addListener(_onConnectivityChanged);
    }
  }

  void _onConnectivityChanged() {
    if (mounted) setState(() {});
  }

  void _onGlobalLanguageChanged() {
    if (mounted && _currentLanguage != AppLanguageController.currentLanguage) {
      setState(() => _currentLanguage = AppLanguageController.currentLanguage);
    }
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_onGlobalLanguageChanged);
    if (sl.isRegistered<NetworkConnectivityService>()) {
      sl<NetworkConnectivityService>().isOnlineNotifier.removeListener(_onConnectivityChanged);
    }
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (sl.isRegistered<NetworkConnectivityService>()) {
      await sl<NetworkConnectivityService>().checkConnection();
    }
    await widget.onRefresh();
  }

  Future<void> _openAttendanceModal(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => AttendanceModalBottomSheet(
        api: api,
        workspace: w,
      ),
    );
    if (mounted) {
      await _handleRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final daily = DailyAttendance(w);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            children: [
              DashboardHeader(
                workspace: w,
                api: api,
                currentLanguage: _currentLanguage,
                isOnline: _isOnline,
                onLanguageChanged: (lang) => setState(() => _currentLanguage = lang),
                open: open,
              ),
              SizedBox(height: 14.w),
              DashboardSubheader(
                workspace: w,
                currentLanguage: _currentLanguage,
              ),
              SizedBox(height: 12.w),
              CompactAttendanceCard(
                workspace: w,
                daily: daily,
                language: _currentLanguage,
                onActionPressed: daily.completed
                    ? null
                    : () => _openAttendanceModal(context),
              ),
              DashboardAttendanceStatsGrid(
                workspace: w,
                currentLanguage: _currentLanguage,
              ),
              const SizedBox(height: 16),
              DashboardRecentActivitySection(
                workspace: w,
                api: api,
                currentLanguage: _currentLanguage,
                open: open,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
