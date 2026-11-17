import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_card_input.dart';
import '../form_sections/petty_cash_form_section.dart';

/// FormCardTextInput styled for Medical Claim treatment expenses input
class MedicalClaimAmountCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const MedicalClaimAmountCard({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormCardTextInput(
      controller: controller,
      height: 48.h,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 14.w, right: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rp',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(width: 8.w),
            Container(width: 1.w, height: 18.h, color: const Color(0xFFCBD5E1)),
          ],
        ),
      ),
      hintText: '0',
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF94A3B8),
      ),
      onChanged: (_) => onChanged(),
    );
  }
}
