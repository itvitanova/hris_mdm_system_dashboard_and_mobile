import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'detail_decision_modal_actions.dart';
import 'detail_decision_modal_header.dart';
import 'detail_quick_note_chips.dart';

/// Modal bottom sheet for decision note entry on approval, revision, or rejection
class DetailDecisionModal {
  static Future<String?> show(
    BuildContext context, {
    required String decision,
    required String requestTitle,
  }) async {
    final note = TextEditingController();
    final scrollController = ScrollController();
    final focusNode = FocusNode();
    final isApproved = decision == 'Disetujui';
    final isRevision = decision == 'Perlu revisi';

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    final titleText = isApproved
        ? 'Setujui Pengajuan'
        : isRevision
            ? 'Minta Revisi Pengajuan'
            : 'Tolak Pengajuan';

    final themeColor = isApproved
        ? const Color(0xFF0F766E)
        : isRevision
            ? const Color(0xFFD97706)
            : const Color(0xFFE11D48);

    final quickChips = isApproved
        ? [
            'Bukti lengkap & valid',
            'Sesuai anggaran',
            'Semua rincian disetujui'
          ]
        : isRevision
            ? [
                'Nota kurang jelas/terbaca',
                'Lengkapi bukti fisik',
                'Perbaiki rincian biaya'
              ]
            : [
                'Di luar ketentuan perusahaan',
                'Klaim ganda/duplikat',
                'Anggaran tidak tersedia'
              ];

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailDecisionModalHeader(
                      titleText: titleText,
                      requestTitle: requestTitle,
                      themeColor: themeColor,
                      isApproved: isApproved,
                      isRevision: isRevision,
                    ),
                    SizedBox(height: 16.h),
                    DetailQuickNoteChips(
                      quickChips: quickChips,
                      themeColor: themeColor,
                      selectedText: note.text,
                      onSelect: (chip) {
                        setSheetState(() {
                          note.text = chip;
                          note.selection = TextSelection.fromPosition(
                            TextPosition(offset: note.text.length),
                          );
                        });
                      },
                    ),
                    SizedBox(height: 14.h),
                    TextField(
                      controller: note,
                      focusNode: focusNode,
                      scrollPadding: EdgeInsets.only(bottom: 140.h),
                      maxLines: 3,
                      maxLength: 2000,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        labelText: isApproved
                            ? 'Catatan (opsional)'
                            : 'Catatan wajib diisi',
                        labelStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                        hintText: isApproved
                            ? 'Tambahkan catatan persetujuan...'
                            : 'Jelaskan alasan penolakan atau revisi...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide:
                              BorderSide(color: themeColor, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    DetailDecisionModalActions(
                      themeColor: themeColor,
                      onCancel: () => Navigator.pop(ctx),
                      onSubmit: () => Navigator.pop(ctx, note.text.trim()),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    note.dispose();
    scrollController.dispose();
    focusNode.dispose();
    return result;
  }
}
