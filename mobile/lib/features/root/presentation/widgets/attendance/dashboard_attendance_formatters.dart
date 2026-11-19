import '../language_swap_button.dart';

class DashboardAttendanceFormatters {
  static String extractDate(dynamic att) {
    if (att is Map) {
      return (att['date'] ?? att['attendanceDate'] ?? '').toString();
    }
    try {
      return (att.attendanceDate ?? att.date ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static String? extractString(dynamic att, String key) {
    if (att is Map) return att[key]?.toString();
    try {
      if (key == 'checkIn') return att.checkIn?.toString();
      if (key == 'checkOut') return att.checkOut?.toString();
      if (key == 'status') return att.status?.toString();
    } catch (_) {}
    return null;
  }

  static int extractInt(dynamic att, String key) {
    if (att is Map) {
      final v = att[key];
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }
    try {
      if (key == 'lateMinutes') {
        final v = att.lateMinutes;
        if (v is num) return v.toInt();
      }
    } catch (_) {}
    return 0;
  }

  static bool extractBool(dynamic att, String key) {
    if (att is Map) {
      final v = att[key];
      if (v is bool) return v;
      if (v == 'true' || v == 1) return true;
    }
    try {
      if (key == 'isLate') return att.isLate == true;
      if (key == 'earlyDeparture') return att.earlyDeparture == true;
    } catch (_) {}
    return false;
  }

  static String formatDate(String dateStr, [AppLanguage language = AppLanguage.id]) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const monthsId = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const monthsEn = [
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
    ];
    if (language == AppLanguage.en) {
      return '${monthsEn[dt.month - 1]} ${dt.day}, ${dt.year}';
    }
    return '${dt.day} ${monthsId[dt.month - 1]} ${dt.year}';
  }

  static String formatTime(String timeStr) {
    final clean = timeStr.trim();
    if (clean.isEmpty || clean == '—' || clean == '-') return '--:--';

    final dt = DateTime.tryParse(clean);
    if (dt != null) {
      final local = dt.toLocal();
      final hour = local.hour;
      final minute = local.minute;
      final String period = hour >= 12 ? 'pm' : 'am';
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;
      final hourStr = hour12.toString().padLeft(2, '0');
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr $period';
    }

    final parts = clean.split(':');
    if (parts.length < 2) return timeStr;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return timeStr;

    final String period = hour >= 12 ? 'pm' : 'am';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;

    final hourStr = hour12.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  static bool isSameDay(String dateStr, DateTime target) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return false;
    return dt.year == target.year &&
        dt.month == target.month &&
        dt.day == target.day;
  }
}
