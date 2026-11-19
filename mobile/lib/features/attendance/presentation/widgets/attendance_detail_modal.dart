import 'package:flutter/material.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';
import 'detail/attendance_detail_sheet.dart';

/// Membuka Modal Detail Kehadiran lengkap dengan informasi verifikasi MDM,
/// peta koordinat, kebijakan lokasi penugasan, dan status kepulangan.
void showAttendanceDetailModal(
  BuildContext context,
  Map<String, dynamic> raw, {
  AppLanguage? language,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AttendanceDetailSheet(raw: raw, language: language),
  );
}
