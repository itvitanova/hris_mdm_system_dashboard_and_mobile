import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'employee_details_modal_row.dart';

/// Kartu Informasi Hubungan Kerja & Kepegawaian
class EmployeeEmploymentCard extends StatelessWidget {
  final String nik;
  final String employmentType;
  final String ptkp;
  final String address;
  final bool isFaceEnrolled;
  final VoidCallback onCopyNik;

  const EmployeeEmploymentCard({
    super.key,
    required this.nik,
    required this.employmentType,
    required this.ptkp,
    required this.address,
    required this.isFaceEnrolled,
    required this.onCopyNik,
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
        children: [
          EmployeeDetailsModalRow(
            label: 'NIK (No. KTP)',
            value: nik,
            canCopy: true,
            onCopy: onCopyNik,
          ),
          Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
          EmployeeDetailsModalRow(
            label: 'Hubungan Kerja',
            value: employmentType,
          ),
          Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
          EmployeeDetailsModalRow(
            label: 'Status PTKP',
            value: ptkp,
          ),
          Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
          EmployeeDetailsModalRow(
            label: 'Pendaftaran Wajah',
            value: isFaceEnrolled ? 'Terdaftar' : 'Belum terdaftar',
            customValue: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isFaceEnrolled
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                isFaceEnrolled ? 'Terdaftar' : 'Belum terdaftar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isFaceEnrolled
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309),
                ),
              ),
            ),
          ),
          Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
          EmployeeDetailsModalRow(
            label: 'Alamat Rumah',
            value: address,
          ),
        ],
      ),
    );
  }
}
