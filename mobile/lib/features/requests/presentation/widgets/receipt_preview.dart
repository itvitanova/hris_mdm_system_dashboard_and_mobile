import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/api_client.dart';

class ReceiptPreview extends StatefulWidget {
  const ReceiptPreview({
    super.key,
    required this.api,
    required this.path,
    this.title = 'Bukti transaksi',
  });
  final ApiClient api;
  final String path, title;
  @override
  State<ReceiptPreview> createState() => _ReceiptPreviewState();
}

class _ReceiptPreviewState extends State<ReceiptPreview> {
  late final file = widget.api.requestFile(widget.path);
  bool sharing = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: SafeArea(
      child: FutureBuilder(
        future: file,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Bukti tidak dapat dibuka. ${snapshot.error}'),
              ),
            );
          }
          final result = snapshot.data;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final image = result.contentType.startsWith('image/');
          return Column(
            children: [
              Expanded(
                child: image
                    ? InteractiveViewer(
                        minScale: .5,
                        maxScale: 5,
                        child: Center(
                          child: Image.memory(
                            result.bytes,
                            fit: BoxFit.contain,
                            errorBuilder: (_, error, stack) =>
                                const Text('Gambar tidak dapat ditampilkan.'),
                          ),
                        ),
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Bukti ini berupa PDF. Gunakan tombol di bawah untuk membuka atau menyimpannya melalui aplikasi PDF.',
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: FilledButton.icon(
                  onPressed: sharing
                      ? null
                      : () async {
                          setState(() => sharing = true);
                          File? temp;
                          try {
                            final dir = await getTemporaryDirectory();
                            final ext = result.contentType.contains('pdf')
                                ? 'pdf'
                                : result.contentType.contains('png')
                                ? 'png'
                                : 'jpg';
                            temp = File(
                              '${dir.path}/bukti-${DateTime.now().microsecondsSinceEpoch}.$ext',
                            );
                            await temp.writeAsBytes(result.bytes);
                            if (!context.mounted) return;
                            final box =
                                context.findRenderObject() as RenderBox?;
                            await SharePlus.instance.share(
                              ShareParams(
                                files: [
                                  XFile(
                                    temp.path,
                                    mimeType: result.contentType,
                                  ),
                                ],
                                sharePositionOrigin: box == null
                                    ? null
                                    : box.localToGlobal(Offset.zero) & box.size,
                              ),
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Bukti belum dapat dibagikan: $e',
                                  ),
                                ),
                              );
                            }
                          } finally {
                            if (temp != null && await temp.exists()) {
                              await temp.delete();
                            }
                            if (mounted) setState(() => sharing = false);
                          }
                        },
                  icon: const Icon(Icons.ios_share),
                  label: Text(
                    image ? 'Simpan / bagikan foto' : 'Buka / bagikan PDF',
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
