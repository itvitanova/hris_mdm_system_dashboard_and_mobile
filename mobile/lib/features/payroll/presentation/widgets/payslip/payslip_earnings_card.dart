import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:uicons/uicons.dart';
import 'payslip_detail_row.dart';

/// Card displaying earnings components (pendapatan kotor) on payslip
class PayslipEarningsCard extends StatelessWidget {
  const PayslipEarningsCard({
    super.key,
    required this.slip,
    required this.isV2,
  });

  final Json slip;
  final bool isV2;

  @override
  Widget build(BuildContext context) {
    final baseSalary = number(slip, 'baseSalary');
    final allowance = number(slip, 'allowance');
    final overtime = number(slip, 'overtime');
    final bonus = number(slip, 'bonus');
    final reimbursement = number(slip, 'reimbursement');
    final grossSalary = isV2
        ? number(slip, 'grossSalary')
        : baseSalary + overtime + reimbursement;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: Icon(
                  UIcons.regularRounded.arrow_trend_up,
                  size: 17,
                  color: const Color(0xFF16A34A),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Komponen Pendapatan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 0.8),
                ),
                child: Text(
                  'Penambahan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          PayslipDetailRow(label: 'Gaji Pokok', value: rupiah(baseSalary)),
          if (isV2) PayslipDetailRow(label: 'Tunjangan', value: rupiah(allowance)),
          PayslipDetailRow(label: 'Lembur', value: rupiah(overtime)),
          if (isV2) PayslipDetailRow(label: 'Bonus', value: rupiah(bonus)),
          if (!isV2) PayslipDetailRow(label: 'Reimbursement Historis', value: rupiah(reimbursement)),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Pendapatan Kotor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  rupiah(grossSalary),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF166534),
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
