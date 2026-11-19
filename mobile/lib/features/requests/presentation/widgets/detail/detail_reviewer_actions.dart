import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';

/// Reviewer action buttons (Tolak, Minta Revisi, and Setujui / Verifikasi finance)
class DetailReviewerActions extends StatelessWidget {
  const DetailReviewerActions({
    super.key,
    required this.r,
    required this.busy,
    required this.isFinanceStep,
    required this.onDecide,
  });

  final Json r;
  final bool busy;
  final bool isFinanceStep;
  final void Function(String) onDecide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Baris 1: Tindakan Sekunder (Tolak & Minta Revisi)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 40.h),
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  side: const BorderSide(color: Color(0xFFFECDD3), width: 1.2),
                  backgroundColor:
                      const Color(0xFFFFF1F2).withValues(alpha: 0.5),
                  foregroundColor: const Color(0xFFE11D48),
                ),
                onPressed: busy ? null : () => onDecide('Ditolak'),
                icon: Icon(UIcons.regularRounded.cross_small, size: 18.w),
                label: Text(
                  'Tolak',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (r['version'] == 2) ...[
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 40.h),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    side:
                        const BorderSide(color: Color(0xFFFDE68A), width: 1.2),
                    backgroundColor:
                        const Color(0xFFFFFBEB).withValues(alpha: 0.5),
                    foregroundColor: const Color(0xFFD97706),
                  ),
                  onPressed: busy ? null : () => onDecide('Perlu revisi'),
                  icon: Icon(UIcons.regularRounded.time_past, size: 16.w),
                  label: Text(
                    'Minta revisi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        // Baris 2: Tindakan Utama Penuh (Setujui / Verifikasi finance)
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 2,
            ),
            onPressed: busy ? null : () => onDecide('Disetujui'),
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    UIcons.regularRounded.paper_plane,
                    size: 16.w,
                    color: Colors.white,
                  ),
            label: Text(
              isFinanceStep ? 'Verifikasi finance' : 'Setujui',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
