import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/workspace.dart';

class PettyCashPresetChips extends StatelessWidget {
  final int currentAmount;
  final ValueChanged<int> onAmountSelected;
  final bool disabled;

  const PettyCashPresetChips({
    super.key,
    required this.currentAmount,
    required this.onAmountSelected,
    this.disabled = false,
  });

  static const quickPresets = [50000, 100000, 250000, 500000];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: quickPresets.map((preset) {
        final isMatch = currentAmount == preset;
        final label = switch (preset) {
          50000 => 'Rp 50 rb',
          100000 => 'Rp 100 rb',
          250000 => 'Rp 250 rb',
          500000 => 'Rp 500 rb',
          _ => rupiah(preset),
        };
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : () => onAmountSelected(preset),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: isMatch
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isMatch
                      ? const Color(0xFF0D9488)
                      : const Color(0xFF99F6E4),
                  width: 0.8,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5.sp,
                  fontWeight: isMatch ? FontWeight.w700 : FontWeight.w600,
                  color: isMatch ? Colors.white : const Color(0xFF0F766E),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
