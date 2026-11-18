import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import '../universal_request_card/universal_request_card.dart';

/// Gradient highlight box displaying key metric (days, hours, or amount)
class DetailMetricHighlightBox extends StatelessWidget {
  const DetailMetricHighlightBox({
    super.key,
    required this.model,
    required this.amount,
    required this.hasAmount,
    this.hours,
    this.days,
  });

  final UniversalRequestModel model;
  final num amount;
  final bool hasAmount;
  final int? hours;
  final int? days;

  @override
  Widget build(BuildContext context) {
    String? metricLabel;
    String? metricValue;
    IconData metricIcon = UIcons.regularRounded.calendar;

    switch (model.kind) {
      case SubmissionKind.cuti:
        final totalDays = days ?? model.days ?? 1;
        metricLabel = 'Total Hari Cuti';
        metricValue = '$totalDays Hari';
        metricIcon = UIcons.regularRounded.calendar_clock;
        break;
      case SubmissionKind.izin:
        if (days != null && days! > 0) {
          metricLabel = 'Durasi Izin';
          metricValue = '$days Hari';
        }
        metricIcon = UIcons.regularRounded.calendar_check;
        break;
      case SubmissionKind.lembur:
        final totalHours = hours ?? model.hours ?? 1;
        metricLabel = 'Total Durasi Lembur';
        metricValue = '$totalHours Jam';
        metricIcon = UIcons.regularRounded.clock;
        break;
      case SubmissionKind.reimbursement:
        if (hasAmount) {
          metricLabel = 'Total Klaim Biaya';
          metricValue = rupiah(amount);
        }
        metricIcon = UIcons.regularRounded.receipt;
        break;
      case SubmissionKind.medicalClaim:
        if (hasAmount) {
          metricLabel = 'Biaya Perawatan Medis';
          metricValue = rupiah(amount);
        }
        metricIcon = UIcons.regularRounded.stethoscope;
        break;
      case SubmissionKind.pettyCash:
        if (hasAmount) {
          metricLabel = 'Nominal Kas Kecil';
          metricValue = rupiah(amount);
        }
        metricIcon = UIcons.regularRounded.wallet;
        break;
      case SubmissionKind.generalAffair:
        if (hasAmount) {
          metricLabel = 'Estimasi Biaya';
          metricValue = rupiah(amount);
        }
        metricIcon = UIcons.regularRounded.boxes;
        break;
    }

    if (metricLabel == null || metricValue == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E),
            Color(0xFF14B8A6),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x200F766E),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              metricIcon,
              size: 20.w,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metricLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  metricValue,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
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
