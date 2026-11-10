import 'dart:typed_data';
import 'dart:ui' as ui;

class ImageCompressor {
  static const int maxFileSizeBytes = 2 * 1024 * 1024; // 2 MB backend limit

  /// Compresses image bytes if needed to ensure file is under [maxFileSizeBytes].
  /// If [fileName] is not an image (e.g., PDF), it returns the original bytes.
  static Future<Uint8List> compressIfNeeded(
    Uint8List rawBytes, {
    required String fileName,
    int maxDimension = 1280,
  }) async {
    final lowerName = fileName.toLowerCase();
    final isImage = lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp');

    if (!isImage) {
      return rawBytes;
    }

    // If it's already well under 1.5 MB, no compression needed
    if (rawBytes.length <= 1500 * 1024) {
      return rawBytes;
    }

    try {
      final codec = await ui.instantiateImageCodec(
        rawBytes,
        targetWidth: maxDimension,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData != null) {
        final compressed = byteData.buffer.asUint8List();
        if (compressed.length < rawBytes.length) {
          return compressed;
        }
      }
    } catch (_) {
      // In case decoding fails, return original bytes
    }

    return rawBytes;
  }
}
