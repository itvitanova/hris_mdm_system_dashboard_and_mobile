import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/widgets/shimmer.dart';

class DashboardQuickActionsSkeleton extends StatelessWidget {
  const DashboardQuickActionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(width: 110.w, height: 16.h, borderRadius: 4.r),
            ShimmerBox(width: 45.w, height: 12.h, borderRadius: 4.r),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (_) => Column(
              children: [
                ShimmerBox(
                  width: 52.w,
                  height: 52.w,
                  borderRadius: 16.r,
                ),
                SizedBox(height: 6.h),
                ShimmerBox(
                  width: 44.w,
                  height: 10.h,
                  borderRadius: 4.r,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
