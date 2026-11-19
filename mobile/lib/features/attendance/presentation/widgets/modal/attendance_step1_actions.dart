import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Action buttons for Step 1: Refresh GPS Location button and Proceed to Camera button
class AttendanceStep1Actions extends StatelessWidget {
  final bool isLocating;
  final bool canProceed;
  final String fallbackLabel;
  final VoidCallback onRefresh;
  final VoidCallback onProceed;

  const AttendanceStep1Actions({
    super.key,
    required this.isLocating,
    required this.canProceed,
    required this.fallbackLabel,
    required this.onRefresh,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: OutlinedButton.icon(
            onPressed: isLocating ? null : onRefresh,
            icon: isLocating
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Color(0xFF334155),
                    ),
                  )
                : Icon(
                    UIcons.regularRounded.refresh,
                    size: 18.sp,
                    color: const Color(0xFF334155),
                  ),
            label: Text(
              isLocating ? 'Memperbarui Lokasi...' : 'Refresh Lokasi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: FilledButton.icon(
            onPressed: canProceed ? onProceed : null,
            icon: Icon(
              canProceed ? UIcons.regularRounded.angle_small_right : UIcons.regularRounded.lock,
              size: 18.sp,
              color: canProceed ? Colors.white : const Color(0xFF94A3B8),
            ),
            label: Text(
              canProceed ? 'Lanjut ke Kamera' : fallbackLabel,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: canProceed ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF0D9488),
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
