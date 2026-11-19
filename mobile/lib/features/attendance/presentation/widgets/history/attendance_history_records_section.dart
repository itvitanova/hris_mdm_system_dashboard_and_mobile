import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';
import '../attendance_daily_card.dart';
import '../attendance_stat_card.dart';
import '../filter_dropdowns.dart';
import 'attendance_empty_state.dart';
import 'attendance_history_pagination_bar.dart';
import 'attendance_history_query_helper.dart';

class AttendanceHistoryRecordsSection extends StatelessWidget {
  final List<Map<String, dynamic>> displayedDailyRecords;
  final List<Map<String, dynamic>> paginatedItems;
  final int currentPage;
  final int totalPages;
  final int startIndex;
  final int endIndex;
  final int totalItems;
  final MonthEnum? monthSelected;
  final AttendanceStatType? attendanceSelected;
  final AppLanguage language;
  final void Function(Map<String, dynamic> raw) onCardTap;
  final ValueChanged<int> onPageChanged;

  const AttendanceHistoryRecordsSection({
    super.key,
    required this.displayedDailyRecords,
    required this.paginatedItems,
    required this.currentPage,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.totalItems,
    required this.monthSelected,
    required this.attendanceSelected,
    required this.language,
    required this.onCardTap,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = language == AppLanguage.en;

    if (displayedDailyRecords.isEmpty) {
      return AttendanceEmptyState(isEn: isEn);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...paginatedItems.asMap().entries.map((entry) {
          final index = entry.key;
          final rawRecord = entry.value;
          final isHighlighted = index == 0 &&
              currentPage == 1 &&
              monthSelected == null &&
              attendanceSelected == null;

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: AttendanceDailyCard(
              key: ValueKey(
                'att_daily_${rawRecord['id'] ?? index}_${AttendanceHistoryQueryHelper.extractRawDate(rawRecord)}',
              ),
              raw: rawRecord,
              isHighlighted: isHighlighted,
              language: language,
              onTap: () => onCardTap(rawRecord),
            ),
          );
        }),
        AttendanceHistoryPaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          startIndex: startIndex,
          endIndex: endIndex,
          totalItems: totalItems,
          language: language,
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }
}
