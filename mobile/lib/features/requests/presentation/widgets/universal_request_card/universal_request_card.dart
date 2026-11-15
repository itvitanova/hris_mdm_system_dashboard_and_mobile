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
          .where((part) => !part.trim().toLowerCase().startsWith('lampiran:'))
          .toList();
      final baseDesc = desc.substring(0, metadataMatch.start).trim();
      if (parts.isNotEmpty) {
        desc = baseDesc.isNotEmpty ? '$baseDesc\n\n[${parts.join(' · ')}]' : '[${parts.join(' · ')}]';
      } else {
        desc = baseDesc;
      }
    } else {
      desc = desc.replaceAll(RegExp(r'\[?Lampiran:\s*[^\]\n]+\]?', caseSensitive: false), '').trim();
    }
    return desc.trim();
  }

  static String? _resolveExplicitCategory(UniversalRequestModel data) {
    final raw = data.rawMap;
    if (raw == null) return null;
    final cat = raw['category']?.toString().trim();
    if (cat != null &&
        cat.isNotEmpty &&
        cat != '—' &&
        cat != '-' &&
        !cat.toLowerCase().contains('general affair') &&
        !cat.toLowerCase().contains('kas operasional') &&
        !cat.toLowerCase().contains('manfaat medis') &&
        !cat.toLowerCase().contains('klaim medis')) {
      return cat;
    }
    final leaveType = (raw['leaveType'] ?? raw['permissionType'])?.toString().trim();
    if (leaveType != null &&
        leaveType.isNotEmpty &&
        leaveType != '—' &&
        leaveType != '-' &&
        leaveType.toLowerCase() != 'cuti' &&
        leaveType.toLowerCase() != 'izin') {
      return leaveType;
    }
    return null;
  }

  static Widget _buildCardInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 4.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14.w,
            color: const Color(0xFF94A3B8),
          ),
          SizedBox(width: 6.w),
          Text(
            '$label : ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Blok Kiri: Icon Squircle 38x38 + Judul, Subtitle & Nama Pemohon
                        Expanded(
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
                                    // 1. Judul Pengajuan
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

                                    // 2. Tipe Pengajuan & Metadata Pendukung (Bersih tanpa jumlah hari / metrik duplikat)
                                    Builder(
                                      builder: (context) {
                                        final secondaryMetaRaw = kindConfig
                                            .secondaryMeta(data)
                                            ?.replaceAll(RegExp(r'^[·\-\s]+'), '')
                                            .trim();
                                        final transactionText = data.transactionCount != null &&
                                                data.transactionCount! > 0
                                            ? (language == AppLanguage.en
                                                ? '${data.transactionCount} transactions'
                                                : '${data.transactionCount} transaksi')
                                            : null;
                                        final metaDetail = transactionText ?? secondaryMetaRaw;

                                        return Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 5.w,
                                          children: [
                                            Text(
                                              kindConfig.typeTitle,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F766E),
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                            if (metaDetail != null && metaDetail.isNotEmpty) ...[
                                              const Text(
                                                '•',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                              Text(
                                                metaDetail,
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
                        SizedBox(width: 10.w),

                        // Blok Kanan: Status Pill Rata di Pojok Kanan Atas Kartu
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

                    // BARIS 2: Deskripsi Keperluan (Label 'Deskripsi :' dengan Teks Alasan Simetris)
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language == AppLanguage.en ? 'Description :' : 'Deskripsi :',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 3.5.h),
                              Text(
                                cleanedDesc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF334155),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // BARIS 2B: Metadata Kategori & Nama Pemohon (Gaya Info Row Lengkap tanpa tombol copy)
                    Builder(
                      builder: (context) {
                        final cat = _resolveExplicitCategory(data);
                        final hasCategory = cat != null && cat.isNotEmpty;
                        final hasApplicant =
                            data.employeeName.isNotEmpty && data.employeeName != '—';

                        if (!hasCategory && !hasApplicant) return const SizedBox.shrink();

                        return Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasCategory)
                                _buildCardInfoRow(
                                  icon: kindConfig.icon,
                                  label: language == AppLanguage.en ? 'Category' : 'Kategori',
                                  value: cat,
                                ),
                              if (hasApplicant)
                                _buildCardInfoRow(
                                  icon: UIcons.regularRounded.user,
                                  label: language == AppLanguage.en ? 'Applicant' : 'Pemohon',
                                  value: data.employeeName,
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    // BARIS 3: JIKA PERLU REVISI (Tampilkan Box Revisi + Tombol Aksi Kritis)
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
                      // BARIS 3 NORMAL: Divider + Tanggal di Kiri & Chevron + Metrik (Nominal/Durasi) di Kanan
                      Padding(
                        padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
                        child: const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (bottomMetric != null) ...[
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
                                SizedBox(width: 4.w),
                              ],
                              Icon(
                                UIcons.regularRounded.angle_small_right,
                                size: 18.w,
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
