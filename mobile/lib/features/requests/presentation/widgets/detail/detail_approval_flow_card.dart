import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import 'detail_approval_step_item.dart';
import 'detail_formatters.dart';
import 'detail_section_card.dart';

/// Card showing approval workflow stepper timeline or legacy approval history
class DetailApprovalFlowCard extends StatelessWidget {
  const DetailApprovalFlowCard({
    super.key,
    required this.r,
    required this.steps,
  });

  final Json r;
  final List<Json> steps;

  @override
  Widget build(BuildContext context) {
    final history = ((r['history'] as List?) ?? [])
        .map((v) => Json.from(v as Map))
        .toList();

    if (steps.isEmpty && history.isEmpty) return const SizedBox.shrink();

    final currentStepIdx = (r['currentStep'] as num?)?.toInt() ?? 0;
    final requestStatus = text(r, 'status');

    return DetailSectionCard(
      icon: UIcons.regularRounded.list_check,
      title: 'Alur Persetujuan',
      child: Column(
        children: [
          if (steps.isNotEmpty)
            for (var i = 0; i < steps.length; i++)
              DetailApprovalStepItem(
                step: steps[i],
                index: i,
                isLast: i == steps.length - 1,
                currentStepIdx: currentStepIdx,
                requestStatus: requestStatus,
              )
          else
            for (final h in history)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Icon(
                      UIcons.regularRounded.check,
                      size: 16.w,
                      color: const Color(0xFF0F766E),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${text(h, 'name')} · ${text(h, 'decision')}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${requestDateLabel(text(h, 'at'))} ${text(h, 'note', '').isNotEmpty ? '• ${text(h, 'note')}' : ''}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
