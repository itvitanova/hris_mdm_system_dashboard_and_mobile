import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class AttendanceEmptyState extends StatelessWidget {
  final bool isEn;

  const AttendanceEmptyState({
    super.key,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 40.h,
        horizontal: 20.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              UIcons.regularRounded.calendar,
              size: 24.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isEn
                ? 'No Attendance Records Yet'
                : 'Belum Ada Catatan Kehadiran',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isEn
                ? 'Attendance records will be automatically logged after checking in or out.'
                : 'Catatan kehadiran akan otomatis tercatat setelah melakukan absensi masuk atau pulang.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
