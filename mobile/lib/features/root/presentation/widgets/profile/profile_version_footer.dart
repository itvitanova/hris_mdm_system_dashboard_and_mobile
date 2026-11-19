import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileVersionFooter extends StatelessWidget {
  const ProfileVersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'HRIS MDM System • Versi 1.2.0 (Build 2013)',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
