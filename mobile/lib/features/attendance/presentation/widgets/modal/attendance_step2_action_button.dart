import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Primary action button for Step 2 to launch camera face recognition screen
class AttendanceStep2ActionButton extends StatelessWidget {
  final bool isFaceEnrolled;
  final String punchType;
  final VoidCallback onPressed;

  const AttendanceStep2ActionButton({
    super.key,
    required this.isFaceEnrolled,
    required this.punchType,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final title = punchType == 'in' ? 'Ambil Absen Masuk' : 'Ambil Absen Keluar';

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: FilledButton(
        onPressed: !isFaceEnrolled ? null : onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF0D9488),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              UIcons.regularRounded.camera,
              size: 20.sp,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
