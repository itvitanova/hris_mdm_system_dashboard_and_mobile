import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../form_ui_components.dart';

class GaLocationCard extends StatelessWidget {
  final TextEditingController controller;
  final bool disabled;
  final VoidCallback? onChanged;

  const GaLocationCard({
    super.key,
    required this.controller,
    this.disabled = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildFormInputCard(
      child: TextFormField(
        controller: controller,
        enabled: !disabled,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: 'Lokasi Penempatan / Ruangan (Opsional)',
          hintText: 'Contoh: Gedung A, Lt. 3 - Ruang Operasional / Meja 12',
          prefixIcon: Icon(
            UIcons.regularRounded.marker,
            size: 18.sp,
            color: const Color(0xFF0D9488),
          ),
          helperText: 'Bantu tim GA menemukan titik sarana dengan tepat',
          helperStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5.sp,
            color: const Color(0xFF94A3B8),
          ),
        ),
        onChanged: (_) => onChanged?.call(),
      ),
    );
  }
}
