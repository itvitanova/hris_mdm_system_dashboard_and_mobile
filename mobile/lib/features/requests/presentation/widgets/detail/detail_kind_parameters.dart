import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import '../universal_request_card/universal_request_card.dart';
import 'detail_formatters.dart';
import 'detail_info_row.dart';

/// Renders specific parameter rows depending on submission kind
class DetailKindParameters extends StatelessWidget {
  const DetailKindParameters({
    super.key,
    required this.model,
    required this.r,
    required this.items,
  });

  final UniversalRequestModel model;
  final Json r;
  final List<Json> items;

  @override
  Widget build(BuildContext context) {
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
              DetailInfoRow(
                label: 'Periode Cuti',
                value: dateLabel,
                icon: UIcons.regularRounded.calendar,
              ),
            if (model.leaveBalance != null)
              DetailInfoRow(
                label: 'Sisa Cuti',
                value: '${model.leaveBalance} Hari',
                icon: UIcons.regularRounded.calendar_clock,
              ),
          ],
        );

      case SubmissionKind.izin:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r['permissionType'] != null &&
                text(r, 'permissionType').isNotEmpty)
              DetailInfoRow(
                label: 'Jenis Izin',
                value: text(r, 'permissionType'),
                icon: UIcons.regularRounded.document,
              ),
            if (start.isNotEmpty || end.isNotEmpty)
              DetailInfoRow(
                label: 'Periode Izin',
                value: dateLabel,
                icon: UIcons.regularRounded.calendar,
              ),
          ],
        );

      case SubmissionKind.lembur:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (start.isNotEmpty)
              DetailInfoRow(
                label: 'Tanggal Lembur',
                value: requestDateLabel(start),
                icon: UIcons.regularRounded.calendar,
              ),
          ],
        );

      case SubmissionKind.reimbursement:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (start.isNotEmpty || end.isNotEmpty)
              DetailInfoRow(
                label: 'Periode Biaya',
                value: dateLabel,
                icon: UIcons.regularRounded.calendar,
              ),
            DetailInfoRow(
              label: 'Jumlah Transaksi',
              value:
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
              DetailInfoRow(
                label: 'Tanggal Perawatan',
                value: requestDateLabel(start),
                icon: UIcons.regularRounded.calendar,
              ),
            if (r['category'] != null && text(r, 'category').isNotEmpty)
              DetailInfoRow(
                label: 'Kategori Medis',
                value: text(r, 'category'),
                icon: UIcons.regularRounded.stethoscope,
              ),
          ],
        );

      case SubmissionKind.pettyCash:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (start.isNotEmpty)
              DetailInfoRow(
                label: 'Tanggal Kebutuhan',
                value: requestDateLabel(start),
                icon: UIcons.regularRounded.calendar,
              ),
            if (r['category'] != null && text(r, 'category').isNotEmpty)
              DetailInfoRow(
                label: 'Kategori Kas',
                value: text(r, 'category'),
                icon: UIcons.regularRounded.wallet,
              ),
          ],
        );

      case SubmissionKind.generalAffair:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r['category'] != null && text(r, 'category').isNotEmpty)
              DetailInfoRow(
                label: 'Kategori GA',
                value: text(r, 'category'),
                icon: UIcons.regularRounded.apps,
              ),
            if (r['priority'] != null && text(r, 'priority').isNotEmpty)
              DetailInfoRow(
                label: 'Prioritas GA',
                value: text(r, 'priority'),
                icon: UIcons.regularRounded.flag,
              ),
            if (r['location'] != null && text(r, 'location').isNotEmpty)
              DetailInfoRow(
                label: 'Lokasi',
                value: text(r, 'location'),
                icon: UIcons.regularRounded.marker,
              ),
            if (start.isNotEmpty)
              DetailInfoRow(
                label: 'Tanggal Permintaan',
                value: requestDateLabel(start),
                icon: UIcons.regularRounded.calendar,
              ),
          ],
        );
    }
  }
}
