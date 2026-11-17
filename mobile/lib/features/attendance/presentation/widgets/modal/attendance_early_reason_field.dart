import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Form field for early departure reason when clocking out early
class AttendanceEarlyReasonField extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String workEnd;

  const AttendanceEarlyReasonField({
    super.key,
    required this.formKey,
    required this.controller,
    required this.workEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pulang Sebelum Jadwal ($workEnd)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          TextFormField(
            controller: controller,
            minLines: 2,
            maxLines: 3,
            maxLength: 300,
            style: TextStyle(fontSize: 12.sp, fontFamily: 'Inter'),
            decoration: InputDecoration(
              hintText: 'Isi alasan pulang lebih awal (min. 5 karakter)...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5.sp,
                color: const Color(0xFF94A3B8),
              ),
              contentPadding: EdgeInsets.all(10.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
              ),
            ),
            validator: (v) =>
                (v?.trim().length ?? 0) < 5 ? 'Alasan wajib diisi minimal 5 karakter' : null,
          ),
        ],
      ),
    );
  }
}
