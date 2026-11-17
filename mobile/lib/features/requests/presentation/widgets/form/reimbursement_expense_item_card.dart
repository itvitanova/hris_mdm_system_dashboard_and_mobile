import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/api_client.dart';
import '../../models/expense_draft.dart';
import 'expense_item_date_category.dart';
import 'expense_item_pricing_section.dart';
import 'reimbursement_receipt_card.dart';

/// Single item card in the reimbursement expenses list
class ReimbursementExpenseItemCard extends StatelessWidget {
  final ExpenseDraft item;
  final int index;
  final int totalCount;
  final bool isDisabled;
  final bool uploading;
  final ApiClient api;
  final String Function(DateTime) formatDate;
  final void Function(ExpenseDraft) onPickExpenseDate;
  final void Function(ExpenseDraft) onUploadReceipt;
  final void Function(ExpenseDraft) onRemove;
  final VoidCallback onChanged;

  const ReimbursementExpenseItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.totalCount,
    required this.isDisabled,
    required this.uploading,
    required this.api,
    required this.formatDate,
    required this.onPickExpenseDate,
    required this.onUploadReceipt,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Item #${index + 1}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              const Spacer(),
              if (totalCount > 1)
                IconButton(
                  onPressed: isDisabled ? null : () => onRemove(item),
                  icon: Icon(UIcons.regularRounded.trash, size: 16.sp, color: const Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ExpenseItemDateCategory(
            item: item,
            isDisabled: isDisabled,
            formatDate: formatDate,
            onPickExpenseDate: onPickExpenseDate,
            onChanged: onChanged,
          ),
          SizedBox(height: 12.h),
          ExpenseItemPricingSection(
            item: item,
            isDisabled: isDisabled,
            onChanged: onChanged,
          ),
          SizedBox(height: 12.h),
          ReimbursementReceiptCard(
            item: item,
            index: index,
            isDisabled: isDisabled,
            uploading: uploading,
            api: api,
            onUploadReceipt: onUploadReceipt,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
