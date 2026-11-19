import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Compact badge displayed in Step 2 confirming verified location and radius
class AttendanceStep2VerifiedBadge extends StatelessWidget {
  final String officeName;
  final int distance;

  const AttendanceStep2VerifiedBadge({
    super.key,
    required this.officeName,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(UIcons.regularRounded.check, size: 12.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Terverifikasi di $officeName • Dalam radius ${distance}m',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D9488),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
