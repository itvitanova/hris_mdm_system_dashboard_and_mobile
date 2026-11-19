import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'date_picker_helpers.dart';

class DatePickerMonthHeader extends StatelessWidget {
  final DateTime viewMonth;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const DatePickerMonthHeader({
    super.key,
    required this.viewMonth,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${DatePickerHelpers.monthNames[viewMonth.month - 1]} ${viewMonth.year}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        Row(
          children: [
            _buildCircleNavButton(
              icon: UIcons.regularRounded.angle_small_left,
              onTap: onPrevMonth,
            ),
            const SizedBox(width: 8),
            _buildCircleNavButton(
              icon: UIcons.regularRounded.angle_small_right,
              onTap: onNextMonth,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
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
    );
  }
}
