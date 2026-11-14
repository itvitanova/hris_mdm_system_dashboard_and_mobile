import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../bloc/request_bloc.dart';
import '../bloc/request_event.dart';
import '../widgets/universal_request_card/universal_request_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../core/di/injection_container.dart';
import '../../../home/presentation/bloc/workspace_bloc.dart';
import '../../../home/presentation/bloc/workspace_event.dart';
import 'request_form_page.dart';
import '../widgets/approval_step_summary.dart';
import '../widgets/receipt_preview.dart';
import '../../../root/presentation/widgets/language_swap_button.dart';

class _CopyIconButton extends StatefulWidget {
  const _CopyIconButton({
    required this.textToCopy,
    required this.label,
  });

  final String textToCopy;
  final String label;

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<_CopyIconButton> {
  bool _copied = false;

  void _handleCopy() {
    if (widget.textToCopy.isEmpty) return;
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    notify(context, '${widget.label} ${widget.textToCopy} disalin.');
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = 13.5.w;
    final color = _copied
        ? const Color(0xFF047857)
        : const Color(0xFF0F766E);

    return Tooltip(
      message: 'Salin ${widget.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4.r),
          onTap: _handleCopy,
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                _copied ? UIcons.regularRounded.check : UIcons.regularRounded.copy,
                key: ValueKey(_copied),
                size: size,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.api,
    required this.request,
    required this.own,
  });
  final ApiClient api;
  final Json request;
  final bool own;
  @override
  State<RequestDetailScreen> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetailScreen> {
  late Json request = widget.request;
  bool busy = false;
  String? error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchFreshRequest();
      await markSeen();
    });
  }

  Future<void> _fetchFreshRequest({bool force = false}) async {
    try {
      final w = Workspace(await widget.api.workspace());
      final matches = w.rows('requests').where((r) => r['id'] == request['id']);
      if (matches.isNotEmpty && mounted) {
        setState(() {
          request = matches.first;
          error = null;
        });
      } else if (force && matches.isEmpty) {
        throw ApiException(
          'Pengajuan tidak ditemukan atau akses sudah berubah.',
        );
      }
    } catch (e) {
      if (force && mounted) setState(() => error = e.toString());
    }
  }

  Future<void> markSeen() async {
    final token = text(request, 'updateToken', '');
    if (!widget.own || request['unread'] != true || token.length != 64) return;
    try {
      try {
        context.read<RequestBloc>().add(
          RequestMarkSeenRequested(
            id: text(request, 'id'),
            token: token,
          ),
        );
      } catch (_) {}

      await widget.api.post(
        '/requests/${Uri.encodeComponent(text(request, 'id'))}/seen',
        {'token': token},
      );
      if (mounted) setState(() => request = {...request, 'unread': false});
    } catch (_) {
      /* Keep the update unread when acknowledgement cannot reach the server. */
    }
  }

  Future<void> refresh() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await _fetchFreshRequest(force: true);
      await markSeen();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  List<Json> records(dynamic value) =>
      ((value as List?) ?? []).map((v) => Json.from(v as Map)).toList();

  Future<void> decide(String decision) async {
    final note = TextEditingController();
    final scrollController = ScrollController();
    final focusNode = FocusNode();
    final isApproved = decision == 'Disetujui';
    final isRevision = decision == 'Perlu revisi';

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    final titleText = isApproved
        ? 'Setujui Pengajuan'
        : isRevision
        ? 'Minta Revisi Pengajuan'
        : 'Tolak Pengajuan';

    final themeColor = isApproved
        ? const Color(0xFF0F766E)
        : isRevision
        ? const Color(0xFFD97706)
        : const Color(0xFFE11D48);

    final quickChips = isApproved
        ? ['Bukti lengkap & valid', 'Sesuai anggaran', 'Semua rincian disetujui']
        : isRevision
        ? ['Nota kurang jelas/terbaca', 'Lengkapi bukti fisik', 'Perbaiki rincian biaya']
        : ['Di luar ketentuan perusahaan', 'Klaim ganda/duplikat', 'Anggaran tidak tersedia'];

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isApproved
                                ? UIcons.regularRounded.check
                                : isRevision
                                ? UIcons.regularRounded.time_past
                                : UIcons.regularRounded.cross_small,
                            size: 24.w,
                            color: themeColor,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titleText,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                text(request, 'title'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Quick Reason Chips
                    Text(
                      'PILIHAN CATATAN CEPAT',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: quickChips.map((chipText) {
                        final isSelected = note.text == chipText;
                        return InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: () {
                            setSheetState(() {
                              note.text = chipText;
                              note.selection = TextSelection.fromPosition(
                                TextPosition(offset: note.text.length),
                              );
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themeColor.withValues(alpha: 0.12)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? themeColor
                                    : const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              chipText,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? themeColor
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 14.h),
                    TextField(
                      controller: note,
                      focusNode: focusNode,
                      scrollPadding: EdgeInsets.only(bottom: 140.h),
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 250), () {
                          if (scrollController.hasClients) {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      },
                      maxLines: 3,
                      maxLength: 2000,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        labelText: isApproved ? 'Catatan (opsional)' : 'Catatan wajib diisi',
                        labelStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                        hintText: isApproved
                            ? 'Tambahkan catatan persetujuan...'
                            : 'Jelaskan alasan penolakan atau revisi...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: themeColor, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: themeColor,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx, note.text.trim()),
                            child: const Text(
                              'Simpan keputusan',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    note.dispose();
    scrollController.dispose();
    focusNode.dispose();
    if (result == null || !mounted) return;
    if (decision != 'Disetujui' && result.isEmpty) {
      setState(() => error = 'Isi alasan penolakan atau revisi.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.post(
        '/requests/${Uri.encodeComponent(text(request, 'id'))}/review',
        {
          'status': decision,
          'note': result,
          'revision': request['revision'] ?? 0,
        },
      );
      _changed = true;

      // 1. Instantly update local state optimistically
      if (mounted) {
        setState(() {
          request = {
            ...request,
            'status': decision,
            'canReview': false,
            'reviewNote': result,
            'revision': (request['revision'] ?? 0) + 1,
          };
        });
      }

      // 2. Fetch server-verified latest data (steps, history, finalized status)
      await _fetchFreshRequest();

      // 3. Dispatch global Workspace refresh
      if (sl.isRegistered<WorkspaceBloc>()) {
        sl<WorkspaceBloc>().add(const WorkspaceRefreshRequested());
      }

      if (mounted) {
        Navigator.pop(context, true);
        notify(context, 'Keputusan tersimpan.');
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> share(String path, String name) async {
    setState(() {
      busy = true;
      error = null;
    });
    File? file;
    try {
      final result = await widget.api.requestFile(path);
      final dir = await getTemporaryDirectory();
      final extension = result.contentType.contains('pdf')
          ? '.pdf'
          : result.contentType.contains('png')
          ? '.png'
          : result.contentType.contains('jpeg')
          ? '.jpg'
          : '';
      final fileName = name.contains('.') ? name : '$name$extension';
      file = File(
        '${dir.path}/${DateTime.now().microsecondsSinceEpoch}-$fileName',
      );
      await file.writeAsBytes(result.bytes, flush: true);
      if (!mounted) return;
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
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (file != null && await file.exists()) await file.delete();
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 15.w, color: const Color(0xFF0F766E)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    String? copyValue,
    Widget? action,
    bool showColon = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13.5.w, color: const Color(0xFF94A3B8)),
            SizedBox(width: 6.w),
          ],
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (showColon)
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: showColon
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value.isNotEmpty ? value : '—',
                    textAlign: showColon ? TextAlign.start : TextAlign.end,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (copyValue != null && copyValue.isNotEmpty) ...[
                  SizedBox(width: 5.w),
                  _CopyIconButton(
                    textToCopy: copyValue,
                    label: label,
                  ),
                ] else if (action != null) ...[
                  SizedBox(width: 4.w),
                  action,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBlock(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F172A),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getExpenseCategoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('trans') || c.contains('parkir') || c.contains('bensin') || c.contains('tol') || c.contains('ojek') || c.contains('taksi') || c.contains('kendaraan')) {
      return UIcons.regularRounded.car;
    }
    if (c.contains('makan') || c.contains('konsumsi') || c.contains('kuliner') || c.contains('snack') || c.contains('food')) {
      return UIcons.regularRounded.restaurant;
    }
    if (c.contains('hotel') || c.contains('inap') || c.contains('lodging')) {
      return UIcons.regularRounded.bed;
    }
    if (c.contains('medis') || c.contains('obat') || c.contains('dokter') || c.contains('klinik') || c.contains('kesehatan') || c.contains('claim')) {
      return UIcons.regularRounded.stethoscope;
    }
    if (c.contains('atk') || c.contains('kantor') || c.contains('operasional') || c.contains('logistik') || c.contains('barang')) {
      return UIcons.regularRounded.boxes;
    }
    if (c.contains('pesawat') || c.contains('terbang') || c.contains('flight')) {
      return UIcons.regularRounded.plane;
    }
    if (c.contains('kereta') || c.contains('train') || c.contains('krl') || c.contains('mrt')) {
      return UIcons.regularRounded.train;
    }
    return UIcons.regularRounded.receipt;
  }

  String _cleanItemDescription(String desc) {
    if (desc.isEmpty) return '—';
    var cleaned = desc.trim();

    // Hapus pola harga di dalam tanda kurung, misal " · @Rp 500.000" atau " · 500.000"
    cleaned = cleaned.replaceAll(RegExp(r'\s*·\s*(@?Rp\.?\s*)?[\d.,]+(?=\s*\))', caseSensitive: false), '');

    // Hapus pola harga jika berdiri sendiri di dalam tanda kurung, misal "(@Rp 500.000)" atau "(500.000)"
    cleaned = cleaned.replaceAll(RegExp(r'\s*\((@?Rp\.?\s*)?[\d.,]+\)', caseSensitive: false), '');

    // Hapus pola harga di akhir string setelah titik pemisah, misal " · @Rp 500.000" atau " · 500.000"
    cleaned = cleaned.replaceAll(RegExp(r'\s*·\s*(@?Rp\.?\s*)?[\d.,]+$', caseSensitive: false), '');

    cleaned = cleaned.trim();

    // Jika hanya tersisa kurung membungkus teks spesifikasi/catatan, misal "(Printer)" -> "Printer"
    final singleParenMatch = RegExp(r'^\(([^()]+)\)$').firstMatch(cleaned);
    if (singleParenMatch != null) {
      cleaned = singleParenMatch.group(1)!.trim();
    }

    return cleaned.isNotEmpty ? cleaned : '—';
  }

  bool _isStatusRevision(dynamic status) {
    final s = (status ?? '').toString().toLowerCase().replaceAll(' ', '');
    return s == 'perlurevisi' || s == 'revisi' || s == 'needs_revision';
  }

  Widget? _buildStickyBottomActionBar(Json r, List<Json> steps, String id) {
    final canReview = r['canReview'] == true;
    final needsRevision = widget.own && _isStatusRevision(r['status']);
    final canDownload = r['canDownload'] == true;

    if (!canReview && !needsRevision && !canDownload) return null;

    final currentStepIdx = (r['currentStep'] as num?)?.toInt() ?? 0;
    final isFinanceStep = steps.isNotEmpty &&
        currentStepIdx < steps.length &&
        steps[currentStepIdx]['source'] == 'finance';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canReview) ...[
                // Dual-Row Layout
                // Baris 1: Tindakan Sekunder (Tolak & Minta Revisi)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 40.h),
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          side: const BorderSide(color: Color(0xFFFECDD3), width: 1.2),
                          backgroundColor: const Color(0xFFFFF1F2).withValues(alpha: 0.5),
                          foregroundColor: const Color(0xFFE11D48),
                        ),
                        onPressed: busy ? null : () => decide('Ditolak'),
                        icon: Icon(UIcons.regularRounded.cross_small, size: 18.w),
                        label: Text(
                          'Tolak',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (r['version'] == 2) ...[
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(0, 40.h),
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            side: const BorderSide(color: Color(0xFFFDE68A), width: 1.2),
                            backgroundColor: const Color(0xFFFFFBEB).withValues(alpha: 0.5),
                            foregroundColor: const Color(0xFFD97706),
                          ),
                          onPressed: busy ? null : () => decide('Perlu revisi'),
                          icon: Icon(UIcons.regularRounded.time_past, size: 16),
                          label: Text(
                            'Minta revisi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                // Baris 2: Tindakan Utama Penuh (Setujui / Verifikasi finance)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(44.h),
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    elevation: 1,
                    shadowColor: const Color(0x330F766E),
                  ),
                  onPressed: busy ? null : () => decide('Disetujui'),
                  icon: Icon(UIcons.regularRounded.check, size: 18),
                  label: Text(
                    isFinanceStep ? 'Verifikasi finance' : 'Setujui',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ] else if (needsRevision) ...[
                // Pemohon: Perbaiki pengajuan
                Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x20E11D48),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: busy
                          ? null
                          : () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RequestForm(api: widget.api, initialRequest: r),
                                ),
                              );
                              if (changed == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(UIcons.regularRounded.refresh, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            const Text(
                              'Perbaiki pengajuan',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (canDownload) ...[
                // Unduh dokumen
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x200F766E),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10.r),
                            onTap: busy
                                ? null
                                : () => share(
                                    '/requests/$id/document/pdf',
                                    'reimbursement.pdf',
                                  ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(UIcons.regularRounded.document, size: 18, color: Colors.white),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Unduh PDF',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 44.h,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          onPressed: busy
                              ? null
                              : () => share(
                                  '/requests/$id/document/xlsx',
                                  'reimbursement.xlsx',
                                ),
                          icon: Icon(UIcons.regularRounded.table_layout, size: 16, color: const Color(0xFF0F766E)),
                          label: const Text(
                            'Excel',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = request;
    final id = Uri.encodeComponent(text(r, 'id'));
    final snapshot = Json.from((r['snapshot'] as Map?) ?? {});
    final items = records(r['items']);
    final steps = records(r['steps']);
    final model = UniversalRequestModel.fromMap(r);
    final kindConfig = RequestCardHelper.getKindConfig(model);
    final statusConfig = RequestCardHelper.getStatusConfig(model.status, model.kind);

    final amount = number(r, 'amount');
    final hasAmount = amount > 0;
    final hours = (r['hours'] as num?)?.toInt();
    final days = (r['days'] as num?)?.toInt();

    final isRevision = _isStatusRevision(r['status']) || text(r, 'reviewNote', '').isNotEmpty;
    final pendingWithText = text(r, 'pendingWith', '');

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(_changed);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0.4,
            shadowColor: const Color(0x120F172A),
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(
                UIcons.regularRounded.angle_small_left,
                size: 20,
                color: const Color(0xFF0F172A),
              ),
              onPressed: () => Navigator.of(context).pop(_changed),
            ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Detail Pengajuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                '${kindConfig.typeTitle} · ${text(r, 'id')}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16.w),
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.r),
                  onTap: busy ? null : refresh,
                  child: Tooltip(
                    message: 'Segarkan pengajuan',
                    child: Icon(
                      UIcons.regularRounded.refresh,
                      size: 18.w,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF0F766E),
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              children: [
                // ==================== 1. HERO HEADER SUMMARY CARD ====================
                Container(
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x060F172A),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Type Icon & Name (Left) + Status Badge (Right)
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDFA),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: const Color(0xFFCCFBF1),
                                    width: 0.8,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  kindConfig.icon,
                                  size: 18.w,
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    kindConfig.typeTitle.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F766E),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    text(r, 'id'),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusConfig.badgeBg,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: statusConfig.badgeBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              statusConfig.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: statusConfig.textColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Title
                      Text(
                        text(r, 'title'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                      ),

                      // Box Highlight Metrik (Nominal atau Durasi jika ada)
                      if (hasAmount || (hours != null && hours > 0) || (days != null && days > 0)) ...[
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFCCFBF1), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasAmount
                                    ? UIcons.regularRounded.wallet
                                    : (hours != null ? UIcons.regularRounded.clock : UIcons.regularRounded.calendar),
                                size: 20.w,
                                color: const Color(0xFF0F766E),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasAmount
                                          ? 'TOTAL PENGAJUAN BIAYA'
                                          : (hours != null ? 'TOTAL DURASI LEMBUR' : 'TOTAL HARI CUTI'),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F766E),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      hasAmount
                                          ? rupiah(amount)
                                          : (hours != null ? '$hours Jam' : '$days Hari'),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F766E),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 12.h),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      SizedBox(height: 8.h),

                      // Tanggal diajukan
                      Row(
                        children: [
                          Icon(
                            UIcons.regularRounded.clock,
                            size: 13.w,
                            color: const Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              'Diajukan pada ${requestDateLabel(text(r, 'createdAt'))}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==================== 2. KOTAK REVISI & STATUS TERTUNDA ====================
                if (isRevision) ...[
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFFECDD3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              UIcons.regularRounded.exclamation,
                              size: 16.w,
                              color: const Color(0xFFBE123C),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                _isStatusRevision(r['status'])
                                    ? 'Perlu diperbaiki'
                                    : 'Catatan Peninjau',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFBE123C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          text(r, 'reviewNote'),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9F1239),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (pendingWithText.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFBBF7D0), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          UIcons.regularRounded.clock,
                          size: 15.w,
                          color: const Color(0xFF16A34A),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            pendingWithText,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ==================== 3. RINGKASAN KEPERLUAN & WAKTU ====================
                _buildSectionCard(
                  icon: UIcons.regularRounded.document,
                  title: 'Ringkasan Pengajuan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (text(r, 'description').isNotEmpty) ...[
                        _buildDescriptionBlock('Keperluan', text(r, 'description')),
                        const Divider(height: 12, color: Color(0xFFF8FAFC)),
                      ],
                      _buildInfoRow(
                        'Periode',
                        '${requestDateLabel(text(r, 'startDate'))} – ${requestDateLabel(text(r, 'endDate'))}',
                        icon: UIcons.regularRounded.calendar,
                      ),
                      if (r['permissionType'] != null && text(r, 'permissionType').isNotEmpty)
                        _buildInfoRow('Jenis Izin', text(r, 'permissionType')),
                      if (hours != null && hours > 0)
                        _buildInfoRow('Durasi Lembur', '$hours Jam'),
                      if (days != null && days > 0)
                        _buildInfoRow('Total Cuti', '$days Hari'),
                      if (r['category'] != null && text(r, 'category').isNotEmpty)
                        _buildInfoRow('Kategori', text(r, 'category')),
                      if (r['priority'] != null && text(r, 'priority').isNotEmpty)
                        _buildInfoRow('Prioritas GA', text(r, 'priority')),
                      if (r['location'] != null && text(r, 'location').isNotEmpty)
                        _buildInfoRow('Lokasi', text(r, 'location')),
                    ],
                  ),
                ),

                // ==================== 4. PROFIL PEMOHON & REKENING ====================
                _buildSectionCard(
                  icon: UIcons.regularRounded.user,
                  title: 'Informasi Pemohon',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFCCFBF1),
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              UIcons.regularRounded.user,
                              size: 20.w,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text(snapshot, 'name', text(r, 'employeeName')),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${text(snapshot, 'department', 'Divisi')} · ${text(snapshot, 'position', 'Karyawan')}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (text(snapshot, 'phone').isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        SizedBox(height: 4.h),
                        _buildInfoRow(
                          'Nomor Telepon',
                          text(snapshot, 'phone'),
                          icon: UIcons.regularRounded.phone_call,
                          showColon: true,
                        ),
                      ],
                      if (items.isNotEmpty || text(snapshot, 'bankAccountNumber').isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(UIcons.regularRounded.bank, size: 14.w, color: const Color(0xFF0F766E)),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      'Rekening Penerima Transfer',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F766E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow('Nama Bank', text(snapshot, 'bankName'), showColon: true),
                              _buildInfoRow('Atas Nama', text(snapshot, 'bankAccountName'), showColon: true),
                              _buildInfoRow(
                                'Nomor Rekening',
                                text(snapshot, 'bankAccountNumber'),
                                copyValue: text(snapshot, 'bankAccountNumber'),
                                showColon: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ==================== 5. RINCIAN PENGELUARAN ====================
                if (items.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: UIcons.regularRounded.receipt,
                    title: 'Rincian Pengeluaran (${items.length})',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Squircle Kategori Dinamis
                                Container(
                                  width: 38.w,
                                  height: 38.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDFA),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: const Color(0xFFCCFBF1),
                                      width: 0.8,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _getExpenseCategoryIcon(text(items[i], 'category')),
                                    size: 18.w,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                // 2. Deskripsi & Meta (Kategori, Tanggal)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _cleanItemDescription(text(items[i], 'description')),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6.w,
                                        runSpacing: 2.h,
                                        children: [
                                          Text(
                                            text(items[i], 'category', 'Item'),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF94A3B8),
                                            ),
                                          ),
                                          Text(
                                            requestDateLabel(text(items[i], 'date')),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 11.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),

                                // 3. Nominal & Tombol Bukti
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      rupiah(number(items[i], 'amount')),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    if (text(items[i], 'receiptId').isNotEmpty) ...[
                                      SizedBox(height: 6.h),
                                      Material(
                                        color: const Color(0xFFF0FDFA),
                                        borderRadius: BorderRadius.circular(6.r),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(6.r),
                                          onTap: busy
                                              ? null
                                              : () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ReceiptPreview(
                                                      api: widget.api,
                                                      path:
                                                          '/requests/$id/receipts/${Uri.encodeComponent(text(items[i], 'receiptId'))}',
                                                      title: 'Bukti pengeluaran ${i + 1}',
                                                    ),
                                                  ),
                                                ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6.r),
                                              border: Border.all(
                                                color: const Color(0xFFCCFBF1),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  UIcons.regularRounded.receipt,
                                                  size: 11.5.w,
                                                  color: const Color(0xFF0F766E),
                                                ),
                                                SizedBox(width: 3.w),
                                                Text(
                                                  'Lihat bukti',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 10.5.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF0F766E),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        // 4. Footer Rekapitulasi Total
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFCCFBF1), width: 0.8),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8.w,
                            runSpacing: 4.h,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    UIcons.regularRounded.calculator,
                                    size: 15.w,
                                    color: const Color(0xFF0F766E),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Total (${items.length} Pengeluaran)',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F766E),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                rupiah(amount),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F766E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (text(r, 'attachmentId', '').isNotEmpty) ...[
                  // Lampiran Bukti Tunggal untuk Izin / Medical Claim
                  _buildSectionCard(
                    icon: UIcons.regularRounded.clip,
                    title: 'Berkas Lampiran Pengajuan',
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(UIcons.regularRounded.document, size: 20.w, color: const Color(0xFF0F766E)),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text(r, 'attachmentName', 'Bukti Lampiran Resmi'),
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12.sp, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Lampiran bukti pendukung pengajuan',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                            ),
                            onPressed: busy
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReceiptPreview(
                                        api: widget.api,
                                        path: '/request-receipts/${Uri.encodeComponent(text(r, 'attachmentId'))}',
                                        title: 'Berkas Lampiran',
                                      ),
                                    ),
                                  ),
                            child: const Text('Lihat Bukti', style: TextStyle(fontFamily: 'Inter', fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ==================== 6. ALUR PERSETUJUAN (UNIFIED TIMELINE STEPPER) ====================
                if (steps.isNotEmpty || records(r['history']).isNotEmpty)
                  _buildSectionCard(
                    icon: UIcons.regularRounded.list_check,
                    title: 'Alur Persetujuan',
                    child: Column(
                      children: [
                        if (steps.isNotEmpty)
                          for (var i = 0; i < steps.length; i++) ...[
                            Builder(
                              builder: (context) {
                                final isLast = i == steps.length - 1;
                                final currentStepIdx = (r['currentStep'] as num?)?.toInt() ?? 0;
                                final decisions = records(steps[i]['decisions']);
                                final isStepApproved = steps[i]['status'] == 'Disetujui' ||
                                    decisions.any((d) => d['decision'] == 'Disetujui');
                                final isStepRejected = steps[i]['status'] == 'Ditolak' ||
                                    decisions.any((d) => d['decision'] == 'Ditolak');
                                final isStepRevision = _isStatusRevision(steps[i]['status']) ||
                                    decisions.any((d) => _isStatusRevision(d['decision']));
                                final isCurrentActive = currentStepIdx == i && r['status'] == 'Menunggu';

                                Color nodeColor = const Color(0xFFCBD5E1);
                                IconData nodeIcon = UIcons.regularRounded.circle;
                                double iconSize = 8.w;
                                if (isStepApproved) {
                                  nodeColor = const Color(0xFF10B981);
                                  nodeIcon = UIcons.regularRounded.check;
                                  iconSize = 13.5.w;
                                } else if (isCurrentActive) {
                                  nodeColor = const Color(0xFF0F766E);
                                  nodeIcon = UIcons.regularRounded.clock;
                                  iconSize = 13.5.w;
                                } else if (isStepRejected) {
                                  nodeColor = const Color(0xFFE11D48);
                                  nodeIcon = UIcons.regularRounded.cross_small;
                                  iconSize = 16.w;
                                } else if (isStepRevision) {
                                  nodeColor = const Color(0xFFD97706);
                                  nodeIcon = UIcons.regularRounded.exclamation;
                                  iconSize = 13.5.w;
                                }

                                return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Node & Connecting Line
                                      Column(
                                        children: [
                                          Container(
                                            width: 24.w,
                                            height: 24.w,
                                            decoration: BoxDecoration(
                                              color: nodeColor.withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: nodeColor.withValues(alpha: 0.28),
                                                width: 1.2.w,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(nodeIcon, size: iconSize, color: nodeColor),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 1.5.w,
                                                color: const Color(0xFFE2E8F0),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(width: 12.w),
                                      // Step Content
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Wrap(
                                                alignment: WrapAlignment.spaceBetween,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                spacing: 6.w,
                                                runSpacing: 4.h,
                                                children: [
                                                  Text(
                                                    '${i + 1}. ${text(steps[i], 'name')}',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 13.sp,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  if (isStepApproved)
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFECFDF5),
                                                        borderRadius: BorderRadius.circular(4.r),
                                                      ),
                                                      child: Text(
                                                        'Disetujui',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 9.5.sp,
                                                          fontWeight: FontWeight.w700,
                                                          color: const Color(0xFF047857),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 3.h),
                                              if (records(steps[i]['approvers']).isNotEmpty)
                                                Row(
                                                  children: [
                                                    Icon(UIcons.regularRounded.user, size: 11.w, color: const Color(0xFF64748B)),
                                                    SizedBox(width: 4.w),
                                                    Expanded(
                                                      child: Text(
                                                        records(steps[i]['approvers']).map((v) => text(v, 'name')).join(', '),
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 11.sp,
                                                          color: const Color(0xFF64748B),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: 3.h),
                                              Text(
                                                approvalStepSummary(
                                                  steps[i],
                                                  active: currentStepIdx == i,
                                                  requestStatus: text(r, 'status'),
                                                ),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 11.5.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: isCurrentActive ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                                                ),
                                              ),
                                              if (decisions.isNotEmpty) ...[
                                                SizedBox(height: 6.h),
                                                for (final d in decisions)
                                                  Container(
                                                    width: double.infinity,
                                                    margin: EdgeInsets.only(top: 4.h),
                                                    padding: EdgeInsets.all(8.w),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF8FAFC),
                                                      borderRadius: BorderRadius.circular(8.r),
                                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                        Text(
                                                          '${text(d, 'name')} · ${text(d, 'decision')}',
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: 11.sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF0F172A),
                                                          ),
                                                        ),
                                                        Text(
                                                          requestDateLabel(text(d, 'at')),
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: 10.sp,
                                                            color: const Color(0xFF94A3B8),
                                                          ),
                                                        ),
                                                        if (text(d, 'note', '').isNotEmpty)
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 2.h),
                                                            child: Text(
                                                              text(d, 'note'),
                                                              textAlign: TextAlign.justify,
                                                              style: TextStyle(
                                                                fontFamily: 'Inter',
                                                                fontSize: 11.sp,
                                                                color: const Color(0xFF334155),
                                                                height: 1.35,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ]
                        else
                          for (final h in records(r['history']))
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                children: [
                                  Icon(UIcons.regularRounded.check, size: 16.w, color: const Color(0xFF0F766E)),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${text(h, 'name')} · ${text(h, 'decision')}',
                                          style: TextStyle(fontFamily: 'Inter', fontSize: 12.sp, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '${requestDateLabel(text(h, 'at'))} ${text(h, 'note', '').isNotEmpty ? '• ${text(h, 'note')}' : ''}',
                                          style: TextStyle(fontFamily: 'Inter', fontSize: 11.sp, color: const Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),

                if (error != null) ...[
                  ErrorNotice(error!),
                  SizedBox(height: 10.h),
                ],

                if (busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(color: Color(0xFF0F766E)),
                  ),

                if (r['kind'] == 'Reimbursement')
                  Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                    child: Text(
                      r['version'] == 2
                          ? 'Dokumen final tersedia setelah persetujuan dan verifikasi finance. Persetujuan bukan bukti pembayaran.'
                          : 'Pengajuan lama belum memiliki rincian dan snapshot template. Dokumen otomatis tersedia untuk pengajuan baru.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        color: const Color(0xFF94A3B8),
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildStickyBottomActionBar(r, steps, id),
      ),
    ),
  );
}
}

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key, required this.api});
  final ApiClient api;
  @override
  State<ApprovalsScreen> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<ApprovalsScreen> {
  static const int _itemsPerPage = 10;
  int _currentPage = 1;
  Workspace? workspace;
  String? error;
  bool history = false;
  bool changed = false;
  String query = '';
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    AppLanguageController.instance.addListener(_onLanguageChanged);
    load();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _onPageChanged(int newPage) {
    setState(() => _currentPage = newPage);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_onLanguageChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final next = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          workspace = next;
          error = null;
        });
      }
      if (sl.isRegistered<WorkspaceBloc>()) {
        sl<WorkspaceBloc>().add(const WorkspaceRefreshRequested());
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Widget _buildHeroSummaryBanner(int pendingCount) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F766E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 105.w,
              height: 105.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -30.h,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 2.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      const Flexible(
                        child: Text(
                          'Pusat Persetujuan Tim',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                const Text(
                  'Tinjau & Beri Keputusan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  pendingCount > 0
                      ? 'Ada $pendingCount pengajuan menunggu tindakan persetujuan Anda.'
                      : 'Semua pengajuan telah ditindaklanjuti. Tidak ada yang tertunda.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedFilterBar(int pendingCount) {
    final filters = [
      {
        'key': 'pending',
        'label': pendingCount > 0
            ? 'Menunggu tindakan ($pendingCount)'
            : 'Menunggu tindakan',
        'isSelected': !history,
      },
      {
        'key': 'history',
        'label': 'Riwayat keputusan',
        'isSelected': history,
      },
    ];

    return Container(
      constraints: BoxConstraints(minHeight: 38.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: filters.map((f) {
          final isSelected = f['isSelected'] as bool;
          final label = f['label'] as String;
          final isPending = f['key'] == 'pending';

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('approval_filter_${f['key']}'),
                onTap: () {
                  if (isPending && history) {
                    setState(() {
                      history = false;
                      _currentPage = 1;
                    });
                  } else if (!isPending && !history) {
                    setState(() {
                      history = true;
                      _currentPage = 1;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(7.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F766E), // Teal 700
                              Color(0xFF14B8A6), // Teal 500
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(7.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0F766E)
                                  .withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari pemohon atau pengajuan...',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(
            UIcons.regularRounded.search,
            size: 20,
            color: const Color(0xFF94A3B8),
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(UIcons.regularRounded.cross_small, size: 18, color: const Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      query = '';
                      _currentPage = 1;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: Color(0xFF0F172A),
        ),
        onChanged: (v) => setState(() {
          query = v;
          _currentPage = 1;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = workspace;
    final allRequests = w?.rows('requests') ?? <Json>[];
    final actorId = w?.actor['employeeId'];

    final pendingCount = allRequests
        .where((r) => r['employeeId'] != actorId && r['canReview'] == true)
        .length;

    final rows =
        w
            ?.rows('requests')
            .where(
              (r) =>
                  r['employeeId'] != actorId &&
                  (history
                      ? ((r['steps'] as List?) ?? []).any(
                          (s) => ((s['decisions'] as List?) ?? []).any(
                            (d) => d['employeeId'] == actorId,
                          ),
                        )
                      : r['canReview'] == true),
            )
            .where(
              (r) =>
                  '${text(r, 'employeeName')} ${text(r, 'title')} ${text(r, 'kind')}'
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList() ??
        <Json>[];

    final totalItems = rows.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 999999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final pagedRows = totalItems == 0 || startIndex >= totalItems
        ? <Json>[]
        : rows.sublist(startIndex, endIndex);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.4,
          shadowColor: const Color(0x120F172A),
          titleSpacing: Navigator.of(context).canPop() ? 0 : 20,
          centerTitle: false,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(
                    UIcons.regularRounded.angle_small_left,
                    size: 20,
                    color: const Color(0xFF0F172A),
                  ),
                  onPressed: () => Navigator.pop(context, changed),
                )
              : null,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Persetujuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 1.5),
              Text(
                'Tinjau & Verifikasi Pengajuan Tim',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(11.r),
                  onTap: load,
                  child: Tooltip(
                    message: 'Segarkan persetujuan',
                    child: Icon(
                      UIcons.regularRounded.refresh,
                      size: 19.w,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF0F766E),
            onRefresh: load,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                _buildHeroSummaryBanner(pendingCount),
                SizedBox(height: 16.h),
                _buildSegmentedFilterBar(pendingCount),
                SizedBox(height: 14.h),
                _buildSearchBar(),
                SizedBox(height: 16.h),
                if (error != null) ...[
                  ErrorNotice(error!),
                  SizedBox(height: 8.h),
                  Center(
                    child: TextButton.icon(
                      onPressed: load,
                      icon: Icon(UIcons.regularRounded.refresh, color: const Color(0xFF0F766E)),
                      label: const Text(
                        'Coba lagi',
                        style: TextStyle(color: Color(0xFF0F766E)),
                      ),
                    ),
                  ),
                ],
                if (w == null && error == null)
                  const LinearProgressIndicator(color: Color(0xFF0F766E)),
                if (w != null && w.data['approvalAccess'] != true)
                  const ErrorNotice(
                    'Anda belum ditetapkan sebagai pemberi persetujuan.',
                  )
                else if (w != null && rows.isEmpty)
                  const EmptyState('Tidak ada pengajuan yang sesuai.')
                else ...[
                  for (final r in pagedRows)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: UniversalRequestCard(
                        data: UniversalRequestModel.fromMap(r),
                        showApplicant: true,
                        onCardTap: () async {
                          final result = await Navigator.of(
                            context,
                            rootNavigator: true,
                          ).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => RequestDetailScreen(
                                api: widget.api,
                                request: r,
                                own: false,
                              ),
                            ),
                          );
                          if (result == true) {
                            changed = true;
                            await load();
                          }
                        },
                      ),
                    ),
                  _buildPaginationBar(
                    currentPage,
                    totalPages,
                    startIndex,
                    endIndex,
                    totalItems,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<int> _calculateVisiblePages(int current, int total) {
    if (total <= 5) {
      return List.generate(total, (i) => i + 1);
    }
    int start = current - 2;
    int end = current + 2;
    if (start < 1) {
      start = 1;
      end = 5;
    }
    if (end > total) {
      end = total;
      start = total - 4;
    }
    return List.generate(end - start + 1, (i) => start + i);
  }

  Widget _buildPaginationBar(
    int currentPage,
    int totalPages,
    int startIndex,
    int endIndex,
    int totalItems,
  ) {
    final hasPrev = currentPage > 1;
    final hasNext = currentPage < totalPages;
    final visiblePages = _calculateVisiblePages(currentPage, totalPages);
    final isEn = AppLanguageController.currentLanguage == AppLanguage.en;

    return Container(
      key: const ValueKey('pagination_bar'),
      margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Teks Info di Atas (Halaman X dari Y & Menampilkan A-B dari N)
          Text(
            isEn
                ? 'Page $currentPage of $totalPages'
                : 'Halaman $currentPage dari $totalPages',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            totalItems == 0
                ? (isEn ? 'No submissions' : 'Tidak ada pengajuan')
                : (isEn
                    ? 'Showing ${startIndex + 1}\u2013$endIndex of $totalItems submissions'
                    : 'Menampilkan ${startIndex + 1}\u2013$endIndex dari $totalItems pengajuan'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 10.h),

          // 2. Deretan Tombol Angka Standar [<] [ 1 ] [ 2 ] [ 3 ] [>]
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Panah Kiri (<)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_prev_btn'),
                  onTap: hasPrev
                      ? () => _onPageChanged(currentPage - 1)
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasPrev
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasPrev
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      UIcons.regularRounded.angle_small_left,
                      size: 20.sp,
                      color: hasPrev
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Kotak-Kotak Angka Halaman
              ...visiblePages.map((page) {
                final isActive = page == currentPage;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isActive
                          ? null
                          : () => _onPageChanged(page),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF0D9488)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF0D9488)
                                : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5.sp,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(width: 6.w),

              // Tombol Panah Kanan (>)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_next_btn'),
                  onTap: hasNext
                      ? () => _onPageChanged(currentPage + 1)
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasNext
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasNext
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      UIcons.regularRounded.angle_small_right,
                      size: 20.sp,
                      color: hasNext
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
String requestDateLabel(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final local = value.length > 10 ? date.toLocal() : date;
  final base =
      '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  return value.length > 10
      ? '$base, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}'
      : base;
}

typedef RequestDetailPage = RequestDetailScreen;
typedef ApprovalsPage = ApprovalsScreen;

