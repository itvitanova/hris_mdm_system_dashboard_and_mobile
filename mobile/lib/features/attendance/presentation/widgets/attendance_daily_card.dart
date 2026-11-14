import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/workspace.dart';
import '../../../root/presentation/widgets/language_swap_button.dart';

/// Kartu Riwayat Kehadiran Harian Compact & Simetris (1 Hari = 1 Kartu, ~90h)
/// Menampilkan ringkasan presensi harian secara presisi:
/// - Baris 1: Tanggal di kiri, Badge Status Spesifik di kanan.
/// - Baris 2: Segmented Dual-Box 50%:50% simetris sempurna dengan garis pemisah tengah
///   (Jam Masuk di kiri, Jam Pulang di kanan).
class AttendanceDailyCard extends StatelessWidget {
  final Map<String, dynamic> raw;
  final bool isHighlighted;
  final AppLanguage language;
  final VoidCallback? onTap;

  const AttendanceDailyCard({
    super.key,
    required this.raw,
    this.isHighlighted = false,
    this.language = AppLanguage.id,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = language == AppLanguage.en;

    final dateStr = _extractDate(raw);
    final formattedDate = _formatDate(dateStr, language);

    final checkInRaw = _extractString(raw, 'checkIn');
    final checkOutRaw = _extractString(raw, 'checkOut');

    final hasCheckIn = checkInRaw != null &&
        checkInRaw.trim().isNotEmpty &&
        checkInRaw.trim() != '—' &&
        checkInRaw.trim() != '-';
    final hasCheckOut = checkOutRaw != null &&
        checkOutRaw.trim().isNotEmpty &&
        checkOutRaw.trim() != '—' &&
        checkOutRaw.trim() != '-';

    final checkInTime = hasCheckIn ? _formatTime(checkInRaw) : '--:--';
    final checkOutTime = hasCheckOut ? _formatTime(checkOutRaw) : '--:--';

    final statusRaw = text(raw, 'status', '').toLowerCase();
    final lateMinutes = (raw['lateMinutes'] as num?)?.toInt() ?? 0;
    final isLate = raw['isLate'] == true ||
        lateMinutes > 0 ||
        statusRaw == 'terlambat' ||
        statusRaw == 'telat' ||
        statusRaw == 'late' ||
        statusRaw.contains('terlambat') ||
        statusRaw.contains('telat');

    final isAttended = hasCheckIn ||
        hasCheckOut ||
        isLate ||
        statusRaw == 'hadir' ||
        statusRaw == 'terlambat' ||
        statusRaw == 'telat' ||
        statusRaw == 'late';

    // Status Utama Kartu (Format Spesifik)
    String statusLabel;
    Color statusBgColor;
    Color statusBorderColor;
    Color statusDotColor;
    Color statusTextColor;

    if (!isAttended) {
      statusLabel = isEn ? 'Absent' : 'Belum Absen';
      statusBgColor = const Color(0xFFF1F5F9);
      statusBorderColor = const Color(0xFFE2E8F0);
      statusDotColor = const Color(0xFF94A3B8);
      statusTextColor = const Color(0xFF64748B);
    } else if (isLate) {
      statusLabel = lateMinutes > 0
          ? (isEn ? 'Late ${lateMinutes}m' : 'Telat ${lateMinutes}m')
          : (isEn ? 'Late' : 'Telat');
      statusBgColor = const Color(0xFFFEF2F2);
      statusBorderColor = const Color(0xFFFECACA);
      statusDotColor = const Color(0xFFEF4444);
      statusTextColor = const Color(0xFFB91C1C);
    } else {
      statusLabel = isEn ? 'On Time' : 'Tepat Waktu';
      statusBgColor = const Color(0xFFF0FDFA);
      statusBorderColor = const Color(0xFFCCFBF1);
      statusDotColor = const Color(0xFF0D9488);
      statusTextColor = const Color(0xFF0F766E);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        canRequestFocus: false,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: isHighlighted
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E), // Teal 700
                      Color(0xFF14B8A6), // Teal 500
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
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
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: const [AppShadows.shadow094],
                  color: AppColors.white,
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.w,
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // === 1. BARIS ATAS: TANGGAL & BADGE STATUS SPESIFIK ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tanggal & Icon Kalender
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icon/calendar.svg',
                          width: 13.w,
                          height: 13.w,
                          colorFilter: ColorFilter.mode(
                            isHighlighted
                                ? Colors.white.withValues(alpha: 0.95)
                                : const Color(0xFF64748B),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            formattedDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isHighlighted
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Badge Status Spesifik
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? Colors.white.withValues(alpha: 0.2)
                          : statusBgColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isHighlighted
                            ? Colors.white.withValues(alpha: 0.45)
                            : statusBorderColor,
                        width: 0.8.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? Colors.white
                                : statusDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.5.w),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: isHighlighted
                                ? Colors.white
                                : statusTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // === 2. BARIS BAWAH: SEGMENTED DUAL-BOX 50%:50% SIMETRIS ===
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFE2E8F0),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  children: [
                    // --- SISI KIRI (50%): JAM MASUK ---
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              UIcons.regularRounded.sign_in_alt,
                              size: 15.sp,
                              color: isHighlighted
                                  ? Colors.white
                                  : const Color(0xFF0F766E),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isEn ? 'CHECK IN' : 'JAM MASUK',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      color: isHighlighted
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    checkInTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isHighlighted
                                          ? Colors.white
                                          : (hasCheckIn
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- GARIS PEMISAH TENGAH VERTIKAL (SIMETRI POROS TENGAH) ---
                    Container(
                      width: 0.8.w,
                      height: 30.h,
                      color: isHighlighted
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFFCBD5E1),
                    ),

                    // --- SISI KANAN (50%): JAM PULANG ---
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              UIcons.regularRounded.sign_out_alt,
                              size: 15.sp,
                              color: isHighlighted
                                  ? Colors.white
                                  : const Color(0xFF0F766E),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isEn ? 'CHECK OUT' : 'JAM PULANG',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      color: isHighlighted
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    checkOutTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isHighlighted
                                          ? Colors.white
                                          : (hasCheckOut
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  static String _extractDate(dynamic att) {
    if (att is Map) {
      return (att['date'] ?? att['attendanceDate'] ?? '').toString();
    }
    return '';
  }

  static String? _extractString(dynamic att, String key) {
    if (att is Map) return att[key]?.toString();
    return null;
  }

  static String _formatDate(
    String dateStr, [
    AppLanguage language = AppLanguage.id,
  ]) {
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
    const daysId = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const daysEn = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    final dayName = language == AppLanguage.en
        ? daysEn[(dt.weekday - 1).clamp(0, 6)]
        : daysId[(dt.weekday - 1).clamp(0, 6)];

    if (language == AppLanguage.en) {
      return '$dayName, ${monthsEn[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    }
    return '$dayName, ${dt.day.toString().padLeft(2, '0')} ${monthsId[dt.month - 1]} ${dt.year}';
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
}
