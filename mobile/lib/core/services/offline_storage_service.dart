import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class OfflineStorageService {
  OfflineStorageService({Directory? baseDirectory})
      : _overrideDirectory = baseDirectory;

  final Directory? _overrideDirectory;

  static const String _workspaceCacheFile = 'workspace_cache.json';
  static const String _queueFile = 'offline_request_queue.json';
  static const String _attachmentsDirName = 'offline_attachments';
  static const String _savedAttachmentsDirName = 'saved_attachments';

  Future<Directory> get _baseDir async =>
      _overrideDirectory ?? await getApplicationDocumentsDirectory();

  Future<File> _getFile(String filename) async {
    final dir = await _baseDir;
    return File('${dir.path}${Platform.pathSeparator}$filename');
  }

  Future<Directory> get _attachmentsDir async {
    final dir = await _baseDir;
    final attachDir = Directory(
      '${dir.path}${Platform.pathSeparator}$_attachmentsDirName',
    );
    if (!await attachDir.exists()) {
      await attachDir.create(recursive: true);
    }
    return attachDir;
  }

  Future<Directory> get _savedAttachmentsDir async {
    final dir = await _baseDir;
    final savedDir = Directory(
      '${dir.path}${Platform.pathSeparator}$_savedAttachmentsDirName',
    );
    if (!await savedDir.exists()) {
      await savedDir.create(recursive: true);
    }
    return savedDir;
  }

  // --- Workspace Cache ---

  Future<void> saveWorkspaceCache(Map<String, dynamic> data) async {
    try {
      final file = await _getFile(_workspaceCacheFile);
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      debugPrint('Failed to save workspace cache: $e');
    }
  }

  Future<Map<String, dynamic>?> loadWorkspaceCache() async {
    try {
      final file = await _getFile(_workspaceCacheFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load workspace cache: $e');
    }
    return null;
  }

  Future<void> clearWorkspaceCache() async {
    try {
      final file = await _getFile(_workspaceCacheFile);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to clear workspace cache: $e');
    }
  }

  // --- Offline Request Queue (Outbox) ---

  Future<List<Map<String, dynamic>>> loadQueue() async {
    try {
      final file = await _getFile(_queueFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            return decoded
                .whereType<Map>()
                .map((m) => Map<String, dynamic>.from(m))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load offline queue: $e');
    }
    return [];
  }

  Future<void> saveQueue(List<Map<String, dynamic>> queue) async {
    try {
      final file = await _getFile(_queueFile);
      await file.writeAsString(jsonEncode(queue), flush: true);
    } catch (e) {
      debugPrint('Failed to save offline queue: $e');
    }
  }

  Future<void> enqueueRequest(Map<String, dynamic> request) async {
    final queue = await loadQueue();
    queue.add(request);
    await saveQueue(queue);
  }

  Future<void> dequeueRequest(String id) async {
    final queue = await loadQueue();
    queue.removeWhere((item) => item['id'] == id);
    await saveQueue(queue);
  }

  // --- Ephemeral Attachment Staging (for pending sync uploads) ---

  Future<String> stageAttachment({
    required String fileName,
    required List<int> bytes,
  }) async {
    final dir = await _attachmentsDir;
    final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
    final file = File('${dir.path}${Platform.pathSeparator}$uniqueName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> deleteStagedAttachment(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete staged attachment: $e');
    }
  }

  // --- App-Private Persistent Local Archive (Saved on Submit) ---

  Future<String> saveAttachmentCopy({
    required String identifier,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final dir = await _savedAttachmentsDir;
      final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final targetName = '${identifier}__$sanitizedName';
      final file = File('${dir.path}${Platform.pathSeparator}$targetName');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('Failed to save attachment copy: $e');
      return '';
    }
  }

  Future<File?> getSavedAttachment(String identifier) async {
    try {
      final dir = await _savedAttachmentsDir;
      if (!await dir.exists()) return null;
      final files = await dir.list().toList();
      for (final entity in files) {
        if (entity is File) {
          final baseName = entity.uri.pathSegments.last;
          if (baseName == identifier || baseName.startsWith('${identifier}__')) {
            return entity;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to get saved attachment: $e');
    }
    return null;
  }

  Future<void> linkSavedAttachment({
    required String oldIdentifier,
    required String newIdentifier,
  }) async {
    try {
      final oldFile = await getSavedAttachment(oldIdentifier);
      if (oldFile != null && await oldFile.exists()) {
        final bytes = await oldFile.readAsBytes();
        final oldName = oldFile.uri.pathSegments.last;
        final cleanFileName = oldName.contains('__')
            ? oldName.substring(oldName.indexOf('__') + 2)
            : oldName;
        await saveAttachmentCopy(
          identifier: newIdentifier,
          bytes: bytes,
          fileName: cleanFileName,
        );
      }
    } catch (e) {
      debugPrint('Failed to link saved attachment: $e');
    }
  }

  Future<void> clearSavedAttachments() async {
    try {
      final dir = await _savedAttachmentsDir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to clear saved attachments: $e');
    }
  }

  Future<void> clearAll() async {
    await clearWorkspaceCache();
    await clearSavedAttachments();
    try {
      final file = await _getFile(_queueFile);
      if (await file.exists()) {
        await file.delete();
      }
      final dir = await _attachmentsDir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to clear offline storage: $e');
    }
  }
}
