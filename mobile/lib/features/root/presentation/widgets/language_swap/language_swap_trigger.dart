import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import 'app_language.dart';

class LanguageSwapTrigger extends StatelessWidget {
  final AppLanguage currentLanguage;

  const LanguageSwapTrigger({
    super.key,
    required this.currentLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.w,
      padding: EdgeInsets.symmetric(horizontal: 9.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLanguage.flagEmoji,
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(width: 5.w),
          Text(
            currentLanguage.shortLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(width: 2.w),
          Icon(
            UIcons.regularRounded.angle_small_down,
            size: 18.w,
            color: const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }
}
