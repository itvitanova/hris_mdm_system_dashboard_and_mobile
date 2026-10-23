import '../../core/workspace.dart';

class DailyAttendance {
  DailyAttendance._(this.record);
  factory DailyAttendance(Workspace workspace, {DateTime? now}) {
    // The server supplies the date in the company's configured time zone.
    final today = text(
      workspace.data,
      'attendanceDate',
      dateOnly(now ?? DateTime.now()),
    );
    final record = workspace
        .mine('attendance')
        .firstWhere(
          (row) => row['date'] == today,
          orElse: () => <String, dynamic>{},
        );
    return DailyAttendance._(record);
  }
  final Json record;
  bool get checkedIn => text(record, 'checkIn', '').isNotEmpty;
  bool get completed => checkedIn && text(record, 'checkOut', '').isNotEmpty;
  String? get nextType => completed
      ? null
      : checkedIn
      ? 'out'
      : 'in';
  String get label => completed
      ? 'Absensi Selesai'
      : checkedIn
      ? 'Absensi Keluar'
      : 'Absensi Masuk';
  String get description => completed
      ? 'Absensi hari ini sudah lengkap.'
      : checkedIn
      ? 'Anda sudah melakukan absensi masuk hari ini.'
      : 'Anda belum melakukan absensi masuk hari ini.';
}
