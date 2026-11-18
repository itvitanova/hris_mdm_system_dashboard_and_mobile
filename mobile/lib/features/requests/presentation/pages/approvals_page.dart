import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../core/workspace.dart';
import '../../../home/presentation/bloc/workspace_bloc.dart';
import '../../../home/presentation/bloc/workspace_event.dart';
import '../../../root/presentation/widgets/language_swap_button.dart';
import '../widgets/approvals/approvals_app_bar.dart';
import '../widgets/approvals/approvals_filter_helper.dart';
import '../widgets/approvals/approvals_hero_banner.dart';
import '../widgets/approvals/approvals_pagination_bar.dart';
import '../widgets/approvals/approvals_request_item.dart';
import '../widgets/approvals/approvals_search_bar.dart';
import '../widgets/approvals/approvals_segmented_filter_bar.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key, required this.api});
  final ApiClient api;

  @override
  State<ApprovalsScreen> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<ApprovalsScreen> {
  static const int _itemsPerPage = 10;
  int _currentPage = 1;
  Workspace? workspace;
  String? error;
  bool history = false, changed = false;
  String query = '';
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    AppLanguageController.instance.addListener(_onLanguageChanged);
    load();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _onPageChanged(int newPage) {
    setState(() => _currentPage = newPage);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_onLanguageChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final next = Workspace(await widget.api.workspace());
      if (mounted) setState(() => workspace = next);
      if (sl.isRegistered<WorkspaceBloc>()) {
        sl<WorkspaceBloc>().add(const WorkspaceRefreshRequested());
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = workspace;
    final allRequests = w?.rows('requests') ?? <Json>[];
    final actorId = w?.actor['employeeId'];
    final pendingCount = allRequests
        .where((r) => r['employeeId'] != actorId && r['canReview'] == true)
        .length;

    final rows = ApprovalsFilterHelper.filterRows(
      workspace: w, actorId: actorId, history: history, query: query,
    );

    final totalItems = rows.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 999999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final pagedRows = totalItems == 0 || startIndex >= totalItems
        ? <Json>[]
        : rows.sublist(startIndex, endIndex);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: ApprovalsAppBar(
          canPop: Navigator.of(context).canPop(),
          onBack: () => Navigator.pop(context, changed),
          onRefresh: load,
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            color: const Color(0xFF0F766E),
            onRefresh: load,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
              children: [
                ApprovalsHeroBanner(pendingCount: pendingCount),
                SizedBox(height: 16.h),
                ApprovalsSegmentedFilterBar(
                  history: history,
                  pendingCount: pendingCount,
                  onChanged: (val) => setState(() {
                    history = val;
                    _currentPage = 1;
                  }),
                ),
                SizedBox(height: 14.h),
                ApprovalsSearchBar(
                  controller: _searchController,
                  query: query,
                  onChanged: (v) => setState(() {
                    query = v;
                    _currentPage = 1;
                  }),
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      query = '';
                      _currentPage = 1;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                if (error != null) ...[
                  ErrorNotice(error!),
                  SizedBox(height: 8.h),
                  Center(
                    child: TextButton.icon(
                      onPressed: load,
                      icon: Icon(UIcons.regularRounded.refresh,
                          color: const Color(0xFF0F766E)),
                      label: const Text('Coba lagi',
                          style: TextStyle(color: Color(0xFF0F766E))),
                    ),
                  ),
                ],
                if (w == null && error == null)
                  const LinearProgressIndicator(color: Color(0xFF0F766E)),
                if (w != null && w.data['approvalAccess'] != true)
                  const ErrorNotice(
                      'Anda belum ditetapkan sebagai pemberi persetujuan.')
                else if (w != null && rows.isEmpty)
                  const EmptyState('Tidak ada pengajuan yang sesuai.')
                else ...[
                  for (final r in pagedRows)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ApprovalsRequestItem(
                        api: widget.api,
                        r: r,
                        workspace: w,
                        onChanged: () async {
                          changed = true;
                          await load();
                        },
                      ),
                    ),
                  ApprovalsPaginationBar(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    totalItems: totalItems,
                    onPageChanged: _onPageChanged,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
