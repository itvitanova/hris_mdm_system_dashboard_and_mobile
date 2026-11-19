import 'package:flutter/material.dart';
import 'calendar_constants.dart';

class CalendarWeekdayHeader extends StatelessWidget {
  const CalendarWeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CalendarConstants.dayNames.map((d) {
        final isWeekend = d == 'Sab' || d == 'Min';
        return Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                d,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
