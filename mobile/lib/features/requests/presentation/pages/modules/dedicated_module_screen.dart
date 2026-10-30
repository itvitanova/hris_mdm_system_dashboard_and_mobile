import 'package:flutter/material.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/requests/request_detail.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/features/requests/presentation/models/mock_universal_requests.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/module_stat_card.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/submission_status_filter_dropdown.dart';

/// Halaman Khusus (Dedicated Screen) untuk Setiap Modul Pengajuan Mandiri
/// Dilengkapi rekap statistik 2x2, filter status, dan header riwayat dengan tombol (+) tanpa FAB dan tanpa banner.
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

    // 1. Data riil dari workspace
    for (final r in rows) {
      final model = UniversalRequestModel.fromMap(r);
      if (model.kind == widget.kind) {
        items.add(model);
      }
    }

    // 2. Data mock jika belum ada data riil serupa
    for (final m in mockUniversalRequests) {
      if (m.kind == widget.kind && !items.any((x) => x.title == m.title)) {
        items.add(m);
      }
    }

    return items;
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

    // Filter daftar sesuai status terpilih
    final filteredRequests = _selectedStatusFilter != null
        ? allRequests
            .where((it) => it.status == _selectedStatusFilter)
            .toList()
        : allRequests;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          widget.moduleTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (widget.customActions != null) ...widget.customActions!,
          IconButton(
            tooltip: 'Segarkan data',
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
            children: [
              // ==================== 1. REKAP STATISTIK 2X2 ====================
              Row(
                children: [
                  Expanded(
                    child: ModuleStatCard(
                      label: 'DISETUJUI',
                      value: '$approvedCount',
                      icon: Icons.check_circle_outline_rounded,
                      isSelected:
                          _selectedStatusFilter == SubmissionStatus.disetujui,
                      onTap: () => setState(() {
                        _selectedStatusFilter = _selectedStatusFilter ==
                                SubmissionStatus.disetujui
                            ? null
                            : SubmissionStatus.disetujui;
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ModuleStatCard(
                      label: 'MENUNGGU',
                      value: '$pendingCount',
                      icon: Icons.access_time_rounded,
                      isSelected:
                          _selectedStatusFilter == SubmissionStatus.menunggu,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ModuleStatCard(
                      label: 'DITOLAK / REVISI',
                      value: '$rejectedCount',
                      icon: Icons.highlight_off_rounded,
                      isSelected:
                          _selectedStatusFilter == SubmissionStatus.ditolak ||
                              _selectedStatusFilter ==
                                  SubmissionStatus.perluRevisi,
                      onTap: () => setState(() {
                        _selectedStatusFilter =
                            _selectedStatusFilter == SubmissionStatus.ditolak
                                ? null
                                : SubmissionStatus.ditolak;
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ModuleStatCard(
                      label: widget.keyMetricLabel,
                      value: widget.keyMetricValue,
                      icon: widget.keyMetricIcon,
                      isSelected: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

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
                  const SizedBox(width: 10),
                  _FilterIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: widget.onRefresh,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================== 3. HEADER RIWAYAT DENGAN TOMBOL (+) ====================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Riwayat Pengajuan ${widget.kind.displayName} (${filteredRequests.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0F766E),
                            Color(0xFF14B8A6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x250F766E),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openCreateForm,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ==================== 4. DAFTAR KARTU PENGAJUAN ====================
              if (filteredRequests.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedStatusFilter != null
                            ? 'Tidak ada pengajuan dengan status ini.'
                            : 'Belum ada riwayat pengajuan ${widget.kind.displayName}.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _openCreateForm,
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: Color(0xFF0D9488),
                        ),
                        label: const Text(
                          'Buat Pengajuan Baru',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredRequests.map(
                  (model) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
          highlightColor: const Color(0xFF0D9488).withValues(alpha: 0.05),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF0D9488),
            ),
          ),
        ),
      ),
    );
  }
}
