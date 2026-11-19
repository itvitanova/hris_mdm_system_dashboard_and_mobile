import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/workspace.dart';
import '../../../attendance/presentation/widgets/daily_attendance.dart';
import 'attendance/compact_attendance_action_button.dart';
import 'attendance/compact_attendance_dual_tiles.dart';
import 'attendance/compact_attendance_header.dart';
import 'language_swap_button.dart';

class CompactAttendanceCard extends StatelessWidget {
  const CompactAttendanceCard({
    super.key,
    required this.workspace,
    required this.daily,
    required this.language,
    required this.onActionPressed,
  });

  final Workspace workspace;
  final DailyAttendance daily;
  final AppLanguage language;
  final VoidCallback? onActionPressed;

  String _formatDateHeader(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;

    final isEn = language == AppLanguage.en;
    final dayNames = isEn
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = isEn
        ? const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        : const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    return '${dayNames[dt.weekday - 1]}, ${dt.day} ${monthNames[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isEn = language == AppLanguage.en;

    final todayDate = text(
      daily.record,
      'date',
      text(workspace.data, 'attendanceDate', dateOnly(DateTime.now())),
    );
    final formattedDate = _formatDateHeader(todayDate);

    final workStart = text(workspace.attendancePolicy, 'workStart', '08:30');
    final workEnd = text(workspace.attendancePolicy, 'workEnd', '17:30');
    final shiftSubtitle = '$formattedDate • $workStart - $workEnd';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D9488), // Teal 600
            Color(0xFF0F766E), // Teal 700
            Color(0xFF115E59), // Teal 800
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.25),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header
          CompactAttendanceHeader(
            isEn: isEn,
            shiftSubtitle: shiftSubtitle,
          ),
          SizedBox(height: 12.h),

          // 2. Dual Tiles (Equally Balanced via IntrinsicHeight & Stretch)
          CompactAttendanceDualTiles(
            workspace: workspace,
            daily: daily,
            isEn: isEn,
          ),
          SizedBox(height: 12.h),

          // 3. Action Button
          CompactAttendanceActionButton(
            daily: daily,
            isEn: isEn,
            onActionPressed: onActionPressed,
          ),
        ],
      ),
    );
  }
}
