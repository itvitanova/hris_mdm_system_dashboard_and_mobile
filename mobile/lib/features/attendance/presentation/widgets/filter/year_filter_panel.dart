import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';

class YearFilterPanel extends StatelessWidget {
  final int selected;
  final List<int> years;
  final ValueChanged<int> onSelect;

  const YearFilterPanel({
    super.key,
    required this.selected,
    required this.years,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: AppColors.filterSlateBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: years.map((year) {
          final isSelected = year == selected;
          return Padding(
            padding: EdgeInsets.only(bottom: year != years.last ? 4.w : 0),
            child: GestureDetector(
              onTap: () => onSelect(year),
              child: Container(
                height: 36.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  color: isSelected
                      ? AppColors.filterTealAccent
                      : AppColors.filterSlateBg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      year.toString(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : (year == DateTime.now().year
                                ? AppColors.filterItemText
                                : AppColors.filterSlateIcon),
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 8.w),
                      Icon(UIcons.regularRounded.check, size: 12.w, color: AppColors.white),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
