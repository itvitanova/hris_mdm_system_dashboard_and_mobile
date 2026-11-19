import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:uicons/uicons.dart';

/// Catatan Peninjau box within a notification card
class NotificationCardReviewerNote extends StatelessWidget {
  const NotificationCardReviewerNote({
    super.key,
    required this.note,
    this.reviewerName,
  });

  final String note;
  final String? reviewerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                UIcons.regularRounded.edit,
                size: 13.sp,
                color: AppColors.deepTeal,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  'Catatan Peninjau${reviewerName != null ? ' ($reviewerName)' : ''}:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepTeal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            note,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF334155),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
