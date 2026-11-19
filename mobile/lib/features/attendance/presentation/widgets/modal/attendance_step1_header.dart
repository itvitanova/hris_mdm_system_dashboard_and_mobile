import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Step 1 Header: Title, subtitle, dismiss/back button, and bottom divider
class AttendanceStep1Header extends StatelessWidget {
  final VoidCallback? onClose;

  const AttendanceStep1Header({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verifikasi Lokasi & Waktu',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Mengecek posisi Anda terhadap radius kantor',
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
            Tooltip(
              message: 'Back',
              child: InkWell(
                onTap: onClose ?? () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    UIcons.regularRounded.cross_small,
                    size: 18.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 1.0),
      ],
    );
  }
}
