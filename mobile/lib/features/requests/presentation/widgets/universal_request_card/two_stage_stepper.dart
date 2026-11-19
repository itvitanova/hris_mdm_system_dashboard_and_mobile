import 'package:flutter/material.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../domain/entities/universal_request_item.dart';

class TwoStageStepper extends StatelessWidget {
  final UniversalRequestModel data;

  const TwoStageStepper({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = data.status == SubmissionStatus.disetujui;
    final isRejected = data.status == SubmissionStatus.ditolak;
    final isRevision = data.status == SubmissionStatus.perluRevisi;
    final isSyncPending = data.status == SubmissionStatus.menungguSinkronisasi;

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
    } else if (isSyncPending) {
      secondStepColor = const Color(0xFFF59E0B);
      statusText = 'Menunggu antrean sinkronisasi';
      statusTextColor = const Color(0xFFB45309);
    } else {
      secondStepColor = const Color(0xFFF59E0B);
      statusText = 'Menunggu verifikasi finance';
      statusTextColor = const Color(0xFF475569);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
}
