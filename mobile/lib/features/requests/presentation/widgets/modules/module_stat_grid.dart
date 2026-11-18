import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../domain/entities/submission_status.dart';
import '../services_hub/module_stat_card.dart';

/// 2x2 Bento grid of status metrics (Disetujui, Menunggu, Ditolak, Perlu Revisi)
class ModuleStatGrid extends StatelessWidget {
  const ModuleStatGrid({
    super.key,
    required this.isEn,
    required this.approvedCount,
    required this.pendingCount,
    required this.rejectedCount,
    required this.revisionCount,
    required this.selectedStatusFilter,
    required this.onSelectStatus,
  });

  final bool isEn;
  final int approvedCount;
  final int pendingCount;
  final int rejectedCount;
  final int revisionCount;
  final SubmissionStatus? selectedStatusFilter;
  final ValueChanged<SubmissionStatus?> onSelectStatus;

  void _handleTap(SubmissionStatus status) {
    if (selectedStatusFilter == status) {
      onSelectStatus(null);
    } else {
      onSelectStatus(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ModuleStatCard(
                title: isEn ? 'Approved' : 'Disetujui',
                subTitle: isEn ? 'submissions' : 'pengajuan',
                label: isEn ? 'APPROVED' : 'DISETUJUI',
                value: '$approvedCount',
                icon: UIcons.regularRounded.check,
                isSelected: selectedStatusFilter == SubmissionStatus.disetujui,
                onTap: () => _handleTap(SubmissionStatus.disetujui),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ModuleStatCard(
                title: isEn ? 'Pending' : 'Menunggu',
                subTitle: isEn ? 'in review' : 'dalam proses',
                label: isEn ? 'PENDING' : 'MENUNGGU',
                value: '$pendingCount',
                icon: UIcons.regularRounded.clock,
                isSelected: selectedStatusFilter == SubmissionStatus.menunggu,
                onTap: () => _handleTap(SubmissionStatus.menunggu),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: ModuleStatCard(
                title: isEn ? 'Rejected' : 'Ditolak',
                subTitle: isEn ? 'declined' : 'tidak disetujui',
                label: isEn ? 'REJECTED' : 'DITOLAK',
                value: '$rejectedCount',
                icon: UIcons.regularRounded.cross_circle,
                isSelected: selectedStatusFilter == SubmissionStatus.ditolak,
                onTap: () => _handleTap(SubmissionStatus.ditolak),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ModuleStatCard(
                title: isEn ? 'Needs Revision' : 'Perlu Revisi',
                subTitle: isEn ? 'action needed' : 'perlu tindak',
                label: isEn ? 'NEEDS REVISION' : 'PERLU REVISI',
                value: '$revisionCount',
                icon: UIcons.regularRounded.edit,
                isSelected: selectedStatusFilter == SubmissionStatus.perluRevisi,
                onTap: () => _handleTap(SubmissionStatus.perluRevisi),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
