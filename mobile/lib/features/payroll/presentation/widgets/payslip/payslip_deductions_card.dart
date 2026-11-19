import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:uicons/uicons.dart';
import 'payslip_detail_row.dart';

/// Card displaying deductions components (potongan) on payslip
class PayslipDeductionsCard extends StatelessWidget {
  const PayslipDeductionsCard({
    super.key,
    required this.slip,
    required this.isV2,
  });

  final Json slip;
  final bool isV2;

  @override
  Widget build(BuildContext context) {
    final pph21 = number(slip, 'pph21');
    final isTaxReady = slip['taxReady'] == true;
    final bpjsHealth = number(slip, 'bpjsHealth');
    final jht = number(slip, 'jht');
    final jp = number(slip, 'jp');
    final deductions = number(slip, 'deductions');

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
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFECACA), width: 1),
                ),
                child: Icon(
                  UIcons.regularRounded.arrow_trend_down,
                  size: 17,
                  color: const Color(0xFFDC2626),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Komponen Potongan',
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
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
                ),
                child: Text(
                  'Pengurangan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (isV2) ...[
            PayslipDetailRow(
              label: pph21 < 0 ? 'Pengembalian PPh21' : 'PPh21 (Pajak)',
              value: isTaxReady ? rupiah(pph21) : 'Belum lengkap',
            ),
            PayslipDetailRow(label: 'BPJS Kesehatan (1%)', value: rupiah(bpjsHealth)),
            PayslipDetailRow(label: 'JHT (2%)', value: rupiah(jht)),
            PayslipDetailRow(label: 'JP (1%)', value: rupiah(jp)),
          ],
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFECACA), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Potongan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '- ${rupiah(deductions)}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF991B1B),
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
