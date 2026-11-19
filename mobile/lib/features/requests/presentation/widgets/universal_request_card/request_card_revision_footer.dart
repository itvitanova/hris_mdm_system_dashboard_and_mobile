import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'request_card_config.dart';
import 'request_revision_box.dart';

class RequestCardRevisionFooter extends StatelessWidget {
  final UniversalRequestModel data;
  final String? bottomMetric;
  final String? transactionText;
  final AppLanguage language;
  final VoidCallback? onRevisePressed;

  const RequestCardRevisionFooter({
    super.key,
    required this.data,
    required this.bottomMetric,
    required this.transactionText,
    required this.language,
    this.onRevisePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.reviewNote != null) ...[
          SizedBox(height: 10.h),
          RequestRevisionBox(
            note: data.reviewNote!,
            reviewerName: data.reviewedBy,
          ),
        ],
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bottomMetric != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (transactionText != null) ...[
                        Text(
                          transactionText!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '·',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        bottomMetric!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      UIcons.regularRounded.calendar,
                      size: 12.w,
                      color: const Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      RequestCardHelper.formatDateRange(
                        data.startDate,
                        data.endDate,
                        language,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            InkWell(
              onTap: onRevisePressed,
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 5.5.h,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE11D48),
                      Color(0xFFBE123C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28E11D48),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      UIcons.regularRounded.refresh,
                      size: 12.w,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      language == AppLanguage.en
                          ? 'Revise submission'
                          : 'Perbaiki pengajuan',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
