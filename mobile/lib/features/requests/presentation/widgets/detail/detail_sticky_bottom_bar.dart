import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/workspace.dart';
import 'detail_download_actions.dart';
import 'detail_formatters.dart';
import 'detail_reviewer_actions.dart';

/// Sticky docked bottom action bar for approval, revision, or document download
class DetailStickyBottomBar extends StatelessWidget {
  const DetailStickyBottomBar({
    super.key,
    required this.api,
    required this.r,
    required this.steps,
    required this.id,
    required this.own,
    required this.busy,
    required this.onDecide,
    required this.onShare,
    required this.onFixRequest,
  });

  final ApiClient api;
  final Json r;
  final List<Json> steps;
  final String id;
  final bool own;
  final bool busy;
  final void Function(String) onDecide;
  final void Function(String path, String name) onShare;
  final VoidCallback onFixRequest;

  @override
  Widget build(BuildContext context) {
    final canReview = r['canReview'] == true;
    final needsRevision =
        own && DetailFormatters.isStatusRevision(r['status']);
    final canDownload = r['canDownload'] == true;

    if (!canReview && !needsRevision && !canDownload) {
      return const SizedBox.shrink();
    }

    final currentStepIdx = (r['currentStep'] as num?)?.toInt() ?? 0;
    final isFinanceStep = steps.isNotEmpty &&
        currentStepIdx < steps.length &&
        steps[currentStepIdx]['source'] == 'finance';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canReview)
                DetailReviewerActions(
                  r: r,
                  busy: busy,
                  isFinanceStep: isFinanceStep,
                  onDecide: onDecide,
                )
              else if (needsRevision)
                Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x20E11D48),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: busy ? null : onFixRequest,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(UIcons.regularRounded.refresh,
                                size: 18.w, color: Colors.white),
                            SizedBox(width: 6.w),
                            Text(
                              'Perbaiki pengajuan',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else if (canDownload)
                DetailDownloadActions(
                  id: id,
                  busy: busy,
                  onShare: onShare,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
