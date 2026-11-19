import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/api_client.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/network_connectivity_service.dart';
import '../../../../../core/services/offline_storage_service.dart';
import '../../../../../core/services/offline_sync_manager.dart';
import '../../../../../core/widgets/core_widgets.dart';
import '../../../../../core/workspace.dart';
import '../../../../home/presentation/bloc/workspace_bloc.dart';
import '../../../../home/presentation/bloc/workspace_event.dart';
import '../../bloc/request_bloc.dart';
import '../../bloc/request_event.dart';
import '../../models/expense_draft.dart';
import '../../models/request_form_controllers.dart';
import 'request_submission_service.dart';

/// Handles validation, payload creation, and dispatching request submission online or offline
class RequestFormSubmitter {
  static Future<bool> submit({
    required BuildContext context,
    required RequestFormControllers c,
    required String kind,
    required DateTime start,
    required DateTime end,
    required List<ExpenseDraft> expenses,
    required int totalExpenses,
    required int currentAmount,
    required String? selectedIzinType,
    required String? selectedAttachmentId,
    required String? selectedAttachmentName,
    required Uint8List? selectedAttachmentBytes,
    required String? stagedAttachmentPath,
    required Json? initialRequest,
    required String gaCategory,
    required String gaPriority,
    required Workspace? workspace,
    required ApiClient api,
    required void Function(bool busy) onBusy,
    required void Function(String? error) onError,
  }) async {
    if (!c.formKey.currentState!.validate()) {
      notify(context, 'Mohon lengkapi formulir sebelum mengirim.');
      return false;
    }

    if (kind == 'Reimbursement') {
      if (expenses.isEmpty || expenses.any((e) => e.receiptId.isEmpty)) {
        final msg = expenses.isEmpty
            ? 'Tambahkan minimal satu rincian pengeluaran.'
            : 'Unggah bukti untuk setiap rincian pengeluaran.';
        onError(msg);
        notify(context, 'Perhatian: $msg');
        return false;
      }
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      if (expenses.any((e) => DateTime(e.date.year, e.date.month, e.date.day).isAfter(today))) {
        const msg = 'Tanggal transaksi tidak boleh di masa depan.';
        onError(msg);
        notify(context, 'Perhatian: $msg');
        return false;
      }
    } else if (end.isBefore(start)) {
      const msg = 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
      onError(msg);
      notify(context, 'Perhatian: $msg');
      return false;
    }

    onBusy(true);
    onError(null);

    try {
      final payload = RequestSubmissionService.buildPayload(
        kind: kind,
        title: c.title.text,
        description: c.description.text,
        start: start,
        end: end,
        expenses: expenses,
        totalExpenses: totalExpenses,
        currentAmount: currentAmount,
        hasAmount: kind == 'Petty Cash' || kind == 'Medical Claim',
        hours: c.hours.text,
        selectedIzinType: selectedIzinType,
        selectedAttachmentId: selectedAttachmentId,
        initialRequest: initialRequest,
        revision: (initialRequest?['revision'] as num?)?.toInt() ?? 0,
        gaCategory: gaCategory,
        gaPriority: gaPriority,
        location: c.location.text,
        attachmentName: selectedAttachmentName,
      );

      await RequestSubmissionService.persistAttachmentCopies(
        kind: kind,
        expenses: expenses,
        selectedAttachmentId: selectedAttachmentId,
        selectedAttachmentName: selectedAttachmentName,
        selectedAttachmentBytes: selectedAttachmentBytes,
        stagedAttachmentPath: stagedAttachmentPath,
      );

      final staged = RequestSubmissionService.collectStagedAttachments(
        kind: kind,
        expenses: expenses,
        stagedAttachmentPath: stagedAttachmentPath,
        selectedAttachmentName: selectedAttachmentName,
      );

      final isOnline = sl.isRegistered<NetworkConnectivityService>()
          ? sl<NetworkConnectivityService>().isOnline
          : true;
      bool queueOffline = !isOnline || staged.isNotEmpty;

      if (!queueOffline) {
        try {
          await api.post('/requests', payload);
        } catch (e) {
          if (e is SocketException ||
              e is http.ClientException ||
              (e is ApiException && (e.status == 0 || e.message.contains('jaringan')))) {
            queueOffline = true;
          } else {
            rethrow;
          }
        }
      }

      if (queueOffline) {
        final qItem = {
          'id': 'OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
          'kind': kind,
          'title': c.title.text.trim().isNotEmpty ? c.title.text.trim() : 'Pengajuan $kind',
          'notes': c.description.text.trim(),
          'payload': payload,
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'Menunggu Sinkronisasi',
          'stagedAttachments': staged,
          'employeeId': workspace?.actor['employeeId']?.toString() ?? '',
          'employeeName': workspace?.actor['name']?.toString() ?? 'Karyawan',
          'department': workspace?.employee['department']?.toString(),
        };
        if (sl.isRegistered<OfflineStorageService>()) {
          await sl<OfflineStorageService>().enqueueRequest(qItem);
        }
        if (sl.isRegistered<OfflineSyncManager>()) {
          sl<OfflineSyncManager>().updatePendingCount();
        }
        if (sl.isRegistered<WorkspaceBloc>()) {
          sl<WorkspaceBloc>().add(const WorkspaceRefreshRequested());
        }
        if (sl.isRegistered<RequestBloc>()) {
          sl<RequestBloc>().add(RequestLoadRequested(kind: kind));
        }
        if (context.mounted) {
          notify(context, 'Pengajuan tersimpan di perangkat. Akan otomatis dikirim saat online.');
          Navigator.pop(context, true);
        }
        return true;
      }

      if (sl.isRegistered<WorkspaceBloc>()) {
        sl<WorkspaceBloc>().add(const WorkspaceRefreshRequested());
      }
      if (sl.isRegistered<RequestBloc>()) {
        sl<RequestBloc>().add(RequestLoadRequested(kind: kind));
      }
      if (context.mounted) {
        final successMsg = initialRequest != null
            ? 'Pengajuan yang direvisi telah berhasil dikirim.'
            : 'Pengajuan berhasil dikirim.';
        notify(context, successMsg);
        Navigator.pop(context, true);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        final errText = e.toString().replaceFirst('Exception: ', '');
        onError(errText);
        notify(context, 'Gagal mengirim pengajuan: $errText');
      }
      return false;
    } finally {
      onBusy(false);
    }
  }
}
