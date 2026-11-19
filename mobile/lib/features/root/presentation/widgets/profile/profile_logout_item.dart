import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uicons/uicons.dart';

/// Item Pengaturan Khusus Keluar Akun (Danger Red Card)
class ProfileLogoutItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const ProfileLogoutItem({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFFECDD3),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: const Color(0xFFFEF2F2),
          highlightColor: const Color(0xFFFEE2E2).withValues(alpha: 0.5),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFFECDD3),
                      width: 1.2.w,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: loading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFED2736),
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/icon/logout.svg',
                          width: 20.sp,
                          height: 20.sp,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFED2736),
                            BlendMode.srcIn,
                          ),
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  UIcons.regularRounded.angle_small_right,
                  size: 22.sp,
                  color: const Color(0xFFFCA5A5),
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
