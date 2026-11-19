import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/network_connectivity_service.dart';
import '../../../../../core/services/offline_storage_service.dart';
import '../../../../../core/utils/image_compressor.dart';
import '../../../../../core/workspace.dart';
import '../../models/expense_draft.dart';

/// Helper to handle receipt and general attachment file picking, compressing, and staging
class RequestAttachmentHandler {
  static Future<void> uploadExpenseReceipt({
    required ExpenseDraft item,
    required ApiClient api,
    required void Function(bool uploading) onUploading,
    required void Function(String? error) onError,
  }) async {
    onUploading(true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (file == null) return;
      var bytes = await file.readAsBytes();
      bytes = await ImageCompressor.compressIfNeeded(bytes, fileName: file.name);
      if (bytes.length > ImageCompressor.maxFileSizeBytes) {
        throw ApiException('Bukti transaksi maksimal 2 MB.');
      }
      final isOnline = sl.isRegistered<NetworkConnectivityService>()
          ? sl<NetworkConnectivityService>().isOnline
          : true;
      if (isOnline) {
        try {
          final res = await api.postJson('/request-receipts', {
            'name': file.name,
            'fileBase64': base64Encode(bytes),
          });
          item.receiptId = text(res, 'id', '');
          item.receiptName = file.name;
          item.fileBytes = bytes;
          onError(null);
          return;
        } catch (_) {}
      }
      final staged = sl.isRegistered<OfflineStorageService>()
          ? await sl<OfflineStorageService>().stageAttachment(
              fileName: file.name,
              bytes: bytes,
            )
          : null;
      item.receiptId = 'temp_offline_${DateTime.now().millisecondsSinceEpoch}';
      item.receiptName = file.name;
      item.stagedPath = staged;
      item.fileBytes = bytes;
      onError(null);
    } catch (e) {
      onError(e.toString());
    } finally {
      onUploading(false);
    }
  }

  static Future<void> pickGeneralAttachment({
    required ApiClient api,
    required void Function(bool uploading) onUploading,
    required void Function({
      required String name,
      required String id,
      required Uint8List bytes,
      String? stagedPath,
    }) onSuccess,
  }) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null) return;
      onUploading(true);
      try {
        final raw = await file.readAsBytes();
        final bytes = await ImageCompressor.compressIfNeeded(raw, fileName: file.name);
        if (bytes.length <= ImageCompressor.maxFileSizeBytes) {
          final isOnline = sl.isRegistered<NetworkConnectivityService>()
              ? sl<NetworkConnectivityService>().isOnline
              : true;
          if (isOnline) {
            try {
              final r = await api.postJson('/request-receipts', {
                'name': file.name,
                'fileBase64': base64Encode(bytes),
              });
              onSuccess(name: file.name, id: text(r, 'id', ''), bytes: bytes);
              return;
            } catch (_) {}
          }
          final staged = sl.isRegistered<OfflineStorageService>()
              ? await sl<OfflineStorageService>().stageAttachment(
                  fileName: file.name,
                  bytes: bytes,
                )
              : null;
          final tempId = 'temp_offline_${DateTime.now().millisecondsSinceEpoch}';
          onSuccess(name: file.name, id: tempId, bytes: bytes, stagedPath: staged);
        }
      } finally {
        onUploading(false);
      }
    } catch (_) {}
  }
}
