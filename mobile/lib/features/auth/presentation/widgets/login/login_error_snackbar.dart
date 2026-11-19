import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:uicons/uicons.dart';

/// Helper for displaying error snackbar on login screen
class LoginErrorSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.red,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        content: Row(
          children: [
            Icon(UIcons.regularRounded.exclamation, color: AppColors.white, size: 20.w),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
