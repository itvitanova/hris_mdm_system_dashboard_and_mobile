import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';

class AttendanceLocationBanner extends StatelessWidget {
  const AttendanceLocationBanner({
    super.key,
    required this.policyName,
    required this.isDemo,
    required this.language,
  });

  final String policyName;
  final bool isDemo;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isEn = language == AppLanguage.en;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFCCFBF1),
              width: 1.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  UIcons.regularRounded.marker,
                  size: 20.sp,
                  color: AppColors.deepTeal,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            policyName,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                UIcons.regularRounded.shield_check,
                                size: 10.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                isEn ? 'Location & Face' : 'Lokasi & Wajah',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      isEn
                          ? 'Radius and time zone follow assignment. Coordinates saved automatically.'
                          : 'Radius dan zona waktu mengikuti penugasan. Koordinat tersimpan otomatis.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5.sp,
                        color: const Color(0xFF475569),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isDemo) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Row(
              children: [
                Icon(
                  UIcons.regularRounded.info,
                  size: 13.sp,
                  color: const Color(0xFF2563EB),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Initial history is sample data. "Sample" label does not indicate real verification.'
                        : 'Riwayat awal adalah data contoh. Label "Contoh" tidak menunjukkan verifikasi nyata.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.sp,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
