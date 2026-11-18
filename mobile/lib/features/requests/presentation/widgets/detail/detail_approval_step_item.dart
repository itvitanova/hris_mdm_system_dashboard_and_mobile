import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import '../approval_step_summary.dart';
import 'detail_formatters.dart';
import 'detail_step_decision_card.dart';

/// Single vertical timeline step in the approval flow
class DetailApprovalStepItem extends StatelessWidget {
  const DetailApprovalStepItem({
    super.key,
    required this.step,
    required this.index,
    required this.isLast,
    required this.currentStepIdx,
    required this.requestStatus,
  });

  final Json step;
  final int index;
  final bool isLast;
  final int currentStepIdx;
  final String requestStatus;

  @override
  Widget build(BuildContext context) {
    final decisions = ((step['decisions'] as List?) ?? [])
        .map((v) => Json.from(v as Map))
        .toList();
    final approvers = ((step['approvers'] as List?) ?? [])
        .map((v) => Json.from(v as Map))
        .toList();

    final isStepApproved = step['status'] == 'Disetujui' ||
        decisions.any((d) => d['decision'] == 'Disetujui');
    final isStepRejected = step['status'] == 'Ditolak' ||
        decisions.any((d) => d['decision'] == 'Ditolak');
    final isStepRevision = DetailFormatters.isStatusRevision(step['status']) ||
        decisions.any((d) => DetailFormatters.isStatusRevision(d['decision']));
    final isCurrentActive =
        currentStepIdx == index && requestStatus == 'Menunggu';

    Color nodeColor = const Color(0xFFCBD5E1);
    IconData nodeIcon = UIcons.regularRounded.circle;
    double iconSize = 8.w;
    if (isStepApproved) {
      nodeColor = const Color(0xFF10B981);
      nodeIcon = UIcons.regularRounded.check;
      iconSize = 13.5.w;
    } else if (isCurrentActive) {
      nodeColor = const Color(0xFF0F766E);
      nodeIcon = UIcons.regularRounded.clock;
      iconSize = 13.5.w;
    } else if (isStepRejected) {
      nodeColor = const Color(0xFFE11D48);
      nodeIcon = UIcons.regularRounded.cross_small;
      iconSize = 16.w;
    } else if (isStepRevision) {
      nodeColor = const Color(0xFFD97706);
      nodeIcon = UIcons.regularRounded.exclamation;
      iconSize = 13.5.w;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node & Connecting Line
          Column(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: nodeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: nodeColor.withValues(alpha: 0.28),
                    width: 1.2.w,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(nodeIcon, size: iconSize, color: nodeColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5.w,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          // Step Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      Text(
                        '${index + 1}. ${text(step, 'name')}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (isStepApproved)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Disetujui',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  if (approvers.isNotEmpty)
                    Row(
                      children: [
                        Icon(UIcons.regularRounded.user,
                            size: 11.w, color: const Color(0xFF64748B)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            approvers.map((v) => text(v, 'name')).join(', '),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 3.h),
                  Text(
                    approvalStepSummary(
                      step,
                      active: currentStepIdx == index,
                      requestStatus: requestStatus,
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isCurrentActive
                          ? const Color(0xFF0F766E)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (decisions.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    for (final d in decisions)
                      DetailStepDecisionCard(decision: d),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
