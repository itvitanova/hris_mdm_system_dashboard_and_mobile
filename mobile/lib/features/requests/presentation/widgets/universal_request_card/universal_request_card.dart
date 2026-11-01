import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'request_card_config.dart';
import 'request_revision_box.dart';
import 'request_segmented_stepper.dart';

export '../../../domain/entities/submission_kind.dart';
export '../../../domain/entities/submission_status.dart';
export '../../../domain/entities/universal_request_item.dart';
export 'request_card_config.dart';
export 'request_revision_box.dart';
export 'request_segmented_stepper.dart';

/// Universal Request Card Widget
/// Dilengkapi Judul Tipe Pengajuan (Eyebrow), Judul Bebas Elipsis, dan Stepper Murni.
class UniversalRequestCard extends StatelessWidget {
  final UniversalRequestModel data;
  final VoidCallback? onCardTap;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onRevisePressed;

  const UniversalRequestCard({
    super.key,
    required this.data,
    this.onCardTap,
    this.onDetailPressed,
    this.onRevisePressed,
  });

  @override
  Widget build(BuildContext context) {
    final kindConfig = RequestCardHelper.getKindConfig(data);
    final statusConfig = RequestCardHelper.getStatusConfig(
      data.status,
      data.kind,
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
              // 1. Aksen Garis Vertikal Kiri
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6.w,
                child: Container(color: statusConfig.barColor),
              ),

              // 2. Konten Utama
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 15.h, 16.w, 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BARIS 1: Icon Mint + Type Title + Judul Custom (Full Width, No Ellipsis)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mint Icon Box 40x40
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F4),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            kindConfig.icon,
                            size: 19.w,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Title & Tags Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TYPE TITLE EYEBROW
                              Text(
                                kindConfig.typeTitle.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F766E),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              SizedBox(height: 2.h),

                              // Judul 100% Bebas Elipsis (Auto Multi-Line)
                              Text(
                                data.title,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  height: 1.3,
                                  letterSpacing: -0.2,
                                ),
                              ),

                              SizedBox(height: 6.h),

                              // Tag Baris: [METRIK] [STATUS HALUS] Subtitle
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6.w,
                                runSpacing: 4.h,
                                children: [
                                  // Metric Tag Chip (e.g. [1 HARI])
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                      vertical: 2.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F7F4),
                                      borderRadius: BorderRadius.circular(5.r),
                                      border: Border.all(
                                        color: const Color(0xFFA7F3D0),
                                      ),
                                    ),
                                    child: Text(
                                      kindConfig.metricTag(data),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F766E),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),

                                  // Status Badge Inline Bersih (Tanpa Icon)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                      vertical: 2.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusConfig.badgeBg,
                                      borderRadius: BorderRadius.circular(5.r),
                                      border: Border.all(
                                        color: statusConfig.badgeBorder,
                                      ),
                                    ),
                                    child: Text(
                                      statusConfig.label,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: statusConfig.textColor,
                                      ),
                                    ),
                                  ),

                                  // Subtitle Ringkas
                                  if (kindConfig.secondaryMeta(data) != null)
                                    Text(
                                      kindConfig.secondaryMeta(data)!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // BARIS 2: Deskripsi Keperluan (Prosa Bersih Tanpa Boks)
                    if (data.description != null &&
                        data.description!.trim().isNotEmpty &&
                        data.description != '-') ...[
                      SizedBox(height: 10.h),
                      Text(
                        data.description!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ],

                    SizedBox(height: 12.h),

                    // BARIS 3: STEPPER ATAU REVISION BOX
                    if (isRevision && data.reviewNote != null)
                      RequestRevisionBox(
                        note: data.reviewNote!,
                        reviewerName: data.reviewedBy,
                      )
                    else
                      RequestSegmentedStepper(data: data),

                    SizedBox(height: 12.h),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    SizedBox(height: 10.h),

                    // BARIS 4: Tanggal di Kiri & Tombol Aksi di Kanan
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13.w,
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                RequestCardHelper.formatDateRange(
                                  data.startDate,
                                  data.endDate,
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),

                          if (isRevision)
                            InkWell(
                              onTap: onRevisePressed,
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
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
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: const Color(0x59FFFFFF),
                                    width: 1,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x28E11D48),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      size: 13.w,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4.w),
                                    const Text(
                                      'Perbaiki pengajuan',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            InkWell(
                              onTap: onDetailPressed,
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF0F766E),
                                      Color(0xFF14B8A6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: const Color(0x59FFFFFF),
                                    width: 1,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x200F766E),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 13.w,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4.w),
                                    const Text(
                                      'Rincian dan dokumen',
                                      style: TextStyle(
                                        fontSize: 11.5,
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
                    ),
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
