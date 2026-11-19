import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_stat_card.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

Color statusDotColor(AttendanceStatType status) {
  switch (status) {
    case AttendanceStatType.sudahAbsen:
      return AppColors.filterStatusGreen;
    case AttendanceStatType.tepatWaktu:
      return AppColors.filterStatusBlue;
    case AttendanceStatType.terlambat:
      return AppColors.filterStatusAmber;
    case AttendanceStatType.belumAbsen:
      return AppColors.filterStatusRed;
  }
}

class StatusFilterPanel extends StatelessWidget {
  final AttendanceStatType? selected;
  final ValueChanged<AttendanceStatType?> onSelect;
  final AppLanguage language;

  const StatusFilterPanel({
    super.key,
    required this.selected,
    required this.onSelect,
    this.language = AppLanguage.id,
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
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSemuaRow(),
          SizedBox(height: 8.w),
          ...List.generate(2, (row) {
            final statuses = AttendanceStatType.values;
            return Padding(
              padding: EdgeInsets.only(bottom: row < 1 ? 6.w : 0),
              child: Row(
                children: List.generate(2, (col) {
                  final index = row * 2 + col;
                  final status = statuses[index];
                  final isSelected = selected == status;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: col == 0 ? 8.w : 0),
                      child: GestureDetector(
                        onTap: () => onSelect(status),
                        child: Container(
                          height: 36.w,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: isSelected
                                ? AppColors.filterFrostedTealBg
                                : AppColors.filterSlateBg,
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.filterFrostedTealBorder,
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusDotColor(status),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  status.getLabel(language),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.5.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.filterTealAccent
                                        : AppColors.filterItemText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

  Widget _buildSemuaRow() {
    final isSelected = selected == null;
    return GestureDetector(
      onTap: () => onSelect(null),
      child: Container(
        height: 36.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: isSelected
              ? AppColors.filterFrostedTealBg
              : AppColors.filterSlateBg,
          border: isSelected
              ? Border.all(color: AppColors.filterFrostedTealBorder, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.filterTealAccent
                    : AppColors.filterStatusGreen,
              ),
              child: Center(
                child: Container(
                  width: 3.6.w,
                  height: 3.6.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                language == AppLanguage.en
                    ? 'All Attendance'
                    : 'Semua Kehadiran',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.filterTealAccent
                      : AppColors.filterItemText,
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
