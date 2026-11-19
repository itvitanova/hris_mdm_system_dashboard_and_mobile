import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../form_ui_components.dart';

const gaPriorities = ['Normal', 'Mendesak'];

class GaPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPrioritySelected;
  final bool disabled;

  const GaPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFormSectionTitle('Tingkat Prioritas *'),
        SizedBox(height: 8.h),
        Row(
          children: gaPriorities.map((prio) {
            final isSelected = selectedPriority == prio;
            final isUrgent = prio == 'Mendesak';
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: prio == gaPriorities.first ? 8.w : 0,
                  left: prio == gaPriorities.last ? 8.w : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: disabled ? null : () => onPrioritySelected(prio),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isUrgent
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF0FDFA))
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? (isUrgent
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF0D9488))
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.4 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isUrgent
                                ? UIcons.regularRounded.bolt
                                : UIcons.regularRounded.check,
                            size: 16.sp,
                            color: isSelected
                                ? (isUrgent
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF0D9488))
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            prio,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isUrgent
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF0F766E))
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
