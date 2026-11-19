import 'package:mdm_hris/core/workspace.dart';
import '../attendance_stat_card.dart';
import '../filter_dropdowns.dart';

class AttendanceHistoryStats {
  const AttendanceHistoryStats({
    required this.countSudahAbsen,
    required this.countTepatWaktu,
    required this.countTerlambat,
    required this.countBelumAbsen,
  });

  final int countSudahAbsen;
  final int countTepatWaktu;
  final int countTerlambat;
  final int countBelumAbsen;
}

class AttendanceHistoryQueryHelper {
  static String extractRawDate(Map<String, dynamic> r) {
    for (final key in ['date', 'attendanceDate', 'checkIn', 'createdAt']) {
      final val = text(r, key, '').trim();
      if (val.isNotEmpty && val != '—' && val != '-') {
        return val;
      }
    }
    return '';
  }

  static bool matchesPeriod(String rawDate, int year, MonthEnum? month) {
    if (rawDate.isEmpty) return false;
    final parsed = DateTime.tryParse(rawDate);
    if (parsed != null) {
      if (parsed.year != year) return false;
      if (month != null && parsed.month != (month.index + 1)) return false;
      return true;
    }
    if (!rawDate.startsWith('$year')) return false;
    if (month != null) {
      final prefix = '$year-${(month.index + 1).toString().padLeft(2, '0')}';
      if (!rawDate.startsWith(prefix)) return false;
    }
    return true;
  }

  static AttendanceHistoryStats calculateStats(List<Map<String, dynamic>> records) {
    int countSudahAbsen = 0;
    int countTepatWaktu = 0;
    int countTerlambat = 0;
    int countBelumAbsen = 0;

    for (final r in records) {
      final s = text(r, 'status').toLowerCase();
      final lateMin = (r['lateMinutes'] as num?)?.toInt() ?? 0;
      final isLate = (r['isLate'] == true) ||
          lateMin > 0 ||
          s == 'terlambat' ||
          s == 'telat' ||
          s == 'late' ||
          s.contains('terlambat') ||
          s.contains('telat');
      final checkIn = text(r, 'checkIn', '').trim();
      final checkOut = text(r, 'checkOut', '').trim();
      final hasCheckIn = checkIn.isNotEmpty && checkIn != '—' && checkIn != '-';
      final hasCheckOut = checkOut.isNotEmpty && checkOut != '—' && checkOut != '-';

      final isAttended = hasCheckIn ||
          hasCheckOut ||
          isLate ||
          s == 'hadir' ||
          s == 'terlambat' ||
          s == 'telat' ||
          s == 'late' ||
          s.contains('hadir');

      if (isAttended) {
        countSudahAbsen++;
        if (isLate) {
          countTerlambat++;
        } else {
          countTepatWaktu++;
        }
      } else {
        countBelumAbsen++;
      }
    }

    return AttendanceHistoryStats(
      countSudahAbsen: countSudahAbsen,
      countTepatWaktu: countTepatWaktu,
      countTerlambat: countTerlambat,
      countBelumAbsen: countBelumAbsen,
    );
  }

  static List<Map<String, dynamic>> filterByStatus(
    List<Map<String, dynamic>> records,
    AttendanceStatType? selected,
  ) {
    if (selected == null) return records;

    return records.where((r) {
      final s = text(r, 'status').toLowerCase();
      final lateMin = (r['lateMinutes'] as num?)?.toInt() ?? 0;
      final isLate = (r['isLate'] == true) ||
          lateMin > 0 ||
          s == 'terlambat' ||
          s == 'telat' ||
          s == 'late' ||
          s.contains('terlambat') ||
          s.contains('telat');
      final checkIn = text(r, 'checkIn', '').trim();
      final checkOut = text(r, 'checkOut', '').trim();
      final hasCheckIn = checkIn.isNotEmpty && checkIn != '—' && checkIn != '-';
      final hasCheckOut = checkOut.isNotEmpty && checkOut != '—' && checkOut != '-';

      final isAttended = hasCheckIn ||
          hasCheckOut ||
          isLate ||
          s == 'hadir' ||
          s == 'terlambat' ||
          s == 'telat' ||
          s == 'late' ||
          s.contains('hadir');

      switch (selected) {
        case AttendanceStatType.sudahAbsen:
          return isAttended;
        case AttendanceStatType.tepatWaktu:
          return isAttended && !isLate;
        case AttendanceStatType.terlambat:
          return isAttended && isLate;
        case AttendanceStatType.belumAbsen:
          return !isAttended;
      }
    }).toList();
  }
}
