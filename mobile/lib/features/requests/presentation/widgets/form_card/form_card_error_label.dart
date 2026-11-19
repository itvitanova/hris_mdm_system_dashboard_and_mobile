import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class FormCardErrorLabel extends StatelessWidget {
  final String errorText;

  const FormCardErrorLabel({
    super.key,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              UIcons.regularRounded.exclamation,
              size: 13.w,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                errorText,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
