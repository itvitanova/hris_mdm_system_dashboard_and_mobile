import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets.dart';
import '../../../attendance/attendance_screen.dart';
import '../../../attendance/daily_attendance.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_detail.dart';
import '../../../home/leave_calendar_screen.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({
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
    final daily = DailyAttendance(w);
    final attendance = w.mine('attendance')
      ..sort((a, b) => text(b, 'date').compareTo(text(a, 'date')));
    final pending = w
        .mine('requests')
        .where((r) => r['status'] == 'Menunggu')
        .length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'MDM HR',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Kalender cuti',
            onPressed: () => open(LeaveCalendarScreen(api: api, workspace: w)),
            icon: const Icon(Icons.calendar_month_outlined),
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
              Text(
                'Semangat bekerja,',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 4),
              Text(
                text(w.actor, 'name'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${text(w.employee, 'position')} • ${text(w.employee, 'department')}',
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.deepTeal, Color(0xFF0F5B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepTeal.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          color: Color(0xFFB2EBF2),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Kehadiran hari ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (daily.completed)
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFFB2EBF2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      daily.completed
                          ? 'Sampai jumpa besok'
                          : daily.checkedIn
                          ? 'Selamat bekerja'
                          : 'Mulai hari kerja Anda',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      daily.description,
                      style: const TextStyle(color: Color(0xFFE0F7FA)),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 32,
                      runSpacing: 12,
                      children: [
                        _AttendanceTime(
                          label: 'Masuk',
                          value: timeLabel(daily.record['checkIn']),
                        ),
                        _AttendanceTime(
                          label: 'Pulang',
                          value: timeLabel(daily.record['checkOut']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.deepTeal,
                        disabledBackgroundColor: const Color(0xFF0F5B6B),
                        disabledForegroundColor: const Color(0xFFB2EBF2),
                      ),
                      onPressed: daily.completed
                          ? null
                          : () => open(AttendanceScreen(api: api, workspace: w)),
                      icon: Icon(
                        daily.completed
                            ? Icons.check_circle_outline
                            : daily.checkedIn
                            ? Icons.logout
                            : Icons.login,
                      ),
                      label: Text(daily.label, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
              if (w.data['approvalAccess'] == true)
                Panel(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.fact_check_outlined, color: AppColors.deepTeal),
                    title: const Text('Persetujuan'),
                    subtitle: Text(
                      '${w.rows("requests").where((r) => r["canReview"] == true).length} pengajuan menunggu tindakan Anda',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => open(ApprovalsScreen(api: api)),
                  ),
                ),
              Panel(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = MediaQuery.textScalerOf(context).scale(14) > 22;
                    final children = [
                      _Summary(
                        label: 'Sisa cuti',
                        value: '${number(w.employee, 'leaveBalance').toInt()} hari',
                        icon: Icons.event_available_outlined,
                      ),
                      _Summary(
                        label: 'Pengajuan menunggu',
                        value: '$pending',
                        icon: Icons.schedule_outlined,
                      ),
                    ];
                    return stacked
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [children[0], const Divider(), children[1]],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: children[0]),
                              const SizedBox(width: 16),
                              Expanded(child: children[1]),
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const SectionHeading(
                'Pengajuan cepat',
                subtitle: 'Pilih layanan yang Anda perlukan.',
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = MediaQuery.textScalerOf(context).scale(14) > 21
                      ? 1
                      : 2;
                  final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final kind in requestKinds)
                        SizedBox(
                          width: width,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: line),
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () => open(
                              RequestForm(
                                api: api,
                                initialKind: kind,
                                workspace: w,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(requestIcon(kind), color: AppColors.deepTeal, size: 24),
                                const SizedBox(height: 12),
                                Text(
                                  kind,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const SectionHeading(
                'Riwayat kehadiran',
                subtitle: 'Catatan masuk dan pulang Anda.',
              ),
              OutlinedButton.icon(
                onPressed: () => open(LeaveCalendarScreen(api: api, workspace: w)),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Kalender cuti rekan satu lokasi'),
              ),
              const SizedBox(height: 12),
              if (attendance.isEmpty)
                const Panel(child: EmptyState('Belum ada catatan kehadiran.'))
              else
                ...attendance
                    .take(15)
                    .map(
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
                                  text(r, 'date'),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                StatusPill(text(r, 'status')),
                              ],
                            ),
                            const Divider(),
                            Wrap(
                              spacing: 24,
                              runSpacing: 8,
                              children: [
                                Text('Masuk  ${timeLabel(r['checkIn'])}'),
                                Text('Pulang  ${timeLabel(r['checkOut'])}'),
                                if (r['earlyDeparture'] == true)
                                  Text(
                                    'Pulang ${number(r, 'earlyMinutes').toInt()} menit lebih awal · ${text(r, 'earlyReason')}',
                                    style: const TextStyle(color: Color(0xFFB42318)),
                                  ),
                              ],
                            ),
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

class _AttendanceTime extends StatelessWidget {
  const _AttendanceTime({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFE0F7FA))),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.deepTeal, size: 22),
      const SizedBox(height: 12),
      Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: muted)),
    ],
  );
}
