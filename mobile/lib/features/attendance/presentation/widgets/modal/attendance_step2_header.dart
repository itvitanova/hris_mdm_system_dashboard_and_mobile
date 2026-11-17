import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Step 2 Header: Back navigation button to Step 1, title, subtitle, and bottom divider
class AttendanceStep2Header extends StatelessWidget {
  final String punchType;
  final VoidCallback onBack;

  const AttendanceStep2Header({
    super.key,
    required this.punchType,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final title = punchType == 'in' ? 'Ambil Absen Masuk' : 'Ambil Absen Keluar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Back',
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    UIcons.regularRounded.angle_small_left,
                    size: 18.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Posisikan wajah Anda di dalam bingkai',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 1.0),
      ],
    );
  }
}
