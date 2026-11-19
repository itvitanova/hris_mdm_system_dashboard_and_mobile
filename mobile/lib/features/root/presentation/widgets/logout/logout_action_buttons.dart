import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';

class LogoutActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const LogoutActionButtons({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol Secondary: Batal
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.filterSlateBg,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(
                  color: AppColors.filterSlateBorder,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Tombol Primary: Ya, Keluar Akun
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: FilledButton(
              onPressed: isLoading ? null : onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                disabledBackgroundColor: AppColors.red.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Ya, Keluar Akun',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Ya, Keluar Akun',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
