import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// App Bar for Request Notifications Screen with two-line title and Mark All Read action
class NotificationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotificationsAppBar({
    super.key,
    required this.unreadCount,
    required this.isMarkingAsRead,
    required this.onBack,
    required this.onMarkAllAsRead,
  });

  final int unreadCount;
  final bool isMarkingAsRead;
  final VoidCallback onBack;
  final VoidCallback onMarkAllAsRead;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canMarkRead = unreadCount > 0 && !isMarkingAsRead;

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.4,
      shadowColor: const Color(0x120F172A),
      titleSpacing: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          UIcons.regularRounded.angle_small_left,
          color: const Color(0xFF0F172A),
          size: 20,
        ),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Notifikasi Pengajuan',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Pembaruan Status & Keputusan',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: Material(
            color: unreadCount > 0
                ? const Color(0xFFF0FDFA)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              key: const Key('notif_mark_all_read_btn'),
              onTap: canMarkRead ? onMarkAllAsRead : null,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: unreadCount > 0
                        ? const Color(0xFFCCFBF1)
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      UIcons.regularRounded.check,
                      size: 14.sp,
                      color: unreadCount > 0
                          ? const Color(0xFF0F766E)
                          : const Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Tandai Dibaca',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: unreadCount > 0
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
