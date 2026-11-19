import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uicons/uicons.dart';
import 'dashboard_attendance_item.dart';

class DashboardAttendanceLeadingIcon extends StatelessWidget {
  final DashboardAttendanceItem item;
  final bool isToday;

  const DashboardAttendanceLeadingIcon({
    super.key,
    required this.item,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
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
        iconWidget = Icon(
          UIcons.regularRounded.clock,
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
      iconWidget = Icon(
        UIcons.regularRounded.clock,
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
}
