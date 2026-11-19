import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'app_language.dart';

class LanguageSwapMenuItem extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;

  const LanguageSwapMenuItem({
    super.key,
    required this.language,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 5.w,
      ),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0FDFA) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            language.flagEmoji,
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(width: 6.w),
          Text(
            language.name,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.filterTealAccent
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
