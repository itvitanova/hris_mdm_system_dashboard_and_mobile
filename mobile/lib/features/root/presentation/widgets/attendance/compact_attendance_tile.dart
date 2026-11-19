import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompactAttendanceTile extends StatelessWidget {
  final String label;
  final String chipText;
  final Color chipBg;
  final Color chipTextColor;
  final String timeText;
  final bool isPendingTime;
  final String sublabel;
  final Widget? leadingIcon;

  const CompactAttendanceTile({
    super.key,
    required this.label,
    required this.chipText,
    required this.chipBg,
    required this.chipTextColor,
    required this.timeText,
    required this.isPendingTime,
    required this.sublabel,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
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
                  leadingIcon!,
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
