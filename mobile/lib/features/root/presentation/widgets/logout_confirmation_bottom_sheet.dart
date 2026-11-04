import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Modal bottom sheet untuk konfirmasi keluar akun (logout)
/// Menampilkan drag handle, circular red badge icon logout,
/// title "Konfirmasi Keluar", teks peringatan, serta stacked button
/// "Ya, Keluar" dengan inline loading dan "Batal".
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
          color: Colors.white,
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
                // 1. Drag Handle
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // 2. Circular Red Badge Icon Logout
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFEF4444),
                    size: 26.sp,
                  ),
                ),
                SizedBox(height: 16.h),

                // 3. Title "Konfirmasi Keluar"
                Text(
                  'Konfirmasi Keluar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),

                // 4. Warning Text
                Text(
                  'Apakah Anda yakin ingin keluar dari akun ini? Anda harus memasukkan kredensial kembali untuk masuk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 24.h),

                // 5. Stacked Buttons: "Ya, Keluar" & "Batal"
                // Tombol "Ya, Keluar" dengan inline loading
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      disabledBackgroundColor:
                          const Color(0xFFEF4444).withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Ya, Keluar',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Ya, Keluar',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Tombol "Batal"
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
