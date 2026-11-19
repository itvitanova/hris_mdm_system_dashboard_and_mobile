import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/widgets/shimmer.dart';

class DashboardHeaderSkeleton extends StatelessWidget {
  const DashboardHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ShimmerBox(
                  width: 52.w,
                  height: 52.w,
                  borderRadius: 14.r,
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerBox(
                      width: 80.w,
                      height: 12.h,
                      borderRadius: 4.r,
                    ),
                    SizedBox(height: 6.h),
                    ShimmerBox(
                      width: 140.w,
                      height: 18.h,
                      borderRadius: 4.r,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                ShimmerBox(
                  width: 56.w,
                  height: 36.h,
                  borderRadius: 12.r,
                ),
                SizedBox(width: 8.w),
                ShimmerBox(
                  width: 40.w,
                  height: 40.w,
                  borderRadius: 13.r,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 14.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(
              width: 130.w,
              height: 14.h,
              borderRadius: 4.r,
            ),
            ShimmerBox(
              width: 100.w,
              height: 26.h,
              borderRadius: 20.r,
            ),
          ],
        ),
      ],
    );
  }
}
