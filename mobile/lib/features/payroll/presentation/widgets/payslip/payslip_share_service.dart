import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/widgets/core_widgets.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Helper service for generating and sharing payslip PDF documents
class PayslipShareService {
  static Future<void> share({
    required BuildContext context,
    required ApiClient api,
    required Json slip,
    required void Function(bool) onBusyChanged,
  }) async {
    onBusyChanged(true);
    File? file;
    try {
      final bytes = await api.payslip(text(slip, 'id'));
      final directory = await getTemporaryDirectory();
      final period = text(slip, 'period').replaceAll(RegExp(r'[^0-9-]'), '');
      file = File(
        '${directory.path}/slip-$period-${DateTime.now().microsecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'Slip gaji $period',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (context.mounted) notify(context, e);
    } finally {
      if (file != null && await file.exists()) await file.delete();
      onBusyChanged(false);
    }
  }
}
