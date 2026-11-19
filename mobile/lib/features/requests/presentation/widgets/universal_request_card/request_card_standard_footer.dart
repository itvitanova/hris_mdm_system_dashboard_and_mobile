import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'request_card_config.dart';

class RequestCardStandardFooter extends StatelessWidget {
  final UniversalRequestModel data;
  final String? bottomMetric;
  final String? transactionText;
  final AppLanguage language;

  const RequestCardStandardFooter({
    super.key,
    required this.data,
    required this.bottomMetric,
    required this.transactionText,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
          child: const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFF1F5F9),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6.w,
          runSpacing: 4.h,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  UIcons.regularRounded.calendar,
                  size: 12.w,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(width: 5.w),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 160.w),
                  child: Text(
                    RequestCardHelper.formatDateRange(
                      data.startDate,
                      data.endDate,
                      language,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (transactionText != null) ...[
                  Text(
                    transactionText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  const Text(
                    '·',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(width: 4.w),
                ],
                if (bottomMetric != null) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 220.w),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        bottomMetric!,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                ],
                Icon(
                  UIcons.regularRounded.angle_small_right,
                  size: 16.w,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
