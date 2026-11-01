import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../domain/entities/submission_kind.dart';
import '../../domain/entities/submission_status.dart';
import '../models/mock_request_notifications.dart';
import 'request_detail_page.dart';

/// Halaman Notifikasi Pembaruan Pengajuan Mandiri
/// Dilengkapi Header Dua Baris Seragam, Segmented Filter ('Semua' & 'Belum Dibaca'),
/// Aksi 'Tandai Semua Dibaca', serta kartu notifikasi modern scannable.
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
    final mockList = getMockRequestNotifications();
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

      return RequestNotificationItem(
        id: 'real-$reqId',
        requestId: reqId,
        kind: kind,
        requestTitle: text(r, 'title', 'Pengajuan ${kind.displayName}'),
        status: status,
        headline: headline,
        message: message,
        timeAgo: 'Baru saja',
        isUnread: isUnread,
        reviewerName: reviewer.isNotEmpty ? reviewer : null,
        reviewNote: note.isNotEmpty ? note : null,
        rawRequest: r,
      );
    }).toList();

    return [
      ...realItems,
      ...mockList.map((m) {
        if (_readIds.contains(m.id)) {
          return m.copyWith(isUnread: false);
        }
        return m;
      }),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      final all = _getCombinedNotifications();
      for (final item in all) {
        _readIds.add(item.id);
      }
    });
  }

  Future<void> _openItem(RequestNotificationItem item) async {
    setState(() {
      _readIds.add(item.id);
    });

    final targetRequest = item.rawRequest ??
        {
          'id': item.requestId,
          'title': item.requestTitle,
          'kind': item.kind.displayName,
          'status': item.status.displayName,
          'reviewedBy': item.reviewerName ?? 'Peninjau',
          'reviewNote': item.reviewNote ?? '',
          'startDate': DateTime.now().toIso8601String().substring(0, 10),
          'endDate': DateTime.now().toIso8601String().substring(0, 10),
        };

    await Navigator.push(
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
  }

  Widget _buildSegmentedFilterBar(int unreadCount) {
    final filters = [
      {'key': 'Semua', 'label': 'Semua'},
      {
        'key': 'Belum Dibaca',
        'label': unreadCount > 0 ? 'Belum Dibaca ($unreadCount)' : 'Belum Dibaca',
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
                              color: const Color(0xFF0F766E).withValues(alpha: 0.25),
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
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
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

  Widget _buildNotificationCard(RequestNotificationItem item) {
    final isRevision = item.status == SubmissionStatus.perluRevisi;
    final statusColor = item.status == SubmissionStatus.disetujui
        ? const Color(0xFF0F766E)
        : (isRevision ? const Color(0xFFE11D48) : const Color(0xFFD97706));

    final iconData = item.kind == SubmissionKind.cuti
        ? Icons.calendar_today_rounded
        : (item.kind == SubmissionKind.reimbursement
            ? Icons.receipt_long_rounded
            : (item.kind == SubmissionKind.pettyCash
                ? Icons.account_balance_wallet_rounded
                : (item.kind == SubmissionKind.lembur
                    ? Icons.schedule_rounded
                    : Icons.inventory_2_rounded)));

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('notif_item_${item.id}'),
          onTap: () => _openItem(item),
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            decoration: BoxDecoration(
              color: item.isUnread ? const Color(0xFFFAFDFF) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: item.isUnread
                    ? const Color(0xFFBAE6FD)
                    : const Color(0xFFE2E8F0),
                width: item.isUnread ? 1 : 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Aksen Garis Vertikal Kiri 3.5px
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 3.5.w,
                  child: Container(color: statusColor),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Squircle Icon 38x38
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: isRevision
                              ? const Color(0xFFFFF1F2)
                              : (item.status == SubmissionStatus.disetujui
                                  ? const Color(0xFFF0FDFA)
                                  : const Color(0xFFFEF3C7)),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isRevision
                                ? const Color(0xFFFECDD3)
                                : (item.status == SubmissionStatus.disetujui
                                    ? const Color(0xFFCCFBF1)
                                    : const Color(0xFFFDE68A)),
                            width: 0.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isRevision ? Icons.edit_note_rounded : iconData,
                          size: 19.w,
                          color: isRevision
                              ? const Color(0xFFBE123C)
                              : (item.status == SubmissionStatus.disetujui
                                  ? const Color(0xFF0F766E)
                                  : const Color(0xFFB45309)),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Konten Pesan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kategori · Waktu · Dot Unread
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${item.kind.displayName} · ${item.timeAgo}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10.5,
                                      fontWeight: item.isUnread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: item.isUnread
                                          ? const Color(0xFF0F766E)
                                          : const Color(0xFF94A3B8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.isUnread) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    width: 6.5.w,
                                    height: 6.5.w,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D9488),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 3.h),

                            // Headline Judul Notifikasi
                            Text(
                              item.headline,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontWeight: item.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: const Color(0xFF0F172A),
                                height: 1.3,
                                letterSpacing: -0.1,
                              ),
                            ),
                            SizedBox(height: 3.h),

                            // Detail Pesan / Catatan Peninjau
                            Text(
                              item.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: isRevision
                                    ? const Color(0xFF9F1239)
                                    : const Color(0xFF64748B),
                                height: 1.35,
                              ),
                            ),

                            // Quick Action Pill jika Perlu Revisi
                            if (isRevision) ...[
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: const Color(0xFFFECDD3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      size: 11.w,
                                      color: const Color(0xFFE11D48),
                                    ),
                                    SizedBox(width: 4.w),
                                    const Text(
                                      'Perbaiki sekarang',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE11D48),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18.w,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
          children: const [
            Text(
              'Notifikasi Pengajuan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 1.5),
            Text(
              'Pembaruan Status & Keputusan',
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
          if (unreadCount > 0)
            Container(
              margin: EdgeInsets.only(right: 16.w),
              child: Material(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(8.r),
                child: InkWell(
                  key: const Key('notif_mark_all_read_btn'),
                  onTap: _markAllAsRead,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFCCFBF1),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.done_all_rounded,
                          size: 14.w,
                          color: const Color(0xFF0F766E),
                        ),
                        SizedBox(width: 4.w),
                        const Text(
                          'Tandai Dibaca',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F766E),
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
              // 1. Segmented Status Filter Bar
              _buildSegmentedFilterBar(unreadCount),
              SizedBox(height: 14.h),

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

              // 2. Daftar Notifikasi
              if (filteredItems.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
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
                          size: 24.w,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _selectedFilter == 'Belum Dibaca'
                            ? 'Tidak ada notifikasi yang belum dibaca.'
                            : 'Belum ada pembaruan pengajuan saat ini.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      const Text(
                        'Pembaruan keputusan dan catatan peninjau akan muncul di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredItems.map(_buildNotificationCard),
            ],
          ),
        ),
      ),
    );
  }
}

typedef RequestNotificationsPage = RequestNotificationsScreen;
