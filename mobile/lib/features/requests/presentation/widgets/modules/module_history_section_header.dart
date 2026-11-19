import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/submission_kind.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';

/// Narrative header section for request history with count badge and dynamic subtitle
class ModuleHistorySectionHeader extends StatelessWidget {
  const ModuleHistorySectionHeader({
    super.key,
    required this.kind,
    required this.isEn,
    required this.totalCount,
    this.selectedStatus,
  });

  final SubmissionKind kind;
  final bool isEn;
  final int totalCount;
  final SubmissionStatus? selectedStatus;

  String _buildTitle() {
    if (isEn) {
      return kind == SubmissionKind.medicalClaim
          ? 'Submission History'
          : '${kind.getLabel(AppLanguage.en)} History';
    }
    return kind == SubmissionKind.medicalClaim
        ? 'Riwayat Pengajuan'
        : 'Riwayat Pengajuan ${kind.displayName}';
  }

  String _buildSubtitle() {
    if (selectedStatus != null) {
      return isEn
          ? 'Showing submissions with status "${selectedStatus!.getLabel(AppLanguage.en)}" ($totalCount found).'
          : 'Menampilkan pengajuan berstatus "${selectedStatus!.displayName}" ($totalCount ditemukan).';
    }
    return isEn
        ? 'Track approval process and your ${kind.getLabel(AppLanguage.en).toLowerCase()} history.'
        : 'Pantau proses persetujuan dan riwayat pengajuan ${kind.displayName.toLowerCase()} Anda.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 3.5.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      _buildTitle(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
              child: Text(
                isEn ? '$totalCount Submissions' : '$totalCount Pengajuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          _buildSubtitle(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
