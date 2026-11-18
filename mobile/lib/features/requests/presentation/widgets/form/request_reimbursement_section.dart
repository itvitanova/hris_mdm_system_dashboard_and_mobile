import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/workspace.dart';
import '../../models/expense_draft.dart';
import '../form_card_input.dart';
import 'reimbursement_expense_item_card.dart';
import 'request_reimbursement_account_card.dart';
import 'request_reimbursement_summary_card.dart';

/// Full reimbursement section housing account card, expenses list, and summary
class RequestReimbursementSection extends StatelessWidget {
  final Workspace? workspace;
  final List<ExpenseDraft> expenses;
  final int totalExpenses;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool busy;
  final bool uploading;
  final ApiClient api;
  final String Function(DateTime) formatDate;
  final void Function(ExpenseDraft) onPickExpenseDate;
  final void Function(ExpenseDraft) onUploadReceipt;
  final VoidCallback onAddExpense;
  final void Function(ExpenseDraft) onRemoveExpense;
  final VoidCallback onChanged;

  const RequestReimbursementSection({
    super.key,
    required this.workspace,
    required this.expenses,
    required this.totalExpenses,
    required this.titleController,
    required this.descriptionController,
    required this.busy,
    required this.uploading,
    required this.api,
    required this.formatDate,
    required this.onPickExpenseDate,
    required this.onUploadReceipt,
    required this.onAddExpense,
    required this.onRemoveExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequestReimbursementAccountCard(workspace: workspace),
        SizedBox(height: 16.h),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            Text(
              'Rincian Pengeluaran *',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            TextButton.icon(
              onPressed: busy || uploading ? null : onAddExpense,
              icon: Icon(UIcons.regularRounded.plus, size: 14.sp, color: const Color(0xFF2563EB)),
              label: Text(
                'Tambah rincian',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                backgroundColor: const Color(0xFFEFF6FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return ReimbursementExpenseItemCard(
              item: expenses[index],
              index: index,
              totalCount: expenses.length,
              isDisabled: busy || uploading,
              uploading: uploading,
              api: api,
              formatDate: formatDate,
              onPickExpenseDate: onPickExpenseDate,
              onUploadReceipt: onUploadReceipt,
              onRemove: onRemoveExpense,
              onChanged: onChanged,
            );
          },
        ),
        SizedBox(height: 16.h),
        RequestReimbursementSummaryCard(
          totalAmount: totalExpenses,
          itemCount: expenses.length,
        ),
        SizedBox(height: 16.h),
        Text(
          'Judul pengajuan *',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 8.h),
        FormCardTextInput(
          controller: titleController,
          height: 48.h,
          maxLength: 160,
          hintText: 'Ringkasan keperluan Anda',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          onChanged: (_) => onChanged(),
        ),
        SizedBox(height: 16.h),
        Text(
          'Detail keperluan / referensi bukti *',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 8.h),
        FormCardTextInput(
          controller: descriptionController,
          minLines: 4,
          maxLines: 5,
          maxLength: 3000,
          showCounter: true,
          hintText: 'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
