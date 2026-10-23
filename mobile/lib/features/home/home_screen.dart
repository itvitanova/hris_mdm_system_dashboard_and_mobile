import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/workspace.dart';
import '../../shared/widgets.dart';
import '../attendance/attendance_screen.dart';
import '../attendance/daily_attendance.dart';
import '../auth/change_password_screen.dart';
import '../requests/request_form.dart';
import '../payroll/payslip_screen.dart';

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
    refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
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
    if (mounted && (changed == true || screen is AttendanceScreen)) {
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
          tooltip: 'Segarkan data',
          onPressed: widget.onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: switch (tab) {
          0 => dashboard(),
          1 => requests(),
          2 => payroll(),
          _ => profile(),
        },
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          label: 'Pengajuan',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Slip gaji',
        ),
        NavigationDestination(
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
      Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semangat bekerja,',
              style: TextStyle(color: Color(0xFFDBEAFE)),
            ),
            const SizedBox(height: 6),
            Text(
              text(w.actor, 'name'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${text(w.employee, 'position')} • ${text(w.employee, 'department')}',
              style: const TextStyle(color: Color(0xFFDBEAFE)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: brand,
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
              label: Text(daily.label),
            ),
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.beach_access_outlined, color: brand),
                  const SizedBox(height: 12),
                  Text(
                    '${number(w.employee, 'leaveBalance').toInt()} hari',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Sisa cuti',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule, color: brand),
                  const SizedBox(height: 12),
                  Text(
                    '$pending',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Menunggu',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Pengajuan cepat',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: requestKinds
            .map(
              (kind) => ActionChip(
                avatar: Icon(
                  kind == 'Lembur'
                      ? Icons.more_time
                      : kind == 'Cuti'
                      ? Icons.event_available
                      : Icons.note_add_outlined,
                  size: 18,
                  color: brand,
                ),
                label: Text(kind),
                onPressed: () =>
                    open(RequestForm(api: widget.api, initialKind: kind)),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 28),
      const Text(
        'Riwayat kehadiran',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 14),
      if (attendance.isEmpty)
        const EmptyState('Belum ada catatan kehadiran.')
      else
        ...attendance
            .take(15)
            .map(
              (r) => Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            text(r, 'date'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        StatusPill(text(r, 'status')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Masuk  ${timeLabel(r['checkIn'])}'),
                        ),
                        Expanded(
                          child: Text(
                            'Pulang  ${timeLabel(r['checkOut'])}',
                            textAlign: TextAlign.right,
                          ),
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
      FilledButton.icon(
        onPressed: () => open(RequestForm(api: widget.api)),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        text(r, 'kind'),
                        style: const TextStyle(
                          color: brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusPill(text(r, 'status')),
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
                Text(text(r, 'description')),
                const SizedBox(height: 12),
                Text(
                  '${text(r, 'startDate')} → ${text(r, 'endDate')}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                if (number(r, 'amount') > 0)
                  DetailLine('Nominal', rupiah(number(r, 'amount'))),
                if (r['kind'] == 'Lembur')
                  DetailLine('Durasi', '${number(r, 'hours')} jam'),
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
      const Text(
        'Rincian pendapatan dan potongan Anda.',
        style: TextStyle(color: Color(0xFF64748B)),
      ),
      const SizedBox(height: 20),
      if (rows.isEmpty)
        const EmptyState('Slip gaji belum tersedia.')
      else
        ...rows.map(
          (r) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      text(r, 'period'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          DetailLine('ID karyawan', text(w.employee, 'id')),
          DetailLine('Departemen', text(w.employee, 'department')),
          DetailLine('Jabatan', text(w.employee, 'position')),
          DetailLine('Telepon', text(w.employee, 'phone')),
          DetailLine('Alamat', text(w.employee, 'address')),
          DetailLine('Status PTKP', text(w.employee, 'ptkp')),
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
        style: TextStyle(color: Color(0xFF64748B)),
      ),
    ),
    OutlinedButton.icon(
      onPressed: loggingOut ? null : logout,
      icon: const Icon(Icons.logout),
      label: Text(loggingOut ? 'Keluar…' : 'Keluar akun'),
    ),
  ];
}
