import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'attendance_map_painters.dart';

/// Visual Map Card showing office location pin, user GPS pin, distance line, and radius
class AttendanceMapVisualCard extends StatelessWidget {
  final String officeName;
  final double? distance;
  final bool isSafe;

  const AttendanceMapVisualCard({
    super.key,
    required this.officeName,
    required this.distance,
    required this.isSafe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: MapGridPainter(),
          ),
          Positioned(
            left: 55.w,
            top: 25.h,
            child: Container(
              width: 85.w,
              height: 85.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFF0D9488),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0F766E),
                  ),
                  child: Center(
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 35.w,
            top: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                officeName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (distance != null)
            Positioned(
              left: 105.w,
              top: 66.h,
              right: 85.w,
              child: CustomPaint(
                size: Size(130.w, 1.h),
                painter: DashedLinePainter(
                  color: isSafe ? const Color(0xFF0D9488) : const Color(0xFFDC2626),
                ),
              ),
            ),
          Positioned(
            right: 50.w,
            top: 55.h,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSafe ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
                boxShadow: [
                  BoxShadow(
                    color: (isSafe ? const Color(0xFF0D9488) : const Color(0xFFEF4444))
                        .withValues(alpha: 0.35),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (distance != null)
            Positioned(
              left: 135.w,
              top: 48.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSafe ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSafe ? const Color(0xFF0D9488) : const Color(0xFFDC2626),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${distance!.round()} m',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: isSafe ? const Color(0xFF065F46) : const Color(0xFF991B1B),
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
