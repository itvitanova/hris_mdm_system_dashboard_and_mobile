import 'package:flutter/material.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'calendar_constants.dart';
import 'calendar_days_grid.dart';
import 'calendar_legend_row.dart';
import 'calendar_month_nav_bar.dart';
import 'calendar_preset_chips.dart';
import 'calendar_weekday_header.dart';

class CalendarExecutiveCard extends StatelessWidget {
  const CalendarExecutiveCard({
    super.key,
    required this.selected,
    required this.month,
    required this.today,
    required this.loading,
    required this.workspace,
    required this.entries,
    required this.birthdays,
    required this.onSelectDate,
    required this.onSelectPreset,
    required this.onMoveMonth,
  });

  final DateTime selected;
  final DateTime month;
  final DateTime today;
  final bool loading;
  final Workspace workspace;
  final List<Json> entries;
  final List<Json> birthdays;
  final void Function(DateTime date) onSelectDate;
  final void Function(DateTime date) onSelectPreset;
  final void Function(int offset) onMoveMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'PILIH TANGGAL',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D9488),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CalendarConstants.formatDisplayDate(selected),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CalendarPresetChips(
                selected: selected,
                today: today,
                month: month,
                onSelectPreset: onSelectPreset,
              ),
              const SizedBox(height: 16),
              CalendarMonthNavBar(
                month: month,
                onMoveMonth: onMoveMonth,
              ),
              const SizedBox(height: 14),
              const CalendarWeekdayHeader(),
              const SizedBox(height: 8),
              CalendarDaysGrid(
                month: month,
                selected: selected,
                today: today,
                workspace: workspace,
                entries: entries,
                birthdays: birthdays,
                onSelectDate: onSelectDate,
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),
              const CalendarLegendRow(),
            ],
          ),
        ),
      ),
    );
  }
}
