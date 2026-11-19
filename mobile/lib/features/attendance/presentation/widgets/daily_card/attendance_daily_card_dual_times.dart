import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AttendanceDailyCardDualTimes extends StatelessWidget {
  const AttendanceDailyCardDualTimes({
    super.key,
    required this.checkInTime,
    required this.checkOutTime,
    required this.hasCheckIn,
    required this.hasCheckOut,
    required this.isHighlighted,
    required this.isEn,
  });

  final String checkInTime;
  final String checkOutTime;
  final bool hasCheckIn;
  final bool hasCheckOut;
  final bool isHighlighted;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  SvgPicture.asset(
                    'assets/icon/login.svg',
                    width: 15.sp,
                    height: 15.sp,
                    colorFilter: ColorFilter.mode(
                      isHighlighted
                          ? Colors.white
                          : const Color(0xFF0F766E),
                      BlendMode.srcIn,
                    ),
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
                  SvgPicture.asset(
                    'assets/icon/logout.svg',
                    width: 15.sp,
                    height: 15.sp,
                    colorFilter: ColorFilter.mode(
                      isHighlighted
                          ? Colors.white
                          : const Color(0xFF0F766E),
                      BlendMode.srcIn,
                    ),
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
    );
  }
}
