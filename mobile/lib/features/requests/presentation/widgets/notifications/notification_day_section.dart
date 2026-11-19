import 'package:mdm_hris/features/requests/domain/entities/request_notification_item.dart';

/// Data class grouping notifications by day section (Hari Ini, Kemarin, Terdahulu)
class NotificationDaySection {
  const NotificationDaySection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<RequestNotificationItem> items;
}
