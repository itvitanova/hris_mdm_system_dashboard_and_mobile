import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';

Color statusDotColor(SubmissionStatus status) {
  switch (status) {
    case SubmissionStatus.disetujui:
      return AppColors.filterStatusGreen;
    case SubmissionStatus.menunggu:
      return AppColors.filterStatusAmber;
    case SubmissionStatus.perluRevisi:
      return AppColors.filterStatusOrange;
    case SubmissionStatus.ditolak:
      return AppColors.filterStatusRed;
    case SubmissionStatus.menungguSinkronisasi:
      return AppColors.filterStatusAmber;
  }
}

class StatusOptionTile extends StatelessWidget {
  final SubmissionStatus status;
  final bool isSelected;
  final AppLanguage language;
  final VoidCallback onTap;

  const StatusOptionTile({
    super.key,
    required this.status,
    required this.isSelected,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF14B8A6),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.filterSlateBg,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : statusDotColor(status),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status.getLabel(language),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.filterItemText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
