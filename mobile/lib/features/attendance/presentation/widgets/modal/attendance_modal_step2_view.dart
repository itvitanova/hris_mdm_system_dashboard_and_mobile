import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'attendance_early_reason_field.dart';
import 'attendance_face_tutorial_box.dart';
import 'attendance_step2_action_button.dart';
import 'attendance_step2_header.dart';
import 'attendance_step2_verified_badge.dart';

/// Step 2 View: Face Verification Guide (Header, Badge, Tutorial, Early Input, Action Button)
class AttendanceModalStep2View extends StatelessWidget {
  final String punchType;
  final String officeName;
  final int distance;
  final bool isEarly;
  final bool isFaceEnrolled;
  final GlobalKey<FormState> earlyFormKey;
  final TextEditingController earlyReasonController;
  final String workEnd;
  final VoidCallback onBack;
  final VoidCallback onOpenCamera;

  const AttendanceModalStep2View({
    super.key,
    required this.punchType,
    required this.officeName,
    required this.distance,
    required this.isEarly,
    required this.isFaceEnrolled,
    required this.earlyFormKey,
    required this.earlyReasonController,
    required this.workEnd,
    required this.onBack,
    required this.onOpenCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AttendanceStep2Header(
          punchType: punchType,
          onBack: onBack,
        ),
        SizedBox(height: 10.h),
        AttendanceStep2VerifiedBadge(
          officeName: officeName,
          distance: distance,
        ),
        SizedBox(height: 12.h),
        const AttendanceFaceTutorialBox(),
        if (isEarly) ...[
          SizedBox(height: 12.h),
          AttendanceEarlyReasonField(
            formKey: earlyFormKey,
            controller: earlyReasonController,
            workEnd: workEnd,
          ),
        ],
        SizedBox(height: 16.h),
        AttendanceStep2ActionButton(
          isFaceEnrolled: isFaceEnrolled,
          punchType: punchType,
          onPressed: onOpenCamera,
        ),
        SizedBox(height: 8.h),
        Text(
          'Foto ini akan diverifikasi secara otomatis oleh sistem',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
