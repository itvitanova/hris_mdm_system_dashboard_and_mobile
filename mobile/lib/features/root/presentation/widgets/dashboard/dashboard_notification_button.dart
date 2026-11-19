import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_notifications_page.dart';

class DashboardNotificationButton extends StatelessWidget {
  final Workspace workspace;
  final ApiClient api;
  final Future<void> Function(Widget) open;

  const DashboardNotificationButton({
    super.key,
    required this.workspace,
    required this.api,
    required this.open,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread =
        workspace.mine('requests').any((r) => r['unread'] == true);

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
            RequestNotificationsScreen(api: api, workspace: workspace),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                UIcons.regularStraight.bell,
                size: 16.w,
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
}
