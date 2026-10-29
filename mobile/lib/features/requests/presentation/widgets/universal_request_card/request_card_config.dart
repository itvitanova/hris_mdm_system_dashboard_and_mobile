import 'package:flutter/material.dart';
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
    final buffer = StringBuffer('Rp ');
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  static String formatDateRange(DateTime start, DateTime? end) {
    const months = [
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
      case SubmissionKind.pettyCash:
        return 'Persetujuan Kas Kecil';
      case SubmissionKind.generalAffair:
        return 'Persetujuan General Affair';
      case SubmissionKind.lembur:
        return 'Persetujuan Lembur';
      case SubmissionKind.reimbursement:
        return 'Persetujuan Atasan';
    }
  }

  static RequestKindConfig getKindConfig(UniversalRequestModel d) {
    switch (d.kind) {
      case SubmissionKind.cuti:
        return RequestKindConfig(
          icon: Icons.calendar_today_rounded,
          typeTitle: 'Pengajuan Cuti',
          metricTag: (m) => '${m.days ?? 1} HARI',
          secondaryMeta: (m) =>
              m.leaveBalance != null ? '· Sisa ${m.leaveBalance} hari' : null,
        );
      case SubmissionKind.reimbursement:
        return RequestKindConfig(
          icon: Icons.receipt_long_rounded,
          typeTitle: 'Klaim Reimbursement',
          metricTag: (m) => formatIDR(m.amount ?? 0),
          secondaryMeta: (m) => m.transactionCount != null
              ? '· ${m.transactionCount} transaksi'
              : null,
        );
      case SubmissionKind.pettyCash:
        return RequestKindConfig(
          icon: Icons.account_balance_wallet_rounded,
          typeTitle: 'Pengajuan Petty Cash',
          metricTag: (m) => formatIDR(m.amount ?? 0),
          secondaryMeta: (_) => '· Kas Operasional',
        );
      case SubmissionKind.generalAffair:
        return RequestKindConfig(
          icon: Icons.inventory_2_rounded,
          typeTitle: 'Pengajuan General Affair',
          metricTag: (m) => formatIDR(m.amount ?? 0),
          secondaryMeta: (_) => '· Fasilitas Kantor',
        );
      case SubmissionKind.lembur:
        return RequestKindConfig(
          icon: Icons.schedule_rounded,
          typeTitle: 'Pengajuan Lembur',
          metricTag: (m) => '${m.hours ?? 1} JAM',
          secondaryMeta: (_) => '· Jam Lembur',
        );
    }
  }

  static RequestStatusConfig getStatusConfig(
    SubmissionStatus s,
    SubmissionKind kind,
  ) {
    switch (s) {
      case SubmissionStatus.disetujui:
        return const RequestStatusConfig(
          label: 'Disetujui',
          barColor: Color(0xFF059669),
          badgeBg: Color(0xFFECFDF5),
          badgeBorder: Color(0xFFA7F3D0),
          textColor: Color(0xFF047857),
        );
      case SubmissionStatus.menunggu:
        final text = kind == SubmissionKind.reimbursement
            ? 'Menunggu Finance'
            : 'Menunggu';
        return RequestStatusConfig(
          label: text,
          barColor: const Color(0xFF0F766E),
          badgeBg: const Color(0xFFFEF3C7),
          badgeBorder: const Color(0xFFFDE68A),
          textColor: const Color(0xFFB45309),
        );
      case SubmissionStatus.perluRevisi:
        return const RequestStatusConfig(
          label: 'Perlu Revisi',
          barColor: Color(0xFFE11D48),
          badgeBg: Color(0xFFFFF1F2),
          badgeBorder: Color(0xFFFECDD3),
          textColor: Color(0xFFBE123C),
        );
      case SubmissionStatus.ditolak:
        return const RequestStatusConfig(
          label: 'Ditolak',
          barColor: Color(0xFF64748B),
          badgeBg: Color(0xFFF1F5F9),
          badgeBorder: Color(0xFFCBD5E1),
          textColor: Color(0xFF475569),
        );
    }
  }
}
