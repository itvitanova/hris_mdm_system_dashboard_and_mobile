import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/workspace.dart';
import '../../../attendance/daily_attendance.dart';
import 'language_swap_button.dart';

class CompactAttendanceCard extends StatelessWidget {
  const CompactAttendanceCard({
    super.key,
    required this.workspace,
    required this.daily,
    required this.language,
    required this.onActionPressed,
  });

  final Workspace workspace;
  final DailyAttendance daily;
  final AppLanguage language;
  final VoidCallback? onActionPressed;

  String _formatDateHeader(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;

    final isEn = language == AppLanguage.en;
    final dayNames = isEn
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = isEn
        ? const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        : const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    return '${dayNames[dt.weekday - 1]}, ${dt.day} ${monthNames[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isEn = language == AppLanguage.en;

    final todayDate = text(
      daily.record,
      'date',
      text(workspace.data, 'attendanceDate', dateOnly(DateTime.now())),
    );
    final formattedDate = _formatDateHeader(todayDate);

    final workStart = text(workspace.attendancePolicy, 'workStart', '08:30');
    final workEnd = text(workspace.attendancePolicy, 'workEnd', '17:30');
    final shiftSubtitle = '$formattedDate • $workStart - $workEnd';

    // Check-In Tile Data
    final bool hasCheckIn = daily.checkedIn;
    final String inTime = hasCheckIn
        ? timeLabel(daily.record['checkIn'])
        : '— : —';
    final bool isLate = daily.record['isLate'] == true ||
        text(daily.record, 'status') == 'Terlambat' ||
        number(daily.record, 'lateMinutes') > 0;

    final String inChipText;
    final Color inChipBg;
    final Color inChipTextColor;
    if (hasCheckIn) {
      if (isLate) {
        inChipText = isEn ? 'Late' : 'Telat';
        inChipBg = const Color(0xFFEF4444).withValues(alpha: 0.25);
        inChipTextColor = const Color(0xFFFECACA);
      } else {
        inChipText = isEn ? 'On Time' : 'Tepat';
        inChipBg = const Color(0xFF34D399).withValues(alpha: 0.25);
        inChipTextColor = const Color(0xFFA7F3D0);
      }
    } else {
      inChipText = isEn ? 'Pending' : 'Belum';
      inChipBg = Colors.white.withValues(alpha: 0.12);
      inChipTextColor = const Color(0xFF99F6E4);
    }

    final String inSublabel = hasCheckIn
        ? (isEn ? 'Verified' : 'Verifikasi Sukses')
        : (isEn ? 'Shift: $workStart' : 'Jadwal: $workStart WIB');

    // Check-Out Tile Data
    final bool hasCheckOut = daily.completed;
    final String outTime = hasCheckOut
        ? timeLabel(daily.record['checkOut'])
        : '— : —';
    final bool isEarly = daily.record['earlyDeparture'] == true ||
        number(daily.record, 'earlyMinutes') > 0;

    final String outChipText;
    final Color outChipBg;
    final Color outChipTextColor;
    if (hasCheckOut) {
      if (isEarly) {
        outChipText = isEn ? 'Early' : 'Awal';
        outChipBg = const Color(0xFFEF4444).withValues(alpha: 0.25);
        outChipTextColor = const Color(0xFFFECACA);
      } else {
        outChipText = isEn ? 'Done' : 'Selesai';
        outChipBg = const Color(0xFF34D399).withValues(alpha: 0.25);
        outChipTextColor = const Color(0xFFA7F3D0);
      }
    } else {
      outChipText = isEn ? 'Pending' : 'Belum';
      outChipBg = Colors.white.withValues(alpha: 0.12);
      outChipTextColor = const Color(0xFF99F6E4);
    }

    final String outSublabel = hasCheckOut
        ? (isEn ? 'Shift Ended' : 'Selesai Kerja')
        : (hasCheckIn
            ? (isEn ? 'Est: $workEnd' : 'Estimasi: $workEnd WIB')
            : (isEn ? 'Shift: $workEnd' : 'Jadwal: $workEnd WIB'));

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D9488), // Teal 600
            Color(0xFF0F766E), // Teal 700
            Color(0xFF115E59), // Teal 800
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.25),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.schedule_rounded,
                  size: 15.sp,
                  color: const Color(0xFFCCFBF1),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEn ? "TODAY'S ATTENDANCE" : 'KEHADIRAN HARI INI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: const Color(0xFFCCFBF1),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      shiftSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF99F6E4).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 2. Dual Tiles (Equally Balanced via IntrinsicHeight & Stretch)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildTile(
                    label: isEn ? 'Check In' : 'Jam Masuk',
                    chipText: inChipText,
                    chipBg: inChipBg,
                    chipTextColor: inChipTextColor,
                    timeText: inTime,
                    isPendingTime: !hasCheckIn,
                    sublabel: inSublabel,
                    leadingIcon: hasCheckIn
                        ? Icon(
                            Icons.check_circle_rounded,
                            size: 12.sp,
                            color: const Color(0xFF34D399),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildTile(
                    label: isEn ? 'Check Out' : 'Jam Pulang',
                    chipText: outChipText,
                    chipBg: outChipBg,
                    chipTextColor: outChipTextColor,
                    timeText: outTime,
                    isPendingTime: !hasCheckOut,
                    sublabel: outSublabel,
                    leadingIcon: hasCheckOut
                        ? Icon(
                            Icons.check_circle_rounded,
                            size: 12.sp,
                            color: const Color(0xFF34D399),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // 3. Action Button
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F766E),
                disabledBackgroundColor:
                    const Color(0xFF0F766E).withValues(alpha: 0.6),
                disabledForegroundColor: const Color(0xFFB2EBF2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              onPressed: daily.completed ? null : onActionPressed,
              icon: Icon(
                daily.completed
                    ? Icons.check_circle_outline_rounded
                    : daily.checkedIn
                        ? Icons.logout_rounded
                        : Icons.login_rounded,
                size: 18.sp,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  daily.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String label,
    required String chipText,
    required Color chipBg,
    required Color chipTextColor,
    required String timeText,
    required bool isPendingTime,
    required String sublabel,
    Widget? leadingIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row 1: Label & Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFCCFBF1),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      chipText,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: chipTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Row 2: Time
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              timeText,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22.sp,
                fontWeight: isPendingTime ? FontWeight.w700 : FontWeight.w800,
                letterSpacing: isPendingTime ? 1.0 : -0.5,
                color: isPendingTime
                    ? const Color(0xFFCCFBF1).withValues(alpha: 0.6)
                    : Colors.white,
              ),
            ),
          ),
          SizedBox(height: 6.h),

          // Row 3: Sublabel with optional status icon
          SizedBox(
            height: 14.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon,
                  SizedBox(width: 4.w),
                ],
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      sublabel,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF99F6E4).withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
