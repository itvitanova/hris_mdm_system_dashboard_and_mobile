import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/workspace.dart';
import '../language_swap_button.dart';
import 'dashboard_stat_card.dart';

class DashboardAttendanceStatsGrid extends StatelessWidget {
  final Workspace workspace;
  final AppLanguage currentLanguage;

  const DashboardAttendanceStatsGrid({
    super.key,
    required this.workspace,
    required this.currentLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = currentLanguage == AppLanguage.en;
    final attendance = workspace.mine('attendance');

    final today = text(
      workspace.data,
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
    final belumAbsen = monthlyAttendance.where((r) {
      final s = text(r, 'status').toLowerCase();
      return s == 'alpha' ||
          s == 'tidak hadir' ||
          (text(r, 'checkIn', '').isEmpty && s.contains('absen'));
    }).length;

    return LayoutBuilder(
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
              child: DashboardStatCard(
                icon: UIcons.regularRounded.calendar_check,
                title: isEn ? 'Checked In' : 'Sudah Absen',
                subTitle: isEn ? 'this month' : 'bulan ini',
                day: '$sudahAbsen',
                unit: isEn ? 'days' : 'hari',
                description: isEn ? 'CHECKED IN' : 'SUDAH ABSEN',
              ),
            ),
            SizedBox(
              width: width,
              child: DashboardStatCard(
                icon: UIcons.regularRounded.clock,
                title: isEn ? 'On Time' : 'Tepat Waktu',
                subTitle: isEn ? 'this month' : 'bulan ini',
                day: '$tepatWaktu',
                unit: isEn ? 'days' : 'hari',
                description: isEn ? 'ON TIME' : 'TEPAT WAKTU',
              ),
            ),
            SizedBox(
              width: width,
              child: DashboardStatCard(
                icon: UIcons.regularRounded.alarm_exclamation,
                title: isEn ? 'Late' : 'Terlambat',
                subTitle: isEn ? 'this month' : 'bulan ini',
                day: '$terlambat',
                unit: isEn ? 'days' : 'hari',
                description: isEn ? 'LATE' : 'TERLAMBAT',
              ),
            ),
            SizedBox(
              width: width,
              child: DashboardStatCard(
                icon: UIcons.regularRounded.calendar_minus,
                title: isEn ? 'Absent' : 'Belum Absen',
                subTitle: isEn ? 'this month' : 'bulan ini',
                day: '$belumAbsen',
                unit: isEn ? 'days' : 'hari',
                description: isEn ? 'ABSENT' : 'BELUM ABSEN',
              ),
            ),
          ],
        );
      },
    );
  }
}
