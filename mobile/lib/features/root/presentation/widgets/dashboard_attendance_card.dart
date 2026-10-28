import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import 'language_swap_button.dart';

enum DashboardAttendanceType { masuk, pulang, other }

class DashboardAttendanceItem {
  final DashboardAttendanceType type;
  final String title;
  final String statusText;
  final bool isLate;
  final int lateMinutes;
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
    required this.dateText,
    required this.timeText,
    this.method = 'Via Fingerprint',
    this.isToday = false,
    this.rawData,
  });

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
    final String latestDateInList =
        list.isNotEmpty ? _extractDate(list.first) : '';

    final String pulangTitle =
        language == AppLanguage.en ? 'Check Out' : 'Pulang';
    final String masukTitle =
        language == AppLanguage.en ? 'Check In' : 'Masuk';
    final String onTimeText =
        language == AppLanguage.en ? 'On Time' : 'Tepat Waktu';
    const String methodText = 'Via Fingerprint';

    for (final att in list) {
      final String dateStr = _extractDate(att);
      final String? checkOut = _extractString(att, 'checkOut');
      final String? checkIn = _extractString(att, 'checkIn');
      final String status = _extractString(att, 'status') ?? 'Hadir';
      final int lateMinutes = _extractInt(att, 'lateMinutes');

      final bool isToday = _isSameDay(dateStr, now) ||
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
            statusText: onTimeText,
            isLate: false,
            dateText: _formatDate(dateStr, language),
            timeText: _formatTime(checkOut),
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
        final isLate =
            lateMinutes > 0 || status.toLowerCase() == 'terlambat';
        final String lateText = language == AppLanguage.en
            ? (lateMinutes > 0 ? 'Late (${lateMinutes}m)' : 'Late')
            : (lateMinutes > 0 ? 'Terlambat (${lateMinutes}m)' : 'Terlambat');

        items.add(
          DashboardAttendanceItem(
            type: DashboardAttendanceType.masuk,
            title: masukTitle,
            statusText: isLate ? lateText : onTimeText,
            isLate: isLate,
            lateMinutes: lateMinutes,
            dateText: _formatDate(dateStr, language),
            timeText: _formatTime(checkIn),
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
              checkOut.trim() == '-')) {
        final statusTitle = status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : 'Absensi';
        items.add(
          DashboardAttendanceItem(
            type: DashboardAttendanceType.other,
            title: statusTitle,
            statusText: status.toUpperCase(),
            isLate: false,
            dateText: _formatDate(dateStr, language),
            timeText: '--:--',
            method: 'Pengajuan',
            isToday: isToday,
            rawData: att,
          ),
        );
        if (limit != null && items.length >= limit) break;
      }
    }

    if (limit != null) {
      return items.take(limit).toList();
    }
    return items;
  }

  static String _extractDate(dynamic att) {
    if (att is Map) {
      return (att['date'] ?? att['attendanceDate'] ?? '').toString();
    }
    try {
      return (att.attendanceDate ?? att.date ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static String? _extractString(dynamic att, String key) {
    if (att is Map) return att[key]?.toString();
    try {
      if (key == 'checkIn') return att.checkIn?.toString();
      if (key == 'checkOut') return att.checkOut?.toString();
      if (key == 'status') return att.status?.toString();
    } catch (_) {}
    return null;
  }

  static int _extractInt(dynamic att, String key) {
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

  static String _formatDate(String dateStr,
      [AppLanguage language = AppLanguage.id]) {
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

  static String _formatTime(String timeStr) {
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

  static bool _isSameDay(String dateStr, DateTime target) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return false;
    return dt.year == target.year &&
        dt.month == target.month &&
        dt.day == target.day;
  }
}

class DashboardAttendanceCard extends StatelessWidget {
  final DashboardAttendanceItem item;
  final VoidCallback? onTap;

  const DashboardAttendanceCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = item.isToday;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.w),
        canRequestFocus: false,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 65.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
          decoration: isToday
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E), // Teal 700
                      Color(0xFF14B8A6), // Teal 500
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.w),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1.5.w,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x200F766E),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: const [AppShadows.shadow094],
                  color: AppColors.white,
                ),
          child: Row(
            children: [
              // 1. Icon Container
              _buildLeadingIcon(isToday),
              SizedBox(width: 12.w),

              // 2. Center Column: Title + Badge & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: _buildStatusBadge(isToday),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.w),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icon/calendar.svg',
                          width: 13.w,
                          height: 13.w,
                          colorFilter: ColorFilter.mode(
                            isToday
                                ? Colors.white.withValues(alpha: 0.85)
                                : const Color(0xFF64748B),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Flexible(
                          child: Text(
                            item.dateText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: isToday
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // 3. Right Column: Time & Method
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.timeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 5.w),
                    Text(
                      item.method,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isToday
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(bool isToday) {
    if (isToday) {
      Widget iconWidget;
      if (item.type == DashboardAttendanceType.pulang) {
        iconWidget = SvgPicture.asset(
          'assets/icon/logout.svg',
          width: 22.w,
          height: 22.w,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        );
      } else if (item.isLate) {
        iconWidget = const Icon(
          Icons.access_time_rounded,
          size: 24,
          color: Colors.white,
        );
      } else if (item.type == DashboardAttendanceType.masuk) {
        iconWidget = SvgPicture.asset(
          'assets/icon/login.svg',
          width: 22.w,
          height: 22.w,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        );
      } else {
        iconWidget = SvgPicture.asset(
          'assets/icon/calendar.svg',
          width: 20.w,
          height: 20.w,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        );
      }

      return Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: 1.2.w,
          ),
        ),
        alignment: Alignment.center,
        child: iconWidget,
      );
    }

    // Non-today cards: Unified Corporate Teal
    Widget iconWidget;
    const tealIconColor = Color(0xFF0D9488); // Teal 600

    if (item.type == DashboardAttendanceType.pulang) {
      iconWidget = SvgPicture.asset(
        'assets/icon/logout.svg',
        width: 22.w,
        height: 22.w,
        colorFilter: const ColorFilter.mode(
          tealIconColor,
          BlendMode.srcIn,
        ),
      );
    } else if (item.isLate) {
      iconWidget = const Icon(
        Icons.access_time_rounded,
        size: 24,
        color: tealIconColor,
      );
    } else if (item.type == DashboardAttendanceType.masuk) {
      iconWidget = SvgPicture.asset(
        'assets/icon/login.svg',
        width: 22.w,
        height: 22.w,
        colorFilter: const ColorFilter.mode(
          tealIconColor,
          BlendMode.srcIn,
        ),
      );
    } else {
      iconWidget = SvgPicture.asset(
        'assets/icon/calendar.svg',
        width: 20.w,
        height: 20.w,
        colorFilter: const ColorFilter.mode(
          tealIconColor,
          BlendMode.srcIn,
        ),
      );
    }

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA), // Frosted Soft Mint Teal
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFCCFBF1), // Soft Teal border
          width: 1.w,
        ),
      ),
      alignment: Alignment.center,
      child: iconWidget,
    );
  }

  Widget _buildStatusBadge(bool isToday) {
    if (isToday) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.45),
            width: 0.8.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: item.isLate
                    ? const Color(0xFFF87171)
                    : const Color(0xFF34D399),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.5.w),
            Flexible(
              child: Text(
                item.statusText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color bgColor;
    Color borderColor;
    Color dotColor;
    Color textColor;

    if (item.type == DashboardAttendanceType.pulang) {
      bgColor = const Color(0xFFE0F2FE);
      borderColor = const Color(0xFFBAE6FD);
      dotColor = const Color(0xFF0284C7);
      textColor = const Color(0xFF0284C7);
    } else if (item.isLate) {
      bgColor = const Color(0xFFFEECEC);
      borderColor = const Color(0xFFFECACA);
      dotColor = const Color(0xFFDC2626);
      textColor = const Color(0xFFB91C1C);
    } else if (item.type == DashboardAttendanceType.masuk) {
      bgColor = const Color(0xFFE8FAF3);
      borderColor = const Color(0xFFA7F3D0);
      dotColor = const Color(0xFF059669);
      textColor = const Color(0xFF047857);
    } else {
      bgColor = const Color(0xFFF1F5F9);
      borderColor = const Color(0xFFE2E8F0);
      dotColor = const Color(0xFF64748B);
      textColor = const Color(0xFF475569);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 0.8.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.5.w),
          Flexible(
            child: Text(
              item.statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
