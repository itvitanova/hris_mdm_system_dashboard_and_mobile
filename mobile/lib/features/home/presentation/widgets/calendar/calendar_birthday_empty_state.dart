import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';

class CalendarBirthdayEmptyState extends StatelessWidget {
  const CalendarBirthdayEmptyState({
    super.key,
    required this.selectedDay,
    required this.monthName,
  });

  final int selectedDay;
  final String monthName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            UIcons.regularRounded.cake_birthday,
            size: 36,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tidak Ada Ulang Tahun',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Tidak ada rekan yang berulang tahun pada tanggal $selectedDay $monthName.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
