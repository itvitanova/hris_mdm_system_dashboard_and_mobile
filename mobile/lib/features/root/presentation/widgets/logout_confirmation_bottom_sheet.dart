import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'logout/logout_action_buttons.dart';
import 'logout/logout_sheet_header.dart';
import 'logout/logout_warning_alert_box.dart';

/// Modal bottom sheet untuk konfirmasi keluar akun (logout)
class LogoutConfirmationBottomSheet extends StatefulWidget {
  const LogoutConfirmationBottomSheet({
    super.key,
    required this.onConfirmLogout,
  });

  final Future<void> Function() onConfirmLogout;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onConfirmLogout,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => LogoutConfirmationBottomSheet(
        onConfirmLogout: onConfirmLogout,
      ),
    );
  }

  @override
  State<LogoutConfirmationBottomSheet> createState() =>
      _LogoutConfirmationBottomSheetState();
}

class _LogoutConfirmationBottomSheetState
    extends State<LogoutConfirmationBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onConfirmLogout();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoutSheetHeader(),
                SizedBox(height: 14.h),
                const LogoutWarningAlertBox(),
                SizedBox(height: 20.h),
                LogoutActionButtons(
                  isLoading: _isLoading,
                  onCancel: () => Navigator.of(context).pop(),
                  onConfirm: _handleConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
