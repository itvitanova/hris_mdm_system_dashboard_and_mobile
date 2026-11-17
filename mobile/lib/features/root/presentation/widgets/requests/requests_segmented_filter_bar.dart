import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Segmented Filter Bar: Semua / Menunggu / Selesai
class RequestsSegmentedFilterBar extends StatelessWidget {
  final bool isEn;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const RequestsSegmentedFilterBar({
    super.key,
    required this.isEn,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final segments = [
      (key: 'Semua', label: isEn ? 'All' : 'Semua'),
      (key: 'Menunggu', label: isEn ? 'Pending' : 'Menunggu'),
      (key: 'Selesai', label: isEn ? 'Finished' : 'Selesai'),
    ];

    return Container(
      height: 38.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: segments.map((segment) {
          final isSelected = selectedFilter == segment.key;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('filter_segment_${segment.key}'),
                onTap: () => onFilterChanged(segment.key),
                borderRadius: BorderRadius.circular(7.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
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
                  child: Text(
                    segment.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
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
