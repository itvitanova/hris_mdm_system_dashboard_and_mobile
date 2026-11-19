import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/domain/entities/request_notification_item.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_kind.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_status.dart';
import 'notification_day_section.dart';

/// Helper for parsing notifications and grouping them by calendar date
class NotificationsQueryHelper {
  static List<RequestNotificationItem> getCombinedNotifications(
    Workspace data,
    Set<String> readIds,
  ) {
    final realRows = data.mine('requests').where((r) {
      final history = (r['history'] as List?) ?? [];
      return r['unread'] == true ||
          text(r, 'reviewNote', '').isNotEmpty ||
          (history.isNotEmpty &&
              (history.last as Map)['decision'] != 'Diajukan');
    }).toList();

    return realRows.map((r) {
      final kind = SubmissionKind.fromString(text(r, 'kind', 'cuti'));
      final status = SubmissionStatus.fromString(text(r, 'status', 'menunggu'));
      final reqId = text(r, 'id');
      final isUnread = r['unread'] == true && !_readIdsContains(readIds, reqId);
      final note = text(r, 'reviewNote', '');
      final reviewer = text(r, 'reviewedBy', text(r, 'pendingWith', ''));

      final headline = _createHeadline(kind, status);
      final message = _createMessage(note, reviewer);

      final dateStr = text(r, 'updatedAt', text(r, 'createdAt', ''));
      final rawDt = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;
      final dt = rawDt?.toLocal();
      final timeAgoText = _formatTimeAgo(dt);

      return RequestNotificationItem(
        id: 'real-$reqId',
        requestId: reqId,
        kind: kind,
        requestTitle: text(r, 'title', 'Pengajuan ${kind.displayName}'),
        status: status,
        headline: headline,
        message: message,
        timeAgo: timeAgoText,
        isUnread: isUnread,
        reviewerName: reviewer.isNotEmpty ? reviewer : null,
        reviewNote: note.isNotEmpty ? note : null,
        rawRequest: r,
        createdAt: dt,
      );
    }).toList();
  }

  static bool _readIdsContains(Set<String> readIds, String reqId) {
    return readIds.contains('real-$reqId');
  }

  static String _createHeadline(SubmissionKind kind, SubmissionStatus status) {
    if (status == SubmissionStatus.disetujui) {
      return 'Pengajuan ${kind.displayName} Disetujui';
    } else if (status == SubmissionStatus.perluRevisi) {
      return 'Perlu Revisi Dokumen ${kind.displayName}';
    } else if (status == SubmissionStatus.ditolak) {
      return 'Pengajuan ${kind.displayName} Ditolak';
    }
    return 'Pembaruan Pengajuan ${kind.displayName}';
  }

  static String _createMessage(String note, String reviewer) {
    if (note.isNotEmpty) return 'Catatan peninjau: "$note"';
    if (reviewer.isNotEmpty) return 'Pembaruan peninjauan dari $reviewer';
    return 'Buka untuk melihat perkembangan keputusan.';
  }

  static String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return 'Baru saja';
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = DateTime(now.year, now.month, now.day - 1);
    final itemDate = DateTime(dt.year, dt.month, dt.day);

    if (!dt.isBefore(startOfToday)) {
      final diff = now.difference(dt);
      if (diff.inHours > 0) return '${diff.inHours} jam lalu';
      if (diff.inMinutes > 0) return '${diff.inMinutes} mnt lalu';
      return 'Baru saja';
    } else if (!dt.isBefore(startOfYesterday)) {
      return 'Kemarin';
    }
    final daysDiff = startOfToday.difference(itemDate).inDays;
    if (daysDiff <= 30) return '$daysDiff hari lalu';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  static List<NotificationDaySection> groupNotificationsByDay(
    List<RequestNotificationItem> filteredItems,
  ) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = DateTime(now.year, now.month, now.day - 1);

    final todayItems = <RequestNotificationItem>[];
    final yesterdayItems = <RequestNotificationItem>[];
    final earlierItems = <RequestNotificationItem>[];

    for (final item in filteredItems) {
      if (item.createdAt != null) {
        final dt = item.createdAt!.toLocal();
        if (!dt.isBefore(startOfToday)) {
          todayItems.add(item);
        } else if (!dt.isBefore(startOfYesterday)) {
          yesterdayItems.add(item);
        } else {
          earlierItems.add(item);
        }
      } else {
        final time = item.timeAgo.toLowerCase();
        if (time.contains('kemarin')) {
          yesterdayItems.add(item);
        } else if (time.contains('hari lalu') ||
            time.contains('minggu') ||
            time.contains('bulan') ||
            time.contains('/') ||
            time.contains('202') ||
            time.contains('okt') ||
            time.contains('sep')) {
          earlierItems.add(item);
        } else {
          todayItems.add(item);
        }
      }
    }

    final sections = <NotificationDaySection>[];
    if (todayItems.isNotEmpty) {
      sections.add(NotificationDaySection(title: 'Hari Ini', items: todayItems));
    }
    if (yesterdayItems.isNotEmpty) {
      sections.add(NotificationDaySection(title: 'Kemarin', items: yesterdayItems));
    }
    if (earlierItems.isNotEmpty) {
      sections.add(NotificationDaySection(title: 'Terdahulu', items: earlierItems));
    }
    return sections;
  }

  static Map<String, dynamic> resolveRequestForItem(
    RequestNotificationItem item,
    Workspace data,
  ) {
    if (item.rawRequest != null && item.rawRequest!.isNotEmpty) {
      return Map<String, dynamic>.from(item.rawRequest!);
    }
    final matches = data.rows('requests').where((r) => r['id'] == item.requestId);
    if (matches.isNotEmpty) {
      return Map<String, dynamic>.from(matches.first);
    }
    return {
      'id': item.requestId,
      'title': item.requestTitle,
      'kind': item.kind.displayName,
      'status': item.status.displayName,
      'reviewedBy': item.reviewerName ?? 'Peninjau',
      'reviewNote': item.reviewNote ?? '',
      'startDate': DateTime.now().toIso8601String().substring(0, 10),
      'endDate': DateTime.now().toIso8601String().substring(0, 10),
      'revision': 0,
    };
  }
}
