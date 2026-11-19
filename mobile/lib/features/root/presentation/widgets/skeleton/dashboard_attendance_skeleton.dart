import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/widgets/shimmer.dart';

class DashboardAttendanceSkeleton extends StatelessWidget {
  const DashboardAttendanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 100.w, height: 14.h, borderRadius: 4.r),
              ShimmerBox(width: 70.w, height: 22.h, borderRadius: 12.r),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 60.w, height: 12.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 80.w, height: 20.h, borderRadius: 4.r),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36.h,
                color: const Color(0xFFE2E8F0),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 60.w, height: 12.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 80.w, height: 20.h, borderRadius: 4.r),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          ShimmerBox(
            width: double.infinity,
            height: 40.h,
            borderRadius: 12.r,
          ),
        ],
      ),
    );
  }
}
