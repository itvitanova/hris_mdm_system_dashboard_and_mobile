import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../domain/entities/submission_kind.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';

/// Empty state widget shown when there are no requests matching criteria
class ModuleEmptyState extends StatelessWidget {
  const ModuleEmptyState({
    super.key,
    required this.kind,
    required this.isEn,
    this.selectedStatus,
  });

  final SubmissionKind kind;
  final bool isEn;
  final SubmissionStatus? selectedStatus;

  String _buildMessage() {
    if (selectedStatus != null) {
      return isEn
          ? 'No submissions with status "${selectedStatus!.getLabel(AppLanguage.en)}"'
          : 'Tidak ada pengajuan berstatus "${selectedStatus!.displayName}"';
    }
    return isEn
        ? 'No ${kind.getLabel(AppLanguage.en).toLowerCase()} submission history yet'
        : 'Belum ada riwayat pengajuan ${kind.displayName.toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 36.h),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            UIcons.regularRounded.inbox,
            size: 40.sp,
            color: const Color(0xFF94A3B8),
          ),
          SizedBox(height: 8.h),
          Text(
            _buildMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
