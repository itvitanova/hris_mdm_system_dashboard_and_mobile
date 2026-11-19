import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/home/presentation/bloc/workspace_bloc.dart';
import 'package:mdm_hris/features/home/presentation/bloc/workspace_state.dart';
import 'package:mdm_hris/features/home/presentation/pages/leave_calendar_page.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_bloc.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_event.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_state.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_detail_page.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_form_page.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_notifications_page.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/modules/module_app_bar.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/modules/module_localization_helper.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/modules/module_request_query_helper.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/modules/module_screen_content.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

export '../../../../requests/domain/entities/submission_kind.dart';

/// Halaman Khusus (Dedicated Screen) untuk Setiap Modul Pengajuan Mandiri
class DedicatedModuleScreen extends StatefulWidget {
  const DedicatedModuleScreen({
    super.key,
    required this.kind,
    required this.moduleTitle,
    required this.keyMetricLabel,
    required this.keyMetricValue,
    required this.keyMetricIcon,
    required this.api,
    required this.workspace,
    required this.open,
    required this.onRefresh,
    this.customActions,
    this.initialLanguage = AppLanguage.id,
  });

  final SubmissionKind kind;
  final String moduleTitle, keyMetricLabel, keyMetricValue;
  final IconData keyMetricIcon;
  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function(Widget) open;
  final Future<void> Function() onRefresh;
  final List<Widget>? customActions;
  final AppLanguage initialLanguage;

  @override
  State<DedicatedModuleScreen> createState() => _DedicatedModuleScreenState();
}

class _DedicatedModuleScreenState extends State<DedicatedModuleScreen> {
  static const int _itemsPerPage = 5;
  final ScrollController _scrollController = ScrollController();
  late AppLanguage _currentLanguage = widget.initialLanguage != AppLanguage.id
      ? widget.initialLanguage
      : AppLanguageController.currentLanguage;
  SubmissionStatus? _selectedStatusFilter;
  int _currentPage = 1;

  Workspace get w {
    try {
      final s = BlocProvider.of<WorkspaceBloc>(context).state;
      if (s is WorkspaceLoaded) return s.workspace;
    } catch (_) {}
    return widget.workspace;
  }

  RequestBloc? _tryGetRequestBloc(BuildContext context) {
    try { return BlocProvider.of<RequestBloc>(context); } catch (_) { return null; }
  }

  @override
  void initState() {
    super.initState();
    AppLanguageController.instance.addListener(_onGlobalLanguageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryGetRequestBloc(context)?.add(RequestLoadRequested(kind: widget.kind.displayName));
    });
  }

  void _onGlobalLanguageChanged() {
    if (mounted && widget.initialLanguage == AppLanguage.id) {
      setState(() => _currentLanguage = AppLanguageController.currentLanguage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    AppLanguageController.instance.removeListener(_onGlobalLanguageChanged);
    super.dispose();
  }

  void _changePage(int page) {
    setState(() => _currentPage = page);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  Future<void> _handleRefresh() async {
    await widget.onRefresh();
    if (mounted) {
      _tryGetRequestBloc(context)?.add(RequestLoadRequested(kind: widget.kind.displayName));
      setState(() => _currentPage = 1);
    }
  }

  Future<void> _navigateAndRefresh(Widget target) async {
    await widget.open(target);
    if (mounted) await _handleRefresh();
  }

  void _openCreateForm() => _navigateAndRefresh(RequestForm(
    api: widget.api, workspace: widget.workspace,
    initialKind: widget.kind.displayName, lockKindSelection: true));

  void _openDetail(UniversalRequestModel m) => _navigateAndRefresh(
    RequestDetailScreen(api: widget.api, request: m.rawMap ?? m.toMap(), own: true));

  void _openRevise(UniversalRequestModel m) => _navigateAndRefresh(
    RequestForm(api: widget.api, workspace: w, initialKind: m.kind.displayName,
      initialRequest: m.rawMap ?? m.toMap(), lockKindSelection: true));

  @override
  Widget build(BuildContext context) {
    final requestBloc = _tryGetRequestBloc(context);
    if (requestBloc != null) {
      return BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          final rows = state is RequestsLoaded
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
    final all = ModuleRequestQueryHelper.getAllKindRequests(rows, widget.kind);
    final counts = ModuleRequestCounts.calculate(rows, all);
    final filtered = ModuleRequestQueryHelper.filterByStatus(all, _selectedStatusFilter);

    final totalItems = filtered.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 99999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final paginated = filtered.isEmpty ? <UniversalRequestModel>[] : filtered.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: ModuleAppBar(
        kind: widget.kind,
        title: ModuleLocalizationHelper.getModuleTitle(widget.kind, _currentLanguage, widget.moduleTitle),
        subtitle: ModuleLocalizationHelper.getModuleSubtitle(widget.kind, _currentLanguage),
        unreadCount: counts.unread,
        onBack: () => Navigator.of(context).pop(),
        onOpenCalendar: () => _navigateAndRefresh(LeaveCalendarScreen(api: widget.api, workspace: widget.workspace)),
        onOpenNotifications: () => _navigateAndRefresh(RequestNotificationsScreen(api: widget.api, workspace: widget.workspace)),
        customActions: widget.customActions,
      ),
      body: SafeArea(
        top: false,
        child: ModuleScreenContent(
          scrollController: _scrollController,
          kind: widget.kind,
          language: _currentLanguage,
          isEn: isEn,
          approvedCount: counts.approved,
          pendingCount: counts.pending,
          rejectedCount: counts.rejected,
          revisionCount: counts.revision,
          selectedStatusFilter: _selectedStatusFilter,
          filteredRequests: filtered,
          paginatedRequests: paginated,
          totalItems: totalItems,
          currentPage: currentPage,
          totalPages: totalPages,
          startIndex: startIndex,
          endIndex: endIndex,
          onRefresh: _handleRefresh,
          onCreatePressed: _openCreateForm,
          onSelectStatus: (status) => setState(() { _selectedStatusFilter = status; _currentPage = 1; }),
          onDetailPressed: _openDetail,
          onRevisePressed: _openRevise,
          onPageChanged: _changePage,
        ),
      ),
    );
  }
}
