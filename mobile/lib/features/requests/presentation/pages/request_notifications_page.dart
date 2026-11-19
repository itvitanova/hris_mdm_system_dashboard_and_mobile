import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../domain/entities/request_notification_item.dart';
import '../widgets/notifications/notifications_app_bar.dart';
import '../widgets/notifications/notifications_content_list.dart';
import '../widgets/notifications/notifications_query_helper.dart';
import 'request_detail_page.dart';
import 'request_form_page.dart';

/// Halaman Notifikasi Pembaruan Pengajuan Mandiri
class RequestNotificationsScreen extends StatefulWidget {
  const RequestNotificationsScreen({
    super.key,
    required this.api,
    required this.workspace,
  });

  final ApiClient api;
  final Workspace workspace;

  @override
  State<RequestNotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends State<RequestNotificationsScreen> {
  late Workspace data = widget.workspace;
  String? error;
  String _selectedFilter = 'Semua';
  final Set<String> _readIds = {};
  bool _markingAsRead = false;

  Future<void> refresh() async {
    try {
      final next = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          data = next;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  void _showFeedbackSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(UIcons.regularRounded.check, color: Colors.white, size: 18),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final all = NotificationsQueryHelper.getCombinedNotifications(data, _readIds);
    final unreadItems = all.where((it) => it.isUnread).toList();
    if (unreadItems.isEmpty || _markingAsRead) return;

    setState(() {
      _markingAsRead = true;
      for (final item in unreadItems) {
        _readIds.add(item.id);
      }
    });

    _showFeedbackSnackBar('Semua notifikasi telah ditandai dibaca');

    try {
      final unreadRequests = data.mine('requests').where((r) => r['unread'] == true).toList();
      for (final r in unreadRequests) {
        final id = text(r, 'id');
        final token = text(r, 'updateToken');
        if (id.isNotEmpty && token.isNotEmpty) {
          try {
            await widget.api.post('/requests/${Uri.encodeComponent(id)}/seen', {'token': token});
          } catch (_) {}
        }
      }
      final next = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          data = next;
          error = null;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _markingAsRead = false);
    }
  }

  Future<void> _openRevisionForm(RequestNotificationItem item) async {
    setState(() => _readIds.add(item.id));
    final targetRequest = NotificationsQueryHelper.resolveRequestForItem(item, data);

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestForm(
          api: widget.api,
          workspace: data,
          initialKind: item.kind.displayName,
          initialRequest: targetRequest,
          lockKindSelection: true,
        ),
      ),
    );

    if (changed == true) {
      await refresh();
      _showFeedbackSnackBar('Pengajuan yang direvisi telah berhasil dikirim.');
    }
  }

  Future<void> _openItem(RequestNotificationItem item) async {
    setState(() => _readIds.add(item.id));
    final targetRequest = NotificationsQueryHelper.resolveRequestForItem(item, data);

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(
          api: widget.api,
          request: targetRequest,
          own: true,
        ),
      ),
    );

    await refresh();
    if (changed == true) {
      _showFeedbackSnackBar('Pengajuan yang direvisi telah berhasil dikirim.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = NotificationsQueryHelper.getCombinedNotifications(data, _readIds);
    final unreadCount = allItems.where((i) => i.isUnread).length;
    final filteredItems = _selectedFilter == 'Belum Dibaca'
        ? allItems.where((i) => i.isUnread).toList()
        : allItems;
    final sections = NotificationsQueryHelper.groupNotificationsByDay(filteredItems);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: NotificationsAppBar(
        unreadCount: unreadCount,
        isMarkingAsRead: _markingAsRead,
        onBack: () => Navigator.of(context).pop(),
        onMarkAllAsRead: _markAllAsRead,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          color: const Color(0xFF0F766E),
          child: NotificationsContentList(
            unreadCount: unreadCount,
            selectedFilter: _selectedFilter,
            onSelectFilter: (filter) => setState(() => _selectedFilter = filter),
            error: error,
            sections: sections,
            isEmpty: filteredItems.isEmpty,
            onOpenItem: _openItem,
            onOpenRevision: _openRevisionForm,
          ),
        ),
      ),
    );
  }
}

typedef RequestNotificationsPage = RequestNotificationsScreen;
