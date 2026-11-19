import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import 'package:mdm_hris/core/theme/app_text_styles.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/presentation/pages/attendance_history_page.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_daily_card.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_detail_modal.dart';
import '../language_swap_button.dart';

class DashboardRecentActivitySection extends StatelessWidget {
  final Workspace workspace;
  final ApiClient api;
  final AppLanguage currentLanguage;
  final Future<void> Function(Widget) open;

  const DashboardRecentActivitySection({
    super.key,
    required this.workspace,
    required this.api,
    required this.currentLanguage,
    required this.open,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = currentLanguage == AppLanguage.en;
    final attendance = workspace.mine('attendance')
      ..sort((a, b) => text(b, 'date').compareTo(text(a, 'date')));

    final recentAttendanceRecords = attendance.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                  isEn ? 'Your activity' : 'Aktivitas Anda',
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
                      open(
                        AttendanceHistoryPage(
                          api: api,
                          workspace: workspace,
                          initialLanguage: currentLanguage,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 4.w,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isEn ? 'View all' : 'Lihat semua',
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
        if (recentAttendanceRecords.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.w),
            alignment: Alignment.center,
            child: Text(
              isEn
                  ? 'No attendance records yet.'
                  : 'Belum ada catatan kehadiran.',
              style: AppTextStyles.inter128RegularSecondary,
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < recentAttendanceRecords.length; i++) ...[
                AttendanceDailyCard(
                  key: ValueKey('dash_daily_$i'),
                  raw: Map<String, dynamic>.from(recentAttendanceRecords[i]),
                  isHighlighted: i == 0,
                  language: currentLanguage,
                  onTap: () {
                    showAttendanceDetailModal(
                      context,
                      Map<String, dynamic>.from(recentAttendanceRecords[i]),
                      language: currentLanguage,
                    );
                  },
                ),
                if (i < recentAttendanceRecords.length - 1)
                  SizedBox(height: 10.w),
              ],
            ],
          ),
      ],
    );
  }
}
