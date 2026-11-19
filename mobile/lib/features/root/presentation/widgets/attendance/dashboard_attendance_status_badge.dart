import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dashboard_attendance_item.dart';

class DashboardAttendanceStatusBadge extends StatelessWidget {
  final DashboardAttendanceItem item;
  final bool isToday;

  const DashboardAttendanceStatusBadge({
    super.key,
    required this.item,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWarning = item.isLate || item.isEarly;

    final textColor = isToday
        ? Colors.white
        : (isWarning
            ? const Color(0xFFB91C1C)
            : (item.type == DashboardAttendanceType.pulang
                ? const Color(0xFF0284C7)
                : (item.type == DashboardAttendanceType.masuk
                    ? const Color(0xFF047857)
                    : const Color(0xFF475569))));

    final bgColor = isToday
        ? Colors.white.withValues(alpha: 0.20)
        : (isWarning
            ? const Color(0xFFFEECEC)
            : (item.type == DashboardAttendanceType.pulang
                ? const Color(0xFFE0F2FE)
                : (item.type == DashboardAttendanceType.masuk
                    ? const Color(0xFFE8FAF3)
                    : const Color(0xFFF1F5F9))));

    final borderColor = isToday
        ? Colors.white.withValues(alpha: 0.45)
        : (isWarning
            ? const Color(0xFFFECACA)
            : (item.type == DashboardAttendanceType.pulang
                ? const Color(0xFFBAE6FD)
                : (item.type == DashboardAttendanceType.masuk
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFE2E8F0))));

    final dotColor = isToday
        ? (isWarning ? const Color(0xFFF87171) : const Color(0xFF34D399))
        : (isWarning
            ? const Color(0xFFDC2626)
            : (item.type == DashboardAttendanceType.pulang
                ? const Color(0xFF0284C7)
                : (item.type == DashboardAttendanceType.masuk
                    ? const Color(0xFF059669)
                    : const Color(0xFF64748B))));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 0.8.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3.5.w,
            height: 3.5.w,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            item.statusText,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
