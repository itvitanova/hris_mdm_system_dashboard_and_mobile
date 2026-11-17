import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'profile_info_card.dart';

/// Grid 2x2 Info Cards (Tinggi dan Lebar Simetris 100%)
class ProfileInfoGrid extends StatelessWidget {
  final String empId;
  final String dept;
  final String position;
  final String phone;

  const ProfileInfoGrid({
    super.key,
    required this.empId,
    required this.dept,
    required this.position,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileInfoCard(
                icon: UIcons.regularRounded.qrcode,
                label: 'ID Karyawan',
                value: empId,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ProfileInfoCard(
                icon: UIcons.regularRounded.building,
                label: 'Departemen',
                value: dept,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: ProfileInfoCard(
                icon: UIcons.regularRounded.briefcase,
                label: 'Jabatan',
                value: position,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ProfileInfoCard(
                icon: UIcons.regularRounded.phone_call,
                label: 'Nomor Telepon',
                value: phone,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
