import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';

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
  late final file = _loadFile();
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

  Future<({dynamic bytes, String contentType})> _loadFile() async {
    try {
      final res = await widget.api.requestFile(widget.path);
      return (bytes: res.bytes, contentType: res.contentType);
    } catch (e) {
      if (widget.fallbackPath != null && widget.fallbackPath!.isNotEmpty) {
        final res = await widget.api.requestFile(widget.fallbackPath!);
        return (bytes: res.bytes, contentType: res.contentType);
      }
      rethrow;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _shareFile(({dynamic bytes, String contentType}) result) async {
    if (sharing) return;
    setState(() => sharing = true);
    File? temp;
    try {
      final dir = await getTemporaryDirectory();
      final ext = result.contentType.contains('pdf')
          ? 'pdf'
          : result.contentType.contains('png')
              ? 'png'
              : 'jpg';
      final safeName = widget.title
          .replaceAll(RegExp(r'[^\w\s\.-]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      final filename = safeName.isNotEmpty
          ? '$safeName.$ext'
          : 'lampiran-${DateTime.now().millisecondsSinceEpoch}.$ext';
      temp = File('${dir.path}/$filename');
      await temp.writeAsBytes(result.bytes);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(temp.path, mimeType: result.contentType),
          ],
          sharePositionOrigin:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (mounted) {
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
            final byteCount = (result?.bytes is List)
                ? (result!.bytes as List).length
                : 0;
            final sizeLabel = _formatFileSize(byteCount);

            return Stack(
              children: [
                // 1. MAIN CANVAS AREA
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Color(0xFF14B8A6),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Text(
                                  'Memuat lampiran...',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 48.w,
                                    height: 48.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      UIcons.regularRounded.cross_circle,
                                      size: 24.w,
                                      color: const Color(0xFFF87171),
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  Text(
                                    'Berkas Tidak Dapat Dibuka',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    '${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF94A3B8),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
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
                                errorBuilder: (_, error, stack) => Center(
                                  child: Text(
                                    'Gambar tidak dapat ditampilkan.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13.sp,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      // HERO CARD UNTUK FILE DOKUMEN / PDF
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 68.w,
                                  height: 68.w,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFDC2626),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x30EF4444),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    UIcons.regularRounded.document,
                                    size: 32.w,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    isPdf ? 'DOKUMEN PDF · $sizeLabel' : 'BERKAS DOKUMEN · $sizeLabel',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFCBD5E1),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                Text(
                                  'Berkas dokumen ini siap dibuka atau dibagikan ke aplikasi penampil dokumen di perangkat Anda.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF94A3B8),
                                    height: 1.45,
                                  ),
                                ),
                                SizedBox(height: 22.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46.h,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF0F766E),
                                          Color(0xFF14B8A6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x250F766E),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: sharing ? null : () => _shareFile(result),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                      ),
                                      icon: sharing
                                          ? SizedBox(
                                              width: 18.w,
                                              height: 18.w,
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              UIcons.regularRounded.share,
                                              size: 18.w,
                                              color: Colors.white,
                                            ),
                                      label: Text(
                                        sharing ? 'Menyiapkan berkas...' : 'Buka / Bagikan Dokumen PDF',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. TRANSLUCENT FLOATING TOP BAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Material(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10.r),
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      width: 36.w,
                                      height: 36.w,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        UIcons.regularRounded.arrow_left,
                                        size: 17.w,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      if (result != null) ...[
                                        SizedBox(height: 2.h),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5.w,
                                                vertical: 1.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isPdf
                                                    ? const Color(0xFFEF4444)
                                                    : const Color(0xFF0F766E),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                isPdf
                                                    ? 'PDF'
                                                    : result.contentType.contains('png')
                                                        ? 'PNG'
                                                        : 'JPG',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 9.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              sizeLabel,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (result != null) ...[
                                  SizedBox(width: 8.w),
                                  Material(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10.r),
                                      onTap: sharing ? null : () => _shareFile(result),
                                      child: Container(
                                        width: 36.w,
                                        height: 36.w,
                                        alignment: Alignment.center,
                                        child: sharing
                                            ? SizedBox(
                                                width: 16.w,
                                                height: 16.w,
                                                child: const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Icon(
                                                UIcons.regularRounded.share,
                                                size: 16.w,
                                                color: Colors.white,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. FLOATING GLASSMORPHISM BOTTOM DOCK (Hanya untuk mode Gambar)
                if (result != null && isImage)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isZoomed
                                  ? 'Ketuk dua kali untuk mereset tampilan zoom'
                                  : 'Cubit untuk zoom · Ketuk 2x untuk perbesar',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if (_isZoomed) ...[
                                        Material(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10.r),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(10.r),
                                            onTap: _resetZoom,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 8.h,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    UIcons.regularRounded.compress_alt,
                                                    size: 15.w,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    'Reset',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                      ],
                                      Expanded(
                                        child: SizedBox(
                                          height: 42.h,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF0F766E),
                                                  Color(0xFF14B8A6),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(10.r),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x250F766E),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed: sharing ? null : () => _shareFile(result),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.r),
                                                ),
                                              ),
                                              icon: sharing
                                                  ? SizedBox(
                                                      width: 16.w,
                                                      height: 16.w,
                                                      child: const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Icon(
                                                      UIcons.regularRounded.share,
                                                      size: 16.w,
                                                      color: Colors.white,
                                                    ),
                                              label: Text(
                                                sharing ? 'Menyiapkan...' : 'Simpan / Bagikan Foto',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
