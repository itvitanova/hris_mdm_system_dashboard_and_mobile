import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'detail_info_row.dart';

/// Card showing recipient bank account info for reimbursement and medical claims
class DetailBankAccountCard extends StatelessWidget {
  const DetailBankAccountCard({
    super.key,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
  });

  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                UIcons.regularRounded.bank,
                size: 15.w,
                color: const Color(0xFF0F766E),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Rekening Penerima Transfer',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (bankName.isNotEmpty) ...[
            DetailBankModalRow(label: 'Nama Bank', value: bankName),
            Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
          ],
          DetailBankModalRow(
            label: 'Nomor Rekening',
            value: bankAccountNumber,
            copyValue: bankAccountNumber,
          ),
          if (bankAccountName.isNotEmpty) ...[
            Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
            DetailBankModalRow(
              label: 'Nama Pemilik',
              value: bankAccountName,
            ),
          ],
        ],
      ),
    );
  }
}
