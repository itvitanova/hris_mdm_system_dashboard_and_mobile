import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

class AttendanceNotActiveCardWidget extends StatelessWidget {
  final String status;
  final String day;
  final String checkIn;
  final String checkOut;

  const AttendanceNotActiveCardWidget({
    super.key,
    required this.status,
    required this.day,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = status.trim().isNotEmpty
        ? '${status.trim()[0].toUpperCase()}${status.trim().substring(1).toLowerCase()}'
        : 'Hadir';

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 65.w),
      padding: EdgeInsets.only(
        top: 7.5.w,
        bottom: 7.5.w,
        left: 7.5.w,
        right: 20.5.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        boxShadow: const [AppShadows.shadow094],
        color: AppColors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.w),
                    color: AppColors.deepTeal50,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      status.toLowerCase() == 'libur'
                          ? 'assets/icon/logout.svg'
                          : 'assets/icon/login.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.deepTeal,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.inter14MediumNotActive,
                      ),
                      SizedBox(height: 4.w),
                      Text(
                        day,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.inter1102RegularNotActive,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'In $checkIn',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inter14MediumNotActive,
                ),
                SizedBox(height: 4.w),
                Text(
                  'Out $checkOut',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inter1102RegularNotActive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
