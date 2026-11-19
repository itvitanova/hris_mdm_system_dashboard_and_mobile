import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';

class LogoutSheetHeader extends StatelessWidget {
  const LogoutSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Drag Handle
        Center(
          child: Container(
            width: 38.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.filterSlateBorder,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(height: 18.h),

        // 2. Squircle icon badge
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: AppColors.red50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.red.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icon/logout.svg',
            width: 24.sp,
            height: 24.sp,
            colorFilter: const ColorFilter.mode(
              AppColors.red,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: 14.h),

        // 3. Title 'Keluar dari Akun?'
        Text(
          'Keluar dari Akun?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
