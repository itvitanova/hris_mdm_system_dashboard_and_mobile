import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Full-width action button to download or share payslip PDF
class PayslipDownloadButton extends StatelessWidget {
  const PayslipDownloadButton({
    super.key,
    required this.busy,
    required this.onPressed,
  });

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: ElevatedButton.icon(
        key: const Key('payslip_share_btn'),
        onPressed: busy ? null : onPressed,
        icon: busy
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(UIcons.regularRounded.document, size: 18.sp),
        label: Text(
          busy ? 'Menyiapkan Dokumen…' : 'Unduh / Bagikan Slip Gaji (PDF)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
