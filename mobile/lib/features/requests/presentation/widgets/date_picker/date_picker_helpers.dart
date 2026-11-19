class DatePickerHelpers {
  const DatePickerHelpers._();

  static const List<String> monthNames = [
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
    'Desember'
  ];

  static const List<String> dayNames = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab'
  ];

  static const List<String> dayNamesLong = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu'
  ];

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatDisplayDate(DateTime date) {
    final weekdayStr = dayNamesLong[date.weekday % 7];
    final monthStr = monthNames[date.month - 1].substring(0, 3);
    return '$weekdayStr, ${date.day} $monthStr ${date.year}';
  }
}
