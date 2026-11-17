import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import 'employee_details_modal_row.dart';

/// Kartu Informasi Rekening Payroll Karyawan
class EmployeePayrollCard extends StatelessWidget {
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final VoidCallback onCopyAccountNumber;

  const EmployeePayrollCard({
    super.key,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.onCopyAccountNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekening Payroll',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.deepTeal,
            ),
          ),
          SizedBox(height: 8.h),
          EmployeeDetailsModalRow(label: 'Nama Bank', value: bankName),
          Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
          EmployeeDetailsModalRow(
            label: 'Nomor Rekening',
            value: bankAccountNumber,
            canCopy: true,
            onCopy: onCopyAccountNumber,
          ),
          Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
          EmployeeDetailsModalRow(
            label: 'Nama Pemilik',
            value: bankAccountName,
          ),
        ],
      ),
    );
  }
}
