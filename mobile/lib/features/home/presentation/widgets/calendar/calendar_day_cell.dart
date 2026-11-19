import 'package:flutter/material.dart';
import 'calendar_constants.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.text,
    this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.count,
    this.hasBirthday = false,
    required this.onTap,
  });

  final String text;
  final DateTime? date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final int count;
  final bool hasBirthday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!isCurrentMonth) {
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ),
      );
    }

    final monthName = date != null
        ? CalendarConstants.monthNames[date!.month - 1]
        : '';

    return Semantics(
      label: date != null
          ? '${date!.day} $monthName ${date!.year}${hasBirthday ? ", $count rekan ulang tahun" : ""}'
          : text,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF14B8A6),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : isToday
                    ? const Color(0xFFF0FDFA)
                    : (hasBirthday
                        ? const Color(0xFFFFFBEB)
                        : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? null
                : isToday
                    ? Border.all(color: const Color(0xFF0D9488), width: 1.2)
                    : (hasBirthday
                        ? Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 0.8,
                          )
                        : null),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w700
                          : (hasBirthday ? FontWeight.w700 : FontWeight.w500),
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFF0D9488)
                              : (hasBirthday
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasBirthday)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (!hasBirthday && isToday && !isSelected)
                      Container(
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
