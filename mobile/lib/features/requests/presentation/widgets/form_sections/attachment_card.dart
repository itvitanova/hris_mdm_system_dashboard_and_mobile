import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'form_ui_components.dart';

class FormAttachmentCard extends StatelessWidget {
  final String? attachmentName;
  final VoidCallback onPickAttachment;
  final VoidCallback onClearAttachment;

  const FormAttachmentCard({
    super.key,
    required this.attachmentName,
    required this.onPickAttachment,
    required this.onClearAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return buildFormCardContainer(
      child: attachmentName != null
          ? Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPickAttachment,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.file_present_rounded,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attachmentName!,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Ketuk untuk mengganti berkas',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF0D9488),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Tooltip(
                  message: 'Hapus lampiran',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('delete_attachment_button'),
                      onTap: onClearAttachment,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFFECACA),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 15.sp,
                              color: const Color(0xFFDC2626),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickAttachment,
                borderRadius: BorderRadius.circular(8.r),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.upload_file_rounded,
                        size: 20.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Berkas Lampiran',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'PDF, JPG, PNG (Maks 2MB)',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 18.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
