import 'package:flutter/material.dart';
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
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
                width: 6,
                child: Container(color: statusConfig.barColor),
              ),

              // 2. Konten Utama
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 16, 15),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            kindConfig.icon,
                            size: 19,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                        const SizedBox(width: 12),

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
                              const SizedBox(height: 2),

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

                              const SizedBox(height: 6),

                              // Tag Baris: [METRIK] [STATUS HALUS] Subtitle
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  // Metric Tag Chip (e.g. [1 HARI])
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F7F4),
                                      borderRadius: BorderRadius.circular(5),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusConfig.badgeBg,
                                      borderRadius: BorderRadius.circular(5),
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
                      const SizedBox(height: 10),
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

                    const SizedBox(height: 12),

                    // BARIS 3: STEPPER ATAU REVISION BOX
                    if (isRevision && data.reviewNote != null)
                      RequestRevisionBox(
                        note: data.reviewNote!,
                        reviewerName: data.reviewedBy,
                      )
                    else
                      RequestSegmentedStepper(data: data),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),

                    // BARIS 4: Tanggal di Kiri & Tombol Aksi di Kanan
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              RequestCardHelper.formatDateRange(
                                data.startDate,
                                data.endDate,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),

                        if (isRevision)
                          InkWell(
                            onTap: onRevisePressed,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFECDD3),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 13,
                                    color: Color(0xFFBE123C),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Perbaiki pengajuan',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFBE123C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          InkWell(
                            onTap: onDetailPressed,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 13,
                                    color: Color(0xFF0F766E),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Rincian dan dokumen',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
