import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/workspace.dart';
import '../../shared/widgets.dart';
import 'request_detail.dart';

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

  @override
  Widget build(BuildContext context) {
    final rows = data.mine('requests').where((r) {
      final history = (r['history'] as List?) ?? [];
      return r['unread'] == true ||
          text(r, 'reviewNote', '').isNotEmpty ||
          (history.isNotEmpty &&
              (history.last as Map)['decision'] != 'Diajukan');
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi pengajuan')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeading(
                'Pembaruan pengajuan',
                subtitle:
                    'Keputusan dan catatan peninjau. Buka pengajuan untuk membaca pembaruannya.',
              ),
              const SizedBox(height: 20),
              if (error != null) ErrorNotice(error!),
              if (rows.isEmpty)
                const EmptyState('Belum ada pembaruan pengajuan.'),
              for (final r in rows)
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      r['status'] == 'Perlu revisi'
                          ? Icons.edit_note
                          : Icons.notifications_outlined,
                      color: r['unread'] == true
                          ? const Color(0xFFB42318)
                          : muted,
                    ),
                    title: Text(
                      text(r, 'title'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${text(r, 'status')}\n${text(r, 'reviewNote', text(r, 'pendingWith', 'Buka untuk melihat keputusan.'))}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RequestDetailScreen(
                            api: widget.api,
                            request: r,
                            own: true,
                          ),
                        ),
                      );
                      await refresh();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
