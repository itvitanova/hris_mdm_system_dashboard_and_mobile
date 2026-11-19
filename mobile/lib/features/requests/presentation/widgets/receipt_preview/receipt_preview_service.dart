import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/offline_storage_service.dart';

class ReceiptPreviewService {
  static Future<({dynamic bytes, String contentType})> loadFile({
    required ApiClient api,
    required String path,
    String? fallbackPath,
  }) async {
    // 1. Local-first preview: lookup in private offline storage
    if (sl.isRegistered<OfflineStorageService>()) {
      final storage = sl<OfflineStorageService>();
      final pathSegments = path.split('/');
      final identifier = pathSegments.isNotEmpty ? pathSegments.last : path;
      final localFile = await storage.getSavedAttachment(identifier);
      if (localFile != null && await localFile.exists()) {
        final localBytes = await localFile.readAsBytes();
        final lowerPath = localFile.path.toLowerCase();
        final ct = lowerPath.endsWith('.pdf')
            ? 'application/pdf'
            : lowerPath.endsWith('.png')
                ? 'image/png'
                : 'image/jpeg';
        return (bytes: localBytes, contentType: ct);
      }
    }

    // 2. Fallback to network request
    try {
      final res = await api.requestFile(path);
      // Auto-cache copy to saved_attachments for future offline access
      if (sl.isRegistered<OfflineStorageService>()) {
        final pathSegments = path.split('/');
        final identifier = pathSegments.isNotEmpty ? pathSegments.last : path;
        final ext = res.contentType.contains('pdf')
            ? 'pdf'
            : (res.contentType.contains('png') ? 'png' : 'jpg');
        sl<OfflineStorageService>().saveAttachmentCopy(
          identifier: identifier,
          bytes: res.bytes,
          fileName: 'cached_doc.$ext',
        );
      }
      return (bytes: res.bytes, contentType: res.contentType);
    } catch (e) {
      if (fallbackPath != null && fallbackPath.isNotEmpty) {
        final res = await api.requestFile(fallbackPath);
        return (bytes: res.bytes, contentType: res.contentType);
      }
      rethrow;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static Future<void> shareFile({
    required BuildContext context,
    required ({dynamic bytes, String contentType}) result,
    required String title,
  }) async {
    File? temp;
    try {
      final dir = await getTemporaryDirectory();
      final ext = result.contentType.contains('pdf')
          ? 'pdf'
          : result.contentType.contains('png')
              ? 'png'
              : 'jpg';
      final safeName = title
          .replaceAll(RegExp(r'[^\w\s\.-]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      final filename = safeName.isNotEmpty
          ? '$safeName.$ext'
          : 'lampiran-${DateTime.now().millisecondsSinceEpoch}.$ext';
      temp = File('${dir.path}/$filename');
      await temp.writeAsBytes(result.bytes);
      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(temp.path, mimeType: result.contentType)],
          sharePositionOrigin:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lampiran belum dapat dibagikan: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (temp != null && await temp.exists()) {
        await temp.delete();
      }
    }
  }
}
