import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer.dart';

/// Full-screen shimmering skeleton that replicates the Dashboard and navigation bar layout.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Shimmer(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            children: [
              _buildHeaderTop(),
              SizedBox(height: 14.w),
              _buildSubHeader(),
              SizedBox(height: 12.w),
              _buildAttendanceCard(),
              SizedBox(height: 12.w),
              _buildStatCards(),
              SizedBox(height: 16.w),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavSkeleton(),
    );
  }

  Widget _buildHeaderTop() {
    return Row(
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
    );
  }

  Widget _buildSubHeader() {
    return Row(
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
    );
  }

  Widget _buildAttendanceCard() {
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

  Widget _buildStatCards() {
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

  Widget _buildQuickActions() {
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

  Widget _buildBottomNavSkeleton() {
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
