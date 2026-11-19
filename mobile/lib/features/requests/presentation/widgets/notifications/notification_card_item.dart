import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import 'package:mdm_hris/features/requests/domain/entities/request_notification_item.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_kind.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_status.dart';
import 'package:uicons/uicons.dart';
import 'notification_card_fix_now_button.dart';
import 'notification_card_reviewer_note.dart';
import 'notification_card_tag_row.dart';

/// Notification card item displaying status, reviewer note, and quick actions
class NotificationCardItem extends StatelessWidget {
  const NotificationCardItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFixNow,
  });

  final RequestNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onFixNow;

  IconData _resolveKindIcon(SubmissionKind kind) {
    if (kind == SubmissionKind.cuti) return UIcons.regularRounded.calendar;
    if (kind == SubmissionKind.reimbursement) return UIcons.regularRounded.receipt;
    if (kind == SubmissionKind.pettyCash) return UIcons.regularRounded.wallet;
    if (kind == SubmissionKind.lembur) return UIcons.regularRounded.clock;
    if (kind == SubmissionKind.izin) return UIcons.regularRounded.calendar_check;
    if (kind == SubmissionKind.medicalClaim) return UIcons.regularRounded.stethoscope;
    return UIcons.regularRounded.boxes;
  }

  @override
  Widget build(BuildContext context) {
    final isRevision = item.status == SubmissionStatus.perluRevisi;
    final iconData = _resolveKindIcon(item.kind);
    final hasReviewNote = item.reviewNote != null && item.reviewNote!.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white, width: 1.5.w),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Stack(
          children: [
            if (item.isUnread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3.5.w,
                child: Container(color: AppColors.filterTealAccent),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('notif_item_${item.id}'),
                onTap: onTap,
                splashColor: const Color(0xFF0D9488).withValues(alpha: 0.08),
                highlightColor: const Color(0xFF0D9488).withValues(alpha: 0.03),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFCCFBF1), width: 1.w),
                        ),
                        alignment: Alignment.center,
                        child: Icon(iconData, size: 20.sp, color: const Color(0xFF0D9488)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NotificationCardTagRow(
                              kind: item.kind,
                              status: item.status,
                              isUnread: item.isUnread,
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              item.headline,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5.sp,
                                fontWeight: item.isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: item.isUnread ? const Color(0xFF0F172A) : const Color(0xFF334155),
                                letterSpacing: -0.2,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              item.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                                height: 1.38,
                              ),
                            ),
                            if (hasReviewNote) ...[
                              SizedBox(height: 8.h),
                              NotificationCardReviewerNote(
                                note: item.reviewNote!,
                                reviewerName: item.reviewerName,
                              ),
                            ],
                            if (isRevision) ...[
                              SizedBox(height: 8.h),
                              NotificationCardFixNowButton(
                                itemId: item.id,
                                onTap: onFixNow,
                              ),
                            ],
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(UIcons.regularRounded.clock, size: 11.5.sp, color: const Color(0xFF94A3B8)),
                                SizedBox(width: 4.w),
                                Text(
                                  item.timeAgo,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                const Spacer(),
                                Icon(UIcons.regularRounded.angle_small_right, size: 16.sp, color: const Color(0xFFCBD5E1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
