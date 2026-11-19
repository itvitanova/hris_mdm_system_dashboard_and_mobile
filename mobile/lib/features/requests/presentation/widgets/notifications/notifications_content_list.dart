import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/features/requests/domain/entities/request_notification_item.dart';
import 'notification_card_item.dart';
import 'notification_day_section.dart';
import 'notifications_empty_state.dart';
import 'notifications_filter_bar.dart';
import 'notifications_section_header.dart';

/// Scrollable list content for Request Notifications Screen
class NotificationsContentList extends StatelessWidget {
  const NotificationsContentList({
    super.key,
    required this.unreadCount,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.error,
    required this.sections,
    required this.isEmpty,
    required this.onOpenItem,
    required this.onOpenRevision,
  });

  final int unreadCount;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;
  final String? error;
  final List<NotificationDaySection> sections;
  final bool isEmpty;
  final ValueChanged<RequestNotificationItem> onOpenItem;
  final ValueChanged<RequestNotificationItem> onOpenRevision;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 16.h),
      children: [
        // 1. Segmented Status Filter Bar ('Semua' & 'Belum Dibaca')
        NotificationsFilterBar(
          selectedFilter: selectedFilter,
          unreadCount: unreadCount,
          onFilterSelected: onSelectFilter,
        ),
        SizedBox(height: 10.h),

        // 2. Error Banner
        if (error != null)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Text(
              error!,
              style: const TextStyle(color: Color(0xFFBE123C)),
            ),
          ),

        // 3. Notification Cards grouped by day or Empty State
        if (isEmpty)
          NotificationsEmptyState(selectedFilter: selectedFilter)
        else
          ...sections.expand((section) => [
                NotificationsSectionHeader(
                  title: section.title,
                  count: section.items.length,
                ),
                ...section.items.map(
                  (item) => NotificationCardItem(
                    item: item,
                    onTap: () => onOpenItem(item),
                    onFixNow: () => onOpenRevision(item),
                  ),
                ),
              ]),
      ],
    );
  }
}
