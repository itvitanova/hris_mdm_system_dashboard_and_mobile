import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uicons/uicons.dart';
import '../../../../attendance/presentation/widgets/daily_attendance.dart';

class CompactAttendanceActionButton extends StatelessWidget {
  final DailyAttendance daily;
  final bool isEn;
  final VoidCallback? onActionPressed;

  const CompactAttendanceActionButton({
    super.key,
    required this.daily,
    required this.isEn,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        icon: daily.completed
            ? Icon(
                UIcons.regularRounded.check,
                size: 17.sp,
              )
            : SvgPicture.asset(
                daily.checkedIn
                    ? 'assets/icon/logout.svg'
                    : 'assets/icon/login.svg',
                width: 17.sp,
                height: 17.sp,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF0F766E),
                  BlendMode.srcIn,
                ),
              ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            isEn
                ? (daily.completed
                    ? 'Attendance Completed'
                    : daily.checkedIn
                        ? 'Check Out'
                        : 'Check In')
                : daily.label,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
