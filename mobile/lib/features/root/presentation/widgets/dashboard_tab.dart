import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../attendance/attendance_screen.dart';
import '../../../attendance/daily_attendance.dart';
import '../../../requests/request_notifications.dart';
import 'dashboard_attendance_card.dart';
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

  Widget _buildAvatar(String name) {
    final initials = _getInitials(name);
    final size = 52.w;

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
              borderRadius: BorderRadius.circular(14.r),
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
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Positioned(
            right: -1.w,
            bottom: -1.w,
            child: Container(
              key: const Key('dashboard_avatar_online_dot'),
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                color: const Color(0xFF00AA13),
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

  Widget _buildGreetingAndName(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Selamat Datang 👋',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: 3.w),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.deepTeal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    final hasUnread = w.mine('requests').any((r) => r['unread'] == true);

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('dashboard_notification_button'),
          borderRadius: BorderRadius.circular(13.r),
          onTap: () => open(
            RequestNotificationsScreen(api: api, workspace: w),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 20.w,
                color: const Color(0xFF0F172A),
              ),
              if (hasUnread)
                Positioned(
                  top: 8.w,
                  right: 8.w,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
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
        LanguageSwapButton(
          initialLanguage: _currentLanguage,
          onLanguageChanged: (lang) {
            setState(() {
              _currentLanguage = lang;
            });
          },
        ),
        SizedBox(width: 8.w),
        _buildNotificationButton(),
      ],
    );

    if (isLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatar(userName),
              actions,
            ],
          ),
          SizedBox(height: 8.w),
          _buildGreetingAndName(userName),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildAvatar(userName),
              SizedBox(width: 14.w),
              Expanded(child: _buildGreetingAndName(userName)),
            ],
          ),
        ),
        SizedBox(width: 8.w),
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

    final dateWidget = Text(
      _getFormattedDate(DateTime.now(), _currentLanguage),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 9.6.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF334155),
      ),
    );

    final badge = Container(
      height: 26.w,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 4.w,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x200F766E),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ADE80).withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              positionText,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );

    final isLargeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    if (isLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dateWidget,
          SizedBox(height: 8.w),
          badge,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: dateWidget),
        SizedBox(width: 8.w),
        Flexible(child: badge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final daily = DailyAttendance(w);
    final attendance = w.mine('attendance')
      ..sort((a, b) => text(b, 'date').compareTo(text(a, 'date')));

    final today = text(
      w.data,
      'attendanceDate',
      dateOnly(DateTime.now()),
    );
    final currentMonthPrefix = today.length >= 7
        ? today.substring(0, 7)
        : dateOnly(DateTime.now()).substring(0, 7);

    final monthlyAttendance = attendance.where((r) {
      final d = text(r, 'date');
      return d.startsWith(currentMonthPrefix);
    }).toList();

    final sudahAbsen = monthlyAttendance
        .where((r) => text(r, 'checkIn', '').isNotEmpty)
        .length;
    final tepatWaktu = monthlyAttendance
        .where((r) =>
            text(r, 'checkIn', '').isNotEmpty &&
            text(r, 'status') != 'Terlambat' &&
            number(r, 'lateMinutes') == 0)
        .length;
    final terlambat = monthlyAttendance
        .where((r) =>
            text(r, 'status') == 'Terlambat' || number(r, 'lateMinutes') > 0)
        .length;
    final totalAbsen = monthlyAttendance
        .where((r) {
          final s = text(r, 'status').toLowerCase();
          return s == 'alpha' ||
              s == 'tidak hadir' ||
              (text(r, 'checkIn', '').isEmpty && s.contains('absen'));
        })
        .length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _buildHeaderTop(context),
              SizedBox(height: 22.w),
              _buildSubHeader(context),
              SizedBox(height: 17.w),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.filterGradientStart,
                      AppColors.filterGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.filterGradientStart.withValues(alpha: 0.25),
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
                        foregroundColor: AppColors.filterGradientStart,
                        disabledBackgroundColor: const Color(0xFF0F766E),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      MediaQuery.textScalerOf(context).scale(14) > 21 ? 1 : 2;
                  final spacing = 12.w;
                  final width =
                      (constraints.maxWidth - (columns - 1) * spacing) / columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: width,
                        child: _AttendanceStatCard(
                          icon: UIcons.regularRounded.calendar_check,
                          title: 'Sudah Absen',
                          subTitle: 'bulan ini',
                          day: '$sudahAbsen',
                          description: 'SUDAH ABSEN',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _AttendanceStatCard(
                          icon: UIcons.regularRounded.clock,
                          title: 'Tepat Waktu',
                          subTitle: 'bulan ini',
                          day: '$tepatWaktu',
                          description: 'TEPAT WAKTU',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _AttendanceStatCard(
                          icon: UIcons.regularRounded.alarm_exclamation,
                          title: 'Terlambat',
                          subTitle: 'bulan ini',
                          day: '$terlambat',
                          description: 'TERLAMBAT',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _AttendanceStatCard(
                          icon: UIcons.regularRounded.calendar_minus,
                          title: 'Total Absen',
                          subTitle: 'bulan ini',
                          day: '$totalAbsen',
                          description: 'TIDAK HADIR',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: const [AppShadows.shadow094],
                  color: AppColors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Your activity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.inter14MediumPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 96.w,
                      constraints: BoxConstraints(minHeight: 27.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0F766E),
                            Color(0xFF14B8A6),
                          ],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5.w),
                          canRequestFocus: false,
                          onTap: () {
                            // Button show all tanpa redirect dulu sesuai permintaan
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 4.w,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'View all',
                                maxLines: 1,
                                style: AppTextStyles.inter12MediumWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 17.w),
              Builder(
                builder: (context) {
                  final recentAttendanceItems =
                      DashboardAttendanceItem.fromAttendanceList(
                    attendance,
                    limit: 2,
                    language: _currentLanguage,
                  );

                  if (recentAttendanceItems.isEmpty) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 24.w),
                      alignment: Alignment.center,
                      child: Text(
                        'Belum ada catatan kehadiran.',
                        style: AppTextStyles.inter128RegularSecondary,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (int i = 0; i < recentAttendanceItems.length; i++) ...[
                        DashboardAttendanceCard(
                          key: ValueKey('dash_$i'),
                          item: recentAttendanceItems[i],
                          onTap: () {},
                        ),
                        if (i < recentAttendanceItems.length - 1)
                          SizedBox(height: 10.w),
                      ],
                    ],
                  );
                },
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

class _AttendanceStatCard extends StatelessWidget {
  const _AttendanceStatCard({
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.day,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String subTitle;
  final String day;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 14.w,
        left: 14.w,
        right: 12.w,
        bottom: 14.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        boxShadow: const [AppShadows.shadow094],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(7.w),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 16.w,
                  color: AppColors.filterGradientStart,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$day hari',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.w),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
