import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/workspace.dart';

class AttendanceDetailTimeBox extends StatelessWidget {
  const AttendanceDetailTimeBox({
    super.key,
    required this.checkIn,
    required this.checkOut,
    required this.earlyDeparture,
    required this.earlyMinutes,
    required this.earlyReason,
    required this.isEn,
  });

  final String checkIn;
  final String checkOut;
  final bool earlyDeparture;
  final int earlyMinutes;
  final String earlyReason;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'CHECK-IN TIME' : 'JAM MASUK',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      timeLabel(checkIn),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32.h,
                color: const Color(0xFFCBD5E1),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'CHECK-OUT TIME' : 'JAM PULANG',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      timeLabel(checkOut),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (earlyDeparture) ...[
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              children: [
                Icon(
                  UIcons.regularRounded.exclamation,
                  size: 16.sp,
                  color: const Color(0xFFE11D48),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Left $earlyMinutes minutes early${earlyReason.isNotEmpty ? ': "$earlyReason"' : ''}'
                        : 'Pulang $earlyMinutes menit lebih awal${earlyReason.isNotEmpty ? ': "$earlyReason"' : ''}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFBE123C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
