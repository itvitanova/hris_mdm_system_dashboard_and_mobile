import 'package:flutter/material.dart';

class CalendarPresetChips extends StatelessWidget {
  const CalendarPresetChips({
    super.key,
    required this.selected,
    required this.today,
    required this.month,
    required this.onSelectPreset,
  });

  final DateTime selected;
  final DateTime today;
  final DateTime month;
  final void Function(DateTime date) onSelectPreset;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPresetChip(
            label: 'Hari Ini',
            isSelected: _isSameDay(selected, today),
            onTap: () => onSelectPreset(today),
          ),
          const SizedBox(width: 8),
          _buildPresetChip(
            label: 'Awal Bulan',
            isSelected: _isSameDay(
              selected,
              DateTime(month.year, month.month, 1),
            ),
            onTap: () => onSelectPreset(
              DateTime(month.year, month.month, 1),
            ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D9488)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
