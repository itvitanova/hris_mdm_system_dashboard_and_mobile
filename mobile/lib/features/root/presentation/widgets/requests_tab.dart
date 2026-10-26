import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_detail.dart';
import '../../../requests/request_notifications.dart';

class RequestsTab extends StatelessWidget {
  const RequestsTab({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.open,
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Widget) open;

  Workspace get w => workspace;

  @override
  Widget build(BuildContext context) {
    final rows = w.mine('requests');
    final unreadCount = rows.where((r) => r['unread'] == true).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Pengajuan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi pengajuan',
            onPressed: () => open(RequestNotificationsScreen(api: api, workspace: w)),
            icon: Badge.count(
              count: unreadCount,
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Segarkan data',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const SectionHeading(
                'Pengajuan Anda',
                subtitle: 'Pantau persetujuan, revisi, dan dokumen Anda.',
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => open(RequestForm(api: api, workspace: w)),
                icon: const Icon(Icons.add),
                label: const Text('Buat pengajuan'),
              ),
              const SizedBox(height: 20),
              if (rows.isEmpty)
                const EmptyState('Pengajuan Anda akan tampil di sini.')
              else
                ...rows.map(
                  (r) => Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              text(r, 'kind'),
                              style: const TextStyle(
                                color: AppColors.deepTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            StatusPill(text(r, 'status')),
                            if (r['unread'] == true)
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: Color(0xFFB42318), size: 8),
                                  SizedBox(width: 6),
                                  Text(
                                    'Ada pembaruan',
                                    style: TextStyle(
                                      color: Color(0xFFB42318),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          text(r, 'title'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          text(r, 'description'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: muted),
                        ),
                        if (text(r, 'pendingWith', '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              text(r, 'pendingWith'),
                              style: const TextStyle(
                                color: AppColors.deepTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          '${text(r, 'startDate')} s.d. ${text(r, 'endDate')}',
                          style: const TextStyle(color: Color(0xFF52637A)),
                        ),
                        if (number(r, 'amount') > 0)
                          DetailLine('Nominal', rupiah(number(r, 'amount'))),
                        if (r['kind'] == 'Lembur')
                          DetailLine('Durasi', '${number(r, 'hours')} jam'),
                        OutlinedButton.icon(
                          onPressed: () => open(
                            RequestDetailScreen(api: api, request: r, own: true),
                          ),
                          icon: const Icon(Icons.article_outlined),
                          label: const Text('Rincian dan dokumen'),
                        ),
                        if (text(r, 'reviewNote', '').isNotEmpty)
                          DetailLine('Catatan HR', text(r, 'reviewNote')),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
