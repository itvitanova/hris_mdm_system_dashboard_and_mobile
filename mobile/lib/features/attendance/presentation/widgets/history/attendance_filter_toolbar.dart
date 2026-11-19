import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../attendance_stat_card.dart';
import '../filter_dropdowns.dart';

class AttendanceFilterToolbar extends StatelessWidget {
  const AttendanceFilterToolbar({
    super.key,
    required this.monthSelected,
    required this.attendanceSelected,
    required this.yearsSelected,
    required this.listYears,
    required this.language,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onStatusChanged,
    required this.onReset,
  });

  final MonthEnum? monthSelected;
  final AttendanceStatType? attendanceSelected;
  final int yearsSelected;
  final List<int> listYears;
  final AppLanguage language;
  final ValueChanged<MonthEnum?> onMonthChanged;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<AttendanceStatType?> onStatusChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        boxShadow: const [AppShadows.shadow094],
        color: AppColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: MonthFilterDropdown(
                  selected: monthSelected,
                  language: language,
                  onChanged: onMonthChanged,
                ),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                width: 110.w,
                child: YearFilterDropdown(
                  selected: yearsSelected,
                  years: listYears,
                  onChanged: onYearChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: StatusFilterDropdown(
                  selected: attendanceSelected,
                  language: language,
                  onChanged: onStatusChanged,
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 110.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.filterGradientStart,
                      AppColors.filterGradientEnd,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.w),
                    canRequestFocus: false,
                    onTap: onReset,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 16.w,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
