import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/submission_kind.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'request_card_config.dart';
import 'request_revision_box.dart';

export '../../../domain/entities/submission_kind.dart';
export '../../../domain/entities/submission_status.dart';
export '../../../domain/entities/universal_request_item.dart';
export 'request_card_config.dart';
export 'request_revision_box.dart';
export 'request_segmented_stepper.dart';

/// Universal Request Card Widget
/// Desain scannable, tenang, dan bersih dengan Status Pill di pojok kanan atas,
/// baris metadata terstruktur, dan chevron subtle (tanpa stepper berat / tombol berlebih).
class UniversalRequestCard extends StatelessWidget {
  final UniversalRequestModel data;
  final VoidCallback? onCardTap;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onRevisePressed;
  final bool showApplicant;
  final AppLanguage language;

  const UniversalRequestCard({
    super.key,
    required this.data,
    this.onCardTap,
    this.onDetailPressed,
    this.onRevisePressed,
    this.showApplicant = false,
    this.language = AppLanguage.id,
  });

  static String _cleanCardDescription(String raw) {
    var desc = raw;
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

  static String _getDescriptionLabel(SubmissionKind kind, AppLanguage language) {
    final isEn = language == AppLanguage.en;
    switch (kind) {
      case SubmissionKind.cuti:
        return isEn ? 'Leave Reason' : 'Alasan Cuti';
      case SubmissionKind.izin:
        return isEn ? 'Permission Reason' : 'Alasan Izin';
      case SubmissionKind.lembur:
        return isEn ? 'Overtime Tasks' : 'Uraian Tugas Lembur';
      case SubmissionKind.reimbursement:
        return isEn ? 'Claim Description' : 'Keterangan Klaim';
      case SubmissionKind.medicalClaim:
        return isEn ? 'Medical Notes / Diagnosis' : 'Catatan / Diagnosa Medis';
      case SubmissionKind.pettyCash:
        return isEn ? 'Fund Purpose' : 'Peruntukan Dana';
      case SubmissionKind.generalAffair:
        return isEn ? 'GA Requirements' : 'Deskripsi Kebutuhan GA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final kindConfig = RequestCardHelper.getKindConfig(data, language);
    final statusConfig = RequestCardHelper.getStatusConfig(
      data.status,
      data.kind,
      language,
    );
    final isRevision = data.status == SubmissionStatus.perluRevisi;
    final hasMonetaryAmount = (data.amount != null && data.amount! > 0) ||
        data.kind == SubmissionKind.reimbursement ||
        data.kind == SubmissionKind.pettyCash ||
        data.kind == SubmissionKind.medicalClaim;

    String? resolveBottomMetric() {
      if (hasMonetaryAmount) {
        return RequestCardHelper.formatIDR(data.amount ?? 0);
      }
      if (data.kind == SubmissionKind.cuti || data.kind == SubmissionKind.izin) {
        final days = data.days ?? 1;
        return '$days ${language == AppLanguage.en ? 'Hari' : 'Hari'}';
      }
      if (data.kind == SubmissionKind.lembur) {
        final hours = data.hours ?? 1;
        return '$hours ${language == AppLanguage.en ? 'Jam' : 'Jam'}';
      }
      return null;
    }

    final bottomMetric = resolveBottomMetric();
    final transactionCount = data.transactionCount != null && data.transactionCount! > 0
        ? data.transactionCount
        : null;
    final transactionText = transactionCount != null
        ? (language == AppLanguage.en
            ? '$transactionCount transactions'
            : '$transactionCount transaksi')
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCardTap ?? onDetailPressed,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFF5F5F5),
                blurRadius: 9,
                offset: Offset(0, 0),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 1. Aksen Garis Vertikal Kiri Tipis & Elegan (3.5px)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3.5.w,
                child: Container(color: statusConfig.barColor),
              ),

              // 2. Konten Utama
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BARIS 1: Header Rata Kanan-Kiri (Blok Identitas di Kiri, Badge Status Menempel di Kanan)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        // Identitas Pengajuan: Icon, Judul & Subtitle
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 220.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  children: [
                                    // Judul Pengajuan
                                    Text(
                                      data.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                        height: 1.3,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),

                                    // Subtitle Tipe & Meta Pendukung / Info Pemohon
                                    Builder(
                                      builder: (context) {
                                        final secondaryMetaRaw = kindConfig
                                            .secondaryMeta(data)
                                            ?.replaceAll(RegExp(r'^[·\-\s]+'), '')
                                            .trim();
                                        final isApprovalMode = showApplicant &&
                                            data.employeeName.isNotEmpty &&
                                            data.employeeName != '—';
                                        final hasDept = data.department != null &&
                                            data.department!.isNotEmpty &&
                                            data.department != '—' &&
                                            data.department != '-';
                                        final applicantDisplay = isApprovalMode
                                            ? (hasDept
                                                ? '${data.employeeName} (${data.department})'
                                                : data.employeeName)
                                            : kindConfig.typeTitle;

                                        return Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 5.w,
                                          children: [
                                            Text(
                                              applicantDisplay,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: isApprovalMode ? 11.5 : 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF0F766E),
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                            if (secondaryMetaRaw != null && secondaryMetaRaw.isNotEmpty) ...[
                                              const Text(
                                                '•',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                              Text(
                                                secondaryMetaRaw,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge Status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.5.h,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusConfig.textColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Deskripsi Pengajuan (Elegant Quote Strip dengan aksen garis kiri agar harmonis & tidak bentrok dengan Box Revisi)
                    Builder(
                      builder: (context) {
                        final raw = data.description;
                        if (raw == null || raw.trim().isEmpty || raw == '-') {
                          return const SizedBox.shrink();
                        }
                        final cleanedDesc = _cleanCardDescription(raw);
                        if (cleanedDesc.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Container(
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
                                  _getDescriptionLabel(data.kind, language),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                SizedBox(height: 2.5.h),
                                Text(
                                  '"$cleanedDesc"',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF334155),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Box Revisi & Aksi (Khusus status perlu revisi)
                    if (isRevision && data.reviewNote != null) ...[
                      SizedBox(height: 10.h),
                      RequestRevisionBox(
                        note: data.reviewNote!,
                        reviewerName: data.reviewedBy,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (bottomMetric != null) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (transactionText != null) ...[
                                      Text(
                                        transactionText,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '·',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                    ],
                                    Text(
                                      bottomMetric,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                              ],
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    UIcons.regularRounded.calendar,
                                    size: 12.w,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    RequestCardHelper.formatDateRange(
                                      data.startDate,
                                      data.endDate,
                                      language,
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: onRevisePressed,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.5.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFE11D48),
                                    Color(0xFFBE123C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x28E11D48),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    UIcons.regularRounded.refresh,
                                    size: 12.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    language == AppLanguage.en
                                        ? 'Revise submission'
                                        : 'Perbaiki pengajuan',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Footer: Tanggal di Kiri & Metrik/Aksi di Kanan
                      Padding(
                        padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
                        child: const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                UIcons.regularRounded.calendar,
                                size: 12.w,
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(width: 5.w),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 160.w),
                                child: Text(
                                  RequestCardHelper.formatDateRange(
                                    data.startDate,
                                    data.endDate,
                                    language,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (transactionText != null) ...[
                                Text(
                                  transactionText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                const Text(
                                  '·',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                              ],
                              if (bottomMetric != null) ...[
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 220.w),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      bottomMetric,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                              ],
                              Icon(
                                UIcons.regularRounded.angle_small_right,
                                size: 16.w,
                                color: const Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
