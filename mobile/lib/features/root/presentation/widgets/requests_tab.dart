import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../shared/widgets.dart';
import '../../../home/leave_calendar_screen.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_detail.dart';
import '../../../requests/request_notifications.dart';
import '../../../requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import '../../../requests/presentation/widgets/services_hub/service_module_card.dart';
import '../../../requests/presentation/models/mock_universal_requests.dart';
import '../../../requests/presentation/pages/modules/dedicated_module_screen.dart';
import 'payroll_tab.dart';

class RequestsTab extends StatelessWidget {
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

  Workspace get w => workspace;

  @override
  Widget build(BuildContext context) {
    final rows = w.mine('requests');
    final unreadCount = rows.where((r) => r['unread'] == true).length;

    // Gabungkan data request riil dan mock
    final allCards = <Widget>[
      ...rows.map((r) {
        final model = UniversalRequestModel.fromMap(r);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UniversalRequestCard(
            data: model,
            onDetailPressed: () => open(
              RequestDetailScreen(
                api: api,
                request: r,
                own: true,
              ),
            ),
            onRevisePressed: () => open(
              RequestForm(
                api: api,
                workspace: w,
                initialKind: model.kind.displayName,
                initialRequest: r,
              ),
            ),
          ),
        );
      }),
      ...mockUniversalRequests
          .where((m) => !rows.any((r) => text(r, 'title') == m.title))
          .map((mockItem) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UniversalRequestCard(
            data: mockItem,
            onDetailPressed: () => open(
              RequestDetailScreen(
                api: api,
                request: mockItem.toMap(),
                own: true,
              ),
            ),
            onRevisePressed: () => open(
              RequestForm(
                api: api,
                workspace: w,
                initialKind: mockItem.kind.displayName,
                initialRequest: mockItem.toMap(),
              ),
            ),
          ),
        );
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Layanan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Kalender cuti',
            onPressed: () => open(LeaveCalendarScreen(api: api, workspace: w)),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            tooltip: 'Notifikasi pengajuan',
            onPressed: () =>
                open(RequestNotificationsScreen(api: api, workspace: w)),
            icon: Badge.count(
              count: unreadCount,
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          if (w.data['approvalAccess'] == true)
            IconButton(
              tooltip: 'Persetujuan',
              onPressed: () => open(ApprovalsScreen(api: api)),
              icon: Badge(
                label: Text(
                  '${w.rows("requests").where((r) => r["canReview"] == true).length}',
                ),
                child: const Icon(Icons.fact_check_outlined),
              ),
            ),
          IconButton(
            tooltip: 'Segarkan data',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // ==================== 1. KATALOG MODUL LAYANAN (GRID 2-KOLOM) ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Katalog Layanan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => open(RequestForm(api: api, workspace: w)),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Buat pengajuan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final itemWidth = (constraints.maxWidth - spacing) / 2;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: ServiceModuleCard(
                          title: 'Cuti & Izin',
                          metricTag: 'Sisa 10 Hari',
                          description: 'Tahunan, sakit & izin kerja',
                          icon: Icons.event_available_outlined,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.cuti,
                              moduleTitle: 'Pengajuan Cuti & Izin',
                              heroTitle: 'Kuota Cuti: 10 Hari',
                              heroSubtitle: 'Sisa cuti tahunan dan hak istirahat kerja Anda',
                              moduleIcon: Icons.event_available_outlined,
                              actionButtonText: 'Ajukan Cuti Baru',
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                              customActions: [
                                IconButton(
                                  tooltip: 'Kalender cuti',
                                  onPressed: () => open(
                                    LeaveCalendarScreen(api: api, workspace: w),
                                  ),
                                  icon: const Icon(Icons.calendar_month_outlined),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: ServiceModuleCard(
                          title: 'Lembur',
                          metricTag: 'Jam Kerja',
                          description: 'Tugas lembur & kompensasi',
                          icon: Icons.access_time_rounded,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.lembur,
                              moduleTitle: 'Pengajuan Lembur',
                              heroTitle: 'Total Lembur: 4 Jam',
                              heroSubtitle: 'Akumulasi jam kerja lembur bulan berjalan',
                              moduleIcon: Icons.access_time_rounded,
                              actionButtonText: 'Ajukan Lembur Baru',
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: ServiceModuleCard(
                          title: 'Reimbursement',
                          metricTag: 'Klaim Biaya',
                          description: 'Transport, makan & klien',
                          icon: Icons.receipt_long_rounded,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.reimbursement,
                              moduleTitle: 'Klaim Reimbursement',
                              heroTitle: 'Total Klaim: Rp 850.000',
                              heroSubtitle: 'Penggantian biaya dinas, transport & makan klien',
                              moduleIcon: Icons.receipt_long_rounded,
                              actionButtonText: 'Buat Klaim Baru',
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: ServiceModuleCard(
                          title: 'Petty Cash',
                          metricTag: 'Kas Kecil',
                          description: 'Permohonan dana operasional',
                          icon: Icons.payments_outlined,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.pettyCash,
                              moduleTitle: 'Pengajuan Petty Cash',
                              heroTitle: 'Kas Kecil: Rp 375.000',
                              heroSubtitle: 'Permohonan uang kas operasional harian divisi',
                              moduleIcon: Icons.payments_outlined,
                              actionButtonText: 'Ajukan Kas Kecil Baru',
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: ServiceModuleCard(
                          title: 'General Affair',
                          metricTag: 'Fasilitas & GA',
                          description: 'Pengadaan barang & sarana',
                          icon: Icons.inventory_2_outlined,
                          onTap: () => open(
                            DedicatedModuleScreen(
                              kind: SubmissionKind.generalAffair,
                              moduleTitle: 'Pengadaan General Affair',
                              heroTitle: 'Fasilitas & Aset Kantor',
                              heroSubtitle: 'Permohonan inventaris, sarana, ATK & perlengkapan',
                              moduleIcon: Icons.inventory_2_outlined,
                              actionButtonText: 'Ajukan Permintaan GA Baru',
                              api: api,
                              workspace: w,
                              open: open,
                              onRefresh: onRefresh,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: ServiceModuleCard(
                          title: 'Slip Gaji',
                          metricTag: 'Payroll',
                          description: 'Rincian pendapatan bulanan',
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: () => open(
                            PayrollTab(
                              api: api,
                              workspace: w,
                              onRefresh: onRefresh,
                              open: open,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // ==================== 2. PENGAJUAN TERKINI ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pengajuan Terkini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${allCards.length} Pengajuan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Pantau status dan tindak lanjut pengajuan terbaru Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),

              if (allCards.isEmpty)
                const EmptyState('Belum ada pengajuan aktif saat ini.')
              else
                ...allCards,
            ],
          ),
        ),
      ),
    );
  }
}
