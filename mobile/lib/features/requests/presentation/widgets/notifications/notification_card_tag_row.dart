import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_kind.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_status.dart';

/// Tag wrap displaying submission kind, status badge, and optional unread indicator
class NotificationCardTagRow extends StatelessWidget {
  const NotificationCardTagRow({
    super.key,
    required this.kind,
    required this.status,
    required this.isUnread,
  });

  final SubmissionKind kind;
  final SubmissionStatus status;
  final bool isUnread;

  Color _resolveStatusBgColor(SubmissionStatus status) {
    if (status == SubmissionStatus.disetujui) return const Color(0xFFDCFCE7);
    if (status == SubmissionStatus.perluRevisi) return const Color(0xFFFFF1F2);
    if (status == SubmissionStatus.ditolak) return const Color(0xFFFEE2E2);
    return const Color(0xFFFEF3C7);
  }

  Color _resolveStatusTextColor(SubmissionStatus status) {
    if (status == SubmissionStatus.disetujui) return const Color(0xFF15803D);
    if (status == SubmissionStatus.perluRevisi) return const Color(0xFFE11D48);
    if (status == SubmissionStatus.ditolak) return const Color(0xFFDC2626);
    return const Color(0xFFB45309);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: const Color(0xFFCCFBF1), width: 0.8.w),
                ),
                child: Text(
                  kind.displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepTeal,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: _resolveStatusBgColor(status),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  status.displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: _resolveStatusTextColor(status),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isUnread) ...[
          SizedBox(width: 8.w),
          Container(
            width: 7.w,
            height: 7.w,
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
