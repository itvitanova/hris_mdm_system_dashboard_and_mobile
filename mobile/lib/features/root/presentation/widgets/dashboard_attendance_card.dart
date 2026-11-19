import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import 'attendance/dashboard_attendance_item.dart';
import 'attendance/dashboard_attendance_leading_icon.dart';
import 'attendance/dashboard_attendance_status_badge.dart';

export 'attendance/dashboard_attendance_item.dart';

class DashboardAttendanceCard extends StatelessWidget {
  final DashboardAttendanceItem item;
  final VoidCallback? onTap;
  final bool? isHighlighted;

  const DashboardAttendanceCard({
    super.key,
    required this.item,
    this.onTap,
    this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = isHighlighted ?? item.isToday;

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Icon Container
              DashboardAttendanceLeadingIcon(
                item: item,
                isToday: isToday,
              ),
              SizedBox(width: 10.w),

              // 2. Center Column: Title + Badge & Date
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          DashboardAttendanceStatusBadge(
                            item: item,
                            isToday: isToday,
                          ),
                        ],
                      ),
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
                        Expanded(
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
                flex: 3,
                fit: FlexFit.loose,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.timeText,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.w),
                      Text(
                        item.method,
                        maxLines: 1,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
