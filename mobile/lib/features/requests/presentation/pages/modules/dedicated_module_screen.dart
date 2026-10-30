import 'package:flutter/material.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/requests/request_detail.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/features/requests/presentation/models/mock_universal_requests.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';

/// Halaman Khusus (Dedicated Screen) untuk Setiap Modul Layanan Mandiri
class DedicatedModuleScreen extends StatefulWidget {
  final SubmissionKind kind;
  final String moduleTitle;
  final String heroTitle;
  final String heroSubtitle;
  final IconData moduleIcon;
  final String actionButtonText;
  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function(Widget) open;
  final Future<void> Function() onRefresh;
  final List<Widget>? customActions;

  const DedicatedModuleScreen({
    super.key,
    required this.kind,
    required this.moduleTitle,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.moduleIcon,
    required this.actionButtonText,
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

  List<UniversalRequestModel> _getModuleRequests() {
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

    // 3. Filter berdasarkan status jika ada yang dipilih
    if (_selectedStatusFilter != null) {
      return items.where((it) => it.status == _selectedStatusFilter).toList();
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
    final requests = _getModuleRequests();

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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              // 1. HERO METRIC SUMMARY CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCCFBF1),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.moduleIcon,
                        size: 24,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.heroTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.heroSubtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. TOMBOL AKSI PRIMER (BUAT PENGAJUAN MODUL INI)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _openCreateForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: Text(
                    widget.actionButtonText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. STATUS FILTER TABS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(null, 'Semua'),
                    const SizedBox(width: 6),
                    _filterChip(SubmissionStatus.menunggu, 'Menunggu'),
                    const SizedBox(width: 6),
                    _filterChip(SubmissionStatus.disetujui, 'Disetujui'),
                    const SizedBox(width: 6),
                    _filterChip(SubmissionStatus.perluRevisi, 'Perlu Revisi'),
                    const SizedBox(width: 6),
                    _filterChip(SubmissionStatus.ditolak, 'Ditolak'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. LIST KARTU PENGAJUAN TERISOLASI
              if (requests.isEmpty)
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
                    ],
                  ),
                )
              else
                ...requests.map(
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

  Widget _filterChip(SubmissionStatus? status, String label) {
    final isSelected = _selectedStatusFilter == status;
    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = status),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
