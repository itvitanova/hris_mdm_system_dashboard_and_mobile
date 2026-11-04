import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet untuk konfirmasi keluar akun (logout)
/// Menampilkan drag handle, squircle red badge icon logout,
/// title "Keluar dari Akun?", alert box card peringatan sesi,
/// serta stacked button "Ya, Keluar Akun" dengan inline loading dan "Batal, Tetap Masuk".
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
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Drag Handle (#E2E8F0, w=38, h=4)
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 2. Squircle icon badge (52x52, r=16, gradient #FFE4E6->#FEE2E2, border #FECDD3, icon #E11D48)
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFE4E6),
                        Color(0xFFFEE2E2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFFECDD3),
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFE11D48),
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 14.h),

                // 3. Title 'Keluar dari Akun?' (#0F172A, 18.sp, w700)
                Text(
                  'Keluar dari Akun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 14.h),

                // 4. Alert box card (bg #FFF1F2, border #FEE2E2, circle icon #FEE2E2/#E11D48, title 'Apakah Anda yakin ingin mengakhiri sesi ini?' #991B1B 12.sp w600, subtitle 'Data sesi dan absensi Anda akan tetap aman.' #B91C1C 11.5.sp)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFFEE2E2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: const Color(0xFFE11D48),
                          size: 13.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Apakah Anda yakin ingin mengakhiri sesi ini?',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF991B1B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Data sesi dan absensi Anda akan tetap aman.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 5. Button primary 'Ya, Keluar Akun' (gradient #F43F5E->#E11D48->#BE123C, shadow #E11D48 22%, h=48, r=14, inline loading)
                Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFF43F5E),
                        Color(0xFFE11D48),
                        Color(0xFFBE123C),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _handleConfirm,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Center(
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
                                    'Ya, Keluar Akun',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Ya, Keluar Akun',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // 6. Button secondary 'Batal, Tetap Masuk' (bg #F8FAFC, border #E2E8F0, text #475569, h=48, r=14)
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Batal, Tetap Masuk',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                        letterSpacing: 0.1,
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
