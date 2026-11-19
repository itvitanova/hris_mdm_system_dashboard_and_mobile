import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';

/// Card showing employee's eligibility and year info for Medical Claim
class MedicalClaimPlafonInfoCard extends StatelessWidget {
  final Workspace? workspace;

  const MedicalClaimPlafonInfoCard({super.key, this.workspace});

  @override
  Widget build(BuildContext context) {
    final balances = (workspace?.data['medicalBalances'] as List?)?.cast<Map>();
    final myBalance = balances?.firstWhere(
      (b) => b['employeeId'] == workspace?.actor['employeeId'],
      orElse: () => <String, dynamic>{},
    );

    final year = myBalance?['year']?.toString() ?? DateTime.now().year.toString();
    final reason = myBalance?['reason']?.toString();
    final eligibilityMessage = reason != null && reason.trim().isNotEmpty
        ? reason
        : 'Medical Claim hanya tersedia untuk karyawan PKWTT';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    UIcons.regularRounded.stethoscope,
                    size: 14.sp,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Medical Claim',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  year,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            eligibilityMessage,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE0F2FE),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tahun kalender Januari–Desember; sisa saldo tidak dibawa ke tahun berikutnya. Lampiran gambar/PDF opsional.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
