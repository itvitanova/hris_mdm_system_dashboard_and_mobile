import 'package:flutter/material.dart';

class DatePickerDayCell extends StatelessWidget {
  final String text;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final bool isEnabled;
  final VoidCallback? onTap;

  const DatePickerDayCell({
    super.key,
    required this.text,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCurrentMonth || !isEnabled) {
      return Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFCBD5E1),
          ),
        ),
      );
    }

    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F766E),
                Color(0xFF14B8A6),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFF0FDFA) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: const Color(0xFF0D9488), width: 1.2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color:
                    isToday ? const Color(0xFF0D9488) : const Color(0xFF1E293B),
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 2),
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
    );
  }
}
