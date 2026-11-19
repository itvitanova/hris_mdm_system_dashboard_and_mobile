import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DurationPickerActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const DurationPickerActionButtons({
    super.key,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x200F766E),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onApply,
                borderRadius: BorderRadius.circular(10.r),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terapkan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
