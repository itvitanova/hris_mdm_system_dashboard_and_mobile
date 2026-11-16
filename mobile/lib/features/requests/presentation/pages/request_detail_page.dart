import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../home/presentation/bloc/workspace_state.dart';
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
  Workspace? _workspace;

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
          _workspace = w;
          request = matches.first;
          error = null;
        });
      } else if (force && matches.isEmpty) {
        throw ApiException(
          'Pengajuan tidak ditemukan atau akses sudah berubah.',
        );
      } else if (mounted) {
        setState(() {
          _workspace = w;
        });
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
    IconData? icon,
    String? svgPath,
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
                child: svgPath != null
                    ? SvgPicture.asset(
                        svgPath,
                        width: 15.w,
                        height: 15.w,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0F766E),
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(icon, size: 15.w, color: const Color(0xFF0F766E)),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  SizedBox(width: 5.w),
                  action,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankModalRow({
    required String label,
    required String value,
    String? copyValue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 6,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5.sp,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (copyValue != null && copyValue.isNotEmpty) ...[
                SizedBox(width: 4.w),
                _CopyIconButton(
                  textToCopy: copyValue,
                  label: label,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewAttachmentAction(
    String attachmentId, {
    String title = 'Berkas Lampiran',
  }) {
    final reqId = text(request, 'id', '');
    final receiptPath = reqId.isNotEmpty
        ? '/requests/${Uri.encodeComponent(reqId)}/receipts/${Uri.encodeComponent(attachmentId)}'
        : '/request-receipts/${Uri.encodeComponent(attachmentId)}';
    final fallbackPath = reqId.isNotEmpty
        ? '/request-receipts/${Uri.encodeComponent(attachmentId)}'
        : null;

    return Material(
      color: const Color(0xFFF0FDFA),
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: busy
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceiptPreview(
                    api: widget.api,
                    path: receiptPath,
                    fallbackPath: fallbackPath,
                    title: title,
                  ),
                ),
              ),
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: const Color(0xFF99F6E4),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                UIcons.regularRounded.eye,
                size: 11.5.w,
                color: const Color(0xFF0F766E),
              ),
              SizedBox(width: 3.5.w),
              Text(
                'Lihat lampiran',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'HR';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  Widget _buildDescriptionBlock(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 9.w,
        top: 2.h,
        bottom: 2.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: const Color(0xFFCBD5E1),
            width: 2.5.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value.startsWith('"') && value.endsWith('"') ? value : '"$value"',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
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

    // Deduplikasi jika teks di dalam kurung sama persis dengan teks utama di luar kurung
    // Contoh: "kertas AVS part 2 (kertas AVS part 2)" -> "kertas AVS part 2"
    final duplicateMatch = RegExp(r'^(.*?)\s*\(\s*(.*?)\s*\)$', caseSensitive: false).firstMatch(cleaned);
    if (duplicateMatch != null) {
      final mainText = duplicateMatch.group(1)!.trim();
      final insideParen = duplicateMatch.group(2)!.trim();
      if (mainText.toLowerCase() == insideParen.toLowerCase()) {
        cleaned = mainText;
      }
    }

    return cleaned.isNotEmpty ? cleaned : '—';
  }

  String _cleanDescriptionText(String rawDesc) {
    if (rawDesc.isEmpty) return '';
    var desc = rawDesc;
    final metadataMatch = RegExp(r'\n\n\[(.*?)\]$').firstMatch(desc);
    if (metadataMatch != null) {
      final metaContent = metadataMatch.group(1)!;
      final parts = metaContent
          .split(' · ')
          .where((part) {
            final p = part.trim().toLowerCase();
            return !p.startsWith('lampiran:') && !p.startsWith('jenis izin:');
          })
          .toList();
      final baseDesc = desc.substring(0, metadataMatch.start).trim();
      if (parts.isNotEmpty) {
        desc = baseDesc.isNotEmpty ? '$baseDesc\n\n[${parts.join(' · ')}]' : '[${parts.join(' · ')}]';
      } else {
        desc = baseDesc;
      }
    } else {
      desc = desc.replaceAll(RegExp(r'\[?Lampiran:\s*[^\]\n]+\]?', caseSensitive: false), '');
      desc = desc.replaceAll(RegExp(r'\[?Jenis Izin:\s*[^\]\n]+\]?', caseSensitive: false), '');
    }
    return desc.trim();
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
                Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: busy
                        ? const LinearGradient(
                            colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
                          )
                        : const LinearGradient(
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
                      onTap: busy ? null : () => decide('Disetujui'),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Center(
                        child: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    UIcons.regularRounded.paper_plane,
                                    size: 16.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    isFinanceStep ? 'Verifikasi finance' : 'Setujui',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
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
                kindConfig.typeTitle,
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
                // ==================== 1. UNIFIED REQUEST OVERVIEW CARD ====================
                Container(
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
                      // Header Row: Type & Tanggal Diajukan (Left) + Status Badge (Right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 38.w,
                                  height: 38.w,
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
                                        color: Color(0x220F766E),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    kindConfig.icon,
                                    size: 19.w,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        kindConfig.typeTitle.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                        'Diajukan pada ${requestDateLabel(text(r, 'createdAt'))}',
                                        softWrap: true,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
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
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
                      ),

                      // Judul Pengajuan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Judul Pengajuan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            text(r, 'title').isNotEmpty ? text(r, 'title') : '—',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              height: 1.35,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),

                      // Baris Metrik Utama (Highlight Box Khusus per jenis pengajuan)
                      Builder(
                        builder: (context) {
                          String? metricLabel;
                          String? metricValue;
                          IconData metricIcon = UIcons.regularRounded.calendar;

                          switch (model.kind) {
                            case SubmissionKind.cuti:
                              final totalDays = days ?? model.days ?? 1;
                              metricLabel = 'Total Hari Cuti';
                              metricValue = '$totalDays Hari';
                              metricIcon = UIcons.regularRounded.calendar_clock;
                              break;
                            case SubmissionKind.izin:
                              if (days != null && days > 0) {
                                metricLabel = 'Durasi Izin';
                                metricValue = '$days Hari';
                              }
                              metricIcon = UIcons.regularRounded.calendar_check;
                              break;
                            case SubmissionKind.lembur:
                              final totalHours = hours ?? model.hours ?? 1;
                              metricLabel = 'Total Durasi Lembur';
                              metricValue = '$totalHours Jam';
                              metricIcon = UIcons.regularRounded.clock;
                              break;
                            case SubmissionKind.reimbursement:
                              if (hasAmount) {
                                metricLabel = 'Total Klaim Biaya';
                                metricValue = rupiah(amount);
                              }
                              metricIcon = UIcons.regularRounded.receipt;
                              break;
                            case SubmissionKind.medicalClaim:
                              if (hasAmount) {
                                metricLabel = 'Biaya Perawatan Medis';
                                metricValue = rupiah(amount);
                              }
                              metricIcon = UIcons.regularRounded.stethoscope;
                              break;
                            case SubmissionKind.pettyCash:
                              if (hasAmount) {
                                metricLabel = 'Nominal Kas Kecil';
                                metricValue = rupiah(amount);
                              }
                              metricIcon = UIcons.regularRounded.wallet;
                              break;
                            case SubmissionKind.generalAffair:
                              if (hasAmount) {
                                metricLabel = 'Estimasi Biaya';
                                metricValue = rupiah(amount);
                              }
                              metricIcon = UIcons.regularRounded.boxes;
                              break;
                          }

                          if (metricLabel == null || metricValue == null) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            margin: EdgeInsets.only(top: 14.h),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x200F766E),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    metricIcon,
                                    size: 20.w,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        metricLabel,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(alpha: 0.85),
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        metricValue,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Divider pemisah ke rincian keperluan & parameter
                      SizedBox(height: 14.h),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      SizedBox(height: 10.h),

                      // Keperluan / Deskripsi dengan Label Kontekstual & Format Quote Strip
                      Builder(
                        builder: (context) {
                          final cleanedDesc = _cleanDescriptionText(text(r, 'description'));
                          if (cleanedDesc.isEmpty) return const SizedBox.shrink();

                          final isEn = AppLanguageController.currentLanguage == AppLanguage.en;
                          String descLabel;
                          switch (model.kind) {
                            case SubmissionKind.cuti:
                              descLabel = isEn ? 'Leave Reason' : 'Alasan Cuti';
                              break;
                            case SubmissionKind.izin:
                              descLabel = isEn ? 'Permission Reason' : 'Alasan Izin';
                              break;
                            case SubmissionKind.lembur:
                              descLabel = isEn ? 'Overtime Tasks' : 'Uraian Tugas Lembur';
                              break;
                            case SubmissionKind.reimbursement:
                              descLabel = isEn ? 'Claim Description' : 'Keterangan Klaim';
                              break;
                            case SubmissionKind.medicalClaim:
                              descLabel = isEn ? 'Medical Notes / Diagnosis' : 'Catatan / Diagnosa Medis';
                              break;
                            case SubmissionKind.pettyCash:
                              descLabel = isEn ? 'Fund Purpose' : 'Peruntukan Dana';
                              break;
                            case SubmissionKind.generalAffair:
                              descLabel = isEn ? 'GA Requirements' : 'Deskripsi Kebutuhan GA';
                              break;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDescriptionBlock(descLabel, cleanedDesc),
                              SizedBox(height: 12.h),
                            ],
                          );
                        },
                      ),

                      // Parameter Spesifik per Jenis Pengajuan
                      Builder(
                        builder: (context) {
                          final start = text(r, 'startDate');
                          final end = text(r, 'endDate');
                          final dateLabel = start == end || end.isEmpty
                              ? requestDateLabel(start)
                              : '${requestDateLabel(start)} – ${requestDateLabel(end)}';

                          switch (model.kind) {
                            case SubmissionKind.cuti:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (start.isNotEmpty || end.isNotEmpty)
                                    _buildInfoRow('Periode Cuti', dateLabel, icon: UIcons.regularRounded.calendar),
                                  if (model.leaveBalance != null)
                                    _buildInfoRow('Sisa Cuti', '${model.leaveBalance} Hari', icon: UIcons.regularRounded.calendar_clock),
                                ],
                              );

                            case SubmissionKind.izin:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (r['permissionType'] != null && text(r, 'permissionType').isNotEmpty)
                                    _buildInfoRow('Jenis Izin', text(r, 'permissionType'), icon: UIcons.regularRounded.document),
                                  if (start.isNotEmpty || end.isNotEmpty)
                                    _buildInfoRow('Periode Izin', dateLabel, icon: UIcons.regularRounded.calendar),
                                ],
                              );

                            case SubmissionKind.lembur:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (start.isNotEmpty)
                                    _buildInfoRow('Tanggal Lembur', requestDateLabel(start), icon: UIcons.regularRounded.calendar),
                                ],
                              );

                            case SubmissionKind.reimbursement:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (start.isNotEmpty || end.isNotEmpty)
                                    _buildInfoRow('Periode Biaya', dateLabel, icon: UIcons.regularRounded.calendar),
                                  _buildInfoRow(
                                    'Jumlah Transaksi',
                                    '${items.isNotEmpty ? items.length : (model.transactionCount ?? 1)} item pengeluaran',
                                    icon: UIcons.regularRounded.receipt,
                                  ),
                                ],
                              );

                            case SubmissionKind.medicalClaim:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (start.isNotEmpty)
                                    _buildInfoRow('Tanggal Perawatan', requestDateLabel(start), icon: UIcons.regularRounded.calendar),
                                  if (r['category'] != null && text(r, 'category').isNotEmpty)
                                    _buildInfoRow('Kategori Medis', text(r, 'category'), icon: UIcons.regularRounded.stethoscope),
                                ],
                              );

                            case SubmissionKind.pettyCash:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (start.isNotEmpty)
                                    _buildInfoRow('Tanggal Kebutuhan', requestDateLabel(start), icon: UIcons.regularRounded.calendar),
                                  if (r['category'] != null && text(r, 'category').isNotEmpty)
                                    _buildInfoRow('Kategori Kas', text(r, 'category'), icon: UIcons.regularRounded.wallet),
                                ],
                              );

                            case SubmissionKind.generalAffair:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (r['category'] != null && text(r, 'category').isNotEmpty)
                                    _buildInfoRow('Kategori GA', text(r, 'category'), icon: UIcons.regularRounded.apps),
                                  if (r['priority'] != null && text(r, 'priority').isNotEmpty)
                                    _buildInfoRow('Prioritas GA', text(r, 'priority'), icon: UIcons.regularRounded.flag),
                                  if (r['location'] != null && text(r, 'location').isNotEmpty)
                                    _buildInfoRow('Lokasi', text(r, 'location'), icon: UIcons.regularRounded.marker),
                                  if (start.isNotEmpty)
                                    _buildInfoRow('Tanggal Permintaan', requestDateLabel(start), icon: UIcons.regularRounded.calendar),
                                ],
                              );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // ==================== 4. PROFIL PEMOHON & REKENING ====================
                Builder(
                  builder: (context) {
                    Workspace? currentWs = _workspace;
                    if (currentWs == null && sl.isRegistered<WorkspaceBloc>()) {
                      final wsState = sl<WorkspaceBloc>().state;
                      if (wsState is WorkspaceLoaded) {
                        currentWs = wsState.workspace;
                      }
                    }

                    final applicantEmpId = text(snapshot, 'employeeId', text(r, 'employeeId'));
                    Json empFromWs = {};
                    if (currentWs != null && applicantEmpId.isNotEmpty) {
                      empFromWs = currentWs.rows('employees').firstWhere(
                        (e) => e['id'] == applicantEmpId,
                        orElse: () => {},
                      );
                    }

                    final applicantName = text(
                      snapshot,
                      'name',
                      text(empFromWs, 'name', text(r, 'employeeName', 'Karyawan')),
                    );

                    final rawNik = text(snapshot, 'employeeNumber', text(empFromWs, 'employeeNumber'));
                    final applicantId = (rawNik.isNotEmpty && rawNik != '—')
                        ? rawNik
                        : (applicantEmpId != '—' ? applicantEmpId : '');

                    final rawDept = text(snapshot, 'department');
                    final dept = (rawDept.isNotEmpty && rawDept != '—')
                        ? rawDept
                        : text(empFromWs, 'department', 'Divisi');

                    final rawPos = text(snapshot, 'position');
                    final pos = (rawPos.isNotEmpty && rawPos != '—')
                        ? rawPos
                        : text(empFromWs, 'position', 'Karyawan');

                    final rawPhone = text(snapshot, 'phone');
                    final phone = (rawPhone.isNotEmpty && rawPhone != '—')
                        ? rawPhone
                        : text(empFromWs, 'phone', '');

                    final rawBankName = text(snapshot, 'bankName');
                    final bankName = (rawBankName.isNotEmpty && rawBankName != '—')
                        ? rawBankName
                        : text(empFromWs, 'bankName', '');

                    final rawBankAccountName = text(snapshot, 'bankAccountName');
                    final bankAccountName = (rawBankAccountName.isNotEmpty && rawBankAccountName != '—')
                        ? rawBankAccountName
                        : text(empFromWs, 'bankAccountName', '');

                    final rawBankAccountNumber = text(snapshot, 'bankAccountNumber');
                    final bankAccountNumber = (rawBankAccountNumber.isNotEmpty && rawBankAccountNumber != '—')
                        ? rawBankAccountNumber
                        : text(empFromWs, 'bankAccountNumber', '');

                    final isTransferRelevant = model.kind == SubmissionKind.reimbursement ||
                        model.kind == SubmissionKind.medicalClaim;
                    final shouldShowBank = isTransferRelevant && bankAccountNumber.isNotEmpty;

                    return _buildSectionCard(
                      svgPath: 'assets/icon/profile-not-active.svg',
                      title: 'Informasi Pemohon',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11.r),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF0F766E),
                                      Color(0xFF14B8A6),
                                    ],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x180F766E),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _getInitials(applicantName),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      applicantName,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '$dept · $pos',
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
                          if (applicantId.isNotEmpty || phone.isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            SizedBox(height: 4.h),
                          ],
                          if (applicantId.isNotEmpty)
                            _buildInfoRow(
                              'ID Karyawan',
                              applicantId,
                              icon: UIcons.regularRounded.badge_check,
                              copyValue: applicantId,
                              showColon: true,
                            ),
                          if (phone.isNotEmpty)
                            _buildInfoRow(
                              'Nomor Telepon',
                              phone,
                              icon: UIcons.regularRounded.phone_call,
                              copyValue: phone,
                              showColon: true,
                            ),
                          if (shouldShowBank) ...[
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        UIcons.regularRounded.bank,
                                        size: 15.w,
                                        color: const Color(0xFF0F766E),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'Rekening Penerima Transfer',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0F766E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  if (bankName.isNotEmpty) ...[
                                    _buildBankModalRow(label: 'Nama Bank', value: bankName),
                                    Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
                                  ],
                                  _buildBankModalRow(
                                    label: 'Nomor Rekening',
                                    value: bankAccountNumber,
                                    copyValue: bankAccountNumber,
                                  ),
                                  if (bankAccountName.isNotEmpty) ...[
                                    Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
                                    _buildBankModalRow(
                                      label: 'Nama Pemilik',
                                      value: bankAccountName,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                if (items.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: UIcons.regularRounded.receipt,
                    title: 'Rincian Pengeluaran',
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${items.length} item',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 4.h),
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 38.w,
                                  height: 38.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 0.8,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _getExpenseCategoryIcon(text(items[i], 'category')),
                                    size: 17.w,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _cleanItemDescription(text(items[i], 'description')),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                                        spacing: 5.w,
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
                                              fontSize: 10.sp,
                                              color: const Color(0xFFCBD5E1),
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
                                SizedBox(width: 10.w),
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
                              ],
                            ),
                          ),
                        ],
                        Padding(
                          padding: EdgeInsets.only(top: 14.h, bottom: 12.h),
                          child: const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total Pengeluaran',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                Text(
                                  '${items.length} transaksi tercatat',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              rupiah(amount),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // ==================== 5B. BERKAS LAMPIRAN / BUKTI TRANSAKSI (DIPISAH SENDIRI) ====================
                if (items.any((item) => text(item, 'receiptId').isNotEmpty) || text(r, 'attachmentId', '').isNotEmpty) ...[
                  _buildSectionCard(
                    icon: UIcons.regularRounded.clip,
                    title: 'Berkas Lampiran Pengajuan',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bukti Transaksi per Item Pengeluaran (Reimbursement)
                        for (var i = 0; i < items.length; i++) ...[
                          if (text(items[i], 'receiptId').isNotEmpty) ...[
                            if (i > 0 && items.take(i).any((prev) => text(prev, 'receiptId').isNotEmpty))
                              SizedBox(height: 8.h),
                            Container(
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
                                    child: Icon(
                                      UIcons.regularRounded.document,
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
                                          'Bukti Transaksi ${i + 1}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _cleanItemDescription(text(items[i], 'description')),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10.5.sp,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildViewAttachmentAction(
                                    text(items[i], 'receiptId'),
                                    title: 'Bukti Transaksi ${i + 1}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],

                        // Lampiran Berkas Tunggal (Medical Claim, Izin, Cuti, dll)
                        if (text(r, 'attachmentId', '').isNotEmpty) ...[
                          if (items.any((item) => text(item, 'receiptId').isNotEmpty))
                            SizedBox(height: 8.h),
                          Container(
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
                                  child: Icon(
                                    UIcons.regularRounded.document,
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
                                        text(r, 'attachmentName', 'Bukti Lampiran Resmi'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Lampiran bukti pendukung pengajuan',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10.5.sp,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                _buildViewAttachmentAction(
                                  text(r, 'attachmentId'),
                                  title: 'Berkas Lampiran',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
    final isEn = AppLanguageController.currentLanguage == AppLanguage.en;
    final filters = [
      {
        'key': 'pending',
        'label': isEn ? 'Pending Action' : 'Menunggu tindakan',
        'isSelected': !history,
      },
      {
        'key': 'history',
        'label': isEn ? 'Decision History' : 'Riwayat keputusan',
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5.sp,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (isPending && pendingCount > 0) ...[
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.5.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.24)
                                : const Color(0xFFED2736),
                            borderRadius: BorderRadius.circular(10.r),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 0.8,
                                  )
                                : null,
                          ),
                          child: Text(
                            pendingCount > 99 ? '99+' : '$pendingCount',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ],
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

    return Scaffold(
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
          top: false,
          bottom: false,
          child: RefreshIndicator(
            color: const Color(0xFF0F766E),
            onRefresh: load,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
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
                      child: Builder(
                        builder: (context) {
                          Map<String, dynamic> enriched = r;
                          final hasDept = r['department'] != null ||
                              (r['snapshot'] is Map && r['snapshot']['department'] != null);
                          if (!hasDept && w != null) {
                            final empId = r['employeeId'] ??
                                (r['snapshot'] is Map ? r['snapshot']['employeeId'] : null);
                            if (empId != null) {
                              final emp = w.rows('employees').firstWhere(
                                (e) => e['id'] == empId,
                                orElse: () => {},
                              );
                              final d = emp['department']?.toString().trim();
                              if (d != null && d.isNotEmpty && d != '—') {
                                enriched = Map<String, dynamic>.from(r);
                                enriched['department'] = d;
                              }
                            }
                          }
                          return UniversalRequestCard(
                            data: UniversalRequestModel.fromMap(enriched),
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
                          );
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
      margin: EdgeInsets.only(top: 8.h, bottom: 2.h),
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

