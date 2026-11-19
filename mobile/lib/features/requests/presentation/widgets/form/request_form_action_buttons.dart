import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Bottom action buttons (Cancel and Submit) for request submission
class RequestFormActionButtons extends StatelessWidget {
  final bool busy;
  final bool uploading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const RequestFormActionButtons({
    super.key,
    required this.busy,
    required this.uploading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton(
              onPressed: busy || uploading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                backgroundColor: Colors.white,
                elevation: 0,
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
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 6,
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: busy || uploading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
              ),
              child: busy
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : uploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Mengunggah...',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(UIcons.regularRounded.paper_plane, size: 15, color: Colors.white),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Kirim pengajuan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ],
    );
  }
}
