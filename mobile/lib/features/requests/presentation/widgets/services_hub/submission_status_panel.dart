import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import 'status_option_tile.dart';

export 'status_option_tile.dart';

class SubmissionStatusPanel extends StatelessWidget {
  final SubmissionStatus? selected;
  final ValueChanged<SubmissionStatus?> onSelect;
  final AppLanguage language;

  const SubmissionStatusPanel({
    super.key,
    required this.selected,
    required this.onSelect,
    this.language = AppLanguage.id,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = [
      SubmissionStatus.disetujui,
      SubmissionStatus.menunggu,
      SubmissionStatus.perluRevisi,
      SubmissionStatus.ditolak,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSemuaRow(),
          const SizedBox(height: 8),
          ...List.generate(2, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < 1 ? 6 : 0),
              child: Row(
                children: List.generate(2, (col) {
                  final index = row * 2 + col;
                  final status = statuses[index];
                  final isSelected = selected == status;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: col == 1 ? 6 : 0),
                      child: StatusOptionTile(
                        status: status,
                        isSelected: isSelected,
                        language: language,
                        onTap: () => onSelect(status),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSemuaRow() {
    final isSelected = selected == null;
    return GestureDetector(
      onTap: () => onSelect(null),
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
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white
                    : AppColors.filterStatusGreen,
              ),
              child: Center(
                child: Container(
                  width: 3.6,
                  height: 3.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                language == AppLanguage.en
                    ? 'All Submission Statuses'
                    : 'Semua Status Pengajuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.filterItemText,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                UIcons.regularRounded.check,
                size: 14,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
