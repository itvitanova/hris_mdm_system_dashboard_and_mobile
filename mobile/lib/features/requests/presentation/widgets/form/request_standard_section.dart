import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_card_input.dart';
import '../form_sections/cuti_izin_form_section.dart';
import '../form_sections/overtime_form_section.dart';
import 'request_izin_type_selector.dart';
import 'request_policy_workflow_card.dart';

/// Form section for standard requests: Cuti, Izin, Lembur, and General Affair
class RequestStandardSection extends StatelessWidget {
  final String kind;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController hoursController;
  final String? selectedIzinType;
  final bool busy;
  final bool uploading;
  final DateTime start;
  final DateTime end;
  final int leaveDays;
  final String Function(DateTime) formatDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onPickDuration;
  final ValueChanged<String?> onIzinTypeChanged;
  final Widget attachmentWidget;
  final VoidCallback onChanged;

  const RequestStandardSection({
    super.key,
    required this.kind,
    required this.titleController,
    required this.descriptionController,
    required this.hoursController,
    required this.selectedIzinType,
    required this.busy,
    required this.uploading,
    required this.start,
    required this.end,
    required this.leaveDays,
    required this.formatDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onPickDuration,
    required this.onIzinTypeChanged,
    required this.attachmentWidget,
    required this.onChanged,
  });

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = busy || uploading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequestPolicyWorkflowCard(kind: kind),
        SizedBox(height: 16.h),
        if (kind == 'Izin') ...[
          RequestIzinTypeSelector(
            selectedType: selectedIzinType,
            onChanged: (v) {
              onIzinTypeChanged(v);
              onChanged();
            },
          ),
          SizedBox(height: 16.h),
        ],
        _buildSectionTitle(
          kind == 'Lembur'
              ? 'Keperluan Lembur *'
              : (kind == 'Izin' || kind == 'Reimbursement' || kind == 'General Affair')
                  ? 'Judul pengajuan *'
                  : 'Judul Pengajuan *',
        ),
        SizedBox(height: 8.h),
        FormCardTextInput(
          controller: titleController,
          height: 48.h,
          maxLength: 160,
          hintText: (kind == 'Izin' || kind == 'Reimbursement' || kind == 'General Affair')
              ? 'Ringkasan keperluan Anda'
              : 'Judul',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          onChanged: (_) => onChanged(),
        ),
        SizedBox(height: 16.h),
        if (kind == 'Lembur') ...[
          _buildSectionTitle('Tanggal & Durasi Lembur *'),
          SizedBox(height: 8.h),
          OvertimeDateDurationCard(
            hoursController: hoursController,
            dateText: formatDate(start),
            onPickDate: isDisabled ? () {} : onPickStart,
            onPickDuration: isDisabled ? () {} : onPickDuration,
          ),
        ] else ...[
          _buildSectionTitle(kind == 'Cuti' ? 'Rentang Tanggal *' : 'Periode Pengajuan'),
          SizedBox(height: 8.h),
          LeaveDateRangeCard(
            startLabel: kind == 'Cuti' ? 'Mulai' : 'Tanggal Mulai',
            endLabel: kind == 'Cuti' ? 'Selesai' : 'Tanggal Selesai',
            startDateText: formatDate(start),
            endDateText: formatDate(end),
            onPickStart: isDisabled ? () {} : onPickStart,
            onPickEnd: isDisabled ? () {} : onPickEnd,
            leaveDays: leaveDays,
            showDuration: kind == 'Cuti',
          ),
        ],
        SizedBox(height: 16.h),
        _buildSectionTitle(
          (kind == 'Izin' || kind == 'General Affair')
              ? 'Detail keperluan / referensi bukti *'
              : 'Keterangan / Alasan *',
        ),
        SizedBox(height: 8.h),
        FormCardTextInput(
          controller: descriptionController,
          minLines: 4,
          maxLines: 5,
          maxLength: 3000,
          showCounter: true,
          hintText: (kind == 'Izin' || kind == 'General Affair')
              ? 'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung'
              : 'Keperluan / rincian',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          onChanged: (_) => onChanged(),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Lampiran pendukung (opsional)'),
        SizedBox(height: 8.h),
        attachmentWidget,
      ],
    );
  }
}
