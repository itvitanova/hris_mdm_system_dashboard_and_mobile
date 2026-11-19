import 'package:flutter/material.dart';
import 'date_picker_day_cell.dart';
import 'date_picker_helpers.dart';

class DatePickerCalendarGrid extends StatelessWidget {
  final DateTime viewMonth;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelectDate;

  const DatePickerCalendarGrid({
    super.key,
    required this.viewMonth,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: DatePickerHelpers.dayNames.map((d) {
            return SizedBox(
              width: 38,
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        _buildCalendarGrid(today),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime today) {
    final firstDayOfMonth = DateTime(viewMonth.year, viewMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(viewMonth.year, viewMonth.month);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final prevMonth = DateTime(viewMonth.year, viewMonth.month - 1, 1);
    final daysInPrevMonth =
        DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final totalCells = (startingWeekday + daysInMonth > 35) ? 42 : 35;
    final dayWidgets = <Widget>[];

    for (int i = 0; i < totalCells; i++) {
      if (i < startingWeekday) {
        final dayNum = daysInPrevMonth - (startingWeekday - 1) + i;
        dayWidgets.add(
          DatePickerDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            isEnabled: false,
            onTap: null,
          ),
        );
      } else if (i < startingWeekday + daysInMonth) {
        final dayNum = i - startingWeekday + 1;
        final cellDate = DateTime(viewMonth.year, viewMonth.month, dayNum);
        final isSelected = DatePickerHelpers.isSameDay(cellDate, selectedDate);
        final isToday = DatePickerHelpers.isSameDay(cellDate, today);
        final isBeforeFirst = cellDate.isBefore(
          DateTime(firstDate.year, firstDate.month, firstDate.day),
        );
        final isAfterLast = cellDate.isAfter(
          DateTime(lastDate.year, lastDate.month, lastDate.day),
        );
        final isEnabled = !isBeforeFirst && !isAfterLast;

        dayWidgets.add(
          DatePickerDayCell(
            text: '$dayNum',
            isCurrentMonth: true,
            isSelected: isSelected,
            isToday: isToday,
            isEnabled: isEnabled,
            onTap: isEnabled ? () => onSelectDate(cellDate) : null,
          ),
        );
      } else {
        final dayNum = i - (startingWeekday + daysInMonth) + 1;
        dayWidgets.add(
          DatePickerDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            isEnabled: false,
            onTap: null,
          ),
        );
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }
}
