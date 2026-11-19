import 'package:flutter/material.dart';

class DatePickerActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const DatePickerActionButtons({
    super.key,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF8FAFC),
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 44,
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
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onApply,
                borderRadius: BorderRadius.circular(10),
                child: const Center(
                  child: Text(
                    'Terapkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
