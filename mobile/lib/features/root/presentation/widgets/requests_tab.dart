import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/leave_calendar_screen.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_detail.dart';
import '../../../requests/request_notifications.dart';
import '../../../requests/presentation/bloc/request_bloc.dart';
import '../../../requests/presentation/bloc/request_event.dart';
import '../../../requests/presentation/bloc/request_state.dart';
import '../../../requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import '../../../requests/presentation/widgets/services_hub/service_module_card.dart';
import '../../../requests/presentation/pages/modules/dedicated_module_screen.dart';
import '../../../home/presentation/bloc/workspace_bloc.dart';
import '../../../home/presentation/bloc/workspace_state.dart';
import 'package:uicons/uicons.dart';
import 'language_swap_button.dart';

/// Halaman Hub Pengajuan Utama (Tab 'Pengajuan' di Bottom Navbar)
/// Berisi Hero Action Banner, Bento Layout Simetris 5 Modul Layanan Mandiri,
/// serta Seksi Pengajuan Terkini dengan Interactive Status Chip Filter.
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
      ? widget.initialLanguage
      : AppLanguageController.currentLanguage;
  String _selectedFilter = 'Semua';

  ApiClient get api => widget.api;
  Workspace get w {
    try {
      final state = BlocProvider.of<WorkspaceBloc>(context).state;
      if (state is WorkspaceLoaded) {
        return state.workspace;
      }
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

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage != AppLanguage.id
        ? widget.initialLanguage
        : AppLanguageController.currentLanguage;
    AppLanguageController.instance.addListener(_onGlobalLanguageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tryGetRequestBloc(context)?.add(const RequestLoadRequested());
      }
    });
  }

  void _onGlobalLanguageChanged() {
    if (mounted && _currentLanguage != AppLanguageController.currentLanguage) {
      setState(() {
        _currentLanguage = AppLanguageController.currentLanguage;
      });
    }
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_onGlobalLanguageChanged);
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await widget.onRefresh();
    if (mounted) {
      _tryGetRequestBloc(context)?.add(const RequestLoadRequested());
    }
  }

  Future<void> _navigateAndRefresh(Widget target) async {
    await open(target);
    if (mounted) {
      await _handleRefresh();
    }
  }

  Widget _buildHeroActionBanner() {
    final isEn = _currentLanguage == AppLanguage.en;
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F766E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 105.w,
              height: 105.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -30.h,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 7.w,
                vertical: 2.5.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    isEn ? 'Self-Service Hub' : 'Pusat Layanan Mandiri',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isEn
                  ? 'Service & Approval Center'
                  : 'Pusat Layanan & Persetujuan',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              isEn
                  ? 'Review team approvals or access submission forms via the self-service modules below.'
                  : 'Tinjau persetujuan pengajuan tim kerja atau akses formulir melalui modul layanan mandiri di bawah.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.3,
              ),
            ),
            SizedBox(height: 12.h),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateAndRefresh(ApprovalsScreen(api: api)),
                borderRadius: BorderRadius.circular(5.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 13.w,
                    vertical: 7.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        UIcons.regularRounded.list_check,
                        size: 15.w,
                        color: const Color(0xFF0F766E),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        isEn ? 'Approval Center' : 'Pusat Persetujuan',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }

  Widget _buildSegmentedFilterBar() {
    final isEn = _currentLanguage == AppLanguage.en;
    final segments = [
      (key: 'Semua', label: isEn ? 'All' : 'Semua'),
      (key: 'Menunggu', label: isEn ? 'Pending' : 'Menunggu'),
      (key: 'Selesai', label: isEn ? 'Finished' : 'Selesai'),
    ];

    return Container(
      height: 38.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: segments.map((segment) {
          final isSelected = _selectedFilter == segment.key;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('filter_segment_${segment.key}'),
                onTap: () {
                  setState(() {
                    _selectedFilter = segment.key;
                  });
                },
                borderRadius: BorderRadius.circular(7.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F766E), // Teal 700
                              Color(0xFF14B8A6), // Teal 500
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(7.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    segment.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
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

    // Data request riil karyawan dari workspace
    final allRawItems = List<Map<String, dynamic>>.from(rows);

    // Konversi ke model universal
    final allModels = allRawItems.map((r) => UniversalRequestModel.fromMap(r)).toList();

    // Kalkulasi metriks dinamis per modul
    final cutiRequests = allModels
        .where((m) => m.kind == SubmissionKind.cuti)
        .toList();
    final izinRequests = allModels
        .where((m) => m.kind == SubmissionKind.izin)
        .toList();
    final lemburRequests = allModels
        .where((m) => m.kind == SubmissionKind.lembur)
        .toList();
    final reimburseRequests = allModels
        .where((m) => m.kind == SubmissionKind.reimbursement)
        .toList();
    final medicalRequests = allModels
        .where((m) => m.kind == SubmissionKind.medicalClaim)
        .toList();
    final pettyCashRequests = allModels
        .where((m) => m.kind == SubmissionKind.pettyCash)
        .toList();
    final gaRequests = allModels
        .where((m) => m.kind == SubmissionKind.generalAffair)
        .toList();

    // 1. Cuti: Sisa kuota aktif (Base saldo kuota dikurangi pengajuan cuti berstatus Menunggu)
    final baseLeaveBalance = (w.employee['leaveBalance'] as num?)?.toInt() ?? 12;
    final pendingLeaveDays = cutiRequests
        .where((r) => r.status == SubmissionStatus.menunggu)
        .fold<int>(0, (sum, r) => sum + (r.days ?? 0));
    final currentLeaveBalance = (baseLeaveBalance - pendingLeaveDays).clamp(0, 999);
    final cutiMetricStr = '$currentLeaveBalance ${isEn ? 'Days' : 'Hari'}';

    // 2. Lembur: Total durasi jam lembur yang disetujui
    final totalLemburHours = lemburRequests
        .where((r) => r.status == SubmissionStatus.disetujui)
        .fold<int>(0, (sum, r) => sum + (r.hours ?? 0));
    final lemburMetricStr = '$totalLemburHours ${isEn ? 'Hours' : 'Jam'}';

    // 3. Reimbursement: Total nominal klaim yang disetujui
    final totalReimburseAmount = reimburseRequests
        .where((r) => r.status == SubmissionStatus.disetujui)
        .fold<int>(0, (sum, r) => sum + (r.amount ?? 0));
    final reimburseMetricStr = rupiah(totalReimburseAmount);

    // 4. Medical Claim: Total nominal klaim yang disetujui
    final totalMedicalAmount = medicalRequests
        .where((r) => r.status == SubmissionStatus.disetujui)
        .fold<int>(0, (sum, r) => sum + (r.amount ?? 0));
    final medicalMetricStr = rupiah(totalMedicalAmount);

    // 5. Petty Cash: Jumlah permohonan kas kecil yang diajukan
    final pettyCashMetricStr = '${pettyCashRequests.length} ${isEn ? 'Submissions' : 'Pengajuan'}';

    // 6. GA: Jumlah permohonan sarana GA aktif / terkini
    final activeGaCount = gaRequests
        .where((r) => r.status == SubmissionStatus.menunggu || r.status == SubmissionStatus.perluRevisi)
        .length;
    final gaMetricStr = activeGaCount > 0
        ? '$activeGaCount ${isEn ? 'Active' : 'Aktif'}'
        : '${gaRequests.length} ${isEn ? 'Submissions' : 'Pengajuan'}';

    // Terapkan filter status
    final filteredIndices = <int>[];
    for (int i = 0; i < allModels.length; i++) {
      final model = allModels[i];
      if (_selectedFilter == 'Semua') {
        filteredIndices.add(i);
      } else if (_selectedFilter == 'Menunggu') {
        if (model.status == SubmissionStatus.menunggu) {
          filteredIndices.add(i);
        }
      } else if (_selectedFilter == 'Selesai') {
        if (model.status == SubmissionStatus.disetujui ||
            model.status == SubmissionStatus.perluRevisi ||
            model.status == SubmissionStatus.ditolak) {
          filteredIndices.add(i);
        }
      }
    }

    final hasMoreThanTwo = filteredIndices.length > 2;

    // Ambil maksimal 2 kartu untuk menjaga feed tetap ringkas dan elegan
    final takenCards = filteredIndices.take(2).toList();
    final recentCards = takenCards.asMap().entries.map((entry) {
      final indexInList = entry.key;
      final idx = entry.value;
      final model = allModels[idx];
      final raw = allRawItems[idx];
      final isLastItem = indexInList == takenCards.length - 1;
      return Padding(
        padding: EdgeInsets.only(
          bottom: (isLastItem && !hasMoreThanTwo) ? 0 : 12.h,
        ),
        child: UniversalRequestCard(
          data: model,
          language: _currentLanguage,
          onDetailPressed: () => _navigateAndRefresh(
            RequestDetailScreen(
              api: api,
              request: raw,
              own: true,
            ),
          ),
          onRevisePressed: () => _navigateAndRefresh(
            RequestForm(
              api: api,
              workspace: w,
              initialKind: model.kind.displayName,
              initialRequest: raw,
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        titleSpacing: 20,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEn ? 'Submissions' : 'Pengajuan',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 1.5),
            Text(
              isEn
                  ? 'Self-Service & Employee Requests'
                  : 'Layanan & Permohonan Mandiri',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        actions: [
          // 1. Kalender Ulang Tahun (Smooth Soft-Slate Button)
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('requests_calendar_button'),
                borderRadius: BorderRadius.circular(11.r),
                onTap: () => _navigateAndRefresh(LeaveCalendarScreen(api: api, workspace: w)),
                child: Icon(
                  UIcons.regularRounded.calendar,
                  size: 16.w,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // 2. Notifikasi Pengajuan (Smooth Soft-Slate Button with Dot)
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('requests_notification_button'),
                borderRadius: BorderRadius.circular(11.r),
                onTap: () =>
                    _navigateAndRefresh(RequestNotificationsScreen(api: api, workspace: w)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      UIcons.regularRounded.bell,
                      size: 16.w,
                      color: const Color(0xFF334155),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 7.h,
                        right: 7.w,
                        child: Container(
                          width: 7.5.w,
                          height: 7.5.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFED2736),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
        ],
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
              // ==================== 0. HERO ACTION BANNER ====================
              _buildHeroActionBanner(),

              // ==================== 1. KATALOG 5 MODUL (BENTO LAYOUT) ====================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'Submission Catalog' : 'Katalog Pengajuan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isEn
                        ? 'Select a module to view quota summary & private history.'
                        : 'Pilih modul untuk melihat rekap kuota & riwayat privat Anda.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // 6 Modul Layanan Mandiri (Grid Seimbang 2 Kolom)
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 12.w;
                  final itemWidth = (constraints.maxWidth - spacing) / 2;
                  const itemHeight = 142.0;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      // 1. Cuti
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: isEn ? 'Leave' : 'Cuti',
                          metricTag: isEn ? 'Annual Leave' : 'Cuti Tahunan',
                          description: isEn ? 'Annual leave & personal time off' : 'Cuti tahunan & urusan penting',
                          icon: UIcons.regularRounded.calendar_clock,
                          onTap: () => _navigateAndRefresh(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.cuti,
                              moduleTitle: isEn ? 'Leave Request' : 'Pengajuan Cuti',
                              keyMetricLabel: isEn ? 'REMAINING QUOTA' : 'SISA KUOTA',
                              keyMetricValue: cutiMetricStr,
                              keyMetricIcon: UIcons.regularRounded.calendar_clock,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: _handleRefresh,
                              initialLanguage: _currentLanguage,
                            ),
                          ),
                        ),
                      ),
                      // 2. Izin
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: isEn ? 'Permission' : 'Izin',
                          metricTag: isEn ? 'Official Letter' : 'Surat Izin',
                          description: isEn ? 'Sick leave & work dispensation' : 'Sakit & dispensasi kerja',
                          icon: UIcons.regularRounded.treatment,
                          onTap: () => _navigateAndRefresh(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.izin,
                              moduleTitle: isEn ? 'Permission Request' : 'Pengajuan Izin',
                              keyMetricLabel: isEn ? 'TOTAL PERMISSIONS' : 'TOTAL IZIN',
                              keyMetricValue: '${izinRequests.length} ${isEn ? 'Submissions' : 'Pengajuan'}',
                              keyMetricIcon: UIcons.regularRounded.treatment,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: _handleRefresh,
                              initialLanguage: _currentLanguage,
                            ),
                          ),
                        ),
                      ),
                      // 3. Lembur
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: isEn ? 'Overtime' : 'Lembur',
                          metricTag: isEn ? 'Compensation' : 'Kompensasi',
                          description: isEn ? 'Overtime tasks & compensation' : 'Tugas lembur & kompensasi',
                          icon: UIcons.regularRounded.clock,
                          onTap: () => _navigateAndRefresh(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.lembur,
                              moduleTitle: isEn ? 'Overtime Request' : 'Pengajuan Lembur',
                              keyMetricLabel: isEn ? 'TOTAL OVERTIME' : 'TOTAL LEMBUR',
                              keyMetricValue: lemburMetricStr,
                              keyMetricIcon: UIcons.regularRounded.clock,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: _handleRefresh,
                              initialLanguage: _currentLanguage,
                            ),
                          ),
                        ),
                      ),
                      // 4. Reimbursement
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: 'Reimbursement',
                          metricTag: isEn ? 'Expense Claim' : 'Klaim Biaya',
                          description: isEn ? 'Transport, meals & clients' : 'Transport, makan & klien',
                          icon: UIcons.regularRounded.receipt,
                          onTap: () => _navigateAndRefresh(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.reimbursement,
                              moduleTitle: isEn ? 'Reimbursement Claim' : 'Klaim Reimbursement',
                              keyMetricLabel: isEn ? 'TOTAL CLAIMS' : 'TOTAL KLAIM',
                              keyMetricValue: reimburseMetricStr,
                              keyMetricIcon: UIcons.regularRounded.receipt,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: _handleRefresh,
                              initialLanguage: _currentLanguage,
                            ),
                          ),
                        ),
                      ),
                      // 5. Medical Claim
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: 'Medical Claim',
                          metricTag: isEn ? 'Medical Quota' : 'Plafon Medis',
                          description: isEn ? 'Outpatient & health expenses' : 'Rawat jalan & pengobatan',
                          icon: UIcons.regularRounded.stethoscope,
                          onTap: () => _navigateAndRefresh(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.medicalClaim,
                              moduleTitle: 'Medical Claim',
                              keyMetricLabel: isEn ? 'TOTAL CLAIMS' : 'TOTAL KLAIM',
                              keyMetricValue: medicalMetricStr,
                              keyMetricIcon: UIcons.regularRounded.stethoscope,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: _handleRefresh,
                              initialLanguage: _currentLanguage,
                            ),
                          ),
                        ),
                      ),
                      // 6. Petty Cash
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: 'Petty Cash',
                          metricTag: isEn ? 'Petty Cash' : 'Kas Kecil',
                          description: isEn ? 'Operational cash requests' : 'Permohonan dana operasional',
                          icon: UIcons.regularRounded.wallet,
                          onTap: () => _navigateAndRefresh(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.pettyCash,
                              moduleTitle: isEn ? 'Petty Cash Request' : 'Pengajuan Petty Cash',
                              keyMetricLabel: isEn ? 'TOTAL SUBMISSIONS' : 'TOTAL PENGAJUAN',
                              keyMetricValue: pettyCashMetricStr,
                              keyMetricIcon: UIcons.regularRounded.wallet,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: _handleRefresh,
                              initialLanguage: _currentLanguage,
                            ),
                          ),
                        ),
                      ),
                      // 7. General Affair (Featured Full-Width Card)
                      SizedBox(
                        width: constraints.maxWidth,
                        child: ServiceModuleCard(
                          title: 'General Affair',
                          metricTag: isEn ? 'Facilities & GA' : 'Fasilitas & GA',
                          description: isEn
                              ? 'Equipment procurement, logistics & facilities'
                              : 'Pengadaan barang, logistik & sarana kantor',
                          icon: UIcons.regularRounded.boxes,
                          isFeatured: true,
                          onTap: () => _navigateAndRefresh(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.generalAffair,
                              moduleTitle: 'General Affair',
                              keyMetricLabel: isEn ? 'GA REQUESTS' : 'PERMOHONAN GA',
                              keyMetricValue: gaMetricStr,
                              keyMetricIcon: UIcons.regularRounded.boxes,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: _handleRefresh,
                              initialLanguage: _currentLanguage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              SizedBox(height: 18.h),

              // ==================== 2. PENGAJUAN TERKINI ====================
              Text(
                isEn ? 'Recent Submissions' : 'Pengajuan Terkini',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                isEn
                    ? 'Track the status and next steps of your latest submissions.'
                    : 'Pantau status dan tindak lanjut pengajuan terbaru Anda.',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 12.h),

              // Segmented Status Filter Bar
              _buildSegmentedFilterBar(),
              SizedBox(height: 14.h),

              if (recentCards.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          UIcons.regularRounded.inbox,
                          size: 22.w,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        _selectedFilter == 'Semua'
                            ? (isEn
                                ? 'No active submissions at the moment.'
                                : 'Belum ada pengajuan aktif saat ini.')
                            : (isEn
                                ? 'No submissions with status "${_selectedFilter == 'Menunggu' ? 'Pending' : 'Finished'}".'
                                : 'Belum ada pengajuan dengan status "$_selectedFilter".'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isEn
                            ? 'Choose one of the service modules above to submit a new request.'
                            : 'Pilih salah satu modul layanan di atas untuk mengajukan permohonan baru.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ...recentCards,
                if (hasMoreThanTwo)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, bottom: 0),
                    child: Center(
                      child: Text(
                        isEn
                            ? 'Showing 2 latest submissions. Open catalog module for full history.'
                            : 'Menampilkan 2 pengajuan terbaru. Buka modul katalog untuk riwayat lengkap.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
