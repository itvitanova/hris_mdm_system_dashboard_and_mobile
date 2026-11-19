import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Helper for displaying success and error snackbars on ChangePasswordScreen
class ChangePasswordSnackbarHelper {
  static void showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(UIcons.regularRounded.check, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Password berhasil diganti. Silakan login kembali.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(UIcons.regularRounded.exclamation, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
