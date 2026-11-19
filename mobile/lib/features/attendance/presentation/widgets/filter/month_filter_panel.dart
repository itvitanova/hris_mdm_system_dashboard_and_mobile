import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';
import 'month_enum.dart';

class MonthFilterPanel extends StatelessWidget {
  final MonthEnum? selected;
  final ValueChanged<MonthEnum?> onSelect;
  final AppLanguage language;

  const MonthFilterPanel({
    super.key,
    required this.selected,
    required this.onSelect,
    this.language = AppLanguage.id,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonthIndex = DateTime.now().month - 1; // 0-based

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
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSemuaBulanRow(),
          SizedBox(height: 8.w),
          ...List.generate(3, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < 2 ? 6.w : 0),
              child: Row(
                children: List.generate(4, (col) {
                  final index = row * 4 + col;
                  final month = MonthEnum.values[index];
                  final isSelected = selected == month;
                  final isCurrentMonth = index == currentMonthIndex && selected == null;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: col < 3 ? 8.w : 0),
                      child: GestureDetector(
                        onTap: () => onSelect(month),
                        child: Container(
                          height: 34.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: (isSelected || isCurrentMonth)
                                ? AppColors.filterTealAccent
                                : AppColors.filterSlateBg,
                          ),
                          child: Text(
                            month.getShortName(language),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5.sp,
                              fontWeight: (isSelected || isCurrentMonth)
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: (isSelected || isCurrentMonth)
                                  ? AppColors.white
                                  : AppColors.filterItemText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSemuaBulanRow() {
    final isSelected = selected == null;
    return GestureDetector(
      onTap: () => onSelect(null),
      child: Container(
        height: 34.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: isSelected ? AppColors.filterFrostedTealBg : AppColors.filterSlateBg,
          border: isSelected ? Border.all(color: AppColors.filterFrostedTealBorder, width: 1) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language == AppLanguage.en ? 'All Months' : 'Semua Bulan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.filterTealAccent : AppColors.filterItemText,
                ),
              ),
            ),
            if (isSelected)
              Icon(UIcons.regularRounded.check, size: 14.w, color: AppColors.filterTealAccent),
          ],
        ),
      ),
    );
  }
}
