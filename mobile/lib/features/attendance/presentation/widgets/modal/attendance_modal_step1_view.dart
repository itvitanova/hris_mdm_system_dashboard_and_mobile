import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'attendance_location_status_banner.dart';
import 'attendance_map_visual_card.dart';
import 'attendance_step1_actions.dart';
import 'attendance_step1_header.dart';

/// Step 1 View: GPS Verification (Header, Map Card, Status Banner, and Action Buttons)
class AttendanceModalStep1View extends StatelessWidget {
  final String officeName;
  final double? distance;
  final bool isSafe;
  final bool isFaceEnrolled;
  final String? gpsError;
  final num radius;
  final bool isLocating;
  final bool canProceed;
  final String fallbackLabel;
  final VoidCallback onRefresh;
  final VoidCallback onProceed;

  const AttendanceModalStep1View({
    super.key,
    required this.officeName,
    required this.distance,
    required this.isSafe,
    required this.isFaceEnrolled,
    required this.gpsError,
    required this.radius,
    required this.isLocating,
    required this.canProceed,
    required this.fallbackLabel,
    required this.onRefresh,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AttendanceStep1Header(),
        SizedBox(height: 12.h),
        AttendanceMapVisualCard(
          officeName: officeName,
          distance: distance,
          isSafe: isSafe,
        ),
        SizedBox(height: 14.h),
        AttendanceLocationStatusBanner(
          isFaceEnrolled: isFaceEnrolled,
          isSafeLocation: isSafe,
          gpsError: gpsError,
          distance: distance,
          radius: radius,
          officeName: officeName,
        ),
        SizedBox(height: 16.h),
        AttendanceStep1Actions(
          isLocating: isLocating,
          canProceed: canProceed,
          fallbackLabel: fallbackLabel,
          onRefresh: onRefresh,
          onProceed: onProceed,
        ),
      ],
    );
  }
}
