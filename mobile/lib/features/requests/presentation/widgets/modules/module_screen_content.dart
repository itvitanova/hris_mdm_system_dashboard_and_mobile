import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../universal_request_card/universal_request_card.dart';
import 'module_empty_state.dart';
import 'module_filter_bar.dart';
import 'module_hero_action_banner.dart';
import 'module_history_section_header.dart';
import 'module_pagination_bar.dart';
import 'module_stat_grid.dart';

/// Scrollable list content for dedicated module screen
class ModuleScreenContent extends StatelessWidget {
  const ModuleScreenContent({
    super.key,
    required this.scrollController,
    required this.kind,
    required this.language,
    required this.isEn,
    required this.approvedCount,
    required this.pendingCount,
    required this.rejectedCount,
    required this.revisionCount,
    required this.selectedStatusFilter,
    required this.filteredRequests,
    required this.paginatedRequests,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.onRefresh,
    required this.onCreatePressed,
    required this.onSelectStatus,
    required this.onDetailPressed,
    required this.onRevisePressed,
    required this.onPageChanged,
  });

  final ScrollController scrollController;
  final SubmissionKind kind;
  final AppLanguage language;
  final bool isEn;
  final int approvedCount, pendingCount, rejectedCount, revisionCount;
  final SubmissionStatus? selectedStatusFilter;
  final List<UniversalRequestModel> filteredRequests, paginatedRequests;
  final int totalItems, currentPage, totalPages, startIndex, endIndex;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreatePressed;
  final ValueChanged<SubmissionStatus?> onSelectStatus;
  final ValueChanged<UniversalRequestModel> onDetailPressed, onRevisePressed;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        children: [
          ModuleHeroActionBanner(
            kind: kind,
            language: language,
            onCreatePressed: onCreatePressed,
          ),
          ModuleStatGrid(
            isEn: isEn,
            approvedCount: approvedCount,
            pendingCount: pendingCount,
            rejectedCount: rejectedCount,
            revisionCount: revisionCount,
            selectedStatusFilter: selectedStatusFilter,
            onSelectStatus: onSelectStatus,
          ),
          SizedBox(height: 18.h),
          ModuleFilterBar(
            selectedStatus: selectedStatusFilter,
            language: language,
            onChanged: onSelectStatus,
            onRefresh: onRefresh,
          ),
          SizedBox(height: 20.h),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          SizedBox(height: 18.h),
          ModuleHistorySectionHeader(
            kind: kind,
            isEn: isEn,
            totalCount: totalItems,
            selectedStatus: selectedStatusFilter,
          ),
          SizedBox(height: 14.h),
          if (filteredRequests.isEmpty)
            ModuleEmptyState(
              kind: kind,
              isEn: isEn,
              selectedStatus: selectedStatusFilter,
            )
          else ...[
            for (final model in paginatedRequests)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: UniversalRequestCard(
                  data: model,
                  language: language,
                  onDetailPressed: () => onDetailPressed(model),
                  onRevisePressed: () => onRevisePressed(model),
                ),
              ),
            ModulePaginationBar(
              currentPage: currentPage,
              totalPages: totalPages,
              startIndex: startIndex,
              endIndex: endIndex,
              totalItems: totalItems,
              isEn: isEn,
              onPageChanged: onPageChanged,
            ),
          ],
        ],
      ),
    );
  }
}
