import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'duration_picker_hour_cell.dart';

class DurationPickerQuickGrid extends StatelessWidget {
  final int selectedHours;
  final ValueChanged<int> onSelectHour;

  const DurationPickerQuickGrid({
    super.key,
    required this.selectedHours,
    required this.onSelectHour,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pilihan Jam Cepat (1 - 12 Jam)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            DurationPickerHourCell(
              hour: 1,
              isSelected: selectedHours == 1,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 2,
              isSelected: selectedHours == 2,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 3,
              isSelected: selectedHours == 3,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 4,
              isSelected: selectedHours == 4,
              onSelect: onSelectHour,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            DurationPickerHourCell(
              hour: 5,
              isSelected: selectedHours == 5,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 6,
              isSelected: selectedHours == 6,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 7,
              isSelected: selectedHours == 7,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 8,
              isSelected: selectedHours == 8,
              onSelect: onSelectHour,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            DurationPickerHourCell(
              hour: 9,
              isSelected: selectedHours == 9,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 10,
              isSelected: selectedHours == 10,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 11,
              isSelected: selectedHours == 11,
              onSelect: onSelectHour,
            ),
            SizedBox(width: 8.w),
            DurationPickerHourCell(
              hour: 12,
              isSelected: selectedHours == 12,
              onSelect: onSelectHour,
            ),
          ],
        ),
      ],
    );
  }
}
