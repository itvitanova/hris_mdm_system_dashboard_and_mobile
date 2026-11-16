import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../utils/image_compressor.dart';
import '../workspace.dart';
import 'network_connectivity_service.dart';
import 'offline_storage_service.dart';

typedef SyncCallback = void Function();

class OfflineSyncManager {
  OfflineSyncManager({
    required this.apiClient,
    required this.offlineStorage,
    required this.connectivityService,
    this.onSyncCompleted,
  });

  final ApiClient apiClient;
  final OfflineStorageService offlineStorage;
  final NetworkConnectivityService connectivityService;
  final SyncCallback? onSyncCompleted;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  final ValueNotifier<int> pendingCountNotifier = ValueNotifier<int>(0);

  void initialize() {
    connectivityService.isOnlineNotifier.addListener(_onConnectivityChanged);
    updatePendingCount();
  }

  Future<void> updatePendingCount() async {
    final queue = await offlineStorage.loadQueue();
    pendingCountNotifier.value = queue.length;
  }

  void _onConnectivityChanged() {
    if (connectivityService.isOnline) {
      syncPendingRequests();
    }
  }

  Future<void> syncPendingRequests() async {
    if (_isSyncing) return;
    if (!connectivityService.isOnline) return;

    final queue = await offlineStorage.loadQueue();
    if (queue.isEmpty) {
      pendingCountNotifier.value = 0;
      return;
    }

    _isSyncing = true;
    try {
      final itemsToProcess = List<Map<String, dynamic>>.from(queue);
      for (final item in itemsToProcess) {
        final id = item['id']?.toString() ?? '';
        final payload = Map<String, dynamic>.from(item['payload'] as Map);
        final stagedAttachments = (item['stagedAttachments'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];

        bool uploadError = false;

        // 1. Process and upload any staged attachments
        for (final att in stagedAttachments) {
          final targetType = att['type']?.toString() ?? 'attachment';
          final filePath = att['path']?.toString() ?? '';
          final fileName = att['name']?.toString() ?? 'bukti.jpg';

          final file = File(filePath);
          if (await file.exists()) {
            try {
              var bytes = await file.readAsBytes();
              bytes = await ImageCompressor.compressIfNeeded(
                bytes,
                fileName: fileName,
              );
              final result = await apiClient.postJson('/request-receipts', {
                'name': fileName,
                'fileBase64': base64Encode(bytes),
              });
              final serverReceiptId = text(result, 'id', '');

              if (targetType == 'receipt') {
                final itemIndex = (att['itemIndex'] as num?)?.toInt() ?? 0;
                final items = List<Map<String, dynamic>>.from(
                  (payload['items'] as List?)
                          ?.map((e) => Map<String, dynamic>.from(e as Map)) ??
                      [],
                );
                if (itemIndex >= 0 && itemIndex < items.length) {
                  final oldTempId =
                      items[itemIndex]['receiptId']?.toString() ?? '';
                  items[itemIndex]['receiptId'] = serverReceiptId;
                  payload['items'] = items;
                  if (oldTempId.isNotEmpty) {
                    await offlineStorage.linkSavedAttachment(
                      oldIdentifier: oldTempId,
                      newIdentifier: serverReceiptId,
                    );
                  }
                }
              } else {
                final oldTempId = payload['attachmentId']?.toString() ?? '';
                payload['attachmentId'] = serverReceiptId;
                if (oldTempId.isNotEmpty) {
                  await offlineStorage.linkSavedAttachment(
                    oldIdentifier: oldTempId,
                    newIdentifier: serverReceiptId,
                  );
                }
              }

              // Also ensure a permanent copy is indexed under the new serverReceiptId
              await offlineStorage.saveAttachmentCopy(
                identifier: serverReceiptId,
                bytes: bytes,
                fileName: fileName,
              );

              // Clean up staged temporary file from disk after successful upload
              await offlineStorage.deleteStagedAttachment(filePath);
            } catch (e) {
              uploadError = true;
              debugPrint('Error uploading staged attachment: $e');
              break;
            }
          }
        }

        if (uploadError) {
          // If attachment upload failed, break out and retry on next connection
          break;
        }

        // 2. Dispatch the actual request
        try {
          await apiClient.post('/requests', payload);
          // 3. Dequeue successfully synced item
          await offlineStorage.dequeueRequest(id);
        } catch (e) {
          debugPrint('Error dispatching queued request $id: $e');
          // If server or network error, stop processing rest of queue
          break;
        }
      }

      await updatePendingCount();
      onSyncCompleted?.call();
    } catch (e) {
      debugPrint('OfflineSyncManager sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    connectivityService.isOnlineNotifier.removeListener(_onConnectivityChanged);
    pendingCountNotifier.dispose();
  }
}
