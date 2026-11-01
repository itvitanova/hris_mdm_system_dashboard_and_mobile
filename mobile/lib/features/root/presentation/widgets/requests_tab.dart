import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/leave_calendar_screen.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_detail.dart';
import '../../../requests/request_notifications.dart';
import '../../../requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import '../../../requests/presentation/widgets/services_hub/service_module_card.dart';
import '../../../requests/presentation/models/mock_universal_requests.dart';
import '../../../requests/presentation/pages/modules/dedicated_module_screen.dart';

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
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Widget) open;

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  String _selectedFilter = 'Semua';

  ApiClient get api => widget.api;
  Workspace get w => widget.workspace;
  Future<void> Function() get onRefresh => widget.onRefresh;
  Future<void> Function(Widget) get open => widget.open;

  Widget _buildHeroActionBanner() {
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
                  const Text(
                    'Pusat Layanan Mandiri',
                    style: TextStyle(
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
            const Text(
              'Ada Kebutuhan Kerja Hari Ini?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Ajukan cuti, lembur, atau reimbursement dengan mudah. Riwayat dan kuota tersimpan rapi di tiap modul.',
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
                onTap: () => open(RequestForm(api: api, workspace: w)),
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
                        Icons.add_circle_rounded,
                        size: 15.w,
                        color: const Color(0xFF0F766E),
                      ),
                      SizedBox(width: 5.w),
                      const Text(
                        'Buat Pengajuan Baru',
                        style: TextStyle(
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
    final segments = ['Semua', 'Menunggu', 'Selesai'];

    return Container(
      height: 38.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: segments.map((segment) {
          final isSelected = _selectedFilter == segment;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('filter_segment_$segment'),
                onTap: () {
                  setState(() {
                    _selectedFilter = segment;
                  });
                },
                borderRadius: BorderRadius.circular(7.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
                    borderRadius: BorderRadius.circular(7.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.18),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    segment,
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
    final rows = w.mine('requests');
    final unreadCount = rows.where((r) => r['unread'] == true).length;

    // Kumpulkan seluruh data request riil dan mock
    final allRawItems = <Map<String, dynamic>>[
      ...rows,
      ...mockUniversalRequests
          .where((m) => !rows.any((r) => text(r, 'title') == m.title))
          .map((m) => m.toMap()),
    ];

    // Konversi ke model universal
    final allModels = allRawItems.map((r) => UniversalRequestModel.fromMap(r)).toList();

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
          onDetailPressed: () => open(
            RequestDetailScreen(
              api: api,
              request: raw,
              own: true,
            ),
          ),
          onRevisePressed: () => open(
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
          children: const [
            Text(
              'Pengajuan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 1.5),
            Text(
              'Layanan & Permohonan Mandiri',
              style: TextStyle(
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
          // 1. Kalender Cuti (Smooth Soft-Slate Button)
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
                onTap: () => open(LeaveCalendarScreen(api: api, workspace: w)),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 19.w,
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
                    open(RequestNotificationsScreen(api: api, workspace: w)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 19.w,
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
          onRefresh: onRefresh,
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
                  const Text(
                    'Katalog Pengajuan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  const Text(
                    'Pilih modul untuk melihat rekap kuota & riwayat privat Anda.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // 1. Featured Card: Cuti & Izin (Full Width Horizontal)
              ServiceModuleCard(
                isFeatured: true,
                title: 'Cuti & Izin',
                metricTag: 'Layanan Utama',
                description: 'Tahunan, cuti khusus, sakit & izin kerja',
                icon: Icons.event_available_outlined,
                onTap: () => open(
                  DedicatedModuleScreen(
                    kind: SubmissionKind.cuti,
                    moduleTitle: 'Pengajuan Cuti & Izin',
                    keyMetricLabel: 'SISA KUOTA',
                    keyMetricValue: '10 Hari',
                    keyMetricIcon: Icons.event_available_outlined,
                    api: api,
                    workspace: w,
                    open: open,
                    onRefresh: onRefresh,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // 2. 2x2 Grid Seimbang: Lembur, Reimbursement, Petty Cash, General Affair
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 12.w;
                  final itemWidth = (constraints.maxWidth - spacing) / 2;
                  const itemHeight = 142.0;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      // 2. Lembur
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: 'Lembur',
                          metricTag: 'Kompensasi',
                          description: 'Tugas lembur & kompensasi',
                          icon: Icons.access_time_rounded,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.lembur,
                              moduleTitle: 'Pengajuan Lembur',
                              keyMetricLabel: 'TOTAL LEMBUR',
                              keyMetricValue: '4 Jam',
                              keyMetricIcon: Icons.access_time_rounded,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ),
                      ),
                      // 3. Reimbursement
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: 'Reimbursement',
                          metricTag: 'Klaim Biaya',
                          description: 'Transport, makan & klien',
                          icon: Icons.receipt_long_rounded,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.reimbursement,
                              moduleTitle: 'Klaim Reimbursement',
                              keyMetricLabel: 'TOTAL KLAIM',
                              keyMetricValue: 'Rp 850K',
                              keyMetricIcon: Icons.receipt_long_rounded,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ),
                      ),
                      // 4. Petty Cash
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: 'Petty Cash',
                          metricTag: 'Kas Kecil',
                          description: 'Permohonan dana operasional',
                          icon: Icons.payments_outlined,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.pettyCash,
                              moduleTitle: 'Pengajuan Petty Cash',
                              keyMetricLabel: 'KAS KECIL',
                              keyMetricValue: 'Rp 375K',
                              keyMetricIcon: Icons.payments_outlined,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ),
                      ),
                      // 5. General Affair
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: ServiceModuleCard(
                          title: 'General Affair',
                          metricTag: 'Fasilitas & GA',
                          description: 'Pengadaan barang & sarana',
                          icon: Icons.inventory_2_outlined,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.generalAffair,
                              moduleTitle: 'General Affair',
                              keyMetricLabel: 'PERMOHONAN GA',
                              keyMetricValue: '1 Aktif',
                              keyMetricIcon: Icons.inventory_2_outlined,
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Pengajuan Terkini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Text(
                    '${filteredIndices.length} Pengajuan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              const Text(
                'Pantau status dan tindak lanjut pengajuan terbaru Anda.',
                style: TextStyle(
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
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedFilter == 'Semua'
                        ? 'Belum ada pengajuan aktif saat ini.'
                        : 'Belum ada pengajuan dengan status "$_selectedFilter".',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                )
              else ...[
                ...recentCards,
                if (hasMoreThanTwo)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, bottom: 0),
                    child: Center(
                      child: Text(
                        'Menampilkan 2 pengajuan terbaru. Buka modul katalog untuk riwayat lengkap.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
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
