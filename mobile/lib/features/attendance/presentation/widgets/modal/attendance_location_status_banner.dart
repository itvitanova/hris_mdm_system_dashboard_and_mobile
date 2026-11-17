import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Status banner for attendance location check (Face enrolled, outside radius, or verified)
class AttendanceLocationStatusBanner extends StatelessWidget {
  final bool isFaceEnrolled;
  final bool isSafeLocation;
  final String? gpsError;
  final double? distance;
  final num radius;
  final String officeName;

  const AttendanceLocationStatusBanner({
    super.key,
    required this.isFaceEnrolled,
    required this.isSafeLocation,
    required this.gpsError,
    required this.distance,
    required this.radius,
    required this.officeName,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFaceEnrolled) {
      return _BannerBox(
        bgColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFEE2E2),
        iconBgColor: const Color(0xFFDC2626),
        icon: UIcons.regularRounded.exclamation,
        title: 'Wajah Belum Terdaftar',
        titleColor: const Color(0xFF7F1D1D),
        message: 'Wajah Anda belum terdaftar di sistem. Hubungi admin untuk mendaftarkan foto wajah.',
        messageColor: const Color(0xFF991B1B),
      );
    }

    if (!isSafeLocation || gpsError != null) {
      final msg = gpsError ??
          (distance != null
              ? 'Anda berada ${distance!.round()}m dari kantor (maksimal ${radius.round()}m). Silakan mendekat ke area kantor untuk absensi.'
              : 'Lokasi Anda belum dapat dipastikan dalam radius kantor.');

      return _BannerBox(
        bgColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFEE2E2),
        iconBgColor: const Color(0xFFDC2626),
        icon: UIcons.regularRounded.exclamation,
        title: 'Di Luar Radius Kantor',
        titleColor: const Color(0xFF7F1D1D),
        message: msg,
        messageColor: const Color(0xFF991B1B),
      );
    }

    return _BannerBox(
      bgColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFBBF7D0),
      iconBgColor: const Color(0xFF0D9488),
      icon: UIcons.regularRounded.check,
      title: 'Lokasi Memenuhi Syarat',
      titleColor: const Color(0xFF065F46),
      message: 'Posisi terverifikasi di $officeName (${distance?.round() ?? 0}m dari pusat radius).',
      messageColor: const Color(0xFF047857),
    );
  }
}

class _BannerBox extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final Color iconBgColor;
  final IconData icon;
  final String title;
  final Color titleColor;
  final String message;
  final Color messageColor;

  const _BannerBox({
    required this.bgColor,
    required this.borderColor,
    required this.iconBgColor,
    required this.icon,
    required this.title,
    required this.titleColor,
    required this.message,
    required this.messageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Center(
              child: Icon(icon, size: 14.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5.sp,
                    color: messageColor,
                    height: 1.35,
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
