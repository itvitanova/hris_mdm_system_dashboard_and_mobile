import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Row of download buttons (Unduh PDF and Excel)
class DetailDownloadActions extends StatelessWidget {
  const DetailDownloadActions({
    super.key,
    required this.id,
    required this.busy,
    required this.onShare,
  });

  final String id;
  final bool busy;
  final void Function(String path, String name) onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
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
                borderRadius: BorderRadius.circular(10.r),
                onTap: busy
                    ? null
                    : () => onShare(
                          '/requests/$id/document/pdf',
                          'reimbursement.pdf',
                        ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(UIcons.regularRounded.document,
                          size: 18.w, color: Colors.white),
                      SizedBox(width: 6.w),
                      Text(
                        'Unduh PDF',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
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
        SizedBox(width: 8.w),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 44.h,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.w),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              onPressed: busy
                  ? null
                  : () => onShare(
                        '/requests/$id/document/xlsx',
                        'reimbursement.xlsx',
                      ),
              icon: Icon(UIcons.regularRounded.table_layout,
                  size: 16.w, color: const Color(0xFF0F766E)),
              label: Text(
                'Excel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
