import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import '../universal_request_card/universal_request_card.dart';
import 'detail_bank_account_card.dart';
import 'detail_formatters.dart';
import 'detail_info_row.dart';
import 'detail_section_card.dart';

/// Card showing employee applicant info, department, contact, and optional bank info
class DetailApplicantCard extends StatelessWidget {
  const DetailApplicantCard({
    super.key,
    required this.r,
    required this.snapshot,
    required this.workspace,
    required this.model,
  });

  final Json r;
  final Json snapshot;
  final Workspace? workspace;
  final UniversalRequestModel model;

  @override
  Widget build(BuildContext context) {
    final applicantEmpId =
        text(snapshot, 'employeeId', text(r, 'employeeId'));
    Json empFromWs = {};
    if (workspace != null && applicantEmpId.isNotEmpty) {
      empFromWs = workspace!.rows('employees').firstWhere(
            (e) => e['id'] == applicantEmpId,
            orElse: () => {},
          );
    }

    final applicantName = text(
      snapshot,
      'name',
      text(empFromWs, 'name', text(r, 'employeeName', 'Karyawan')),
    );

    final rawNik =
        text(snapshot, 'employeeNumber', text(empFromWs, 'employeeNumber'));
    final applicantId = (rawNik.isNotEmpty && rawNik != '—')
        ? rawNik
        : (applicantEmpId != '—' ? applicantEmpId : '');

    final rawDept = text(snapshot, 'department');
    final dept = (rawDept.isNotEmpty && rawDept != '—')
        ? rawDept
        : text(empFromWs, 'department', 'Divisi');

    final rawPos = text(snapshot, 'position');
    final pos = (rawPos.isNotEmpty && rawPos != '—')
        ? rawPos
        : text(empFromWs, 'position', 'Karyawan');

    final rawPhone = text(snapshot, 'phone');
    final phone = (rawPhone.isNotEmpty && rawPhone != '—')
        ? rawPhone
        : text(empFromWs, 'phone', '');

    final rawBankName = text(snapshot, 'bankName');
    final bankName = (rawBankName.isNotEmpty && rawBankName != '—')
        ? rawBankName
        : text(empFromWs, 'bankName', '');

    final rawBankAccountName = text(snapshot, 'bankAccountName');
    final bankAccountName =
        (rawBankAccountName.isNotEmpty && rawBankAccountName != '—')
            ? rawBankAccountName
            : text(empFromWs, 'bankAccountName', '');

    final rawBankAccountNumber = text(snapshot, 'bankAccountNumber');
    final bankAccountNumber =
        (rawBankAccountNumber.isNotEmpty && rawBankAccountNumber != '—')
            ? rawBankAccountNumber
            : text(empFromWs, 'bankAccountNumber', '');

    final isTransferRelevant = model.kind == SubmissionKind.reimbursement ||
        model.kind == SubmissionKind.medicalClaim;
    final shouldShowBank = isTransferRelevant && bankAccountNumber.isNotEmpty;

    return DetailSectionCard(
      svgPath: 'assets/icon/profile-not-active.svg',
      title: 'Informasi Pemohon',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF14B8A6),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x180F766E),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  DetailFormatters.getInitials(applicantName),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicantName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$dept · $pos',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (applicantId.isNotEmpty || phone.isNotEmpty) ...[
            SizedBox(height: 10.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 4.h),
          ],
          if (applicantId.isNotEmpty)
            DetailInfoRow(
              label: 'ID Karyawan',
              value: applicantId,
              icon: UIcons.regularRounded.badge_check,
              copyValue: applicantId,
              showColon: true,
            ),
          if (phone.isNotEmpty)
            DetailInfoRow(
              label: 'Nomor Telepon',
              value: phone,
              icon: UIcons.regularRounded.phone_call,
              copyValue: phone,
              showColon: true,
            ),
          if (shouldShowBank) ...[
            SizedBox(height: 12.h),
            DetailBankAccountCard(
              bankName: bankName,
              bankAccountNumber: bankAccountNumber,
              bankAccountName: bankAccountName,
            ),
          ],
        ],
      ),
    );
  }
}
