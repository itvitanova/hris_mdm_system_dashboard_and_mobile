import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/di/injection_container.dart';
import 'package:mdm_hris/core/services/network_connectivity_service.dart';
import 'package:mdm_hris/core/services/offline_sync_manager.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/home/presentation/pages/leave_calendar_page.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_bloc.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_event.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_state.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_detail_page.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_notifications_page.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import 'package:mdm_hris/features/home/presentation/bloc/workspace_bloc.dart';
import 'package:mdm_hris/features/home/presentation/bloc/workspace_state.dart';
import 'language_swap_button.dart';
import 'requests/requests_app_bar.dart';
import 'requests/requests_catalog_section.dart';
import 'requests/requests_hero_action_banner.dart';
import 'requests/requests_offline_banner.dart';
import 'requests/requests_recent_section.dart';

/// Halaman Hub Pengajuan Utama (Tab 'Pengajuan' di Bottom Navbar)
class RequestsTab extends StatefulWidget {
  const RequestsTab({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.open,
    this.initialLanguage = AppLanguage.id,
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Widget) open;
  final AppLanguage initialLanguage;

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  late AppLanguage _currentLanguage = widget.initialLanguage != AppLanguage.id
      ? widget.initialLanguage : AppLanguageController.currentLanguage;
  String _selectedFilter = 'Semua';

  ApiClient get api => widget.api;
  Workspace get w {
    try {
      final state = BlocProvider.of<WorkspaceBloc>(context).state;
      if (state is WorkspaceLoaded) return state.workspace;
    } catch (_) {}
    return widget.workspace;
  }

  Future<void> Function() get onRefresh => widget.onRefresh;
  Future<void> Function(Widget) get open => widget.open;

  RequestBloc? _tryGetRequestBloc(BuildContext context) {
    try {
      return BlocProvider.of<RequestBloc>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  bool get _isOnline => sl.isRegistered<NetworkConnectivityService>()
      ? sl<NetworkConnectivityService>().isOnline : true;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage != AppLanguage.id
        ? widget.initialLanguage : AppLanguageController.currentLanguage;
    AppLanguageController.instance.addListener(_onGlobalLanguageChanged);
    if (sl.isRegistered<NetworkConnectivityService>()) {
      sl<NetworkConnectivityService>().isOnlineNotifier.addListener(_onConnectivityChanged);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tryGetRequestBloc(context)?.add(const RequestLoadRequested());
    });
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
    if (sl.isRegistered<OfflineSyncManager>()) {
      await sl<OfflineSyncManager>().syncPendingRequests();
    }
    await widget.onRefresh();
    if (mounted) _tryGetRequestBloc(context)?.add(const RequestLoadRequested());
  }

  Future<void> _navigateAndRefresh(Widget target) async {
    await open(target);
    if (mounted) await _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _tryGetRequestBloc(context);
    if (bloc != null) {
      return BlocBuilder<RequestBloc, RequestState>(
        bloc: bloc,
        builder: (context, state) {
          final rows = (state is RequestsLoaded && state.activeKind == null)
              ? state.requests
              : w.mine('requests');
          return _buildScaffold(context, rows);
        },
      );
    }
    return _buildScaffold(context, w.mine('requests'));
  }

  Widget _buildScaffold(BuildContext context, List<Map<String, dynamic>> rows) {
    final isEn = _currentLanguage == AppLanguage.en;
    final unreadCount = rows.where((r) => r['unread'] == true).length;
    final allRawItems = List<Map<String, dynamic>>.from(rows);
    final allModels = allRawItems.map((r) => UniversalRequestModel.fromMap(r)).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: RequestsAppBar(
        isEn: isEn,
        unreadCount: unreadCount,
        onCalendarTap: () => _navigateAndRefresh(LeaveCalendarScreen(api: api, workspace: w)),
        onNotificationTap: () => _navigateAndRefresh(RequestNotificationsScreen(api: api, workspace: w)),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            children: [
              if (!_isOnline) RequestsOfflineBanner(isEn: isEn),
              RequestsHeroActionBanner(
                isEn: isEn,
                onApprovalCenterPressed: () => _navigateAndRefresh(ApprovalsScreen(api: api)),
              ),
              RequestsCatalogSection(
                isEn: isEn,
                currentLanguage: _currentLanguage,
                api: api,
                workspace: w,
                open: open,
                onRefresh: _handleRefresh,
                allModels: allModels,
                onNavigate: _navigateAndRefresh,
              ),
              SizedBox(height: 24.h),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              SizedBox(height: 18.h),
              RequestsRecentSection(
                isEn: isEn,
                currentLanguage: _currentLanguage,
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
                allModels: allModels,
                allRawItems: allRawItems,
                onNavigate: _navigateAndRefresh,
                api: api,
                workspace: w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
