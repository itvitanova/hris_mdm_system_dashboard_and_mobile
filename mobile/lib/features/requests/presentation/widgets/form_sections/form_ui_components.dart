import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
export '../form_card_input.dart';

Widget buildFormSectionTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontFamily: 'Inter',
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF0F172A),
    ),
  );
}

Widget buildFormSectionLabel(String label) {
  return Text(
    label,
    style: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF0F172A),
    ),
  );
}

Widget buildFormCardContainer({
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    width: double.infinity,
    padding: padding ?? EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.04),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget buildFormInputCard({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      color: Colors.white,
    ),
    child: child,
  );
}

Widget buildFormPickerBox({
  required String label,
  required IconData icon,
  required String valueText,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  icon,
                  size: 14.sp,
                  color: const Color(0xFF0D9488),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      valueText,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

