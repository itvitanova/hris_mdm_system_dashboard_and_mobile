import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';

/// Card showing employee's destination bank account for reimbursement disbursements
class RequestReimbursementAccountCard extends StatelessWidget {
  final Workspace? workspace;

  const RequestReimbursementAccountCard({super.key, this.workspace});

  @override
  Widget build(BuildContext context) {
    final emp = workspace?.employee ?? {};
    final bank = text(emp, 'bankName', 'BCA');
    final account = text(emp, 'bankAccount', '123-456-7890');
    final holder = text(emp, 'bankHolder', text(workspace?.actor ?? {}, 'name', 'Karyawan'));

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(UIcons.regularRounded.wallet, size: 18.sp, color: const Color(0xFF0F172A)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekening Pencairan Reimbursement',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$bank - $account a.n. $holder',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Pastikan rekening aktif untuk pencairan otomatis via Finance.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
