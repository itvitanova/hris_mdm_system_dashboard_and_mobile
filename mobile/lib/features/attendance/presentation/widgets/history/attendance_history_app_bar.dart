import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class AttendanceHistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEn;
  final VoidCallback onBack;

  const AttendanceHistoryAppBar({
    super.key,
    required this.isEn,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.4,
      shadowColor: const Color(0x120F172A),
      leading: IconButton(
        icon: Icon(
          UIcons.regularRounded.angle_small_left,
          color: const Color(0xFF0F172A),
        ),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEn ? 'Attendance History' : 'Riwayat Kehadiran',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            isEn
                ? 'Presence & Location Verification'
                : 'Presensi & Verifikasi Lokasi',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
