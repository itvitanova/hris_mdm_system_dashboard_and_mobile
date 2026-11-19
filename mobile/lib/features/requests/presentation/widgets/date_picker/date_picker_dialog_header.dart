import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'date_picker_helpers.dart';

class DatePickerDialogHeader extends StatelessWidget {
  final String title;
  final DateTime selectedDate;
  final VoidCallback onClose;

  const DatePickerDialogHeader({
    super.key,
    required this.title,
    required this.selectedDate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D9488),
                letterSpacing: 1.2,
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  UIcons.regularRounded.cross,
                  size: 15,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          DatePickerHelpers.formatDisplayDate(selectedDate),
          style: const TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
