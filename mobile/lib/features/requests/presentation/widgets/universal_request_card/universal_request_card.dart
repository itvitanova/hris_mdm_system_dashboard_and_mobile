import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/submission_kind.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'request_card_config.dart';
import 'request_card_description_strip.dart';
import 'request_card_header.dart';
import 'request_card_revision_footer.dart';
import 'request_card_standard_footer.dart';

export '../../../domain/entities/submission_kind.dart';
export '../../../domain/entities/submission_status.dart';
export '../../../domain/entities/universal_request_item.dart';
export 'request_card_config.dart';
export 'request_card_description_strip.dart';
export 'request_card_header.dart';
export 'request_card_revision_footer.dart';
export 'request_card_standard_footer.dart';
export 'request_formatters.dart';
export 'request_revision_box.dart';
export 'request_segmented_stepper.dart';

/// Universal Request Card Widget
/// Desain scannable, tenang, dan bersih dengan Status Pill di pojok kanan atas,
/// baris metadata terstruktur, dan chevron subtle.
class UniversalRequestCard extends StatelessWidget {
  final UniversalRequestModel data;
  final VoidCallback? onCardTap;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onRevisePressed;
  final bool showApplicant;
  final AppLanguage language;

  const UniversalRequestCard({
    super.key,
    required this.data,
    this.onCardTap,
    this.onDetailPressed,
    this.onRevisePressed,
    this.showApplicant = false,
    this.language = AppLanguage.id,
  });

  String? _resolveBottomMetric(bool hasMonetaryAmount) {
    if (hasMonetaryAmount) {
      return RequestCardHelper.formatIDR(data.amount ?? 0);
    }
    if (data.kind == SubmissionKind.cuti || data.kind == SubmissionKind.izin) {
      final days = data.days ?? 1;
      return '$days ${language == AppLanguage.en ? 'Hari' : 'Hari'}';
    }
    if (data.kind == SubmissionKind.lembur) {
      final hours = data.hours ?? 1;
      return '$hours ${language == AppLanguage.en ? 'Jam' : 'Jam'}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final kindConfig = RequestCardHelper.getKindConfig(data, language);
    final statusConfig = RequestCardHelper.getStatusConfig(
      data.status,
      data.kind,
      language,
    );
    final isRevision = data.status == SubmissionStatus.perluRevisi;
    final hasMonetaryAmount = (data.amount != null && data.amount! > 0) ||
        data.kind == SubmissionKind.reimbursement ||
        data.kind == SubmissionKind.pettyCash ||
        data.kind == SubmissionKind.medicalClaim;

    final bottomMetric = _resolveBottomMetric(hasMonetaryAmount);
    final transactionCount = data.transactionCount != null && data.transactionCount! > 0
        ? data.transactionCount
        : null;
    final transactionText = transactionCount != null
        ? (language == AppLanguage.en
            ? '$transactionCount transactions'
            : '$transactionCount transaksi')
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCardTap ?? onDetailPressed,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFF5F5F5),
                blurRadius: 9,
                offset: Offset(0, 0),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3.5.w,
                child: Container(color: statusConfig.barColor),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RequestCardHeader(
                      data: data,
                      kindConfig: kindConfig,
                      statusConfig: statusConfig,
                      showApplicant: showApplicant,
                      language: language,
                    ),
                    RequestCardDescriptionStrip(
                      rawDescription: data.description,
                      kind: data.kind,
                      language: language,
                    ),
                    if (isRevision && data.reviewNote != null)
                      RequestCardRevisionFooter(
                        data: data,
                        bottomMetric: bottomMetric,
                        transactionText: transactionText,
                        language: language,
                        onRevisePressed: onRevisePressed,
                      )
                    else
                      RequestCardStandardFooter(
                        data: data,
                        bottomMetric: bottomMetric,
                        transactionText: transactionText,
                        language: language,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
