import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceDetailHeader extends StatelessWidget {
  const AttendanceDetailHeader({
    super.key,
    required this.formattedDate,
    required this.status,
    required this.lateMinutes,
    required this.isEn,
  });

  final String formattedDate;
  final String status;
  final int lateMinutes;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final isLate = status == 'Terlambat';
    final statusText = lateMinutes > 0
        ? (isEn ? 'Late ${lateMinutes}m' : 'Terlambat $lateMinutes m')
        : (status.toLowerCase() == 'hadir'
            ? (isEn ? 'Present' : 'Hadir')
            : (status.toLowerCase() == 'terlambat'
                ? (isEn ? 'Late' : 'Terlambat')
                : status));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? 'Attendance Details' : 'Detail Kehadiran',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                formattedDate,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isLate ? const Color(0xFFFFFBEB) : const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: isLate ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
              width: 1.w,
            ),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: isLate ? const Color(0xFFB45309) : const Color(0xFF15803D),
            ),
          ),
        ),
      ],
    );
  }
}
