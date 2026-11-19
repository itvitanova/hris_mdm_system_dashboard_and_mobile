import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:uicons/uicons.dart';
import 'payslip_detail_row.dart';
import 'payslip_status_badge.dart';

/// Card displaying company metadata, employee info, period, and status
class PayslipMetaCard extends StatelessWidget {
  const PayslipMetaCard({
    super.key,
    required this.slip,
    required this.isV2,
  });

  final Json slip;
  final bool isV2;

  @override
  Widget build(BuildContext context) {
    final company = text(slip, 'companyName', 'PT MDM Human Resource');
    final address = text(slip, 'companyAddress', '');
    final employeeName = text(slip, 'employeeName');
    final department = text(slip, 'department');
    final period = text(slip, 'period');
    final status = text(slip, 'status', 'Final');
    final ptkp = text(slip, 'ptkp');

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
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFCCFBF1), width: 1),
                ),
                child: Icon(
                  UIcons.regularRounded.building,
                  size: 19,
                  color: const Color(0xFF0F766E),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (address.isNotEmpty) ...[
                      SizedBox(height: 1.5.h),
                      Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              PayslipStatusBadge(status: status),
            ],
          ),
          SizedBox(height: 14.h),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),
          PayslipDetailRow(label: 'Nama Karyawan', value: employeeName, isBold: true),
          PayslipDetailRow(label: 'Departemen', value: department.isNotEmpty ? department : '-'),
          PayslipDetailRow(label: 'Periode Penggajian', value: period),
          if (isV2 && ptkp.isNotEmpty) PayslipDetailRow(label: 'Status PTKP', value: ptkp),
        ],
      ),
    );
  }
}
