import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/workspace.dart';

class PayrollHeroBanner extends StatelessWidget {
  final num latestSalary;
  final String latestPeriod;
  final String selectedPeriod;

  const PayrollHeroBanner({
    super.key,
    required this.latestSalary,
    required this.latestPeriod,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter = selectedPeriod != 'Semua periode';
    final chipLabel = hasFilter
        ? 'Filter: $selectedPeriod'
        : (latestPeriod.isNotEmpty
            ? 'Periode Terkini: $latestPeriod'
            : 'Portal Slip Gaji Karyawan');

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F766E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 105.w,
              height: 105.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -30.h,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.5.w,
                        height: 5.5.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          chipLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  latestSalary > 0 ? rupiah(latestSalary) : 'Rp 0',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  hasFilter
                      ? 'Total penerimaan take-home pay pada periode $selectedPeriod.'
                      : (latestSalary > 0
                          ? 'Total take-home pay penerimaan gaji terakhir Anda.'
                          : 'Data slip gaji resmi diterbitkan secara periodik oleh Finance.'),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3,
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
