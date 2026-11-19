import 'package:flutter/material.dart';
import '../custom_date_picker_dialog.dart';
import '../custom_duration_picker_dialog.dart';

/// Formats DateTime to Indonesian short date string (e.g. "17 Nov 2026")
String formatDisplayDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Helper to pick start or end date with standard constraints
Future<DateTime?> pickRequestDate(
  BuildContext context, {
  required DateTime initial,
  required bool isStart,
}) async {
  final first = isStart ? (initial.isBefore(DateTime(2020)) ? initial : DateTime(2020)) : initial;
  return showCustomDatePickerDialog(
    context: context,
    initialDate: initial.isBefore(first) ? first : initial,
    firstDate: first,
    lastDate: DateTime(2035),
    title: isStart ? 'PILIH TANGGAL MULAI' : 'PILIH TANGGAL SELESAI',
  );
}

/// Helper to pick expense receipt date (cannot be in future)
Future<DateTime?> pickExpenseTransactionDate(
  BuildContext context, {
  required DateTime initial,
}) async {
  final now = DateTime.now();
  return showCustomDatePickerDialog(
    context: context,
    initialDate: initial.isAfter(now) ? now : initial,
    firstDate: DateTime(2020),
    lastDate: now,
    title: 'PILIH TANGGAL TRANSAKSI',
  );
}

/// Helper to pick overtime duration in hours
Future<int?> pickOvertimeHours(
  BuildContext context, {
  required int currentHours,
}) async {
  return showCustomDurationPickerDialog(context: context, initialHours: currentHours);
}
