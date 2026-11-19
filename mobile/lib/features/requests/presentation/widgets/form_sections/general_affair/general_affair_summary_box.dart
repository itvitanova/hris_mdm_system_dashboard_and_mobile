import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'ga_summary_category_date_row.dart';
import 'ga_summary_location_attachment_card.dart';

class GeneralAffairSummaryBox extends StatelessWidget {
  final String category;
  final String priority;
  final String dateText;
  final String locationText;
  final String? attachmentName;

  const GeneralAffairSummaryBox({
    super.key,
    required this.category,
    required this.priority,
    required this.dateText,
    required this.locationText,
    this.attachmentName,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = priority == 'Mendesak';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDFA), Color(0xFFE6FFFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFF99F6E4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080D9488),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  UIcons.regularRounded.boxes,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Ringkasan Kebutuhan GA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.5.h,
                ),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFEE2E2) : Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF99F6E4),
                    width: 0.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUrgent) ...[
                      Icon(
                        UIcons.regularRounded.bolt,
                        size: 11.sp,
                        color: const Color(0xFFDC2626),
                      ),
                      SizedBox(width: 3.w),
                    ],
                    Text(
                      priority,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isUrgent
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GaSummaryCategoryDateRow(
            category: category,
            dateText: dateText,
          ),
          SizedBox(height: 10.h),
          GaSummaryLocationAttachmentCard(
            locationText: locationText,
            attachmentName: attachmentName,
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0x66CCFBF1),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: const Color(0xFF99F6E4),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Icon(
                    UIcons.regularRounded.info,
                    size: 14.sp,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Permohonan GA akan diverifikasi oleh tim operasional fasilitas sesuai ketersediaan sarana dan jadwal teknisi.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5.sp,
                      color: const Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
