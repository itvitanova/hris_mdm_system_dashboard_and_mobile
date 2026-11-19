import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/submission_kind.dart';

class RequestFormatters {
  const RequestFormatters._();

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

  static String formatDateRange(
    DateTime start,
    DateTime? end, [
    AppLanguage language = AppLanguage.id,
  ]) {
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
}

class RequestDescriptionHelper {
  const RequestDescriptionHelper._();

  static String cleanCardDescription(String raw) {
    var desc = raw;
    final metadataMatch = RegExp(r'\n\n\[(.*?)\]$').firstMatch(desc);
    if (metadataMatch != null) {
      final metaContent = metadataMatch.group(1)!;
      final parts = metaContent
          .split(' · ')
          .where((part) {
            final p = part.trim().toLowerCase();
            return !p.startsWith('lampiran:') && !p.startsWith('jenis izin:');
          })
          .toList();
      final baseDesc = desc.substring(0, metadataMatch.start).trim();
      if (parts.isNotEmpty) {
        desc = baseDesc.isNotEmpty ? '$baseDesc\n\n[${parts.join(' · ')}]' : '[${parts.join(' · ')}]';
      } else {
        desc = baseDesc;
      }
    } else {
      desc = desc.replaceAll(RegExp(r'\[?Lampiran:\s*[^\]\n]+\]?', caseSensitive: false), '');
      desc = desc.replaceAll(RegExp(r'\[?Jenis Izin:\s*[^\]\n]+\]?', caseSensitive: false), '');
    }
    return desc.trim();
  }

  static String getDescriptionLabel(SubmissionKind kind, AppLanguage language) {
    final isEn = language == AppLanguage.en;
    switch (kind) {
      case SubmissionKind.cuti:
        return isEn ? 'Leave Reason' : 'Alasan Cuti';
      case SubmissionKind.izin:
        return isEn ? 'Permission Reason' : 'Alasan Izin';
      case SubmissionKind.lembur:
        return isEn ? 'Overtime Tasks' : 'Uraian Tugas Lembur';
      case SubmissionKind.reimbursement:
        return isEn ? 'Claim Description' : 'Keterangan Klaim';
      case SubmissionKind.medicalClaim:
        return isEn ? 'Medical Notes / Diagnosis' : 'Catatan / Diagnosa Medis';
      case SubmissionKind.pettyCash:
        return isEn ? 'Fund Purpose' : 'Peruntukan Dana';
      case SubmissionKind.generalAffair:
        return isEn ? 'GA Requirements' : 'Deskripsi Kebutuhan GA';
    }
  }
}
