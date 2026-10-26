import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../../../attendance/presentation/widgets/daily_attendance.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../requests/presentation/pages/request_form_page.dart';
import '../../../requests/presentation/pages/request_detail_page.dart';
import '../../../payroll/presentation/pages/payslip_page.dart';
import 'leave_calendar_page.dart';
import '../../../requests/presentation/pages/request_notifications_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.onLogout,
  });
  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int tab = 0;
  bool loggingOut = false;
  bool refreshing = false;
  Timer? refreshTimer;
  Workspace get w => widget.workspace;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh the server's company date even if the app stays open overnight.
    refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(refreshVisible());
      }
    });
  }

  Future<void> refreshVisible() async {
    if (!mounted ||
        refreshing ||
        loggingOut ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    refreshing = true;
    try {
      await widget.onRefresh();
    } finally {
      refreshing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refreshVisible());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> open(Widget screen) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted &&
        (changed == true ||
            screen is AttendanceScreen ||
            screen is ApprovalsScreen ||
            screen is RequestDetailScreen ||
            screen is RequestNotificationsScreen)) {
      await widget.onRefresh();
    }
  }

  Future<void> logout() async {
    setState(() => loggingOut = true);
    try {
      await widget.api.logout();
      if (mounted) widget.onLogout();
    } catch (e) {
      if (mounted) notify(context, e);
    } finally {
      if (mounted) setState(() => loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        ['MDM HR', 'Pengajuan', 'Slip gaji', 'Profil saya'][tab],
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          tooltip: 'Kalender cuti',
          onPressed: () =>
              open(LeaveCalendarScreen(api: widget.api, workspace: w)),
          icon: const Icon(Icons.calendar_month_outlined),
        ),
        IconButton(
          tooltip: 'Notifikasi pengajuan',
          onPressed: () =>
              open(RequestNotificationsScreen(api: widget.api, workspace: w)),
          icon: Badge.count(
            count: w.mine('requests').where((r) => r['unread'] == true).length,
            isLabelVisible: w.mine('requests').any((r) => r['unread'] == true),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
        if (w.data['approvalAccess'] == true)
          IconButton(
            tooltip: 'Persetujuan',
            onPressed: () => open(ApprovalsScreen(api: widget.api)),
            icon: Badge(
              label: Text(
                '${w.rows("requests").where((r) => r["canReview"] == true).length}',
              ),
              child: const Icon(Icons.fact_check_outlined),
            ),
          ),
        IconButton(
          tooltip: 'Segarkan data',
          onPressed: widget.onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: switch (tab) {
            0 => dashboard(),
            1 => requests(),
            2 => payroll(),
            _ => profile(),
          },
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Badge.count(
            count: w.mine('requests').where((r) => r['unread'] == true).length,
            isLabelVisible: w.mine('requests').any((r) => r['unread'] == true),
            child: const Icon(Icons.assignment_outlined),
          ),
          label: 'Pengajuan',
        ),
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Slip gaji',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    ),
  );
  List<Widget> dashboard() {
    final daily = DailyAttendance(w);
    final attendance = w.mine('attendance')
      ..sort((a, b) => text(b, 'date').compareTo(text(a, 'date')));
    final pending = w
        .mine('requests')
        .where((r) => r['status'] == 'Menunggu')
        .length;
    return [
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
          color: ink,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  color: Color(0xFFB7CEFF),
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
                    color: Color(0xFFB7CEFF),
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
              style: const TextStyle(color: Color(0xFFD1DEF1)),
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
                foregroundColor: brand,
                disabledBackgroundColor: const Color(0xFF314766),
                disabledForegroundColor: const Color(0xFFD1DEF1),
              ),
              onPressed: daily.completed
                  ? null
                  : () => open(AttendanceScreen(api: widget.api, workspace: w)),
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
            leading: const Icon(Icons.fact_check_outlined, color: brand),
            title: const Text('Persetujuan'),
            subtitle: Text(
              '${w.rows("requests").where((r) => r["canReview"] == true).length} pengajuan menunggu tindakan Anda',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => open(ApprovalsScreen(api: widget.api)),
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
                        api: widget.api,
                        initialKind: kind,
                        workspace: w,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(requestIcon(kind), color: brand, size: 24),
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
        onPressed: () =>
            open(LeaveCalendarScreen(api: widget.api, workspace: w)),
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
    ];
  }

  List<Widget> requests() {
    final rows = w.mine('requests');
    return [
      const SectionHeading(
        'Pengajuan Anda',
        subtitle: 'Pantau persetujuan, revisi, dan dokumen Anda.',
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => open(RequestForm(api: widget.api, workspace: w)),
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
                        color: brand,
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
                        color: brand,
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
                    RequestDetailScreen(api: widget.api, request: r, own: true),
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
    ];
  }

  List<Widget> payroll() {
    final rows = w.mine('payroll')
      ..sort((a, b) => text(b, 'period').compareTo(text(a, 'period')));
    return [
      const SectionHeading(
        'Pendapatan Anda',
        subtitle: 'Rincian pendapatan dan potongan per periode.',
      ),
      const SizedBox(height: 20),
      if (rows.isEmpty)
        const EmptyState('Slip gaji belum tersedia.')
      else
        ...rows.map(
          (r) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    text(r, 'period'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  StatusPill(text(r, 'status')),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  rupiah(number(r, 'netSalary')),
                  style: const TextStyle(
                    color: brand,
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => open(PayslipScreen(api: widget.api, slip: r)),
            ),
          ),
        ),
    ];
  }

  List<Widget> profile() => [
    Panel(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFDBEAFE),
            child: Icon(Icons.person_outline, color: brand, size: 38),
          ),
          const SizedBox(height: 16),
          Text(
            text(w.actor, 'name'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            text(w.actor, 'email'),
            style: const TextStyle(color: Color(0xFF52637A)),
          ),
          const SizedBox(height: 20),
          DetailLine('ID karyawan', text(w.employee, 'id')),
          DetailLine('Departemen', text(w.employee, 'department')),
          DetailLine('Jabatan', text(w.employee, 'position')),
          DetailLine('Telepon', text(w.employee, 'phone')),
          DetailLine('Bank', text(w.employee, 'bankName')),
          DetailLine('Pemilik rekening', text(w.employee, 'bankAccountName')),
          DetailLine('Nomor rekening', text(w.employee, 'bankAccountNumber')),
          DetailLine('Alamat', text(w.employee, 'address')),
          DetailLine('Status PTKP', text(w.employee, 'ptkp')),
          DetailLine('NIK', text(w.employee, 'employeeNumber', 'Belum diisi')),
          DetailLine(
            'Hubungan kerja',
            text(w.employee, 'employmentType', 'Belum diisi'),
          ),
          DetailLine(
            'Pendaftaran wajah',
            w.employee['faceEnrolled'] == true
                ? 'Terdaftar'
                : 'Belum terdaftar',
          ),
        ],
      ),
    ),
    const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        'Hubungi HR untuk memperbarui data pribadi.',
        style: TextStyle(color: Color(0xFF52637A)),
      ),
    ),
    OutlinedButton.icon(
      onPressed: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(api: widget.api),
          ),
        );
        if (changed == true && mounted) widget.onLogout();
      },
      icon: const Icon(Icons.lock_outline),
      label: const Text('Ganti password'),
    ),
    const SizedBox(height: 16),
    OutlinedButton.icon(
      onPressed: loggingOut ? null : logout,
      icon: const Icon(Icons.logout),
      label: Text(loggingOut ? 'Keluar…' : 'Keluar akun'),
    ),
  ];
}

class _AttendanceTime extends StatelessWidget {
  const _AttendanceTime({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFD1DEF1))),
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
      Icon(icon, color: brand, size: 22),
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

typedef HomePage = HomeScreen;
