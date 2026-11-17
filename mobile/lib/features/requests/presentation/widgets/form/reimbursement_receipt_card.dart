import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/api_client.dart';
import '../../models/expense_draft.dart';
import '../receipt_preview.dart';

/// Receipt upload card for an expense item
class ReimbursementReceiptCard extends StatelessWidget {
  final ExpenseDraft item;
  final int index;
  final bool isDisabled;
  final bool uploading;
  final ApiClient api;
  final void Function(ExpenseDraft) onUploadReceipt;
  final VoidCallback onChanged;

  const ReimbursementReceiptCard({
    super.key,
    required this.item,
    required this.index,
    required this.isDisabled,
    required this.uploading,
    required this.api,
    required this.onUploadReceipt,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasReceipt = item.receiptId.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti transaksi *',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: hasReceipt ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: hasReceipt ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isDisabled || uploading ? null : () => onUploadReceipt(item),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: hasReceipt ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            hasReceipt ? UIcons.regularRounded.document : UIcons.regularRounded.cloud_upload,
                            size: 16.sp,
                            color: hasReceipt ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasReceipt ? 'Bukti transaksi terunggah' : 'Unggah bukti transaksi',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                hasReceipt
                                    ? (item.receiptName.isNotEmpty ? item.receiptName : 'Bukti terunggah')
                                    : 'JPEG, PNG, atau PDF; maksimal 2 MB',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.sp,
                                  color: hasReceipt ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (hasReceipt) ...[
                SizedBox(width: 8.w),
                Tooltip(
                  message: 'Hapus berkas bukti',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: Key('delete_receipt_$index'),
                      onTap: isDisabled
                          ? null
                          : () {
                              item.receiptId = '';
                              item.receiptName = '';
                              item.fileBytes = null;
                              item.stagedPath = null;
                              onChanged();
                            },
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: const Color(0xFFFECACA), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(UIcons.regularRounded.trash, size: 13.sp, color: const Color(0xFFDC2626)),
                            SizedBox(width: 4.w),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasReceipt) ...[
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: isDisabled || uploading
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceiptPreview(
                          api: api,
                          path: '/request-receipts/${Uri.encodeComponent(item.receiptId)}',
                          title: item.receiptName.isNotEmpty ? item.receiptName : 'Bukti transaksi',
                        ),
                      ),
                    ),
              icon: Icon(UIcons.regularRounded.picture, size: 15.sp, color: const Color(0xFF0D9488)),
              label: Text(
                'Lihat bukti yang diunggah',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D9488),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
