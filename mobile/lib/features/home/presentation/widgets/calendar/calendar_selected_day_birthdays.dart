import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'calendar_birthday_card.dart';
import 'calendar_birthday_empty_state.dart';
import 'calendar_constants.dart';

class CalendarSelectedDayBirthdays extends StatelessWidget {
  const CalendarSelectedDayBirthdays({
    super.key,
    required this.selected,
    required this.todayBirthdays,
    required this.loading,
    required this.hasError,
  });

  final DateTime selected;
  final List<Json> todayBirthdays;
  final bool loading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final monthName = CalendarConstants.monthNames[selected.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 0.8,
                ),
              ),
              child: Icon(
                UIcons.regularRounded.cake_birthday,
                size: 15,
                color: const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ulang Tahun pada ${selected.day} $monthName',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: todayBirthdays.isNotEmpty
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: todayBirthdays.isNotEmpty
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${todayBirthdays.length} Rekan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: todayBirthdays.isNotEmpty
                        ? const Color(0xFFB45309)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Rekan kerja yang merayakan hari ulang tahun.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        if (!loading && !hasError && todayBirthdays.isNotEmpty) ...[
          for (final b in todayBirthdays) CalendarBirthdayCard(birthday: b),
        ],
        if (!loading && !hasError && todayBirthdays.isEmpty)
          CalendarBirthdayEmptyState(
            selectedDay: selected.day,
            monthName: monthName,
          ),
      ],
    );
  }
}
