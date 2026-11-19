import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Banner status offline pada tab profil
class ProfileOfflineBanner extends StatelessWidget {
  const ProfileOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFECACA),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 16.w,
              color: const Color(0xFFDC2626),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Offline • Koneksi Internet Mati',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  'Menampilkan data profil tersimpan. Data akan disinkronkan saat terhubung.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5.sp,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
