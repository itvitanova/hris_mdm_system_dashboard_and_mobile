import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/workspace.dart';
import 'detail_formatters.dart';
import 'detail_section_card.dart';
import 'detail_view_attachment_action.dart';

/// Card showing attachments (receipts per item or single document attachment)
class DetailAttachmentsCard extends StatelessWidget {
  const DetailAttachmentsCard({
    super.key,
    required this.api,
    required this.r,
    required this.items,
    this.busy = false,
  });

  final ApiClient api;
  final Json r;
  final List<Json> items;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final hasItemReceipts =
        items.any((item) => text(item, 'receiptId').isNotEmpty);
    final hasSingleAttachment = text(r, 'attachmentId', '').isNotEmpty;

    if (!hasItemReceipts && !hasSingleAttachment) {
      return const SizedBox.shrink();
    }

    final reqId = text(r, 'id', '');

    return DetailSectionCard(
      icon: UIcons.regularRounded.clip,
      title: 'Berkas Lampiran Pengajuan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bukti Transaksi per Item Pengeluaran (Reimbursement)
          for (var i = 0; i < items.length; i++) ...[
            if (text(items[i], 'receiptId').isNotEmpty) ...[
              if (i > 0 &&
                  items
                      .take(i)
                      .any((prev) => text(prev, 'receiptId').isNotEmpty))
                SizedBox(height: 8.h),
              DetailAttachmentTile(
                title: 'Bukti Transaksi ${i + 1}',
                subtitle: DetailFormatters.cleanItemDescription(
                  text(items[i], 'description'),
                ),
                api: api,
                requestId: reqId,
                attachmentId: text(items[i], 'receiptId'),
                actionTitle: 'Bukti Transaksi ${i + 1}',
                busy: busy,
              ),
            ],
          ],

          // Lampiran Berkas Tunggal (Medical Claim, Izin, Cuti, dll)
          if (hasSingleAttachment) ...[
            if (hasItemReceipts) SizedBox(height: 8.h),
            DetailAttachmentTile(
              title: text(r, 'attachmentName', 'Bukti Lampiran Resmi'),
              subtitle: 'Lampiran bukti pendukung pengajuan',
              api: api,
              requestId: reqId,
              attachmentId: text(r, 'attachmentId'),
              actionTitle: 'Berkas Lampiran',
              busy: busy,
            ),
          ],
        ],
      ),
    );
  }
}

/// Single attachment item tile row with icon, title, subtitle, and action
class DetailAttachmentTile extends StatelessWidget {
  const DetailAttachmentTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.api,
    required this.requestId,
    required this.attachmentId,
    required this.actionTitle,
    this.busy = false,
  });

  final String title;
  final String subtitle;
  final ApiClient api;
  final String requestId;
  final String attachmentId;
  final String actionTitle;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  UIcons.regularRounded.document,
                  size: 20.w,
                  color: const Color(0xFF0F766E),
                ),
              ),
              SizedBox(width: 10.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 160.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DetailViewAttachmentAction(
            api: api,
            requestId: requestId,
            attachmentId: attachmentId,
            title: actionTitle,
            busy: busy,
          ),
        ],
      ),
    );
  }
}
