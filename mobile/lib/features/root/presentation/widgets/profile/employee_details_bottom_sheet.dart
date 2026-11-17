import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/theme/app_colors.dart';
import 'employee_details_close_button.dart';
import 'employee_details_header.dart';
import 'employee_employment_card.dart';
import 'employee_payroll_card.dart';

/// Modal Bottom Sheet untuk Detail Informasi Lengkap Karyawan
class EmployeeDetailsBottomSheet {
  static void show({
    required BuildContext context,
    required String empId,
    required String nik,
    required String employmentType,
    required String ptkp,
    required String phone,
    required String address,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    required bool isFaceEnrolled,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmployeeDetailsHeader(),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
                  child: Column(
                    children: [
                      EmployeeEmploymentCard(
                        nik: nik,
                        employmentType: employmentType,
                        ptkp: ptkp,
                        address: address,
                        isFaceEnrolled: isFaceEnrolled,
                        onCopyNik: () => _copyToClipboard(ctx, nik, 'NIK'),
                      ),
                      SizedBox(height: 14.h),
                      EmployeePayrollCard(
                        bankName: bankName,
                        bankAccountNumber: bankAccountNumber,
                        bankAccountName: bankAccountName,
                        onCopyAccountNumber: () => _copyToClipboard(
                            ctx, bankAccountNumber, 'Nomor Rekening'),
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFCCFBF1)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              UIcons.regularRounded.info,
                              size: 16.sp,
                              color: AppColors.deepTeal,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Pembaruan data kepegawaian & payroll dapat diajukan melalui tim HRD.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.sp,
                                  color: const Color(0xFF0F766E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              EmployeeDetailsCloseButton(
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _copyToClipboard(
      BuildContext context, String val, String label) {
    if (val.isEmpty || val == '—' || val == 'Belum diisi') return;
    Clipboard.setData(ClipboardData(text: val));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke papan klip'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
