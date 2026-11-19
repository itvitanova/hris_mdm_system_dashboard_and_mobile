import 'package:mdm_hris/core/workspace.dart';

class CalendarQueryHelper {
  static List<Json> onDate({
    required List<Json> entries,
    required DateTime day,
  }) {
    final d = dateOnly(day);
    return entries
        .where(
          (e) =>
              text(e, 'startDate').compareTo(d) <= 0 &&
              text(e, 'endDate').compareTo(d) >= 0,
        )
        .toList();
  }

  static List<Json> birthdaysOnDate({
    required Workspace workspace,
    required List<Json> entries,
    required List<Json> birthdays,
    required DateTime day,
  }) {
    final d = dateOnly(day);
    final fromApi = birthdays.where((b) => text(b, 'date') == d).toList();
    final results = <Json>[...fromApi];

    final emps = workspace.rows('employees');
    for (final emp in emps) {
      final bDate = text(emp, 'birthDate', '');
      if (bDate.length >= 10) {
        final m = int.tryParse(bDate.substring(5, 7));
        final dy = int.tryParse(bDate.substring(8, 10));
        if (m == day.month && dy == day.day) {
          results.add({
            'name': text(emp, 'name', 'Rekan Kerja'),
            'department': text(emp, 'department', ''),
            'position': text(emp, 'position', ''),
            'birthDate': bDate,
            'date': d,
          });
        }
      }
    }

    final leaveEntries = onDate(entries: entries, day: day);
    for (final le in leaveEntries) {
      final name = text(le, 'name', 'Rekan Kerja');
      if (!results.any((r) => text(r, 'name') == name)) {
        results.add({
          'name': name,
          'department': text(le, 'department', ''),
          'position': text(le, 'position', ''),
          'date': d,
        });
      }
    }
    return results;
  }

  static List<Json> birthdaysInMonth({
    required Workspace workspace,
    required List<Json> entries,
    required DateTime targetMonth,
  }) {
    final emps = workspace.rows('employees');
    final results = <Json>[];
    for (final emp in emps) {
      final bDate = text(emp, 'birthDate', '');
      if (bDate.length >= 10) {
        final m = int.tryParse(bDate.substring(5, 7));
        if (m == targetMonth.month) {
          final dy = int.tryParse(bDate.substring(8, 10)) ?? 1;
          results.add({
            'name': text(emp, 'name', 'Rekan Kerja'),
            'department': text(emp, 'department', ''),
            'position': text(emp, 'position', ''),
            'birthDate': bDate,
            'day': dy,
          });
        }
      }
    }
    for (final le in entries) {
      final sDate = text(le, 'startDate', '');
      if (sDate.length >= 10) {
        final m = int.tryParse(sDate.substring(5, 7));
        if (m == targetMonth.month) {
          final dy = int.tryParse(sDate.substring(8, 10)) ?? 1;
          final name = text(le, 'name', 'Rekan Kerja');
          if (!results.any((r) => text(r, 'name') == name)) {
            results.add({
              'name': name,
              'department': text(le, 'department', ''),
              'position': text(le, 'position', ''),
              'day': dy,
            });
          }
        }
      }
    }
    results.sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
    return results;
  }
}
