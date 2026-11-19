import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/widgets/shimmer.dart';

class DashboardStatsSkeleton extends StatelessWidget {
  const DashboardStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCardItem()),
            SizedBox(width: 12.w),
            Expanded(child: _buildStatCardItem()),
          ],
        ),
        SizedBox(height: 12.w),
        Row(
          children: [
            Expanded(child: _buildStatCardItem()),
            SizedBox(width: 12.w),
            Expanded(child: _buildStatCardItem()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardItem() {
    return Container(
      height: 76.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: 36.w,
            height: 36.w,
            borderRadius: 10.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 32.w, height: 18.h, borderRadius: 4.r),
                SizedBox(height: 4.h),
                ShimmerBox(width: 65.w, height: 10.h, borderRadius: 4.r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
