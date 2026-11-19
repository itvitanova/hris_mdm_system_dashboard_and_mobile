import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/workspace.dart';

/// Service to download and share request PDF or Excel documents
class DetailShareService {
  static Future<void> shareDocument({
    required BuildContext context,
    required ApiClient api,
    required Json request,
    required String path,
    required String name,
  }) async {
    File? file;
    try {
      final result = await api.requestFile(path);
      final dir = await getTemporaryDirectory();
      final ext = result.contentType.contains('pdf')
          ? '.pdf'
          : result.contentType.contains('png')
              ? '.png'
              : result.contentType.contains('jpeg')
                  ? '.jpg'
                  : '';
      final fileName = name.contains('.') ? name : '$name$ext';
      file = File(
          '${dir.path}/${DateTime.now().microsecondsSinceEpoch}-$fileName');
      await file.writeAsBytes(result.bytes, flush: true);
      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: result.contentType)],
          subject: text(request, 'title'),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } finally {
      if (file != null && await file.exists()) {
        await file.delete();
      }
    }
  }
}
