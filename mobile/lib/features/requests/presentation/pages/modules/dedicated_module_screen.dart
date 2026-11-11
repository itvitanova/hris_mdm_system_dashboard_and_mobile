import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/home/leave_calendar_screen.dart';
import 'package:mdm_hris/features/requests/request_detail.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/features/requests/request_notifications.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_bloc.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_event.dart';
import 'package:mdm_hris/features/requests/presentation/bloc/request_state.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/module_stat_card.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/submission_status_filter_dropdown.dart';
import 'package:mdm_hris/features/home/presentation/bloc/workspace_bloc.dart';
import 'package:mdm_hris/features/home/presentation/bloc/workspace_state.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

/// Halaman Khusus (Dedicated Screen) untuk Setiap Modul Pengajuan Mandiri
/// Dilengkapi rekap statistik 2x2 korporat, filter status dropdown, dan header riwayat dengan tombol (+) tanpa FAB dan tanpa banner.
class DedicatedModuleScreen extends StatefulWidget {
  final SubmissionKind kind;
  final String moduleTitle;
  final String keyMetricLabel;
  final String keyMetricValue;
  final IconData keyMetricIcon;
  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function(Widget) open;
  final Future<void> Function() onRefresh;
  final List<Widget>? customActions;
  final AppLanguage initialLanguage;

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

  @override
  State<DedicatedModuleScreen> createState() => _DedicatedModuleScreenState();
}

class _DedicatedModuleScreenState extends State<DedicatedModuleScreen> {
  static const int _itemsPerPage = 5;
  late AppLanguage _currentLanguage = widget.initialLanguage != AppLanguage.id
      ? widget.initialLanguage
      : AppLanguageController.currentLanguage;
  SubmissionStatus? _selectedStatusFilter;
  int _currentPage = 1;

  Workspace get w {
    try {
      final state = BlocProvider.of<WorkspaceBloc>(context).state;
      if (state is WorkspaceLoaded) {
        return state.workspace;
      }
    } catch (_) {}
    return widget.workspace;
  }

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
        _tryGetRequestBloc(context)?.add(
          RequestLoadRequested(kind: widget.kind.displayName),
        );
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
      _tryGetRequestBloc(context)?.add(
        RequestLoadRequested(kind: widget.kind.displayName),
      );
      setState(() => _currentPage = 1);
    }
  }

  Future<void> _navigateAndRefresh(Widget target) async {
    await widget.open(target);
    if (mounted) {
      await _handleRefresh();
    }
  }

  List<UniversalRequestModel> _getAllKindRequests([
    List<Map<String, dynamic>>? customRows,
  ]) {
    final rows = customRows ?? w.mine('requests');
    final List<UniversalRequestModel> items = [];

    // Data riil dari workspace atau BLoC
    for (final r in rows) {
      final normalized = Map<String, dynamic>.from(r);
      if (normalized['kind'] == null && normalized['type'] != null) {
        normalized['kind'] = normalized['type'];
      }
      final rawAmount =
          normalized['amount'] ?? normalized['nominal'] ?? normalized['total'];
      if (rawAmount is String) {
        final parsed = int.tryParse(rawAmount);
        if (parsed != null) normalized['amount'] = parsed;
      }
      final rawHours = normalized['hours'] ?? normalized['durasi'];
      if (rawHours is String) {
        final parsed = int.tryParse(rawHours);
        if (parsed != null) normalized['hours'] = parsed;
      }
      final model = UniversalRequestModel.fromMap(normalized);
      if (model.kind == widget.kind) {
        items.add(model);
      }
    }

    return items;
  }

  void _openCreateForm() {
    _navigateAndRefresh(
      RequestForm(
        api: widget.api,
        workspace: widget.workspace,
        initialKind: widget.kind.displayName,
        lockKindSelection: true,
      ),
    );
  }

  String _getModuleTitle(SubmissionKind kind, AppLanguage language) {
    if (language == AppLanguage.en) {
      switch (kind) {
        case SubmissionKind.cuti:
          return 'Leave Request';
        case SubmissionKind.izin:
          return 'Permission Request';
        case SubmissionKind.lembur:
          return 'Overtime Request';
        case SubmissionKind.reimbursement:
          return 'Reimbursement Claim';
        case SubmissionKind.medicalClaim:
          return 'Medical Claim';
        case SubmissionKind.pettyCash:
          return 'Petty Cash Request';
        case SubmissionKind.generalAffair:
          return 'General Affair';
      }
    }
    return widget.moduleTitle;
  }

  String _getModuleSubtitle(SubmissionKind kind, AppLanguage language) {
    if (language == AppLanguage.en) {
      switch (kind) {
        case SubmissionKind.cuti:
          return 'Manage leave quota & requests';
        case SubmissionKind.izin:
          return 'Sick leave & work dispensation records';
        case SubmissionKind.lembur:
          return 'Task records & overtime compensation';
        case SubmissionKind.reimbursement:
          return 'Operational expenses & claims';
        case SubmissionKind.medicalClaim:
          return 'Outpatient & health expenses claim';
        case SubmissionKind.pettyCash:
          return 'Operational petty cash requests';
        case SubmissionKind.generalAffair:
          return 'Procurement, assets & workplace facilities';
      }
    }
    switch (kind) {
      case SubmissionKind.cuti:
        return 'Kelola kuota & permohonan cuti';
      case SubmissionKind.izin:
        return 'Pencatatan izin sakit & dispensasi kerja';
      case SubmissionKind.lembur:
        return 'Pencatatan tugas & kompensasi lembur';
      case SubmissionKind.reimbursement:
        return 'Klaim biaya operasional & reimburse';
      case SubmissionKind.medicalClaim:
        return 'Penggantian biaya kesehatan & rawat jalan';
      case SubmissionKind.pettyCash:
        return 'Pengajuan & kas kecil operasional';
      case SubmissionKind.generalAffair:
        return 'Pengadaan logistik, aset & sarana';
    }
  }

  Widget _buildModuleHeroActionBanner() {
    final isEn = _currentLanguage == AppLanguage.en;
    final (badgeText, headline, subtitle, buttonText) = switch (widget.kind) {
      SubmissionKind.cuti => (
          isEn ? 'Annual Leave Service' : 'Layanan Cuti Tahunan',
          isEn ? 'Need Time Off?' : 'Perlu Cuti Kerja?',
          isEn
              ? 'Apply for annual leave or important personal affairs.'
              : 'Ajukan permohonan cuti tahunan atau urusan penting.',
          isEn ? 'Create Leave Request' : 'Buat Pengajuan Cuti',
        ),
      SubmissionKind.izin => (
          isEn ? 'Permission & Sick Leave' : 'Layanan Izin & Sakit',
          isEn ? 'Need Work Permission?' : 'Perlu Izin Tidak Masuk?',
          isEn
              ? 'Submit sick leave or work dispensation with attachments.'
              : 'Ajukan izin sakit atau dispensasi kerja dengan lampiran dokumen.',
          isEn ? 'Create Permission Request' : 'Buat Pengajuan Izin',
        ),
      SubmissionKind.lembur => (
          isEn ? 'Overtime Service' : 'Layanan Lembur',
          isEn ? 'Assigned Overtime?' : 'Ada Penugasan Lembur?',
          isEn
              ? 'Record overtime tasks for accurate work compensation.'
              : 'Catat tugas lembur untuk kompensasi kerja yang akurat.',
          isEn ? 'Create Overtime Request' : 'Buat Pengajuan Lembur',
        ),
      SubmissionKind.reimbursement => (
          isEn ? 'Operational Expense Claim' : 'Klaim Biaya Operasional',
          isEn ? 'Claim Your Expenses?' : 'Klaim Biaya Pengeluaran?',
          isEn
              ? 'Submit claim for transport, meals, and business trips.'
              : 'Ajukan penggantian dana transportasi, makan, dan dinas.',
          isEn ? 'Submit Reimbursement' : 'Ajukan Reimbursement',
        ),
      SubmissionKind.medicalClaim => (
          isEn ? 'Medical Expense Claim' : 'Klaim Biaya Medis',
          isEn ? 'Inpatient / Outpatient Claim?' : 'Klaim Rawat Jalan / Inap?',
          isEn
              ? 'Reimbursement of employee medical and healthcare costs.'
              : 'Penggantian biaya kesehatan dan rawat jalan karyawan.',
          isEn ? 'Submit Medical Claim' : 'Ajukan Medical Claim',
        ),
      SubmissionKind.pettyCash => (
          isEn ? 'Petty Cash Request' : 'Permohonan Kas Kecil',
          isEn ? 'Need Petty Cash Funds?' : 'Butuh Dana Kas Kecil?',
          isEn
              ? 'Request cash advance or quick office operational funds.'
              : 'Permohonan uang muka atau dana operasional cepat kantor.',
          isEn ? 'Request Petty Cash' : 'Ajukan Petty Cash',
        ),
      SubmissionKind.generalAffair => (
          isEn ? 'GA Facilities & Supplies' : 'Fasilitas & Sarana GA',
          isEn ? 'Need Work Equipment?' : 'Kebutuhan Sarana Kerja?',
          isEn
              ? 'Procurement, inventory repair, and workplace facilities.'
              : 'Pengadaan barang, perbaikan inventaris, dan fasilitas kerja.',
          isEn ? 'Request General Affair' : 'Ajukan General Affair',
        ),
    };

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
            top: -25.w,
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
            bottom: -30.w,
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
                        badgeText,
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
                  headline,
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
                  subtitle,
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
                    onTap: _openCreateForm,
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
                            Icons.add_rounded,
                            size: 16.sp,
                            color: const Color(0xFF0F766E),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            buttonText,
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

  @override
  Widget build(BuildContext context) {
    final bloc = _tryGetRequestBloc(context);
    if (bloc != null) {
      return BlocBuilder<RequestBloc, RequestState>(
        bloc: bloc,
        builder: (context, state) {
          final rows = (state is RequestsLoaded &&
                  (state.activeKind == null ||
                      state.activeKind == widget.kind.displayName))
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
    final allRequests = _getAllKindRequests(rows);
    final approvedCount = allRequests
        .where((r) => r.status == SubmissionStatus.disetujui)
        .length;
    final pendingCount = allRequests
        .where((r) => r.status == SubmissionStatus.menunggu)
        .length;
    final onlyRejectedCount = allRequests
        .where((r) => r.status == SubmissionStatus.ditolak)
        .length;
    final revisionCount = allRequests
        .where((r) => r.status == SubmissionStatus.perluRevisi)
        .length;

    final unreadCount =
        rows.where((r) => r['unread'] == true).length;

    // Filter daftar sesuai status terpilih
    final filteredRequests = _selectedStatusFilter != null
        ? allRequests
            .where((it) => it.status == _selectedStatusFilter)
            .toList()
        : allRequests;

    final totalItems = filteredRequests.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 99999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final paginatedRequests = filteredRequests.isEmpty
        ? <UniversalRequestModel>[]
        : filteredRequests.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getModuleTitle(widget.kind, _currentLanguage),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 1.5),
            Text(
              _getModuleSubtitle(widget.kind, _currentLanguage),
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
          // 1. Tanggal UI / Kalender Action:
          // Hanya jika modul Cuti & Izin; untuk modul lain ("kalau gak ada gak ush")
          if (widget.kind == SubmissionKind.cuti) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11),
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
                  key: const Key('dedicated_calendar_button'),
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => _navigateAndRefresh(
                    LeaveCalendarScreen(
                      api: widget.api,
                      workspace: widget.workspace,
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    size: 19,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // 2. Notifikasi Pengajuan (Smooth Soft-Slate Button with Dot)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(11),
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
                key: const Key('dedicated_notification_button'),
                borderRadius: BorderRadius.circular(11),
                onTap: () => _navigateAndRefresh(
                  RequestNotificationsScreen(
                    api: widget.api,
                    workspace: widget.workspace,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 19,
                      color: Color(0xFF334155),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          width: 7.5,
                          height: 7.5,
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
          if (widget.customActions != null) ...widget.customActions!,
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            children: [
              // ==================== 0. HERO ACTION BANNER ====================
              _buildModuleHeroActionBanner(),

              // ==================== 1. REKAP STATISTIK 2X2 ====================
              Row(
                children: [
                  Expanded(
                    child: ModuleStatCard(
                      title: isEn ? 'Approved' : 'Disetujui',
                      subTitle: isEn ? 'submissions' : 'pengajuan',
                      label: isEn ? 'APPROVED' : 'DISETUJUI',
                      value: '$approvedCount',
                      icon: Icons.check_circle_outline_rounded,
                      isSelected: _selectedStatusFilter == SubmissionStatus.disetujui,
                      onTap: () => setState(() {
                        _selectedStatusFilter = _selectedStatusFilter ==
                                SubmissionStatus.disetujui
                            ? null
                            : SubmissionStatus.disetujui;
                        _currentPage = 1;
                      }),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ModuleStatCard(
                      title: isEn ? 'Pending' : 'Menunggu',
                      subTitle: isEn ? 'in review' : 'dalam proses',
                      label: isEn ? 'PENDING' : 'MENUNGGU',
                      value: '$pendingCount',
                      icon: Icons.access_time_rounded,
                      isSelected: _selectedStatusFilter == SubmissionStatus.menunggu,
                      onTap: () => setState(() {
                        _selectedStatusFilter =
                            _selectedStatusFilter == SubmissionStatus.menunggu
                                ? null
                                : SubmissionStatus.menunggu;
                        _currentPage = 1;
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: ModuleStatCard(
                      title: isEn ? 'Rejected' : 'Ditolak',
                      subTitle: isEn ? 'declined' : 'tidak disetujui',
                      label: isEn ? 'REJECTED' : 'DITOLAK',
                      value: '$onlyRejectedCount',
                      icon: Icons.highlight_off_rounded,
                      isSelected: _selectedStatusFilter == SubmissionStatus.ditolak,
                      onTap: () => setState(() {
                        _selectedStatusFilter =
                            _selectedStatusFilter == SubmissionStatus.ditolak
                                ? null
                                : SubmissionStatus.ditolak;
                        _currentPage = 1;
                      }),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ModuleStatCard(
                      title: isEn ? 'Needs Revision' : 'Perlu Revisi',
                      subTitle: isEn ? 'action needed' : 'perlu tindak',
                      label: isEn ? 'NEEDS REVISION' : 'PERLU REVISI',
                      value: '$revisionCount',
                      icon: Icons.edit_note_rounded,
                      isSelected: _selectedStatusFilter ==
                          SubmissionStatus.perluRevisi,
                      onTap: () => setState(() {
                        _selectedStatusFilter = _selectedStatusFilter ==
                                SubmissionStatus.perluRevisi
                            ? null
                            : SubmissionStatus.perluRevisi;
                        _currentPage = 1;
                      }),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              // ==================== 2. FILTER STATUS DROPDOWN & RELOAD ====================
              Row(
                children: [
                  Expanded(
                    child: SubmissionStatusFilterDropdown(
                      selected: _selectedStatusFilter,
                      language: _currentLanguage,
                      onChanged: (status) {
                        setState(() {
                          _selectedStatusFilter = status;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _FilterIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: _handleRefresh,
                  ),
                ],
              ),

              SizedBox(height: 20.h),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              SizedBox(height: 18.h),

              // ==================== 3. HEADER SEKSI RIWAYAT BERNARASI ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 3.5.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            isEn
                                ? (widget.kind == SubmissionKind.medicalClaim
                                    ? 'Submission History'
                                    : '${widget.kind.getLabel(AppLanguage.en)} History')
                                : (widget.kind == SubmissionKind.medicalClaim
                                    ? 'Riwayat Pengajuan'
                                    : 'Riwayat Pengajuan ${widget.kind.displayName}'),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      isEn
                          ? '${filteredRequests.length} Submissions'
                          : '${filteredRequests.length} Pengajuan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                _selectedStatusFilter != null
                    ? (isEn
                        ? 'Showing submissions with status "${_selectedStatusFilter!.getLabel(AppLanguage.en)}" (${filteredRequests.length} found).'
                        : 'Menampilkan pengajuan berstatus "${_selectedStatusFilter!.displayName}" (${filteredRequests.length} ditemukan).')
                    : (isEn
                        ? 'Track approval process and your ${widget.kind.getLabel(AppLanguage.en).toLowerCase()} history.'
                        : 'Pantau proses persetujuan dan riwayat pengajuan ${widget.kind.displayName.toLowerCase()} Anda.'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 14.h),

              // ==================== 4. DAFTAR KARTU PENGAJUAN ====================
              if (filteredRequests.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 36.h),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 40.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _selectedStatusFilter != null
                            ? (isEn
                                ? 'No submissions with status "${_selectedStatusFilter!.getLabel(AppLanguage.en)}"'
                                : 'Tidak ada pengajuan berstatus "${_selectedStatusFilter!.displayName}"')
                            : (isEn
                                ? 'No ${widget.kind.getLabel(AppLanguage.en).toLowerCase()} submission history yet'
                                : 'Belum ada riwayat pengajuan ${widget.kind.displayName.toLowerCase()}'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ...paginatedRequests.map(
                  (model) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: UniversalRequestCard(
                      data: model,
                      language: _currentLanguage,
                      onDetailPressed: () => _navigateAndRefresh(
                        RequestDetailScreen(
                          api: widget.api,
                          request: model.rawMap ?? model.toMap(),
                          own: true,
                        ),
                      ),
                      onRevisePressed: () => _navigateAndRefresh(
                        RequestForm(
                          api: widget.api,
                          workspace: w,
                          initialKind: model.kind.displayName,
                          initialRequest: model.rawMap ?? model.toMap(),
                          lockKindSelection: true,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildPaginationBar(
                  currentPage,
                  totalPages,
                  startIndex,
                  endIndex,
                  totalItems,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<int> _calculateVisiblePages(int current, int total) {
    if (total <= 5) {
      return List.generate(total, (i) => i + 1);
    }
    int start = current - 2;
    int end = current + 2;
    if (start < 1) {
      start = 1;
      end = 5;
    } else if (end > total) {
      end = total;
      start = total - 4;
    }
    return List.generate(end - start + 1, (i) => start + i);
  }

  Widget _buildPaginationBar(
    int currentPage,
    int totalPages,
    int startIndex,
    int endIndex,
    int totalItems,
  ) {
    final hasPrev = currentPage > 1;
    final hasNext = currentPage < totalPages;
    final visiblePages = _calculateVisiblePages(currentPage, totalPages);
    final isEn = _currentLanguage == AppLanguage.en;

    return Container(
      key: const ValueKey('pagination_bar'),
      margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Teks Info di Atas (Halaman X dari Y & Menampilkan A-B dari N)
          Text(
            isEn
                ? 'Page $currentPage of $totalPages'
                : 'Halaman $currentPage dari $totalPages',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            totalItems == 0
                ? (isEn ? 'No submissions' : 'Tidak ada pengajuan')
                : (isEn
                    ? 'Showing ${startIndex + 1}\u2013$endIndex of $totalItems submissions'
                    : 'Menampilkan ${startIndex + 1}\u2013$endIndex dari $totalItems pengajuan'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 10.h),

          // 2. Deretan Tombol Angka Standar [<] [ 1 ] [ 2 ] [ 3 ] [>]
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Panah Kiri (<)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_prev_btn'),
                  onTap: hasPrev
                      ? () => setState(() => _currentPage = currentPage - 1)
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasPrev
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasPrev
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 20.sp,
                      color: hasPrev
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Kotak-Kotak Angka Halaman
              ...visiblePages.map((page) {
                final isActive = page == currentPage;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isActive
                          ? null
                          : () => setState(() => _currentPage = page),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF0D9488)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF0D9488)
                                : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5.sp,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(width: 6.w),

              // Tombol Panah Kanan (>)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_next_btn'),
                  onTap: hasNext
                      ? () => setState(() => _currentPage = currentPage + 1)
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasNext
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasNext
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: hasNext
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _FilterIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF5F5F5),
            blurRadius: 9,
            offset: Offset(0, 0),
          ),
        ],
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          splashColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
          highlightColor: const Color(0xFF0D9488).withValues(alpha: 0.05),
          child: Center(
            child: Icon(
              icon,
              size: 20.sp,
              color: const Color(0xFF0D9488),
            ),
          ),
        ),
      ),
    );
  }
}
