import 'package:flutter/material.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'calendar_constants.dart';
import 'calendar_day_cell.dart';
import 'calendar_query_helper.dart';

class CalendarDaysGrid extends StatelessWidget {
  const CalendarDaysGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.today,
    required this.workspace,
    required this.entries,
    required this.birthdays,
    required this.onSelectDate,
  });

  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final Workspace workspace;
  final List<Json> entries;
  final List<Json> birthdays;
  final void Function(DateTime date) onSelectDate;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final startingWeekday = (firstDayOfMonth.weekday - 1) % 7; // 0 for Senin

    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final daysInPrevMonth =
        DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final totalCells = (startingWeekday + daysInMonth > 35) ? 42 : 35;
    final dayWidgets = <Widget>[];

    for (int i = 0; i < totalCells; i++) {
      if (i < startingWeekday) {
        final dayNum = daysInPrevMonth - (startingWeekday - 1) + i;
        dayWidgets.add(
          CalendarDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            count: 0,
            onTap: null,
          ),
        );
      } else if (i < startingWeekday + daysInMonth) {
        final dayNum = i - startingWeekday + 1;
        final cellDate = DateTime(month.year, month.month, dayNum);
        final isSelected = CalendarConstants.isSameDay(cellDate, selected);
        final isToday = CalendarConstants.isSameDay(cellDate, today);
        final bDays = CalendarQueryHelper.birthdaysOnDate(
          workspace: workspace,
          entries: entries,
          birthdays: birthdays,
          day: cellDate,
        );
        final count = bDays.length;
        final hasBirthday = count > 0;

        dayWidgets.add(
          CalendarDayCell(
            text: '$dayNum',
            date: cellDate,
            isCurrentMonth: true,
            isSelected: isSelected,
            isToday: isToday,
            count: count,
            hasBirthday: hasBirthday,
            onTap: () => onSelectDate(cellDate),
          ),
        );
      } else {
        final dayNum = i - (startingWeekday + daysInMonth) + 1;
        dayWidgets.add(
          CalendarDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            count: 0,
            onTap: null,
          ),
        );
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }
}
