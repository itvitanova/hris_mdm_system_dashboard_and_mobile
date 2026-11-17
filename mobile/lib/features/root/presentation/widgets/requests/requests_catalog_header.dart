import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Header Teks untuk Katalog Pengajuan
class RequestsCatalogHeader extends StatelessWidget {
  final bool isEn;

  const RequestsCatalogHeader({
    super.key,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Submission Catalog' : 'Katalog Pengajuan',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          isEn
              ? 'Select a module to view quota summary & private history.'
              : 'Pilih modul untuk melihat rekap kuota & riwayat privat Anda.',
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
