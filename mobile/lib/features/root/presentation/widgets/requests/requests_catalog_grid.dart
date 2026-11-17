import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/service_module_card.dart';

/// Grid 7 Modul Layanan Mandiri (Bento Layout 2 Kolom + 1 GA Featured)
class RequestsCatalogGrid extends StatelessWidget {
  final bool isEn;
  final String cutiMetricStr;
  final int izinCount;
  final String lemburMetricStr;
  final String reimburseMetricStr;
  final String medicalMetricStr;
  final String pettyCashMetricStr;
  final String gaMetricStr;
  final VoidCallback onOpenCuti;
  final VoidCallback onOpenIzin;
  final VoidCallback onOpenLembur;
  final VoidCallback onOpenReimbursement;
  final VoidCallback onOpenMedicalClaim;
  final VoidCallback onOpenPettyCash;
  final VoidCallback onOpenGeneralAffair;

  const RequestsCatalogGrid({
    super.key,
    required this.isEn,
    required this.cutiMetricStr,
    required this.izinCount,
    required this.lemburMetricStr,
    required this.reimburseMetricStr,
    required this.medicalMetricStr,
    required this.pettyCashMetricStr,
    required this.gaMetricStr,
    required this.onOpenCuti,
    required this.onOpenIzin,
    required this.onOpenLembur,
    required this.onOpenReimbursement,
    required this.onOpenMedicalClaim,
    required this.onOpenPettyCash,
    required this.onOpenGeneralAffair,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.w;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        const itemHeight = 142.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            // 1. Cuti
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: ServiceModuleCard(
                title: isEn ? 'Leave' : 'Cuti',
                metricTag: isEn ? 'Annual Leave' : 'Cuti Tahunan',
                description: isEn
                    ? 'Annual leave & personal time off'
                    : 'Cuti tahunan & urusan penting',
                icon: UIcons.regularRounded.calendar_clock,
                onTap: onOpenCuti,
              ),
            ),
            // 2. Izin
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: ServiceModuleCard(
                title: isEn ? 'Permission' : 'Izin',
                metricTag: isEn ? 'Official Letter' : 'Surat Izin',
                description: isEn
                    ? 'Sick leave & work dispensation'
                    : 'Sakit & dispensasi kerja',
                icon: UIcons.regularRounded.calendar_check,
                onTap: onOpenIzin,
              ),
            ),
            // 3. Lembur
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: ServiceModuleCard(
                title: isEn ? 'Overtime' : 'Lembur',
                metricTag: isEn ? 'Compensation' : 'Kompensasi',
                description: isEn
                    ? 'Overtime tasks & compensation'
                    : 'Tugas lembur & kompensasi',
                icon: UIcons.regularRounded.clock,
                onTap: onOpenLembur,
              ),
            ),
            // 4. Reimbursement
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: ServiceModuleCard(
                title: 'Reimbursement',
                metricTag: isEn ? 'Expense Claim' : 'Klaim Biaya',
                description: isEn
                    ? 'Transport, meals & clients'
                    : 'Transport, makan & klien',
                icon: UIcons.regularRounded.receipt,
                onTap: onOpenReimbursement,
              ),
            ),
            // 5. Medical Claim
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: ServiceModuleCard(
                title: 'Medical Claim',
                metricTag: isEn ? 'Medical Quota' : 'Plafon Medis',
                description: isEn
                    ? 'Outpatient & health expenses'
                    : 'Rawat jalan & pengobatan',
                icon: UIcons.regularRounded.stethoscope,
                onTap: onOpenMedicalClaim,
              ),
            ),
            // 6. Petty Cash
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: ServiceModuleCard(
                title: 'Petty Cash',
                metricTag: isEn ? 'Petty Cash' : 'Kas Kecil',
                description: isEn
                    ? 'Operational cash requests'
                    : 'Permohonan dana operasional',
                icon: UIcons.regularRounded.wallet,
                onTap: onOpenPettyCash,
              ),
            ),
            // 7. General Affair (Featured Full-Width Card)
            SizedBox(
              width: constraints.maxWidth,
              child: ServiceModuleCard(
                title: 'General Affair',
                metricTag: isEn ? 'Facilities & GA' : 'Fasilitas & GA',
                description: isEn
                    ? 'Equipment procurement, logistics & facilities'
                    : 'Pengadaan barang, logistik & sarana kantor',
                icon: UIcons.regularRounded.boxes,
                isFeatured: true,
                onTap: onOpenGeneralAffair,
              ),
            ),
          ],
        );
      },
    );
  }
}
