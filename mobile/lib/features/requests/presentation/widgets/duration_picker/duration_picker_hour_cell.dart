import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DurationPickerHourCell extends StatelessWidget {
  final int hour;
  final bool isSelected;
  final ValueChanged<int> onSelect;

  const DurationPickerHourCell({
    super.key,
    required this.hour,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(hour),
          borderRadius: BorderRadius.circular(8.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.2 : 0.8,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x200D9488),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$hour Jam',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
