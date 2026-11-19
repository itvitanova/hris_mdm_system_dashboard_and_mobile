import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/offline_storage_service.dart';
import '../../../../../core/workspace.dart';
import '../../models/expense_draft.dart';

/// Helper class to construct payload and persist/collect attachments
class RequestSubmissionService {
  static Map<String, dynamic> buildPayload({
    required String kind,
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    required List<ExpenseDraft> expenses,
    required int totalExpenses,
    required int currentAmount,
    required bool hasAmount,
    required String? hours,
    required String? selectedIzinType,
    required String? selectedAttachmentId,
    required Json? initialRequest,
    required int revision,
    required String gaCategory,
    required String gaPriority,
    required String location,
    required String? attachmentName,
  }) {
    String fullDescription = description.trim();
    if (kind == 'General Affair') {
      final meta = [
        'Kategori: $gaCategory',
        'Prioritas: $gaPriority',
        if (location.isNotEmpty) 'Lokasi: $location',
        if (attachmentName != null && attachmentName.isNotEmpty) 'Lampiran: $attachmentName',
      ].join(' · ');
      fullDescription = fullDescription.isNotEmpty ? '$fullDescription\n\n[$meta]' : '[$meta]';
    } else if (kind == 'Izin') {
      final meta = [
        if (selectedIzinType != null && selectedIzinType.isNotEmpty)
          'Jenis Izin: $selectedIzinType',
        if (attachmentName != null && attachmentName.isNotEmpty) 'Lampiran: $attachmentName',
      ].join(' · ');
      if (meta.isNotEmpty) {
        fullDescription = fullDescription.isNotEmpty ? '$fullDescription\n\n[$meta]' : '[$meta]';
      }
    } else if (kind == 'Cuti') {
      final meta = [
        if (attachmentName != null && attachmentName.isNotEmpty) 'Lampiran: $attachmentName',
      ].join(' · ');
      if (meta.isNotEmpty) {
        fullDescription = fullDescription.isNotEmpty ? '$fullDescription\n\n[$meta]' : '[$meta]';
      }
    }

    DateTime reimbursementStart = start;
    DateTime reimbursementEnd = end;
    if (kind == 'Reimbursement' && expenses.isNotEmpty) {
      final sortedDates = expenses.map((e) => e.date).toList()..sort();
      reimbursementStart = sortedDates.first;
      reimbursementEnd = sortedDates.last;
    }

    final isRevision = initialRequest != null;

    return {
      'kind': kind,
      'title': title.trim(),
      'description': fullDescription,
      'startDate': dateOnly(kind == 'Reimbursement' ? reimbursementStart : start),
      'endDate': dateOnly(kind == 'Reimbursement'
          ? reimbursementEnd
          : (kind == 'Lembur' || kind == 'General Affair' ? start : end)),
      if (isRevision) ...{
        'id': initialRequest['id'].toString(),
        'revision': revision,
      },
      if (kind == 'Reimbursement') ...{
        'items': expenses.map((e) => e.json()).toList(),
        'amount': totalExpenses,
      } else if (hasAmount) ...{
        'amount': currentAmount,
      } else if (kind == 'General Affair' || kind == 'Cuti' || kind == 'Izin' || kind == 'Lembur') ...{
        'amount': 0,
      },
      if (kind == 'Izin' && selectedIzinType != null && selectedIzinType.isNotEmpty) ...{
        'permissionType': selectedIzinType,
      },
      if (kind != 'Reimbursement') ...{
        if (selectedAttachmentId != null && selectedAttachmentId.isNotEmpty) ...{
          'attachmentId': selectedAttachmentId,
        } else if (initialRequest != null &&
            initialRequest['attachmentId'] != null &&
            initialRequest['attachmentId'].toString().isNotEmpty) ...{
          'attachmentId': initialRequest['attachmentId'].toString(),
        },
      },
      if (kind == 'Lembur')
        'hours': (int.tryParse(hours ?? '') ??
            (double.tryParse((hours ?? '').replaceAll(',', '.'))?.toInt() ?? 0)),
    };
  }

  static Future<void> persistAttachmentCopies({
    required String kind,
    required List<ExpenseDraft> expenses,
    required String? selectedAttachmentId,
    required String? selectedAttachmentName,
    required Uint8List? selectedAttachmentBytes,
    required String? stagedAttachmentPath,
  }) async {
    final offlineStorage =
        sl.isRegistered<OfflineStorageService>() ? sl<OfflineStorageService>() : null;
    if (offlineStorage == null) return;

    if (kind == 'Reimbursement') {
      for (final e in expenses) {
        if (e.stagedPath != null && e.fileBytes != null) {
          try {
            await File(e.stagedPath!).writeAsBytes(e.fileBytes!);
          } catch (_) {}
        }
      }
    } else {
      if (stagedAttachmentPath != null && selectedAttachmentBytes != null) {
        try {
          await File(stagedAttachmentPath).writeAsBytes(selectedAttachmentBytes);
        } catch (_) {}
      }
    }
  }

  static List<Map<String, dynamic>> collectStagedAttachments({
    required String kind,
    required List<ExpenseDraft> expenses,
    required String? stagedAttachmentPath,
    required String? selectedAttachmentName,
  }) {
    final staged = <Map<String, dynamic>>[];
    if (kind == 'Reimbursement') {
      for (final e in expenses) {
        if (e.stagedPath != null) {
          staged.add({
            'tempId': e.receiptId,
            'fileName': e.receiptName,
            'stagedPath': e.stagedPath,
            'type': 'receipt',
          });
        }
      }
    } else {
      if (stagedAttachmentPath != null && selectedAttachmentName != null) {
        staged.add({
          'tempId': 'temp_attachment',
          'fileName': selectedAttachmentName,
          'stagedPath': stagedAttachmentPath,
          'type': 'general',
        });
      }
    }
    return staged;
  }
}
