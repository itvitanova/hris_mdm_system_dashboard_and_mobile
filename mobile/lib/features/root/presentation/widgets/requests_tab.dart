import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../shared/widgets.dart';
import '../../../home/leave_calendar_screen.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_detail.dart';
import '../../../requests/request_notifications.dart';
import '../../../requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import '../../../requests/presentation/models/mock_universal_requests.dart';

class _TabMeta {
  final SubmissionKind kind;
  final String label;
  final String fabText;

  const _TabMeta({
    required this.kind,
    required this.label,
    required this.fabText,
  });
}

const List<_TabMeta> _tabCategories = [
  _TabMeta(
    kind: SubmissionKind.cuti,
    label: 'Cuti & Izin',
    fabText: 'Ajukan Cuti',
  ),
  _TabMeta(
    kind: SubmissionKind.lembur,
    label: 'Lembur',
    fabText: 'Ajukan Lembur',
  ),
  _TabMeta(
    kind: SubmissionKind.reimbursement,
    label: 'Reimbursement',
    fabText: 'Buat Klaim',
  ),
  _TabMeta(
    kind: SubmissionKind.pettyCash,
    label: 'Petty Cash',
    fabText: 'Ajukan Kas Kecil',
  ),
  _TabMeta(
    kind: SubmissionKind.generalAffair,
    label: 'General Affair',
    fabText: 'Permintaan GA',
  ),
];

/// Halaman Pengajuan Terpadu (Single-Page Direct View)
/// Mengintegrasikan 5 kategori pengajuan mandiri dengan Top Scrollable TabBar,
/// Dynamic FAB, dan Filter Status inline tanpa banner dekoratif.
class RequestsTab extends StatefulWidget {
  const RequestsTab({
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
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  SubmissionStatus? _selectedStatusFilter;

  Workspace get w => widget.workspace;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCategories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  List<UniversalRequestModel> _getRequestsForKind(SubmissionKind kind) {
    final rows = w.mine('requests');
    final List<UniversalRequestModel> items = [];

    // 1. Data riil dari workspace
    for (final r in rows) {
      final model = UniversalRequestModel.fromMap(r);
      if (model.kind == kind) {
        items.add(model);
      }
    }

    // 2. Data mock jika belum ada data riil serupa
    for (final m in mockUniversalRequests) {
      if (m.kind == kind && !items.any((x) => x.title == m.title)) {
        items.add(m);
      }
    }

    // 3. Filter berdasarkan status jika ada yang dipilih
    if (_selectedStatusFilter != null) {
      return items.where((it) => it.status == _selectedStatusFilter).toList();
    }

    return items;
  }

  void _openCreateForm(SubmissionKind kind) {
    widget.open(
      RequestForm(
        api: widget.api,
        workspace: widget.workspace,
        initialKind: kind.displayName,
        lockKindSelection: true,
      ),
    );
  }

  Widget _filterChip(SubmissionStatus? status, String label) {
    final isSelected = _selectedStatusFilter == status;
    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = status),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x200F766E),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = w.mine('requests');
    final unreadCount = rows.where((r) => r['unread'] == true).length;
    final activeMeta = _tabCategories[_tabController.index];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Pengajuan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Kalender cuti',
            onPressed: () => widget.open(
              LeaveCalendarScreen(api: widget.api, workspace: w),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            tooltip: 'Notifikasi pengajuan',
            onPressed: () => widget.open(
              RequestNotificationsScreen(api: widget.api, workspace: w),
            ),
            icon: Badge.count(
              count: unreadCount,
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          if (w.data['approvalAccess'] == true)
            IconButton(
              tooltip: 'Persetujuan',
              onPressed: () => widget.open(ApprovalsScreen(api: widget.api)),
              icon: Badge(
                label: Text(
                  '${w.rows("requests").where((r) => r["canReview"] == true).length}',
                ),
                child: const Icon(Icons.fact_check_outlined),
              ),
            ),
          IconButton(
            tooltip: 'Segarkan data',
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFF0F766E),
              indicatorWeight: 2.5,
              labelColor: const Color(0xFF0F766E),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelColor: const Color(0xFF64748B),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: _tabCategories.map((meta) => Tab(text: meta.label)).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330F766E),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          onPressed: () => _openCreateForm(activeMeta.kind),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: Text(
            activeMeta.fabText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Status Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(null, 'Semua'),
                    const SizedBox(width: 8),
                    _filterChip(SubmissionStatus.menunggu, 'Menunggu'),
                    const SizedBox(width: 8),
                    _filterChip(SubmissionStatus.disetujui, 'Disetujui'),
                    const SizedBox(width: 8),
                    _filterChip(SubmissionStatus.perluRevisi, 'Perlu Revisi'),
                    const SizedBox(width: 8),
                    _filterChip(SubmissionStatus.ditolak, 'Ditolak'),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabCategories.map((meta) {
                  final items = _getRequestsForKind(meta.kind);
                  return RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                            children: [
                              EmptyState(
                                'Belum ada pengajuan ${meta.label.toLowerCase()}.',
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: UniversalRequestCard(
                                  data: item,
                                  onDetailPressed: () => widget.open(
                                    RequestDetailScreen(
                                      api: widget.api,
                                      request: item.toMap(),
                                      own: true,
                                    ),
                                  ),
                                  onRevisePressed: () => widget.open(
                                    RequestForm(
                                      api: widget.api,
                                      workspace: widget.workspace,
                                      initialKind: item.kind.displayName,
                                      initialRequest: item.toMap(),
                                      lockKindSelection: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
