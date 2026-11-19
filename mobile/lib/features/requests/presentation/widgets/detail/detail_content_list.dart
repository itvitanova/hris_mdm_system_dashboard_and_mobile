import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/widgets/core_widgets.dart';
import '../../../../../core/workspace.dart';
import '../universal_request_card/universal_request_card.dart';
import 'detail_applicant_card.dart';
import 'detail_approval_flow_card.dart';
import 'detail_attachments_card.dart';
import 'detail_expense_items_card.dart';
import 'detail_overview_card.dart';

/// Scrollable content body of the request detail page
class DetailContentList extends StatelessWidget {
  const DetailContentList({
    super.key,
    required this.api,
    required this.r,
    required this.snapshot,
    required this.workspace,
    required this.model,
    required this.kindConfig,
    required this.statusConfig,
    required this.amount,
    required this.hasAmount,
    this.hours,
    this.days,
    required this.items,
    required this.steps,
    required this.busy,
    this.error,
  });

  final ApiClient api;
  final Json r;
  final Json snapshot;
  final Workspace? workspace;
  final UniversalRequestModel model;
  final RequestKindConfig kindConfig;
  final RequestStatusConfig statusConfig;
  final num amount;
  final bool hasAmount;
  final int? hours;
  final int? days;
  final List<Json> items;
  final List<Json> steps;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      children: [
        DetailOverviewCard(
          r: r,
          model: model,
          kindConfig: kindConfig,
          statusConfig: statusConfig,
          amount: amount,
          hasAmount: hasAmount,
          hours: hours,
          days: days,
          items: items,
        ),
        DetailApplicantCard(
          r: r,
          snapshot: snapshot,
          workspace: workspace,
          model: model,
        ),
        DetailExpenseItemsCard(items: items, amount: amount),
        DetailAttachmentsCard(
          api: api,
          r: r,
          items: items,
          busy: busy,
        ),
        DetailApprovalFlowCard(r: r, steps: steps),
        if (error != null) ...[
          ErrorNotice(error!),
          SizedBox(height: 10.h),
        ],
        if (busy)
          const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(color: Color(0xFF0F766E)),
          ),
        if (r['kind'] == 'Reimbursement')
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
            child: Text(
              r['version'] == 2
                  ? 'Dokumen final tersedia setelah persetujuan dan verifikasi finance. Persetujuan bukan bukti pembayaran.'
                  : 'Pengajuan lama belum memiliki rincian dan snapshot template. Dokumen otomatis tersedia untuk pengajuan baru.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                color: const Color(0xFF94A3B8),
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}
