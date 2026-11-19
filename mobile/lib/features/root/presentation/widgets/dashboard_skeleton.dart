import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer.dart';
import 'skeleton/dashboard_attendance_skeleton.dart';
import 'skeleton/dashboard_bottom_nav_skeleton.dart';
import 'skeleton/dashboard_header_skeleton.dart';
import 'skeleton/dashboard_quick_actions_skeleton.dart';
import 'skeleton/dashboard_stats_skeleton.dart';

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
              const DashboardHeaderSkeleton(),
              SizedBox(height: 12.w),
              const DashboardAttendanceSkeleton(),
              SizedBox(height: 12.w),
              const DashboardStatsSkeleton(),
              SizedBox(height: 16.w),
              const DashboardQuickActionsSkeleton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DashboardBottomNavSkeleton(),
    );
  }
}
