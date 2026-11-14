import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final kindConfig = RequestCardHelper.getKindConfig(data, language);
    final statusConfig = RequestCardHelper.getStatusConfig(
      data.status,
      data.kind,
      language,
    );
    final isRevision = data.status == SubmissionStatus.perluRevisi;

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
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                    // Baris Metadata Ringkas & Tenang
                                    Text(
                                      [
                                        '${kindConfig.typeTitle} · ${kindConfig.metricTag(data)}',
                                        if (kindConfig.secondaryMeta(data) != null)
                                          kindConfig.secondaryMeta(data)!,
                                      ].join(' '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    if (showApplicant && data.employeeName.isNotEmpty) ...[
                                      SizedBox(height: 5.h),
                                      Row(
                                        children: [
                                          Icon(
                                            UIcons.regularRounded.user,
                                            size: 13.w,
                                            color: const Color(0xFF0F766E),
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              data.employeeName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F766E),
                                              ),
                                            ),
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

                    // BARIS 2: Deskripsi Keperluan (Maksimal 2 baris elipsis agar rapi)
                    if (data.description != null &&
                        data.description!.trim().isNotEmpty &&
                        data.description != '-') ...[
                      SizedBox(height: 8.h),
                      Text(
                        data.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                    ],

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
                      // BARIS 3 NORMAL: Tanggal di Kiri & Chevron Subtle '>' di Kanan
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  UIcons.regularRounded.calendar,
                                  size: 12.w,
                                  color: const Color(0xFF94A3B8),
                                ),
                                SizedBox(width: 5.w),
                                Expanded(
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
                          ),
                          Icon(
                            UIcons.regularRounded.angle_small_right,
                            size: 18.w,
                            color: const Color(0xFF94A3B8),
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
