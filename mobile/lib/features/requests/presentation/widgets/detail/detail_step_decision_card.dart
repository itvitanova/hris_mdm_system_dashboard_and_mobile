import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/workspace.dart';
import 'detail_formatters.dart';

/// Single decision note box inside approval step
class DetailStepDecisionCard extends StatelessWidget {
  const DetailStepDecisionCard({
    super.key,
    required this.decision,
  });

  final Json decision;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${text(decision, 'name')} · ${text(decision, 'decision')}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            requestDateLabel(text(decision, 'at')),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
          if (text(decision, 'note', '').isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                text(decision, 'note'),
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.sp,
                  color: const Color(0xFF334155),
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
