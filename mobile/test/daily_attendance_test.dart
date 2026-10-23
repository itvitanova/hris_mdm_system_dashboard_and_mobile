import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/daily_attendance.dart';

Workspace snapshot(List<Json> rows, {String date = '2026-10-23'}) => Workspace({
  'actor': {'employeeId': 'EMP-002'},
  'attendanceDate': date,
  'attendance': rows,
});
Json record({
  String employee = 'EMP-002',
  String date = '2026-10-23',
  bool out = false,
}) => {
  'employeeId': employee,
  'date': date,
  'checkIn': '${date}T09:00:00+07:00',
  'checkOut': out ? '${date}T17:00:00+07:00' : '',
};

void main() {
  test('check-in, check-out and completion follow the saved record', () {
    expect(DailyAttendance(snapshot([])).nextType, 'in');
    final checkedIn = DailyAttendance(snapshot([record()]));
    expect(checkedIn.nextType, 'out');
    expect(checkedIn.label, 'Absensi Keluar');
    final completed = DailyAttendance(snapshot([record(out: true)]));
    expect(completed.nextType, isNull);
    expect(completed.label, 'Absensi Selesai');
  });
  test('another employee and yesterday records never change the action', () {
    final state = DailyAttendance(
      snapshot([
        record(employee: 'EMP-003'),
        record(date: '2026-10-22', out: true),
      ]),
    );
    expect(state.label, 'Absensi Masuk');
  });
  test(
    'server company date wins over a different phone date and resets next day',
    () {
      expect(
        DailyAttendance(
          snapshot([record()]),
          now: DateTime(2026, 10, 24),
        ).nextType,
        'out',
      );
      expect(
        DailyAttendance(
          snapshot([record(out: true)], date: '2026-10-24'),
        ).nextType,
        'in',
      );
    },
  );
}
