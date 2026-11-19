import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/daily_attendance.dart';
import 'compact_attendance_tile.dart';

class CompactAttendanceDualTiles extends StatelessWidget {
  final Workspace workspace;
  final DailyAttendance daily;
  final bool isEn;

  const CompactAttendanceDualTiles({
    super.key,
    required this.workspace,
    required this.daily,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final workStart = text(workspace.attendancePolicy, 'workStart', '08:30');
    final workEnd = text(workspace.attendancePolicy, 'workEnd', '17:30');

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

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CompactAttendanceTile(
              label: isEn ? 'Check In' : 'Jam Masuk',
              chipText: inChipText,
              chipBg: inChipBg,
              chipTextColor: inChipTextColor,
              timeText: inTime,
              isPendingTime: !hasCheckIn,
              sublabel: inSublabel,
              leadingIcon: hasCheckIn
                  ? Icon(
                      UIcons.regularRounded.check,
                      size: 12.sp,
                      color: const Color(0xFF34D399),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CompactAttendanceTile(
              label: isEn ? 'Check Out' : 'Jam Pulang',
              chipText: outChipText,
              chipBg: outChipBg,
              chipTextColor: outChipTextColor,
              timeText: outTime,
              isPendingTime: !hasCheckOut,
              sublabel: outSublabel,
              leadingIcon: hasCheckOut
                  ? Icon(
                      UIcons.regularRounded.check,
                      size: 12.sp,
                      color: const Color(0xFF34D399),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
