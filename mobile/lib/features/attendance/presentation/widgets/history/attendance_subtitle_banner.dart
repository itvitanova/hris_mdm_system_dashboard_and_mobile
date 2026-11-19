import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../attendance_stat_card.dart';
import '../filter_dropdowns.dart';

class AttendanceSubtitleBanner extends StatelessWidget {
  const AttendanceSubtitleBanner({
    super.key,
    required this.attendanceSelected,
    required this.monthSelected,
    required this.yearsSelected,
    required this.language,
  });

  final AttendanceStatType? attendanceSelected;
  final MonthEnum? monthSelected;
  final int yearsSelected;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isEn = language == AppLanguage.en;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Row(
        children: [
          Container(
            width: 3.5.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: AppColors.deepTeal,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${isEn ? "Attendance History" : "Riwayat Absensi"}${attendanceSelected != null ? " - ${attendanceSelected!.getLabel(language)}" : ""}${monthSelected != null ? " - ${monthSelected!.getName(language)}" : ""} $yearsSelected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
