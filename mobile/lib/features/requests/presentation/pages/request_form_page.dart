import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../models/expense_draft.dart';
import '../models/request_form_controllers.dart';
import '../widgets/form/form_date_utils.dart';
import '../widgets/form/request_attachment_handler.dart';
import '../widgets/form/request_attachment_section_card.dart';
import '../widgets/form/request_form_app_bar.dart';
import '../widgets/form/request_form_body.dart';
import '../widgets/form/request_form_bottom_bar.dart';
import '../widgets/form/request_form_initial_data.dart';
import '../widgets/form/request_form_submitter.dart';

export '../models/expense_draft.dart';
export '../widgets/form/expense_item_date_category.dart' show reimbursementCategories;
export '../widgets/form/request_kind_picker_bottom_sheet.dart' show requestKinds;

class RequestForm extends StatefulWidget {
  const RequestForm({
    super.key,
    required this.api,
    this.initialKind = 'Cuti',
    this.initialRequest,
    this.workspace,
    this.lockKindSelection = false,
  });

  final ApiClient api;
  final String initialKind;
  final Json? initialRequest;
  final Workspace? workspace;
  final bool lockKindSelection;

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  late final c = RequestFormControllers(
    initialKind: text(widget.initialRequest ?? {}, 'kind', widget.initialKind),
  );
  late String kind = text(widget.initialRequest ?? {}, 'kind', widget.initialKind);
  DateTime start = DateTime.now(), end = DateTime.now();
  bool busy = false, uploading = false;
  final expenses = <ExpenseDraft>[];
  String? error, selectedIzinType;
  String gaCategory = 'Pengadaan Barang', gaPriority = 'Normal';
  String? _selectedAttachmentName, _selectedAttachmentId, _stagedAttachmentPath;
  Uint8List? _selectedAttachmentBytes;

  int get currentAmount => int.tryParse(c.amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int get leaveDays => (DateTime(end.year, end.month, end.day).difference(DateTime(start.year, start.month, start.day)).inDays + 1).clamp(1, 9999);
  int get totalExpenses => expenses.fold<int>(0, (s, e) => s + (int.tryParse(e.amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? ((int.tryParse(e.qty.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1) * (int.tryParse(e.unitPrice.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0))));

  String get formTitle => widget.initialRequest != null ? 'Perbaiki pengajuan' : 'Formulir Pengajuan $kind';
  String get formSubtitle => 'Lengkapi formulir sesuai data pengajuan Anda';

  @override
  void initState() {
    super.initState();
    if (widget.initialRequest != null) {
      RequestFormInitialData.populateControllers(
        r: widget.initialRequest!, c: c, expenses: expenses,
        onMeta: (cat, prio, izin, aName, aId, s, e) {
          gaCategory = cat; gaPriority = prio; selectedIzinType = izin;
          _selectedAttachmentName = aName; _selectedAttachmentId = aId;
          if (s != null) start = s; if (e != null) end = e;
        },
      );
    } else {
      expenses.add(ExpenseDraft({}));
    }
  }

  @override
  void dispose() {
    c.dispose();
    for (final e in expenses) { e.dispose(); }
    super.dispose();
  }

  void _setAttachment({String? name, String? id, Uint8List? bytes, String? path}) {
    if (mounted) setState(() { _selectedAttachmentName = name; _selectedAttachmentId = id; _selectedAttachmentBytes = bytes; _stagedAttachmentPath = path; });
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await pickRequestDate(context, initial: isStart ? start : end, isStart: isStart);
    if (picked != null && mounted) {
      setState(() {
        if (isStart) { start = picked; if (end.isBefore(start)) end = start; } else { end = picked; }
        if (kind == 'Lembur') end = start;
      });
    }
  }

  Future<void> _submit() async {
    if (busy || uploading) return;
    await RequestFormSubmitter.submit(
      context: context, c: c, kind: kind, start: start, end: end, expenses: expenses,
      totalExpenses: totalExpenses, currentAmount: currentAmount, selectedIzinType: selectedIzinType,
      selectedAttachmentId: _selectedAttachmentId, selectedAttachmentName: _selectedAttachmentName,
      selectedAttachmentBytes: _selectedAttachmentBytes, stagedAttachmentPath: _stagedAttachmentPath,
      initialRequest: widget.initialRequest, gaCategory: gaCategory, gaPriority: gaPriority,
      workspace: widget.workspace, api: widget.api,
      onBusy: (b) => setState(() => busy = b), onError: (e) => setState(() => error = e),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), minTextAdapt: true,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: RequestFormAppBar(title: formTitle, subtitle: formSubtitle, onBack: () => Navigator.pop(context)),
        body: RequestFormBody(
          c: c, kind: kind, currentAmount: currentAmount, leaveDays: leaveDays,
          totalExpenses: totalExpenses, start: start, end: end, expenses: expenses,
          busy: busy, uploading: uploading, lockKindSelection: widget.lockKindSelection,
          error: error, selectedIzinType: selectedIzinType, workspace: widget.workspace, api: widget.api,
          attachmentWidget: RequestAttachmentSectionCard(
            api: widget.api, attachmentName: _selectedAttachmentName, stagedAttachmentPath: _stagedAttachmentPath,
            onUploading: (u) => setState(() => uploading = u),
            onAttachmentSelected: ({required name, required id, required bytes, stagedPath}) =>
                _setAttachment(name: name, id: id, bytes: bytes, path: stagedPath),
            onClearAttachment: () => _setAttachment(),
          ),
          onKindSelected: (k) => setState(() {
            kind = k; c.kindSearch.text = k;
            if (kind == 'Lembur' || kind == 'General Affair') end = start;
          }),
          onPickStart: () => pickDate(true), onPickEnd: () => pickDate(false),
          onPickDuration: () async {
            final sel = await pickOvertimeHours(context, currentHours: int.tryParse(c.hours.text) ?? 1);
            if (sel != null && mounted) setState(() => c.hours.text = sel.toString());
          },
          onExpenseDate: (item) async {
            final next = await pickExpenseTransactionDate(context, initial: item.date);
            if (next != null && mounted) setState(() => item.date = next);
          },
          onUploadExpenseReceipt: (item) => RequestAttachmentHandler.uploadExpenseReceipt(
            item: item, api: widget.api,
            onUploading: (u) => setState(() => uploading = u),
            onError: (e) => setState(() => error = e),
          ),
          onAddExpense: () => setState(() => expenses.add(ExpenseDraft({}))),
          onRemoveExpense: (e) => setState(() { expenses.remove(e); e.dispose(); }),
          onIzinTypeChanged: (v) => setState(() => selectedIzinType = v),
          onChanged: () => setState(() {}),
        ),
        bottomNavigationBar: RequestFormBottomBar(
          busy: busy, uploading: uploading,
          onCancel: () => Navigator.pop(context), onSubmit: _submit,
        ),
      ),
    );
  }
}

typedef RequestFormPage = RequestForm;
