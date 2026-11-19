import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Custom AppBar untuk Tab Pengajuan (RequestsTab)
class RequestsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEn;
  final int unreadCount;
  final VoidCallback onCalendarTap;
  final VoidCallback onNotificationTap;

  const RequestsAppBar({
    super.key,
    required this.isEn,
    required this.unreadCount,
    required this.onCalendarTap,
    required this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.4,
      shadowColor: const Color(0x120F172A),
      titleSpacing: 20,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEn ? 'Submissions' : 'Pengajuan',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1.5),
          Text(
            isEn
                ? 'Self-Service & Employee Requests'
                : 'Layanan & Permohonan Mandiri',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
      actions: [
        // 1. Kalender Ulang Tahun
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('requests_calendar_button'),
              borderRadius: BorderRadius.circular(11.r),
              onTap: onCalendarTap,
              child: Icon(
                UIcons.regularRounded.calendar,
                size: 16.w,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // 2. Notifikasi Pengajuan dengan Red Dot Indicator
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('requests_notification_button'),
              borderRadius: BorderRadius.circular(11.r),
              onTap: onNotificationTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    UIcons.regularRounded.bell,
                    size: 16.w,
                    color: const Color(0xFF334155),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 7.h,
                      right: 7.w,
                      child: Container(
                        width: 7.5.w,
                        height: 7.5.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFED2736),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
      ],
    );
  }
}
