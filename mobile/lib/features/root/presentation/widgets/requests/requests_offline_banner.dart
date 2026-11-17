import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Banner status offline pada tab pengajuan
class RequestsOfflineBanner extends StatelessWidget {
  final bool isEn;

  const RequestsOfflineBanner({
    super.key,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFDE68A),
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
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 16.w,
              color: const Color(0xFFB45309),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn
                      ? 'Offline Mode • Viewing Cached Data'
                      : 'Mode Offline • Menampilkan Data Tersimpan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  isEn
                      ? 'New submissions are queued and will auto-sync when online.'
                      : 'Pengajuan baru tersimpan dan otomatis disinkronkan saat online.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5.sp,
                    color: const Color(0xFFB45309),
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
