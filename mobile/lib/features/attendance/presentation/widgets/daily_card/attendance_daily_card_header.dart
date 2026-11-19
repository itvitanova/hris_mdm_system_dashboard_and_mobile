import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AttendanceDailyCardHeader extends StatelessWidget {
  const AttendanceDailyCardHeader({
    super.key,
    required this.formattedDate,
    required this.statusLabel,
    required this.statusBgColor,
    required this.statusBorderColor,
    required this.statusDotColor,
    required this.statusTextColor,
    required this.isHighlighted,
  });

  final String formattedDate;
  final String statusLabel;
  final Color statusBgColor;
  final Color statusBorderColor;
  final Color statusDotColor;
  final Color statusTextColor;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  color: isHighlighted ? Colors.white : statusDotColor,
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
                  color: isHighlighted ? Colors.white : statusTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
