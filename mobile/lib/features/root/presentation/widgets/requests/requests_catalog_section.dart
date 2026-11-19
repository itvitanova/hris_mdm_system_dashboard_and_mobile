import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/workspace.dart';
import '../../../../requests/presentation/pages/modules/dedicated_module_screen.dart';
import '../../../../requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import '../language_swap_button.dart';
import 'requests_catalog_grid.dart';
import 'requests_catalog_header.dart';

/// Seksi Katalog Modul Pengajuan (Header + Grid 7 Modul)
class RequestsCatalogSection extends StatelessWidget {
  final bool isEn;
  final AppLanguage currentLanguage;
  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function(Widget) open;
  final Future<void> Function() onRefresh;
  final List<UniversalRequestModel> allModels;
  final Future<void> Function(Widget) onNavigate;

  const RequestsCatalogSection({
    super.key,
    required this.isEn,
    required this.currentLanguage,
    required this.api,
    required this.workspace,
    required this.open,
    required this.onRefresh,
    required this.allModels,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final cutiRequests = allModels.where((m) => m.kind == SubmissionKind.cuti).toList();
    final izinRequests = allModels.where((m) => m.kind == SubmissionKind.izin).toList();
    final lemburRequests = allModels.where((m) => m.kind == SubmissionKind.lembur).toList();
    final reimburseRequests = allModels.where((m) => m.kind == SubmissionKind.reimbursement).toList();
    final medicalRequests = allModels.where((m) => m.kind == SubmissionKind.medicalClaim).toList();
    final pettyCashRequests = allModels.where((m) => m.kind == SubmissionKind.pettyCash).toList();
    final gaRequests = allModels.where((m) => m.kind == SubmissionKind.generalAffair).toList();

    // 1. Cuti: Sisa kuota aktif
    final baseLeaveBalance = (workspace.employee['leaveBalance'] as num?)?.toInt() ?? 12;
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
        .fold<int>(0, (sum, r) => sum + (r.amount ?? 0).toInt());
    final reimburseMetricStr = rupiah(totalReimburseAmount);

    // 4. Medical Claim: Total nominal klaim yang disetujui
    final totalMedicalAmount = medicalRequests
        .where((r) => r.status == SubmissionStatus.disetujui)
        .fold<int>(0, (sum, r) => sum + (r.amount ?? 0).toInt());
    final medicalMetricStr = rupiah(totalMedicalAmount);

    // 5. Petty Cash: Jumlah permohonan kas kecil
    final pettyCashMetricStr = '${pettyCashRequests.length} ${isEn ? 'Submissions' : 'Pengajuan'}';

    // 6. GA: Jumlah permohonan sarana GA aktif / terkini
    final activeGaCount = gaRequests
        .where((r) => r.status == SubmissionStatus.menunggu || r.status == SubmissionStatus.perluRevisi)
        .length;
    final gaMetricStr = activeGaCount > 0
        ? '$activeGaCount ${isEn ? 'Active' : 'Aktif'}'
        : '${gaRequests.length} ${isEn ? 'Submissions' : 'Pengajuan'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequestsCatalogHeader(isEn: isEn),
        SizedBox(height: 12.h),
        RequestsCatalogGrid(
          isEn: isEn,
          cutiMetricStr: cutiMetricStr,
          izinCount: izinRequests.length,
          lemburMetricStr: lemburMetricStr,
          reimburseMetricStr: reimburseMetricStr,
          medicalMetricStr: medicalMetricStr,
          pettyCashMetricStr: pettyCashMetricStr,
          gaMetricStr: gaMetricStr,
          onOpenCuti: () => onNavigate(DedicatedModuleScreen(
            kind: SubmissionKind.cuti,
            moduleTitle: isEn ? 'Leave Request' : 'Pengajuan Cuti',
            keyMetricLabel: isEn ? 'REMAINING QUOTA' : 'SISA KUOTA',
            keyMetricValue: cutiMetricStr,
            keyMetricIcon: UIcons.regularRounded.calendar_clock,
            api: api,
            workspace: workspace,
            open: open,
            onRefresh: onRefresh,
            initialLanguage: currentLanguage,
          )),
          onOpenIzin: () => onNavigate(DedicatedModuleScreen(
            kind: SubmissionKind.izin,
            moduleTitle: isEn ? 'Permission Request' : 'Pengajuan Izin',
            keyMetricLabel: isEn ? 'TOTAL PERMISSIONS' : 'TOTAL IZIN',
            keyMetricValue: '${izinRequests.length} ${isEn ? 'Submissions' : 'Pengajuan'}',
            keyMetricIcon: UIcons.regularRounded.calendar_check,
            api: api,
            workspace: workspace,
            open: open,
            onRefresh: onRefresh,
            initialLanguage: currentLanguage,
          )),
          onOpenLembur: () => onNavigate(DedicatedModuleScreen(
            kind: SubmissionKind.lembur,
            moduleTitle: isEn ? 'Overtime Request' : 'Pengajuan Lembur',
            keyMetricLabel: isEn ? 'TOTAL OVERTIME' : 'TOTAL LEMBUR',
            keyMetricValue: lemburMetricStr,
            keyMetricIcon: UIcons.regularRounded.clock,
            api: api,
            workspace: workspace,
            open: open,
            onRefresh: onRefresh,
            initialLanguage: currentLanguage,
          )),
          onOpenReimbursement: () => onNavigate(DedicatedModuleScreen(
            kind: SubmissionKind.reimbursement,
            moduleTitle: isEn ? 'Reimbursement Claim' : 'Klaim Reimbursement',
            keyMetricLabel: isEn ? 'TOTAL CLAIMS' : 'TOTAL KLAIM',
            keyMetricValue: reimburseMetricStr,
            keyMetricIcon: UIcons.regularRounded.receipt,
            api: api,
            workspace: workspace,
            open: open,
            onRefresh: onRefresh,
            initialLanguage: currentLanguage,
          )),
          onOpenMedicalClaim: () => onNavigate(DedicatedModuleScreen(
            kind: SubmissionKind.medicalClaim,
            moduleTitle: 'Medical Claim',
            keyMetricLabel: isEn ? 'TOTAL CLAIMS' : 'TOTAL KLAIM',
            keyMetricValue: medicalMetricStr,
            keyMetricIcon: UIcons.regularRounded.stethoscope,
            api: api,
            workspace: workspace,
            open: open,
            onRefresh: onRefresh,
            initialLanguage: currentLanguage,
          )),
          onOpenPettyCash: () => onNavigate(DedicatedModuleScreen(
            kind: SubmissionKind.pettyCash,
            moduleTitle: isEn ? 'Petty Cash Request' : 'Pengajuan Petty Cash',
            keyMetricLabel: isEn ? 'TOTAL SUBMISSIONS' : 'TOTAL PENGAJUAN',
            keyMetricValue: pettyCashMetricStr,
            keyMetricIcon: UIcons.regularRounded.wallet,
            api: api,
            workspace: workspace,
            open: open,
            onRefresh: onRefresh,
            initialLanguage: currentLanguage,
          )),
          onOpenGeneralAffair: () => onNavigate(DedicatedModuleScreen(
            kind: SubmissionKind.generalAffair,
            moduleTitle: 'General Affair',
            keyMetricLabel: isEn ? 'GA REQUESTS' : 'PERMOHONAN GA',
            keyMetricValue: gaMetricStr,
            keyMetricIcon: UIcons.regularRounded.boxes,
            api: api,
            workspace: workspace,
            open: open,
            onRefresh: onRefresh,
            initialLanguage: currentLanguage,
          )),
        ),
      ],
    );
  }
}
