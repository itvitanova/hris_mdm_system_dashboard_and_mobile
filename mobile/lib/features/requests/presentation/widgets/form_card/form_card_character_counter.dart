import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormCardCharacterCounter extends StatelessWidget {
  final Widget child;
  final int currentLength;
  final int maxLength;

  const FormCardCharacterCounter({
    super.key,
    required this.child,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$currentLength/$maxLength karakter',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }
}
