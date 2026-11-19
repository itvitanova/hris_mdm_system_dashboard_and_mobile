import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class GaSummaryLocationAttachmentCard extends StatelessWidget {
  final String locationText;
  final String? attachmentName;

  const GaSummaryLocationAttachmentCard({
    super.key,
    required this.locationText,
    this.attachmentName,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = locationText.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFCCFBF1),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                UIcons.regularRounded.marker,
                size: 15.sp,
                color: const Color(0xFF0D9488),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Penempatan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      hasLocation ? locationText.trim() : 'Sesuai meja kerja pemohon',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: hasLocation
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (attachmentName != null) ...[
            SizedBox(height: 8.h),
            const Divider(
              height: 1,
              thickness: 0.6,
              color: Color(0xFFF1F5F9),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  UIcons.regularRounded.clip,
                  size: 15.sp,
                  color: const Color(0xFF0D9488),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lampiran Berkas',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        attachmentName!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
