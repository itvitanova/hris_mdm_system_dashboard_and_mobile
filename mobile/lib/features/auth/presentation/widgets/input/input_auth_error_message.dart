import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';

class InputAuthErrorMessage extends StatelessWidget {
  const InputAuthErrorMessage({
    super.key,
    required this.errorText,
  });

  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          UIcons.regularRounded.exclamation,
          size: 13.w,
          color: AppColors.red,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            errorText,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.red,
            ),
          ),
        ),
      ],
    );
  }
}
