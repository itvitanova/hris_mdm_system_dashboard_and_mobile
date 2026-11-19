import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/widgets/shimmer.dart';

class DashboardBottomNavSkeleton extends StatelessWidget {
  const DashboardBottomNavSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Shimmer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (_) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(
                  width: 22.w,
                  height: 22.w,
                  borderRadius: 6.r,
                ),
                SizedBox(height: 4.h),
                ShimmerBox(
                  width: 36.w,
                  height: 9.h,
                  borderRadius: 3.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
