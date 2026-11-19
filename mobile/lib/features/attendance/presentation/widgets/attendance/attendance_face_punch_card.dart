import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/widgets/core_widgets.dart';
import '../daily_attendance.dart';

class AttendanceFacePunchCard extends StatelessWidget {
  const AttendanceFacePunchCard({
    super.key,
    required this.daily,
    required this.available,
    required this.canPunch,
    required this.onPunch,
  });

  final DailyAttendance daily;
  final bool available;
  final bool canPunch;
  final VoidCallback? onPunch;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            UIcons.regularRounded.user,
            size: 40,
            color: brand,
          ),
          const SizedBox(height: 18),
          const Text(
            'Cukup arahkan wajah',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Arahkan wajah ke kamera saat absensi. Sistem membandingkan dengan wajah terdaftar dan memeriksa lokasi kembali sebelum mencatat absensi.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(daily.description, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: canPunch ? onPunch : null,
            icon: daily.completed
                ? Icon(UIcons.regularRounded.check)
                : SvgPicture.asset(
                    daily.checkedIn
                        ? 'assets/icon/logout.svg'
                        : 'assets/icon/login.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
            label: Text(daily.label),
          ),
          if (!available)
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text(
                'Wajah harus terdaftar dan layanan verifikasi harus siap sebelum absensi.',
              ),
            ),
        ],
      ),
    );
  }
}
