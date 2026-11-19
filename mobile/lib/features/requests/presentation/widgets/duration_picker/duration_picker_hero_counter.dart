import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class DurationPickerHeroCounter extends StatelessWidget {
  final int selectedHours;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const DurationPickerHeroCounter({
    super.key,
    required this.selectedHours,
    required this.onDecrement,
    required this.onIncrement,
  });

  static String getCategoryLabel(int hours) {
    if (hours <= 2) return 'Lembur Ringan';
    if (hours <= 4) return 'Lembur Reguler';
    return 'Lembur Intensif';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDFA), Color(0xFFE6FFFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFF99F6E4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: selectedHours > 1 ? onDecrement : null,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: selectedHours > 1 ? Colors.white : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: selectedHours > 1
                        ? const Color(0xFF99F6E4)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: selectedHours > 1
                      ? const [
                          BoxShadow(
                            color: Color(0x100D9488),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  UIcons.regularRounded.minus,
                  size: 20.sp,
                  color: selectedHours > 1
                      ? const Color(0xFF0F766E)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$selectedHours',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F766E),
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Jam',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF14B8A6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: const Color(0xFF99F6E4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    getCategoryLabel(selectedHours),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: selectedHours < 24 ? onIncrement : null,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: selectedHours < 24
                      ? const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedHours >= 24 ? const Color(0xFFF1F5F9) : null,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: selectedHours < 24
                      ? const [
                          BoxShadow(
                            color: Color(0x280F766E),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  UIcons.regularRounded.plus,
                  size: 20.sp,
                  color: selectedHours < 24 ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
