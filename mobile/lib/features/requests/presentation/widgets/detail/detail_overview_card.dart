import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../universal_request_card/universal_request_card.dart';
import 'detail_description_block.dart';
import 'detail_formatters.dart';
import 'detail_kind_parameters.dart';
import 'detail_metric_highlight_box.dart';
import 'detail_overview_header.dart';

/// Top card in detail view showing request title, status badge, metric, and parameter overview
class DetailOverviewCard extends StatelessWidget {
  const DetailOverviewCard({
    super.key,
    required this.r,
    required this.model,
    required this.kindConfig,
    required this.statusConfig,
    required this.amount,
    required this.hasAmount,
    this.hours,
    this.days,
    required this.items,
  });

  final Json r;
  final UniversalRequestModel model;
  final RequestKindConfig kindConfig;
  final RequestStatusConfig statusConfig;
  final num amount;
  final bool hasAmount;
  final int? hours;
  final int? days;
  final List<Json> items;

  @override
  Widget build(BuildContext context) {
    final cleanedDesc =
        DetailFormatters.cleanDescriptionText(text(r, 'description'));
    final isEn = AppLanguageController.currentLanguage == AppLanguage.en;

    String descLabel;
    switch (model.kind) {
      case SubmissionKind.cuti:
        descLabel = isEn ? 'Leave Reason' : 'Alasan Cuti';
        break;
      case SubmissionKind.izin:
        descLabel = isEn ? 'Permission Reason' : 'Alasan Izin';
        break;
      case SubmissionKind.lembur:
        descLabel = isEn ? 'Overtime Tasks' : 'Uraian Tugas Lembur';
        break;
      case SubmissionKind.reimbursement:
        descLabel = isEn ? 'Claim Description' : 'Keterangan Klaim';
        break;
      case SubmissionKind.medicalClaim:
        descLabel =
            isEn ? 'Medical Notes / Diagnosis' : 'Catatan / Diagnosa Medis';
        break;
      case SubmissionKind.pettyCash:
        descLabel = isEn ? 'Fund Purpose' : 'Peruntukan Dana';
        break;
      case SubmissionKind.generalAffair:
        descLabel = isEn ? 'GA Requirements' : 'Deskripsi Kebutuhan GA';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailOverviewHeader(
            r: r,
            kindConfig: kindConfig,
            statusConfig: statusConfig,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Divider(
                height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
          ),
          if (model.status == SubmissionStatus.menungguSinkronisasi) ...[
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    UIcons.regularRounded.cloud_upload,
                    size: 16.w,
                    color: const Color(0xFFB45309),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Pengajuan ini tersimpan di perangkat dan akan dikirim otomatis saat online.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Judul Pengajuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                text(r, 'title').isNotEmpty ? text(r, 'title') : '—',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  height: 1.35,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          DetailMetricHighlightBox(
            model: model,
            amount: amount,
            hasAmount: hasAmount,
            hours: hours,
            days: days,
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 10.h),
          if (cleanedDesc.isNotEmpty) ...[
            DetailDescriptionBlock(label: descLabel, value: cleanedDesc),
            SizedBox(height: 12.h),
          ],
          DetailKindParameters(model: model, r: r, items: items),
        ],
      ),
    );
  }
}
