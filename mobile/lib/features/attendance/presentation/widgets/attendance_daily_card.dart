import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';
import 'daily_card/attendance_daily_card_dual_times.dart';
import 'daily_card/attendance_daily_card_header.dart';
import 'daily_card/attendance_daily_formatters.dart';

/// Kartu Riwayat Kehadiran Harian Compact & Simetris (1 Hari = 1 Kartu, ~90h)
/// Menampilkan ringkasan presensi harian secara presisi:
/// - Baris 1: Tanggal di kiri, Badge Status Spesifik di kanan (AttendanceDailyCardHeader).
/// - Baris 2: Segmented Dual-Box 50%:50% simetris (AttendanceDailyCardDualTimes).
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

    final dateStr = AttendanceDailyCardFormatters.extractDate(raw);
    final formattedDate = AttendanceDailyCardFormatters.formatDate(dateStr, language);

    final checkInRaw = AttendanceDailyCardFormatters.extractString(raw, 'checkIn');
    final checkOutRaw = AttendanceDailyCardFormatters.extractString(raw, 'checkOut');

    final hasCheckIn = checkInRaw != null &&
        checkInRaw.trim().isNotEmpty &&
        checkInRaw.trim() != '—' &&
        checkInRaw.trim() != '-';
    final hasCheckOut = checkOutRaw != null &&
        checkOutRaw.trim().isNotEmpty &&
        checkOutRaw.trim() != '—' &&
        checkOutRaw.trim() != '-';

    final checkInTime = hasCheckIn ? AttendanceDailyCardFormatters.formatTime(checkInRaw) : '--:--';
    final checkOutTime = hasCheckOut ? AttendanceDailyCardFormatters.formatTime(checkOutRaw) : '--:--';

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
    final String statusLabel;
    final Color statusBgColor;
    final Color statusBorderColor;
    final Color statusDotColor;
    final Color statusTextColor;

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
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
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
              AttendanceDailyCardHeader(
                formattedDate: formattedDate,
                statusLabel: statusLabel,
                statusBgColor: statusBgColor,
                statusBorderColor: statusBorderColor,
                statusDotColor: statusDotColor,
                statusTextColor: statusTextColor,
                isHighlighted: isHighlighted,
              ),
              SizedBox(height: 10.h),
              AttendanceDailyCardDualTimes(
                checkInTime: checkInTime,
                checkOutTime: checkOutTime,
                hasCheckIn: hasCheckIn,
                hasCheckOut: hasCheckOut,
                isHighlighted: isHighlighted,
                isEn: isEn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
