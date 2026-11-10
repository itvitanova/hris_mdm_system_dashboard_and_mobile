import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../domain/entities/submission_kind.dart';
import '../../domain/entities/submission_status.dart';
import '../../domain/entities/request_notification_item.dart';
import 'request_detail_page.dart';
import 'request_form_page.dart';

/// Halaman Notifikasi Pembaruan Pengajuan Mandiri
/// Dilengkapi Header Dua Baris Seragam, Segmented Filter ('Semua' & 'Belum Dibaca'),
/// Aksi 'Tandai Semua Dibaca', Card Notifikasi Modern dengan Catatan Peninjau,
/// Tombol 'Perbaiki Sekarang', serta Pengelompokan Hari ('Hari Ini', 'Kemarin', 'Terdahulu').
class RequestNotificationsScreen extends StatefulWidget {
  const RequestNotificationsScreen({
    super.key,
    required this.api,
    required this.workspace,
  });

  final ApiClient api;
  final Workspace workspace;

  @override
  State<RequestNotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends State<RequestNotificationsScreen> {
  late Workspace data = widget.workspace;
  String? error;
  String _selectedFilter = 'Semua';
  final Set<String> _readIds = {};
  bool _markingAsRead = false;

  Future<void> refresh() async {
    try {
      final next = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          data = next;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  List<RequestNotificationItem> _getCombinedNotifications() {
    final realRows = data.mine('requests').where((r) {
      final history = (r['history'] as List?) ?? [];
      return r['unread'] == true ||
          text(r, 'reviewNote', '').isNotEmpty ||
          (history.isNotEmpty &&
              (history.last as Map)['decision'] != 'Diajukan');
    }).toList();

    final realItems = realRows.map((r) {
      final kind = SubmissionKind.fromString(text(r, 'kind', 'cuti'));
      final status = SubmissionStatus.fromString(text(r, 'status', 'menunggu'));
      final reqId = text(r, 'id');
      final isUnread = r['unread'] == true && !_readIds.contains('real-$reqId');
      final note = text(r, 'reviewNote', '');
      final reviewer = text(r, 'reviewedBy', text(r, 'pendingWith', ''));

      String headline = 'Pengajuan ${kind.displayName}';
      if (status == SubmissionStatus.disetujui) {
        headline = 'Pengajuan ${kind.displayName} Disetujui';
      } else if (status == SubmissionStatus.perluRevisi) {
        headline = 'Perlu Revisi Dokumen ${kind.displayName}';
      } else if (status == SubmissionStatus.ditolak) {
        headline = 'Pengajuan ${kind.displayName} Ditolak';
      } else {
        headline = 'Pembaruan Pengajuan ${kind.displayName}';
      }

      String message = note.isNotEmpty
          ? 'Catatan peninjau: "$note"'
          : (reviewer.isNotEmpty
              ? 'Pembaruan peninjauan dari $reviewer'
              : 'Buka untuk melihat perkembangan keputusan.');

      final dateStr = text(r, 'updatedAt', text(r, 'createdAt', ''));
      final rawDt = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;
      final dt = rawDt?.toLocal();
      final now = DateTime.now();

      String timeAgoText = 'Baru saja';
      if (dt != null) {
        final startOfToday = DateTime(now.year, now.month, now.day);
        final startOfYesterday = DateTime(now.year, now.month, now.day - 1);
        final itemDate = DateTime(dt.year, dt.month, dt.day);

        if (!dt.isBefore(startOfToday)) {
          // Hari Ini: terjadi pada jam 00:00:00 atau setelahnya pada hari ini
          final diff = now.difference(dt);
          if (diff.inHours > 0) {
            timeAgoText = '${diff.inHours} jam lalu';
          } else if (diff.inMinutes > 0) {
            timeAgoText = '${diff.inMinutes} mnt lalu';
          } else {
            timeAgoText = 'Baru saja';
          }
        } else if (!dt.isBefore(startOfYesterday)) {
          // Kemarin: terjadi pada jam 00:00:00 s.d. 23:59:59 kemarin
          timeAgoText = 'Kemarin';
        } else {
          // Terdahulu: terjadi sebelum jam 00:00:00 kemarin
          final daysDiff = startOfToday.difference(itemDate).inDays;
          if (daysDiff <= 30) {
            timeAgoText = '$daysDiff hari lalu';
          } else {
            final day = dt.day.toString().padLeft(2, '0');
            final month = dt.month.toString().padLeft(2, '0');
            timeAgoText = '$day/$month/${dt.year}';
          }
        }
      }

      return RequestNotificationItem(
        id: 'real-$reqId',
        requestId: reqId,
        kind: kind,
        requestTitle: text(r, 'title', 'Pengajuan ${kind.displayName}'),
        status: status,
        headline: headline,
        message: message,
        timeAgo: timeAgoText,
        isUnread: isUnread,
        reviewerName: reviewer.isNotEmpty ? reviewer : null,
        reviewNote: note.isNotEmpty ? note : null,
        rawRequest: r,
        createdAt: dt,
      );
    }).toList();

    return realItems;
  }

  Future<void> _markAllAsRead() async {
    final all = _getCombinedNotifications();
    final unreadItems = all.where((it) => it.isUnread).toList();
    if (unreadItems.isEmpty || _markingAsRead) return;

    setState(() {
      _markingAsRead = true;
      for (final item in unreadItems) {
        _readIds.add(item.id);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: Text(
                  'Semua notifikasi telah ditandai dibaca',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F766E),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }

    try {
      final unreadRequests =
          data.mine('requests').where((r) => r['unread'] == true).toList();
      for (final r in unreadRequests) {
        final id = text(r, 'id');
        final token = text(r, 'updateToken');
        if (id.isNotEmpty && token.isNotEmpty) {
          try {
            await widget.api.post(
              '/requests/${Uri.encodeComponent(id)}/seen',
              {'token': token},
            );
          } catch (_) {
            // Abaikan kegagalan individual
          }
        }
      }
      final next = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          data = next;
          error = null;
        });
      }
    } catch (_) {
      // Graceful fallback for offline / network errors
    } finally {
      if (mounted) {
        setState(() {
          _markingAsRead = false;
        });
      }
    }
  }

  Json _resolveRequestForItem(RequestNotificationItem item) {
    if (item.rawRequest != null && item.rawRequest!.isNotEmpty) {
      return Map<String, dynamic>.from(item.rawRequest!);
    }
    final matches =
        data.rows('requests').where((r) => r['id'] == item.requestId);
    if (matches.isNotEmpty) {
      return Map<String, dynamic>.from(matches.first);
    }
    return {
      'id': item.requestId,
      'title': item.requestTitle,
      'kind': item.kind.displayName,
      'status': item.status.displayName,
      'reviewedBy': item.reviewerName ?? 'Peninjau',
      'reviewNote': item.reviewNote ?? '',
      'startDate': DateTime.now().toIso8601String().substring(0, 10),
      'endDate': DateTime.now().toIso8601String().substring(0, 10),
      'revision': 0,
    };
  }

  Future<void> _openRevisionForm(RequestNotificationItem item) async {
    setState(() {
      _readIds.add(item.id);
    });

    final targetRequest = _resolveRequestForItem(item);

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestForm(
          api: widget.api,
          workspace: data,
          initialKind: item.kind.displayName,
          initialRequest: targetRequest,
          lockKindSelection: true,
        ),
      ),
    );

    if (changed == true) {
      await refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8.w),
                const Expanded(
                  child: Text(
                    'Pengajuan yang direvisi telah berhasil dikirim.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F766E),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openItem(RequestNotificationItem item) async {
    setState(() {
      _readIds.add(item.id);
    });

    final targetRequest = _resolveRequestForItem(item);

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(
          api: widget.api,
          request: targetRequest,
          own: true,
        ),
      ),
    );

    await refresh();
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: Text(
                  'Pengajuan yang direvisi telah berhasil dikirim.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F766E),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  Widget _buildSegmentedFilterBar(int unreadCount) {
    final filters = [
      {'key': 'Semua', 'label': 'Semua'},
      {
        'key': 'Belum Dibaca',
        'label':
            unreadCount > 0 ? 'Belum Dibaca ($unreadCount)' : 'Belum Dibaca',
      },
    ];

    return Container(
      height: 38.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: filters.map((f) {
          final key = f['key']!;
          final label = f['label']!;
          final isSelected = _selectedFilter == key;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('notif_filter_$key'),
                onTap: () {
                  setState(() {
                    _selectedFilter = key;
                  });
                },
                borderRadius: BorderRadius.circular(7.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
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

  /// Section Header Grouping Hari: HARI INI, KEMARIN, TERDAHULU
  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.w, 14.h, 2.w, 8.h),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          const Expanded(
            child: Divider(
              color: Color(0xFFE2E8F0),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Notifikasi Modern Berbasis Signature Solid Surface & Teal Accent
  Widget _buildNotificationCard(RequestNotificationItem item) {
    final isRevision = item.status == SubmissionStatus.perluRevisi;
    final isRejected = item.status == SubmissionStatus.ditolak;
    final isApproved = item.status == SubmissionStatus.disetujui;

    final iconData = item.kind == SubmissionKind.cuti
        ? Icons.calendar_today_rounded
        : (item.kind == SubmissionKind.reimbursement
            ? Icons.receipt_long_rounded
            : (item.kind == SubmissionKind.pettyCash
                ? Icons.account_balance_wallet_rounded
                : (item.kind == SubmissionKind.lembur
                    ? Icons.schedule_rounded
                    : Icons.inventory_2_rounded)));

    final hasReviewNote =
        item.reviewNote != null && item.reviewNote!.trim().isNotEmpty;
    // Aksi revisi ("Perbaiki Sekarang") hanya untuk status 'Perlu Revisi', bukan untuk pengajuan yang ditolak
    final needsFixAction = isRevision;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.white,
          width: 1.5.w,
        ),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Stack(
          children: [
            // Left Unread Accent Indicator Bar
            if (item.isUnread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3.5.w,
                child: Container(
                  color: AppColors.filterTealAccent,
                ),
              ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('notif_item_${item.id}'),
                onTap: () => _openItem(item),
                splashColor: const Color(0xFF0D9488).withValues(alpha: 0.08),
                highlightColor:
                    const Color(0xFF0D9488).withValues(alpha: 0.03),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Corporate Teal Squircle Icon
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFFCCFBF1),
                            width: 1.w,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          iconData,
                          size: 20.sp,
                          color: const Color(0xFF0D9488),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Konten Notifikasi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Kategori Tag & Status Pill
                            Row(
                              children: [
                                Flexible(
                                  child: Wrap(
                                    spacing: 6.w,
                                    runSpacing: 4.h,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 7.w,
                                          vertical: 2.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDFA),
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                          border: Border.all(
                                            color: const Color(0xFFCCFBF1),
                                            width: 0.8.w,
                                          ),
                                        ),
                                        child: Text(
                                          item.kind.displayName,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.deepTeal,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 7.w,
                                          vertical: 2.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isApproved
                                              ? const Color(0xFFDCFCE7)
                                              : (isRevision
                                                  ? const Color(0xFFFFF1F2)
                                                  : (isRejected
                                                      ? const Color(0xFFFEE2E2)
                                                      : const Color(
                                                          0xFFFEF3C7))),
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          item.status.displayName,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isApproved
                                                ? const Color(0xFF15803D)
                                                : (isRevision
                                                    ? const Color(0xFFE11D48)
                                                    : (isRejected
                                                        ? const Color(
                                                            0xFFDC2626)
                                                        : const Color(
                                                            0xFFB45309))),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (item.isUnread) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    width: 7.w,
                                    height: 7.w,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D9488),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: 5.h),

                            // 2. Headline Judul Notifikasi
                            Text(
                              item.headline,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5.sp,
                                fontWeight: item.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: item.isUnread
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF334155),
                                letterSpacing: -0.2,
                                height: 1.3,
                              ),
                            ),

                            SizedBox(height: 3.h),

                            // 3. Ringkasan Pesan
                            Text(
                              item.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                                height: 1.38,
                              ),
                            ),

                            // 4. Catatan Peninjau (Reviewer Note Box)
                            if (hasReviewNote) ...[
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 7.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.w,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.rate_review_outlined,
                                          size: 13.sp,
                                          color: AppColors.deepTeal,
                                        ),
                                        SizedBox(width: 5.w),
                                        Expanded(
                                          child: Text(
                                            'Catatan Peninjau${item.reviewerName != null ? ' (${item.reviewerName})' : ''}:',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.deepTeal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      item.reviewNote!,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11.sp,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF334155),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // 5. Button "Perbaiki Sekarang"
                            if (needsFixAction) ...[
                              SizedBox(height: 8.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    key: ValueKey('notif_fix_now_${item.id}'),
                                    onTap: () => _openRevisionForm(item),
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE11D48),
                                            Color(0xFFF43F5E),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE11D48)
                                                .withValues(alpha: 0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_calendar_rounded,
                                            size: 12.sp,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            'Perbaiki Sekarang',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            SizedBox(height: 8.h),

                            // 6. Metadata Bar (Waktu & Chevron)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 11.5.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  item.timeAgo,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16.sp,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _getCombinedNotifications();
    final unreadCount = allItems.where((i) => i.isUnread).length;

    final filteredItems = _selectedFilter == 'Belum Dibaca'
        ? allItems.where((i) => i.isUnread).toList()
        : allItems;

    // Pengelompokan Notifikasi: Hari Ini, Kemarin, Terdahulu
    // Mengikuti batas pergantian hari kalender (jam 00:00), bukan rolling 24 jam
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = DateTime(now.year, now.month, now.day - 1);

    final todayItems = <RequestNotificationItem>[];
    final yesterdayItems = <RequestNotificationItem>[];
    final earlierItems = <RequestNotificationItem>[];

    for (final item in filteredItems) {
      if (item.createdAt != null) {
        final dt = item.createdAt!.toLocal();
        if (!dt.isBefore(startOfToday)) {
          todayItems.add(item);
        } else if (!dt.isBefore(startOfYesterday)) {
          yesterdayItems.add(item);
        } else {
          earlierItems.add(item);
        }
      } else {
        final time = item.timeAgo.toLowerCase();
        if (time.contains('kemarin')) {
          yesterdayItems.add(item);
        } else if (time.contains('hari lalu') ||
            time.contains('minggu') ||
            time.contains('bulan') ||
            time.contains('/') ||
            time.contains('202') ||
            time.contains('okt') ||
            time.contains('sep')) {
          earlierItems.add(item);
        } else {
          todayItems.add(item);
        }
      }
    }

    final sections = <_NotificationDaySection>[];
    if (todayItems.isNotEmpty) {
      sections.add(
        _NotificationDaySection(title: 'Hari Ini', items: todayItems),
      );
    }
    if (yesterdayItems.isNotEmpty) {
      sections.add(
        _NotificationDaySection(title: 'Kemarin', items: yesterdayItems),
      );
    }
    if (earlierItems.isNotEmpty) {
      sections.add(
        _NotificationDaySection(title: 'Terdahulu', items: earlierItems),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notifikasi Pengajuan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Pembaruan Status & Keputusan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            child: Material(
              color: unreadCount > 0
                  ? const Color(0xFFF0FDFA)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              child: InkWell(
                key: const Key('notif_mark_all_read_btn'),
                onTap: unreadCount > 0 && !_markingAsRead
                    ? _markAllAsRead
                    : null,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: unreadCount > 0
                          ? const Color(0xFFCCFBF1)
                          : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 14.sp,
                        color: unreadCount > 0
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Tandai Dibaca',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: unreadCount > 0
                              ? const Color(0xFF0F766E)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          color: const Color(0xFF0F766E),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 16.h),
            children: [
              // 1. Segmented Status Filter Bar ('Semua' & 'Belum Dibaca')
              _buildSegmentedFilterBar(unreadCount),
              SizedBox(height: 10.h),

              if (error != null)
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Color(0xFFBE123C)),
                  ),
                ),

              // 2. Daftar Notifikasi (Grouping: Hari Ini, Kemarin, Terdahulu)
              if (filteredItems.isEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.notifications_off_outlined,
                          size: 24.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _selectedFilter == 'Belum Dibaca'
                            ? 'Tidak ada notifikasi yang belum dibaca.'
                            : 'Belum ada pembaruan pengajuan saat ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Pembaruan keputusan dan catatan peninjau akan muncul di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...sections.expand((section) => [
                      _buildSectionHeader(section.title, section.items.length),
                      ...section.items.map(_buildNotificationCard),
                    ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDaySection {
  final String title;
  final List<RequestNotificationItem> items;

  const _NotificationDaySection({
    required this.title,
    required this.items,
  });
}

typedef RequestNotificationsPage = RequestNotificationsScreen;
