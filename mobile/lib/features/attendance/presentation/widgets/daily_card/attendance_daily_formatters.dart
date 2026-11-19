import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

class AttendanceDailyCardFormatters {
  static String extractDate(dynamic att) {
    if (att is Map) {
      return (att['date'] ?? att['attendanceDate'] ?? '').toString();
    }
    return '';
  }

  static String? extractString(dynamic att, String key) {
    if (att is Map) return att[key]?.toString();
    return null;
  }

  static String formatDate(
    String dateStr, [
    AppLanguage language = AppLanguage.id,
  ]) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const monthsId = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const daysId = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const daysEn = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];

    final dayName = language == AppLanguage.en
        ? daysEn[(dt.weekday - 1).clamp(0, 6)]
        : daysId[(dt.weekday - 1).clamp(0, 6)];

    if (language == AppLanguage.en) {
      return '$dayName, ${monthsEn[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    }
    return '$dayName, ${dt.day.toString().padLeft(2, '0')} ${monthsId[dt.month - 1]} ${dt.year}';
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
}
