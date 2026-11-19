import 'package:flutter/material.dart';
import 'date_picker_helpers.dart';

class DatePickerPresetChips extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectPreset;

  const DatePickerPresetChips({
    super.key,
    required this.selectedDate,
    required this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPresetChip(
            label: 'Hari Ini',
            isSelected: DatePickerHelpers.isSameDay(selectedDate, today),
            onTap: () => onSelectPreset(today),
          ),
          const SizedBox(width: 8),
          _buildPresetChip(
            label: 'Besok',
            isSelected: DatePickerHelpers.isSameDay(selectedDate, tomorrow),
            onTap: () => onSelectPreset(tomorrow),
          ),
          const SizedBox(width: 8),
          _buildPresetChip(
            label: '7 Hari ke Depan',
            isSelected: DatePickerHelpers.isSameDay(selectedDate, nextWeek),
            onTap: () => onSelectPreset(nextWeek),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
