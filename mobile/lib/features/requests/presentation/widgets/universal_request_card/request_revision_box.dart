import 'package:flutter/material.dart';

/// Kotak catatan revisi jika status pengajuan 'Perlu Revisi'
class RequestRevisionBox extends StatelessWidget {
  final String note;
  final String? reviewerName;

  const RequestRevisionBox({
    super.key,
    required this.note,
    this.reviewerName,
  });

  @override
  Widget build(BuildContext context) {
    final reviewer = reviewerName ?? 'Aries Munandar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan Peninjau · $reviewer',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9F1239),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '"$note"',
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF881337),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
