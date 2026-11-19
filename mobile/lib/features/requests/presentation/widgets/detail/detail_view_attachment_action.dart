import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/api_client.dart';
import '../receipt_preview.dart';

/// Button that navigates to ReceiptPreview modal for an attachment
class DetailViewAttachmentAction extends StatelessWidget {
  const DetailViewAttachmentAction({
    super.key,
    required this.api,
    required this.requestId,
    required this.attachmentId,
    this.title = 'Berkas Lampiran',
    this.busy = false,
  });

  final ApiClient api;
  final String requestId;
  final String attachmentId;
  final String title;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final receiptPath = requestId.isNotEmpty
        ? '/requests/${Uri.encodeComponent(requestId)}/receipts/${Uri.encodeComponent(attachmentId)}'
        : '/request-receipts/${Uri.encodeComponent(attachmentId)}';
    final fallbackPath = requestId.isNotEmpty
        ? '/request-receipts/${Uri.encodeComponent(attachmentId)}'
        : null;

    return Material(
      color: const Color(0xFFF0FDFA),
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: busy
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceiptPreview(
                      api: api,
                      path: receiptPath,
                      fallbackPath: fallbackPath,
                      title: title,
                    ),
                  ),
                ),
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: const Color(0xFF99F6E4),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                UIcons.regularRounded.eye,
                size: 11.5.w,
                color: const Color(0xFF0F766E),
              ),
              SizedBox(width: 3.5.w),
              Flexible(
                child: Text(
                  'Lihat lampiran',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
