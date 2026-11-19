import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'calendar_constants.dart';

class CalendarMonthNavBar extends StatelessWidget {
  const CalendarMonthNavBar({
    super.key,
    required this.month,
    required this.onMoveMonth,
  });

  final DateTime month;
  final void Function(int offset) onMoveMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMonthNavButton(
            icon: UIcons.regularRounded.angle_small_left,
            onTap: () => onMoveMonth(-1),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${CalendarConstants.monthNames[month.month - 1]} ${month.year}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
          _buildMonthNavButton(
            icon: UIcons.regularRounded.angle_small_right,
            onTap: () => onMoveMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCCFBF1)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF0D9488),
          ),
        ),
      ),
    );
  }
}
