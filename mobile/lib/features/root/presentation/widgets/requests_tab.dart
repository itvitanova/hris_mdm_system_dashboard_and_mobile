import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../shared/widgets.dart';
import '../../../home/leave_calendar_screen.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_detail.dart';
import '../../../requests/request_notifications.dart';
import '../../../requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import '../../../requests/presentation/models/mock_universal_requests.dart';

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
      appBar: AppBar(
        title: const Text(
          'Pengajuan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Kalender cuti',
            onPressed: () => open(LeaveCalendarScreen(api: api, workspace: w)),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            tooltip: 'Notifikasi pengajuan',
            onPressed: () =>
                open(RequestNotificationsScreen(api: api, workspace: w)),
            icon: Badge.count(
              count: unreadCount,
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          if (w.data['approvalAccess'] == true)
            IconButton(
              tooltip: 'Persetujuan',
              onPressed: () => open(ApprovalsScreen(api: api)),
              icon: Badge(
                label: Text(
                  '${w.rows("requests").where((r) => r["canReview"] == true).length}',
                ),
                child: const Icon(Icons.fact_check_outlined),
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
                onPressed: () => open(RequestForm(api: api, workspace: w)),
                icon: const Icon(Icons.add),
                label: const Text('Buat pengajuan'),
              ),
              const SizedBox(height: 20),
              if (rows.isEmpty && mockUniversalRequests.isEmpty)
                const EmptyState('Pengajuan Anda akan tampil di sini.')
              else ...[
                ...rows.map((r) {
                  final model = UniversalRequestModel.fromMap(r);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: UniversalRequestCard(
                      data: model,
                      onDetailPressed: () => open(
                        RequestDetailScreen(
                          api: api,
                          request: r,
                          own: true,
                        ),
                      ),
                      onRevisePressed: () => open(
                        RequestForm(
                          api: api,
                          workspace: w,
                          initialKind: model.kind.displayName,
                          initialRequest: r,
                        ),
                      ),
                    ),
                  );
                }),
                ...mockUniversalRequests
                    .where((m) => !rows.any((r) => text(r, 'title') == m.title))
                    .map((mockItem) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: UniversalRequestCard(
                      data: mockItem,
                      onDetailPressed: () => open(
                        RequestDetailScreen(
                          api: api,
                          request: mockItem.toMap(),
                          own: true,
                        ),
                      ),
                      onRevisePressed: () => open(
                        RequestForm(
                          api: api,
                          workspace: w,
                          initialKind: mockItem.kind.displayName,
                          initialRequest: mockItem.toMap(),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
