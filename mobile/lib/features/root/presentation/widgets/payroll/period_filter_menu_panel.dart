import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class PeriodFilterMenuPanel extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const PeriodFilterMenuPanel({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.12),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: EdgeInsets.all(8.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 220.h),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: options.length,
          separatorBuilder: (context, index) => SizedBox(height: 5.w),
          itemBuilder: (context, index) {
            final period = options[index];
            final isSelected = period == selected;
            return GestureDetector(
              key: ValueKey('period_option_$period'),
              onTap: () => onSelect(period),
              child: Container(
                height: 36.w,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  color: isSelected
                      ? const Color(0xFFE1F2F5)
                      : const Color(0xFFF8FAFC),
                  border: isSelected
                      ? Border.all(
                          color: const Color(0xFF0F766E),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      UIcons.regularRounded.calendar,
                      size: 14.w,
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        period,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0F766E)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        UIcons.regularRounded.check,
                        size: 14.w,
                        color: const Color(0xFF0F766E),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
