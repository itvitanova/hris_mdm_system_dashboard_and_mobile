import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../domain/entities/submission_kind.dart';

/// App bar for dedicated module screen with localized title, subtitle, and actions
class ModuleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ModuleAppBar({
    super.key,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.unreadCount,
    required this.onBack,
    required this.onOpenNotifications,
    this.onOpenCalendar,
    this.customActions,
  });

  final SubmissionKind kind;
  final String title;
  final String subtitle;
  final int unreadCount;
  final VoidCallback onBack;
  final VoidCallback onOpenNotifications;
  final VoidCallback? onOpenCalendar;
  final List<Widget>? customActions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.4,
      shadowColor: const Color(0x120F172A),
      leading: IconButton(
        icon: Icon(
          UIcons.regularRounded.angle_small_left,
          color: const Color(0xFF0F172A),
          size: 20,
        ),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 1.5),
          Text(
            subtitle,
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
        if (kind == SubmissionKind.cuti && onOpenCalendar != null) ...[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(11),
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
                key: const Key('dedicated_calendar_button'),
                borderRadius: BorderRadius.circular(11),
                onTap: onOpenCalendar,
                child: Icon(
                  UIcons.regularRounded.calendar,
                  size: 19,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(11),
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
              borderRadius: BorderRadius.circular(11),
              onTap: onOpenNotifications,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    UIcons.regularRounded.bell,
                    size: 19,
                    color: const Color(0xFF334155),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 7.5,
                        height: 7.5,
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
        ...?customActions,
        const SizedBox(width: 16),
      ],
    );
  }
}
