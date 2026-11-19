import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'calendar_constants.dart';

class CalendarMonthlyBirthdaysList extends StatelessWidget {
  const CalendarMonthlyBirthdaysList({
    super.key,
    required this.month,
    required this.selected,
    required this.monthlyBirthdays,
    required this.loading,
    required this.hasError,
    required this.onSelectDate,
  });

  final DateTime month;
  final DateTime selected;
  final List<Json> monthlyBirthdays;
  final bool loading;
  final bool hasError;
  final void Function(DateTime date) onSelectDate;

  @override
  Widget build(BuildContext context) {
    final otherMonthlyBirthdays = monthlyBirthdays.where((b) {
      final rawDay = b['day'];
      final dayNum = rawDay is int ? rawDay : 0;
      return dayNum != selected.day;
    }).toList();

    if (loading || hasError || otherMonthlyBirthdays.isEmpty) {
      return const SizedBox.shrink();
    }

    final monthName = CalendarConstants.monthNames[month.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Row(
          children: [
            Icon(
              UIcons.regularRounded.gift,
              size: 16,
              color: const Color(0xFFD97706),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Ulang Tahun Lainnya ($monthName)',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${otherMonthlyBirthdays.length} Rekan',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final b in otherMonthlyBirthdays) _buildItem(b, monthName),
      ],
    );
  }

  Widget _buildItem(Json b, String monthName) {
    final rawDay = b['day'];
    final dayNum = rawDay is int ? rawDay : 1;
    final itemDate = DateTime(month.year, month.month, dayNum);
    final isSelected = CalendarConstants.isSameDay(selected, itemDate);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onSelectDate(itemDate),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$dayNum ${monthName.substring(0, 3)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text(b, 'name', 'Rekan Kerja'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (text(b, 'department', '').isNotEmpty)
                    Text(
                      text(b, 'department', ''),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              UIcons.regularRounded.cake_birthday,
              size: 16,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }
}
