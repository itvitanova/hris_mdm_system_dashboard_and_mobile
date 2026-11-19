import '../language_swap_button.dart';
import 'dashboard_attendance_formatters.dart';

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
  /// Event untuk hari ini (today) ditandai dengan [isToday] = true agar menggunakan
  /// kartu teal gradient.
  static List<DashboardAttendanceItem> fromAttendanceList(
    List<dynamic> list, {
    int? limit,
    bool treatLatestAsToday = true,
    AppLanguage language = AppLanguage.id,
  }) {
    final items = <DashboardAttendanceItem>[];
    final now = DateTime.now();
    final String latestDateInList = list.isNotEmpty
        ? DashboardAttendanceFormatters.extractDate(list.first)
        : '';

    final String pulangTitle =
        language == AppLanguage.en ? 'Check Out' : 'Pulang';
    final String masukTitle =
        language == AppLanguage.en ? 'Check In' : 'Masuk';
    final String inOnTimeText =
        language == AppLanguage.en ? 'On Time' : 'Tepat';
    final String inLateText =
        language == AppLanguage.en ? 'Late' : 'Telat';
    final String outDoneText =
        language == AppLanguage.en ? 'Done' : 'Selesai';
    final String outEarlyText =
        language == AppLanguage.en ? 'Early' : 'Awal';
    const String methodText = 'Via Phone';

    for (final att in list) {
      final String dateStr = DashboardAttendanceFormatters.extractDate(att);
      final String? checkOut =
          DashboardAttendanceFormatters.extractString(att, 'checkOut');
      final String? checkIn =
          DashboardAttendanceFormatters.extractString(att, 'checkIn');
      final String status =
          DashboardAttendanceFormatters.extractString(att, 'status') ?? 'Hadir';
      final int lateMinutes =
          DashboardAttendanceFormatters.extractInt(att, 'lateMinutes');
      final int earlyMinutes =
          DashboardAttendanceFormatters.extractInt(att, 'earlyMinutes');

      final bool isLate =
          DashboardAttendanceFormatters.extractBool(att, 'isLate') ||
              status.toLowerCase() == 'terlambat' ||
              status.toLowerCase() == 'telat' ||
              status.toLowerCase() == 'late' ||
              status.toLowerCase().contains('terlambat') ||
              status.toLowerCase().contains('telat') ||
              lateMinutes > 0;
      final bool isEarly =
          DashboardAttendanceFormatters.extractBool(att, 'earlyDeparture') ||
              status.toLowerCase() == 'pulang awal' ||
              earlyMinutes > 0;

      final bool isToday = DashboardAttendanceFormatters.isSameDay(dateStr, now) ||
          (treatLatestAsToday && dateStr == latestDateInList);

      // 1. Event Pulang (Check-out) ditampilkan lebih atas jika ada
      if (checkOut != null &&
          checkOut.trim().isNotEmpty &&
          checkOut.trim() != '—' &&
          checkOut.trim() != '-') {
        items.add(
          DashboardAttendanceItem(
            type: DashboardAttendanceType.pulang,
            title: pulangTitle,
            statusText: isEarly ? outEarlyText : outDoneText,
            isLate: false,
            lateMinutes: 0,
            isEarly: isEarly,
            earlyMinutes: earlyMinutes,
            dateText: DashboardAttendanceFormatters.formatDate(dateStr, language),
            timeText: DashboardAttendanceFormatters.formatTime(checkOut),
            method: methodText,
            isToday: isToday,
            rawData: att,
          ),
        );
        if (limit != null && items.length >= limit) break;
      }

      // 2. Event Masuk (Check-in)
      if (checkIn != null &&
          checkIn.trim().isNotEmpty &&
          checkIn.trim() != '—' &&
          checkIn.trim() != '-') {
        items.add(
          DashboardAttendanceItem(
            type: DashboardAttendanceType.masuk,
            title: masukTitle,
            statusText: isLate ? inLateText : inOnTimeText,
            isLate: isLate,
            lateMinutes: lateMinutes,
            isEarly: false,
            earlyMinutes: 0,
            dateText: DashboardAttendanceFormatters.formatDate(dateStr, language),
            timeText: DashboardAttendanceFormatters.formatTime(checkIn),
            method: methodText,
            isToday: isToday,
            rawData: att,
          ),
        );
        if (limit != null && items.length >= limit) break;
      } else if (isLate || status.toLowerCase() == 'hadir') {
        items.add(
          DashboardAttendanceItem(
            type: DashboardAttendanceType.masuk,
            title: masukTitle,
            statusText: isLate ? inLateText : inOnTimeText,
            isLate: isLate,
            lateMinutes: lateMinutes,
            isEarly: false,
            earlyMinutes: 0,
            dateText: DashboardAttendanceFormatters.formatDate(dateStr, language),
            timeText: '--:--',
            method: methodText,
            isToday: isToday,
            rawData: att,
          ),
        );
        if (limit != null && items.length >= limit) break;
      }

      // 3. Fallback izin / sakit / cuti tanpa jam masuk & pulang
      if ((checkIn == null ||
              checkIn.trim().isEmpty ||
              checkIn.trim() == '—' ||
              checkIn.trim() == '-') &&
          (checkOut == null ||
              checkOut.trim().isEmpty ||
              checkOut.trim() == '—' ||
              checkOut.trim() == '-') &&
          !isLate &&
          status.toLowerCase() != 'hadir') {
        final statusTitle = status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : 'Absensi';
        items.add(
          DashboardAttendanceItem(
            type: DashboardAttendanceType.other,
            title: statusTitle,
            statusText: status.toUpperCase(),
            isLate: false,
            dateText: DashboardAttendanceFormatters.formatDate(dateStr, language),
            timeText: '--:--',
            method: 'Pengajuan',
            isToday: isToday,
            rawData: att,
          ),
        );
        if (limit != null && items.length >= limit) break;
      }
    }

    final result = limit != null ? items.take(limit).toList() : items;
    if (result.length > 1) {
      return [
        result[0],
        ...result.skip(1).map((item) => item.copyWith(isToday: false)),
      ];
    }
    return result;
  }
}
