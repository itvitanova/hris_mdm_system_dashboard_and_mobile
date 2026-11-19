import '../language_swap_button.dart';
import 'dashboard_attendance_mapper.dart';

enum DashboardAttendanceType { masuk, pulang, other }

class DashboardAttendanceItem {
  final DashboardAttendanceType type;
  final String title;
  final String statusText;
  final bool isLate;
  final int lateMinutes;
  final bool isEarly;
  final int earlyMinutes;
  final String dateText;
  final String timeText;
  final String method;
  final bool isToday;
  final dynamic rawData;

  const DashboardAttendanceItem({
    required this.type,
    required this.title,
    required this.statusText,
    required this.isLate,
    this.lateMinutes = 0,
    this.isEarly = false,
    this.earlyMinutes = 0,
    required this.dateText,
    required this.timeText,
    this.method = 'Via Phone',
    this.isToday = false,
    this.rawData,
  });

  DashboardAttendanceItem copyWith({
    DashboardAttendanceType? type,
    String? title,
    String? statusText,
    bool? isLate,
    int? lateMinutes,
    bool? isEarly,
    int? earlyMinutes,
    String? dateText,
    String? timeText,
    String? method,
    bool? isToday,
    dynamic rawData,
  }) {
    return DashboardAttendanceItem(
      type: type ?? this.type,
      title: title ?? this.title,
      statusText: statusText ?? this.statusText,
      isLate: isLate ?? this.isLate,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      isEarly: isEarly ?? this.isEarly,
      earlyMinutes: earlyMinutes ?? this.earlyMinutes,
      dateText: dateText ?? this.dateText,
      timeText: timeText ?? this.timeText,
      method: method ?? this.method,
      isToday: isToday ?? this.isToday,
      rawData: rawData ?? this.rawData,
    );
  }

  /// Ekstraksi item absensi menjadi deretan kartu aktivitas masuk/pulang.
  static List<DashboardAttendanceItem> fromAttendanceList(
    List<dynamic> list, {
    int? limit,
    bool treatLatestAsToday = true,
    AppLanguage language = AppLanguage.id,
  }) {
    return DashboardAttendanceMapper.fromAttendanceList(
      list,
      limit: limit,
      treatLatestAsToday: treatLatestAsToday,
      language: language,
    );
  }
}
