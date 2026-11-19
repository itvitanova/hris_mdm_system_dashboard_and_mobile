import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/widgets/core_widgets.dart';
import '../../../../../core/workspace.dart';
import '../../models/expense_draft.dart';
import '../../models/request_form_controllers.dart';
import '../form_sections/petty_cash_form_section.dart';
import 'form_date_utils.dart';
import 'medical_claim_web_aligned_section.dart';
import 'petty_cash_web_aligned_section.dart';
import 'request_kind_picker_bottom_sheet.dart';
import 'request_reimbursement_section.dart';
import 'request_standard_section.dart';
import 'request_test_compatibility_picker.dart';

/// Scrollable form body hosting dynamic sections based on selected request kind
class RequestFormBody extends StatelessWidget {
  final RequestFormControllers c;
  final String kind;
  final int currentAmount, leaveDays, totalExpenses;
  final DateTime start, end;
  final List<ExpenseDraft> expenses;
  final bool busy, uploading, lockKindSelection;
  final String? error, selectedIzinType;
  final Workspace? workspace;
  final ApiClient api;
  final Widget attachmentWidget;
  final ValueChanged<String> onKindSelected;
  final VoidCallback onPickStart, onPickEnd, onPickDuration, onAddExpense, onChanged;
  final void Function(ExpenseDraft) onExpenseDate, onUploadExpenseReceipt, onRemoveExpense;
  final ValueChanged<String?> onIzinTypeChanged;

  const RequestFormBody({
    super.key,
    required this.c,
    required this.kind,
    required this.currentAmount,
    required this.leaveDays,
    required this.totalExpenses,
    required this.start,
    required this.end,
    required this.expenses,
    required this.busy,
    required this.uploading,
    required this.lockKindSelection,
    required this.error,
    required this.selectedIzinType,
    required this.workspace,
    required this.api,
    required this.attachmentWidget,
    required this.onKindSelected,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onPickDuration,
    required this.onExpenseDate,
    required this.onUploadExpenseReceipt,
    required this.onAddExpense,
    required this.onRemoveExpense,
    required this.onIzinTypeChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 24.h),
        child: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              RequestTestCompatibilityPicker(
                controller: c.kindSearch,
                enabled: !busy && !uploading && !lockKindSelection,
                initialSelection: kind,
                onSelected: onKindSelected,
              ),
              if (kind == 'Petty Cash')
                PettyCashWebAlignedSection(
                  titleController: c.title,
                  descriptionController: c.description,
                  amountWidget: PettyCashAmountCard(
                    controller: c.amount,
                    currentAmount: currentAmount,
                    onAmountSelected: (val) {
                      c.amount.text = formatThousand(val);
                      onChanged();
                    },
                    onClear: () {
                      c.amount.clear();
                      onChanged();
                    },
                  ),
                  start: start,
                  end: end,
                  formatDate: formatDisplayDate,
                  onPickStart: onPickStart,
                  onPickEnd: onPickEnd,
                  onKindTap: () => RequestKindPickerBottomSheet.show(
                    context,
                    currentKind: kind,
                    onSelected: onKindSelected,
                  ),
                  onChanged: onChanged,
                )
              else if (kind == 'Medical Claim')
                MedicalClaimWebAlignedSection(
                  titleController: c.title,
                  descriptionController: c.description,
                  amountController: c.amount,
                  workspace: workspace,
                  start: start,
                  end: end,
                  formatDate: formatDisplayDate,
                  onPickStart: onPickStart,
                  onPickEnd: onPickEnd,
                  attachmentWidget: attachmentWidget,
                  onChanged: onChanged,
                )
              else if (kind == 'Reimbursement')
                RequestReimbursementSection(
                  workspace: workspace,
                  expenses: expenses,
                  totalExpenses: totalExpenses,
                  titleController: c.title,
                  descriptionController: c.description,
                  busy: busy,
                  uploading: uploading,
                  api: api,
                  formatDate: formatDisplayDate,
                  onPickExpenseDate: onExpenseDate,
                  onUploadReceipt: onUploadExpenseReceipt,
                  onAddExpense: onAddExpense,
                  onRemoveExpense: onRemoveExpense,
                  onChanged: onChanged,
                )
              else
                RequestStandardSection(
                  kind: kind,
                  titleController: c.title,
                  descriptionController: c.description,
                  hoursController: c.hours,
                  selectedIzinType: selectedIzinType,
                  busy: busy,
                  uploading: uploading,
                  start: start,
                  end: end,
                  leaveDays: leaveDays,
                  formatDate: formatDisplayDate,
                  onPickStart: onPickStart,
                  onPickEnd: onPickEnd,
                  onPickDuration: onPickDuration,
                  onIzinTypeChanged: onIzinTypeChanged,
                  attachmentWidget: attachmentWidget,
                  onChanged: onChanged,
                ),
              if (error != null) ...[
                SizedBox(height: 16.h),
                ErrorNotice(error!),
              ],
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
