import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/offline_storage_service.dart';
import '../form_sections/attachment_card.dart';
import 'request_attachment_handler.dart';

/// Form attachment card wrapper integrating general attachment pick, compress, and clear logic
class RequestAttachmentSectionCard extends StatelessWidget {
  final ApiClient api;
  final String? attachmentName;
  final String? stagedAttachmentPath;
  final ValueChanged<bool> onUploading;
  final void Function({
    required String name,
    required String id,
    required Uint8List bytes,
    String? stagedPath,
  }) onAttachmentSelected;
  final VoidCallback onClearAttachment;

  const RequestAttachmentSectionCard({
    super.key,
    required this.api,
    required this.attachmentName,
    required this.stagedAttachmentPath,
    required this.onUploading,
    required this.onAttachmentSelected,
    required this.onClearAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return FormAttachmentCard(
      attachmentName: attachmentName,
      onPickAttachment: () => RequestAttachmentHandler.pickGeneralAttachment(
        api: api,
        onUploading: onUploading,
        onSuccess: onAttachmentSelected,
      ),
      onClearAttachment: () {
        if (stagedAttachmentPath != null && sl.isRegistered<OfflineStorageService>()) {
          sl<OfflineStorageService>().deleteStagedAttachment(stagedAttachmentPath!);
        }
        onClearAttachment();
      },
    );
  }
}
