import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';

/// Segmented tab filter bar ('Menunggu tindakan' vs 'Riwayat keputusan')
class ApprovalsSegmentedFilterBar extends StatelessWidget {
  const ApprovalsSegmentedFilterBar({
    super.key,
    required this.history,
    required this.pendingCount,
    required this.onChanged,
  });

  final bool history;
  final int pendingCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isEn = AppLanguageController.currentLanguage == AppLanguage.en;
    final filters = [
      {
        'key': 'pending',
        'label': isEn ? 'Pending Action' : 'Menunggu tindakan',
        'isSelected': !history,
      },
      {
        'key': 'history',
        'label': isEn ? 'Decision History' : 'Riwayat keputusan',
        'isSelected': history,
      },
    ];

    return Container(
      constraints: BoxConstraints(minHeight: 38.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: filters.map((f) {
          final isSelected = f['isSelected'] as bool;
          final label = f['label'] as String;
          final isPending = f['key'] == 'pending';

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('approval_filter_${f['key']}'),
                onTap: () {
                  if (isPending && history) {
                    onChanged(false);
                  } else if (!isPending && !history) {
                    onChanged(true);
                  }
                },
                borderRadius: BorderRadius.circular(7.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F766E), // Teal 700
                              Color(0xFF14B8A6), // Teal 500
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(7.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0F766E)
                                  .withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5.sp,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (isPending && pendingCount > 0) ...[
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.5.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.24)
                                : const Color(0xFFED2736),
                            borderRadius: BorderRadius.circular(10.r),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 0.8,
                                  )
                                : null,
                          ),
                          child: Text(
                            pendingCount > 99 ? '99+' : '$pendingCount',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
