import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../shared/widgets.dart';
import '../../../attendance/attendance_screen.dart';
import '../../../attendance/daily_attendance.dart';
import '../../../requests/request_form.dart';
import '../../../requests/request_notifications.dart';
import '../../../home/leave_calendar_screen.dart';
import 'language_swap_button.dart';

class DashboardTab extends StatefulWidget {
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

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  AppLanguage _currentLanguage = AppLanguage.id;

  ApiClient get api => widget.api;
  Workspace get w => widget.workspace;
  Future<void> Function(Widget) get open => widget.open;

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'HR';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  Widget _buildAvatar(String name, {bool isOnline = true}) {
    final initials = _getInitials(name);
    const size = 44.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.filterGradientStart,
                  AppColors.filterGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.filterGradientStart.withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              key: const Key('dashboard_avatar_online_dot'),
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFF00AA13)
                    : const Color(0xFFED2736),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour, AppLanguage lang) {
    if (lang == AppLanguage.en) {
      if (hour >= 5 && hour < 12) return 'Good Morning,';
      if (hour >= 12 && hour < 17) return 'Good Afternoon,';
      if (hour >= 17 && hour < 21) return 'Good Evening,';
      return 'Good Night,';
    } else if (lang == AppLanguage.zh) {
      if (hour >= 5 && hour < 12) return '早上好，';
      if (hour >= 12 && hour < 18) return '下午好，';
      return '晚上好，';
    } else {
      if (hour >= 5 && hour < 11) return 'Selamat Pagi,';
      if (hour >= 11 && hour < 15) return 'Selamat Siang,';
      if (hour >= 15 && hour < 18) return 'Selamat Sore,';
      return 'Selamat Malam,';
    }
  }

  Widget _buildGreetingAndName(String name, AppLanguage lang) {
    final hour = DateTime.now().hour;
    final greeting = _getGreeting(hour, lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.deepTeal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final hasUnread = w.mine('requests').any((r) => r['unread'] == true);

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('dashboard_notification_button'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => open(
            RequestNotificationsScreen(api: api, workspace: w),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: Color(0xFF0F172A),
              ),
              if (hasUnread)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFED2736),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTop(BuildContext context) {
    final userName = text(w.actor, 'name');
    final isLargeText = MediaQuery.textScalerOf(context).scale(14) > 22;

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: LanguageSwapButton(
            initialLanguage: _currentLanguage,
            onLanguageChanged: (lang) {
              setState(() {
                _currentLanguage = lang;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        _buildNotificationButton(context),
      ],
    );

    if (isLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatar(userName, isOnline: true),
              actions,
            ],
          ),
          const SizedBox(height: 8),
          _buildGreetingAndName(userName, _currentLanguage),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildAvatar(userName, isOnline: true),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGreetingAndName(userName, _currentLanguage),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        actions,
      ],
    );
  }

  String _getFormattedDate(DateTime date, AppLanguage lang) {
    if (lang == AppLanguage.en) {
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];
      return '$dayName, ${date.day} $monthName ${date.year}';
    } else if (lang == AppLanguage.zh) {
      const days = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      final dayName = days[date.weekday - 1];
      return '${date.year}年${date.month}月${date.day}日 $dayName';
    } else {
      const days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];
      return '$dayName, ${date.day} $monthName ${date.year}';
    }
  }

  Widget _buildSubHeader(BuildContext context) {
    final position = text(w.employee, 'position');
    final department = text(w.employee, 'department');
    final positionText = department != '—' && department.isNotEmpty
        ? '$position • $department'
        : position;
    final isLargeText = MediaQuery.textScalerOf(context).scale(14) > 20;

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x200F766E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x994ADE80),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: Text(
                positionText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final dateWidget = Text(
      _getFormattedDate(DateTime.now(), _currentLanguage),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
    );

    if (isLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dateWidget,
          const SizedBox(height: 6),
          badge,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: dateWidget),
        const SizedBox(width: 8),
        Flexible(child: badge),
      ],
    );
  }

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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _buildHeaderTop(context),
              const SizedBox(height: 8),
              _buildSubHeader(context),
              const SizedBox(height: 12),
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
                      icon: const Icon(Icons.login),
                      label: Text(daily.label),
                    ),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 320;
                  final children = [
                    Panel(
                      child: _Summary(
                        label: 'Sisa cuti',
                        value:
                            '${number(w.employee, 'leaveBalance').toInt()} hari',
                        icon: Icons.beach_access_outlined,
                      ),
                    ),
                    Panel(
                      child: _Summary(
                        label: 'Pengajuan menunggu',
                        value: '$pending',
                        icon: Icons.hourglass_top_outlined,
                      ),
                    ),
                  ];
                  return stacked
                      ? Column(
                          children: [
                            children[0],
                            const SizedBox(height: 12),
                            children[1],
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: children[0]),
                            const SizedBox(width: 16),
                            Expanded(child: children[1]),
                          ],
                        );
                },
              ),
              const SizedBox(height: 12),
              const SectionHeading(
                'Pengajuan cepat',
                subtitle: 'Pilih layanan yang Anda perlukan.',
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      MediaQuery.textScalerOf(context).scale(14) > 21 ? 1 : 2;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
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
                                Icon(
                                  requestIcon(kind),
                                  color: AppColors.deepTeal,
                                  size: 24,
                                ),
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
                    open(LeaveCalendarScreen(api: api, workspace: w)),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                    style: const TextStyle(
                                      color: Color(0xFFB42318),
                                    ),
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
