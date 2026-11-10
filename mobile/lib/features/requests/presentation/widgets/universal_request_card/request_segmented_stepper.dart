import 'package:flutter/material.dart';
import '../../../domain/entities/submission_kind.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'request_card_config.dart';

/// Segmented Stepper Murni & Tenang (Tanpa Centang / Tanpa Over-Status)
class RequestSegmentedStepper extends StatelessWidget {
  final UniversalRequestModel data;

  const RequestSegmentedStepper({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.kind == SubmissionKind.reimbursement) {
      return _buildTwoStageStepper();
    }
    return _buildSingleStageStepper();
  }

  /// 1. REIMBURSEMENT: 2 Tahap (Atasan ➔ Finance)
  Widget _buildTwoStageStepper() {
    final isDone = data.status == SubmissionStatus.disetujui;
    final isRejected = data.status == SubmissionStatus.ditolak;
    final isRevision = data.status == SubmissionStatus.perluRevisi;

    final Color secondStepColor;
    final String statusText;
    final Color statusTextColor;

    if (isDone) {
      secondStepColor = const Color(0xFF059669);
      statusText = 'Disetujui';
      statusTextColor = const Color(0xFF059669);
    } else if (isRejected) {
      secondStepColor = const Color(0xFFE11D48);
      statusText = 'Ditolak';
      statusTextColor = const Color(0xFFE11D48);
    } else if (isRevision) {
      secondStepColor = const Color(0xFFD97706);
      statusText = 'Perlu revisi';
      statusTextColor = const Color(0xFFD97706);
    } else {
      secondStepColor = const Color(0xFFF59E0B);
      statusText = 'Menunggu verifikasi finance';
      statusTextColor = const Color(0xFF475569);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              child: Text(
                'Atasan (Aries M.)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Finance (Alicia)',
                maxLines: 1,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Kapsul Segmented 5px
        Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: secondStepColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tahap 2 dari 2',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                statusText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusTextColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2. CUTI, PETTY CASH, GA, LEMBUR: 1 Tahap (Atasan)
  Widget _buildSingleStageStepper() {
    final isDone = data.status == SubmissionStatus.disetujui;
    final isRejected = data.status == SubmissionStatus.ditolak;
    final isRevision = data.status == SubmissionStatus.perluRevisi;

    final Color trackColor;
    final String statusText;
    final Color statusTextColor;

    if (isDone) {
      trackColor = const Color(0xFF059669);
      statusText = 'Disetujui';
      statusTextColor = const Color(0xFF059669);
    } else if (isRejected) {
      trackColor = const Color(0xFFE11D48);
      statusText = 'Ditolak';
      statusTextColor = const Color(0xFFE11D48);
    } else if (isRevision) {
      trackColor = const Color(0xFFD97706);
      statusText = 'Perlu revisi';
      statusTextColor = const Color(0xFFD97706);
    } else {
      trackColor = const Color(0xFFF59E0B);
      statusText = 'Menunggu persetujuan';
      statusTextColor = const Color(0xFF475569);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                RequestCardHelper.singleStageTitle(data.kind),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              data.reviewedBy ?? 'Aries Munandar',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Single Kapsul Track 5px
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tahap 1 dari 1',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                statusText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusTextColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
