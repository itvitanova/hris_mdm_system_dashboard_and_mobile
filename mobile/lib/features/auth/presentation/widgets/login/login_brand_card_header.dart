import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_text_styles.dart';

/// Top card section with handle bar, logo, and welcome back greetings
class LoginBrandCardHeader extends StatelessWidget {
  const LoginBrandCardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.w),
        Container(
          width: 38.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        SizedBox(height: 28.w),
        SizedBox(
          width: 150.w,
          height: 56.w,
          child: Image.asset(
            "assets/img/app_logo.png",
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(
                'MDM HR',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                  color: AppColors.filterGradientStart,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 40.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome Back, 👋",
                  style: AppTextStyles.interExtraBold18,
                ),
                SizedBox(height: 5.h),
                Text(
                  "Please enter your login details to access your account.",
                  style: AppTextStyles.inter13RegularSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
