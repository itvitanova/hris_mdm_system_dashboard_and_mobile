import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/home/leave_calendar_screen.dart';
import 'package:mdm_hris/features/requests/request_detail.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/features/requests/request_notifications.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/module_stat_card.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/submission_status_filter_dropdown.dart';

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
  });

  @override
  State<DedicatedModuleScreen> createState() => _DedicatedModuleScreenState();
}

class _DedicatedModuleScreenState extends State<DedicatedModuleScreen> {
  SubmissionStatus? _selectedStatusFilter;

  Workspace get w => widget.workspace;

  List<UniversalRequestModel> _getAllKindRequests() {
    final rows = w.mine('requests');
    final List<UniversalRequestModel> items = [];

    // Data riil dari workspace
    for (final r in rows) {
      final model = UniversalRequestModel.fromMap(r);
      if (model.kind == widget.kind) {
        items.add(model);
      }
    }

    return items;
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    final words = text.toLowerCase().split(' ');
    return words
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  void _openCreateForm() {
    widget.open(
      RequestForm(
        api: widget.api,
        workspace: widget.workspace,
        initialKind: widget.kind.displayName,
        lockKindSelection: true,
      ),
    );
  }

  String _getModuleSubtitle(SubmissionKind kind) {
    switch (kind) {
      case SubmissionKind.cuti:
        return 'Kelola kuota, permohonan & kalender cuti';
      case SubmissionKind.lembur:
        return 'Pencatatan tugas & kompensasi lembur';
      case SubmissionKind.reimbursement:
        return 'Klaim biaya operasional & reimburse';
      case SubmissionKind.pettyCash:
        return 'Pengajuan & kas kecil operasional';
      case SubmissionKind.generalAffair:
        return 'Pengadaan logistik, aset & sarana';
    }
  }

  Widget _buildModuleHeroActionBanner() {
    final (badgeText, headline, subtitle, buttonText) = switch (widget.kind) {
      SubmissionKind.cuti => (
          'Layanan Cuti & Izin',
          'Perlu Cuti atau Izin Kerja?',
          'Ajukan cuti tahunan, sakit, atau izin kerja dengan cepat.',
          'Buat Pengajuan Cuti',
        ),
      SubmissionKind.lembur => (
          'Layanan Lembur',
          'Ada Penugasan Lembur?',
          'Catat tugas lembur untuk kompensasi kerja yang akurat.',
          'Buat Pengajuan Lembur',
        ),
      SubmissionKind.reimbursement => (
          'Klaim Biaya Operasional',
          'Klaim Biaya Pengeluaran?',
          'Ajukan penggantian dana transportasi, makan, dan dinas.',
          'Ajukan Reimbursement',
        ),
      SubmissionKind.pettyCash => (
          'Permohonan Kas Kecil',
          'Butuh Dana Kas Kecil?',
          'Permohonan uang muka atau dana operasional cepat kantor.',
          'Ajukan Petty Cash',
        ),
      SubmissionKind.generalAffair => (
          'Fasilitas & Sarana GA',
          'Kebutuhan Sarana Kerja?',
          'Pengadaan barang, perbaikan inventaris, dan fasilitas kerja.',
          'Ajukan General Affair',
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
    final allRequests = _getAllKindRequests();
    final approvedCount = allRequests
        .where((r) => r.status == SubmissionStatus.disetujui)
        .length;
    final pendingCount = allRequests
        .where((r) => r.status == SubmissionStatus.menunggu)
        .length;
    final rejectedCount = allRequests
        .where((r) =>
            r.status == SubmissionStatus.ditolak ||
            r.status == SubmissionStatus.perluRevisi)
        .length;

    final unreadCount =
        w.mine('requests').where((r) => r['unread'] == true).length;

    // Filter daftar sesuai status terpilih
    final filteredRequests = _selectedStatusFilter != null
        ? allRequests
            .where((it) => it.status == _selectedStatusFilter)
            .toList()
        : allRequests;

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
              widget.moduleTitle,
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
              _getModuleSubtitle(widget.kind),
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
                  onTap: () => widget.open(
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
                onTap: () => widget.open(
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
          onRefresh: widget.onRefresh,
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
                      title: 'Disetujui',
                      subTitle: 'pengajuan',
                      label: 'DISETUJUI',
                      value: '$approvedCount',
                      icon: Icons.check_circle_outline_rounded,
                      isSelected: _selectedStatusFilter == SubmissionStatus.disetujui,
                      onTap: () => setState(() {
                        _selectedStatusFilter = _selectedStatusFilter ==
                                SubmissionStatus.disetujui
                            ? null
                            : SubmissionStatus.disetujui;
                      }),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ModuleStatCard(
                      title: 'Menunggu',
                      subTitle: 'dalam proses',
                      label: 'MENUNGGU',
                      value: '$pendingCount',
                      icon: Icons.access_time_rounded,
                      isSelected: _selectedStatusFilter == SubmissionStatus.menunggu,
                      onTap: () => setState(() {
                        _selectedStatusFilter =
                            _selectedStatusFilter == SubmissionStatus.menunggu
                                ? null
                                : SubmissionStatus.menunggu;
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
                      title: 'Ditolak / Revisi',
                      subTitle: 'perlu tindak',
                      label: 'DITOLAK / REVISI',
                      value: '$rejectedCount',
                      icon: Icons.highlight_off_rounded,
                      isSelected: _selectedStatusFilter == SubmissionStatus.ditolak,
                      onTap: () => setState(() {
                        _selectedStatusFilter =
                            _selectedStatusFilter == SubmissionStatus.ditolak
                                ? null
                                : SubmissionStatus.ditolak;
                      }),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ModuleStatCard(
                      title: _toTitleCase(widget.keyMetricLabel),
                      subTitle: widget.kind == SubmissionKind.lembur
                          ? 'jam disetujui'
                          : 'saldo aktif',
                      label: widget.keyMetricLabel,
                      value: widget.keyMetricValue,
                      icon: widget.keyMetricIcon,
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
                      onChanged: (status) {
                        setState(() => _selectedStatusFilter = status);
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _FilterIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: widget.onRefresh,
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
                            'Riwayat Pengajuan ${widget.kind.displayName}',
                            overflow: TextOverflow.ellipsis,
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
                      '${filteredRequests.length} Pengajuan',
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
                    ? 'Menampilkan pengajuan berstatus "${_selectedStatusFilter!.displayName}" (${filteredRequests.length} ditemukan).'
                    : 'Pantau proses persetujuan dan riwayat pengajuan ${widget.kind.displayName.toLowerCase()} Anda.',
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
                            ? 'Tidak ada pengajuan berstatus "${_selectedStatusFilter!.displayName}"'
                            : 'Belum ada riwayat pengajuan ${widget.kind.displayName.toLowerCase()}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextButton.icon(
                        onPressed: _openCreateForm,
                        icon: Icon(
                          Icons.add_rounded,
                          size: 16.sp,
                          color: const Color(0xFF0D9488),
                        ),
                        label: Text(
                          'Buat Pengajuan Baru',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredRequests.map(
                  (model) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: UniversalRequestCard(
                      data: model,
                      onDetailPressed: () => widget.open(
                        RequestDetailScreen(
                          api: widget.api,
                          request: model.toMap(),
                          own: true,
                        ),
                      ),
                      onRevisePressed: () => widget.open(
                        RequestForm(
                          api: widget.api,
                          workspace: widget.workspace,
                          initialKind: model.kind.displayName,
                          initialRequest: model.toMap(),
                          lockKindSelection: true,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
