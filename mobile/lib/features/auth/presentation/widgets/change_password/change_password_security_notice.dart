import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Informational security notice banner about session termination
class ChangePasswordSecurityNotice extends StatelessWidget {
  const ChangePasswordSecurityNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFCCFBF1),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            UIcons.regularRounded.info,
            size: 18.sp,
            color: const Color(0xFF0D9488),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Setelah kata sandi berhasil diperbarui, seluruh sesi login aktif akan diakhiri dan Anda perlu masuk kembali.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5.sp,
                color: const Color(0xFF0F766E),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
