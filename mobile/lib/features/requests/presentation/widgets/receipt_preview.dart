import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/api_client.dart';
import 'receipt_preview/receipt_preview_bottom_dock.dart';
import 'receipt_preview/receipt_preview_document_card.dart';
import 'receipt_preview/receipt_preview_service.dart';
import 'receipt_preview/receipt_preview_state_views.dart';
import 'receipt_preview/receipt_preview_top_bar.dart';

class ReceiptPreview extends StatefulWidget {
  const ReceiptPreview({
    super.key,
    required this.api,
    required this.path,
    this.fallbackPath,
    this.title = 'Bukti transaksi',
  });

  final ApiClient api;
  final String path, title;
  final String? fallbackPath;

  @override
  State<ReceiptPreview> createState() => _ReceiptPreviewState();
}

class _ReceiptPreviewState extends State<ReceiptPreview> {
  late final file = ReceiptPreviewService.loadFile(
    api: widget.api,
    path: widget.path,
    fallbackPath: widget.fallbackPath,
  );
  final _transformationController = TransformationController();
  bool sharing = false;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final zoomed = _transformationController.value != Matrix4.identity();
    if (zoomed != _isZoomed && mounted) {
      setState(() => _isZoomed = zoomed);
    }
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _isZoomed = false;
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_isZoomed) {
      _resetZoom();
    } else {
      final position = details.localPosition;
      setState(() {
        _transformationController.value = Matrix4.diagonal3Values(2.2, 2.2, 1.0)
          ..setTranslationRaw(-position.dx * 1.2, -position.dy * 1.2, 0.0);
        _isZoomed = true;
      });
    }
  }

  Future<void> _shareFile(({dynamic bytes, String contentType}) result) async {
    if (sharing) return;
    setState(() => sharing = true);
    try {
      await ReceiptPreviewService.shareFile(
        context: context,
        result: result,
        title: widget.title,
      );
    } finally {
      if (mounted) setState(() => sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: FutureBuilder<({dynamic bytes, String contentType})>(
          future: file,
          builder: (context, snapshot) {
            final result = snapshot.data;
            final isImage = result?.contentType.startsWith('image/') ?? false;
            final isPdf = result?.contentType.contains('pdf') ?? false;
            final byteCount = (result?.bytes is List) ? (result!.bytes as List).length : 0;
            final sizeLabel = ReceiptPreviewService.formatFileSize(byteCount);

            return Stack(
              children: [
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ReceiptPreviewLoadingView();
                      }
                      if (snapshot.hasError) {
                        return ReceiptPreviewErrorView(error: snapshot.error);
                      }
                      if (result == null) {
                        return const SizedBox.shrink();
                      }
                      if (isImage) {
                        return GestureDetector(
                          onDoubleTapDown: _handleDoubleTap,
                          onDoubleTap: () {},
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 0.5,
                            maxScale: 5.0,
                            child: Center(
                              child: Image.memory(
                                result.bytes,
                                fit: BoxFit.contain,
                                errorBuilder: (_, error, stack) => const Center(
                                  child: Text(
                                    'Gambar tidak dapat ditampilkan.',
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF94A3B8)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return ReceiptPreviewDocumentCard(
                        title: widget.title,
                        isPdf: isPdf,
                        sizeLabel: sizeLabel,
                        sharing: sharing,
                        onShare: () => _shareFile(result),
                      );
                    },
                  ),
                ),
                ReceiptPreviewTopBar(
                  title: widget.title,
                  result: result,
                  isPdf: isPdf,
                  sizeLabel: sizeLabel,
                  sharing: sharing,
                  onBack: () => Navigator.of(context).pop(),
                  onShare: () => _shareFile(result!),
                ),
                if (result != null && isImage)
                  ReceiptPreviewBottomDock(
                    isZoomed: _isZoomed,
                    sharing: sharing,
                    onResetZoom: _resetZoom,
                    onShare: () => _shareFile(result),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
