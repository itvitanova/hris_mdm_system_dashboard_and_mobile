import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_card_input.dart';

const defaultIzinTypes = [
  'Sakit',
  'Ibadah',
  'Melahirkan',
  'Keguguran',
  'Menikah',
  'Keluarga meninggal',
  'Lainnya',
];

/// Dropdown selector for permission (izin) categories
class RequestIzinTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onChanged;

  const RequestIzinTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis izin *',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 8.h),
        FormCardDropdownInput<String>(
          dropdownKey: const ValueKey('izin_type_dropdown'),
          initialValue: selectedType,
          hintText: 'Pilih jenis izin',
          items: defaultIzinTypes.map((t) {
            return DropdownMenuItem<String>(
              value: t,
              child: Text(t),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Pilih jenis izin';
            }
            return null;
          },
        ),
      ],
    );
  }
}
