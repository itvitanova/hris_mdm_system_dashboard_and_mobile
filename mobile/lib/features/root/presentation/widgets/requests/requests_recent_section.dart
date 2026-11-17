import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/workspace.dart';
import '../../../../requests/presentation/pages/request_detail_page.dart';
import '../../../../requests/presentation/pages/request_form_page.dart';
import '../../../../requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import '../language_swap_button.dart';
import 'requests_empty_state.dart';
import 'requests_segmented_filter_bar.dart';

/// Seksi Pengajuan Terkini (Header, Filter Bar, List UniversalRequestCard / Empty State)
class RequestsRecentSection extends StatelessWidget {
  final bool isEn;
  final AppLanguage currentLanguage;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final List<UniversalRequestModel> allModels;
  final List<Map<String, dynamic>> allRawItems;
  final Future<void> Function(Widget) onNavigate;
  final ApiClient api;
  final Workspace workspace;

  const RequestsRecentSection({
    super.key,
    required this.isEn,
    required this.currentLanguage,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.allModels,
    required this.allRawItems,
    required this.onNavigate,
    required this.api,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context) {
    // Terapkan filter status
    final filteredIndices = <int>[];
    for (int i = 0; i < allModels.length; i++) {
      final model = allModels[i];
      if (selectedFilter == 'Semua') {
        filteredIndices.add(i);
      } else if (selectedFilter == 'Menunggu') {
        if (model.status == SubmissionStatus.menunggu ||
            model.status == SubmissionStatus.menungguSinkronisasi) {
          filteredIndices.add(i);
        }
      } else if (selectedFilter == 'Selesai') {
        if (model.status == SubmissionStatus.disetujui ||
            model.status == SubmissionStatus.perluRevisi ||
            model.status == SubmissionStatus.ditolak) {
          filteredIndices.add(i);
        }
      }
    }

    final hasMoreThanTwo = filteredIndices.length > 2;
    final takenCards = filteredIndices.take(2).toList();
    final recentCards = takenCards.asMap().entries.map((entry) {
      final indexInList = entry.key;
      final idx = entry.value;
      final model = allModels[idx];
      final raw = allRawItems[idx];
      final isLastItem = indexInList == takenCards.length - 1;
      return Padding(
        padding: EdgeInsets.only(
          bottom: (isLastItem && !hasMoreThanTwo) ? 0 : 12.h,
        ),
        child: UniversalRequestCard(
          data: model,
          language: currentLanguage,
          onDetailPressed: () => onNavigate(
            RequestDetailScreen(
              api: api,
              request: raw,
              own: true,
            ),
          ),
          onRevisePressed: () => onNavigate(
            RequestForm(
              api: api,
              workspace: workspace,
              initialKind: model.kind.displayName,
              initialRequest: raw,
            ),
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Recent Submissions' : 'Pengajuan Terkini',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          isEn
              ? 'Track the status and next steps of your latest submissions.'
              : 'Pantau status dan tindak lanjut pengajuan terbaru Anda.',
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 12.h),
        RequestsSegmentedFilterBar(
          isEn: isEn,
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
        SizedBox(height: 14.h),
        if (recentCards.isEmpty)
          RequestsEmptyState(
            isEn: isEn,
            selectedFilter: selectedFilter,
          )
        else ...[
          ...recentCards,
          if (hasMoreThanTwo)
            Padding(
              padding: EdgeInsets.only(top: 2.h, bottom: 0),
              child: Center(
                child: Text(
                  isEn
                      ? 'Showing 2 latest submissions. Open catalog module for full history.'
                      : 'Menampilkan 2 pengajuan terbaru. Buka modul katalog untuk riwayat lengkap.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
