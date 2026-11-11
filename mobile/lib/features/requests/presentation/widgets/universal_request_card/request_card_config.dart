import 'package:flutter/material.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/submission_kind.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../domain/entities/universal_request_item.dart';

class RequestKindConfig {
  final IconData icon;
  final String typeTitle;
  final String Function(UniversalRequestModel) metricTag;
  final String? Function(UniversalRequestModel) secondaryMeta;

  const RequestKindConfig({
    required this.icon,
    required this.typeTitle,
    required this.metricTag,
    required this.secondaryMeta,
  });
}

class RequestStatusConfig {
  final String label;
  final Color barColor;
  final Color badgeBg;
  final Color badgeBorder;
  final Color textColor;

  const RequestStatusConfig({
    required this.label,
    required this.barColor,
    required this.badgeBg,
    required this.badgeBorder,
    required this.textColor,
  });
}

class RequestCardHelper {
  const RequestCardHelper._();

  static String formatIDR(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  static String formatDateRange(DateTime start, DateTime? end, [AppLanguage language = AppLanguage.id]) {
    final months = language == AppLanguage.en
        ? const [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ]
        : const [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Agu',
            'Sep',
            'Okt',
            'Nov',
            'Des',
          ];
    final sStr = '${start.day} ${months[start.month]} ${start.year}';
    if (end == null ||
        (start.day == end.day &&
            start.month == end.month &&
            start.year == end.year)) {
      return sStr;
    }
    final eStr = '${end.day} ${months[end.month]} ${end.year}';
    return '$sStr - $eStr';
  }

  static String singleStageTitle(SubmissionKind kind) {
    switch (kind) {
      case SubmissionKind.cuti:
        return 'Persetujuan Cuti';
      case SubmissionKind.izin:
        return 'Persetujuan Izin';
      case SubmissionKind.pettyCash:
        return 'Persetujuan Kas Kecil';
      case SubmissionKind.generalAffair:
        return 'Persetujuan General Affair';
      case SubmissionKind.lembur:
        return 'Persetujuan Lembur';
      case SubmissionKind.reimbursement:
        return 'Persetujuan Atasan';
      case SubmissionKind.medicalClaim:
        return 'Persetujuan Medical Claim';
    }
  }

  static RequestKindConfig getKindConfig(UniversalRequestModel d, [AppLanguage language = AppLanguage.id]) {
    final isEn = language == AppLanguage.en;
    switch (d.kind) {
      case SubmissionKind.cuti:
        return RequestKindConfig(
          icon: Icons.calendar_today_rounded,
          typeTitle: isEn ? 'Leave Request' : 'Pengajuan Cuti',
          metricTag: (m) => '${m.days ?? 1} ${isEn ? 'DAYS' : 'HARI'}',
          secondaryMeta: (m) =>
              m.leaveBalance != null ? (isEn ? '· Remaining ${m.leaveBalance} days' : '· Sisa ${m.leaveBalance} hari') : null,
        );
      case SubmissionKind.izin:
        return RequestKindConfig(
          icon: Icons.assignment_late_outlined,
          typeTitle: isEn ? 'Permission Request' : 'Pengajuan Izin',
          metricTag: (m) => '${m.days ?? 1} ${isEn ? 'DAYS' : 'HARI'}',
          secondaryMeta: (_) => isEn ? '· Work Permission' : '· Izin Kerja',
        );
      case SubmissionKind.reimbursement:
        return RequestKindConfig(
          icon: Icons.receipt_long_rounded,
          typeTitle: isEn ? 'Reimbursement Claim' : 'Klaim Reimbursement',
          metricTag: (m) => formatIDR(m.amount ?? 0),
          secondaryMeta: (m) => m.transactionCount != null
              ? (isEn ? '· ${m.transactionCount} transactions' : '· ${m.transactionCount} transaksi')
              : null,
        );
      case SubmissionKind.medicalClaim:
        return RequestKindConfig(
          icon: Icons.medical_services_outlined,
          typeTitle: 'Medical Claim',
          metricTag: (m) => formatIDR(m.amount ?? 0),
          secondaryMeta: (_) => isEn ? '· Medical Claim' : '· Klaim Medis',
        );
      case SubmissionKind.pettyCash:
        return RequestKindConfig(
          icon: Icons.account_balance_wallet_rounded,
          typeTitle: isEn ? 'Petty Cash Request' : 'Pengajuan Petty Cash',
          metricTag: (m) => formatIDR(m.amount ?? 0),
          secondaryMeta: (_) => isEn ? '· Operational Cash' : '· Kas Operasional',
        );
      case SubmissionKind.generalAffair:
        return RequestKindConfig(
          icon: Icons.inventory_2_rounded,
          typeTitle: isEn ? 'General Affair Request' : 'Pengajuan General Affair',
          metricTag: (m) => m.amount != null && m.amount! > 0
              ? formatIDR(m.amount!)
              : (isEn ? 'GA Facilities' : 'Fasilitas GA'),
          secondaryMeta: (_) => isEn ? '· Office Facilities' : '· Sarana Kantor',
        );
      case SubmissionKind.lembur:
        return RequestKindConfig(
          icon: Icons.schedule_rounded,
          typeTitle: isEn ? 'Overtime Request' : 'Pengajuan Lembur',
          metricTag: (m) => '${m.hours ?? 1} ${isEn ? 'HOURS' : 'JAM'}',
          secondaryMeta: (_) => isEn ? '· Overtime' : '· Jam Lembur',
        );
    }
  }

  static RequestStatusConfig getStatusConfig(
    SubmissionStatus s,
    SubmissionKind kind, [
    AppLanguage language = AppLanguage.id,
  ]) {
    final isEn = language == AppLanguage.en;
    switch (s) {
      case SubmissionStatus.disetujui:
        return RequestStatusConfig(
          label: isEn ? 'Approved' : 'Disetujui',
          barColor: const Color(0xFF0F766E),
          badgeBg: const Color(0xFFECFDF5),
          badgeBorder: const Color(0xFFA7F3D0),
          textColor: const Color(0xFF047857),
        );
      case SubmissionStatus.menunggu:
        final text = kind == SubmissionKind.reimbursement
            ? (isEn ? 'Waiting for Finance' : 'Menunggu Finance')
            : (isEn ? 'Pending' : 'Menunggu');
        return RequestStatusConfig(
          label: text,
          barColor: const Color(0xFF0F766E),
          badgeBg: const Color(0xFFFEF3C7),
          badgeBorder: const Color(0xFFFDE68A),
          textColor: const Color(0xFFB45309),
        );
      case SubmissionStatus.perluRevisi:
        return RequestStatusConfig(
          label: isEn ? 'Needs Revision' : 'Perlu Revisi',
          barColor: const Color(0xFF0F766E),
          badgeBg: const Color(0xFFFFF1F2),
          badgeBorder: const Color(0xFFFECDD3),
          textColor: const Color(0xFFBE123C),
        );
      case SubmissionStatus.ditolak:
        return RequestStatusConfig(
          label: isEn ? 'Rejected' : 'Ditolak',
          barColor: const Color(0xFF0F766E),
          badgeBg: const Color(0xFFF1F5F9),
          badgeBorder: const Color(0xFFCBD5E1),
          textColor: const Color(0xFF475569),
        );
    }
  }
}
