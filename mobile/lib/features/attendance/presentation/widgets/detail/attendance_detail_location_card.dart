import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';

class AttendanceDetailLocationCard extends StatelessWidget {
  const AttendanceDetailLocationCard({
    super.key,
    required this.policyName,
    required this.faceVerified,
    required this.distance,
    required this.inLat,
    required this.inLng,
    required this.outLat,
    required this.outLng,
    required this.isEn,
  });

  final String policyName;
  final bool faceVerified;
  final double distance;
  final double? inLat;
  final double? inLng;
  final double? outLat;
  final double? outLng;
  final bool isEn;

  Future<void> _openMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    UIcons.regularRounded.building,
                    size: 15.sp,
                    color: AppColors.deepTeal,
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      policyName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    UIcons.regularRounded.shield_check,
                    size: 15.sp,
                    color: faceVerified
                        ? const Color(0xFF15803D)
                        : const Color(0xFF64748B),
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      faceVerified
                          ? (isEn
                              ? 'Face Verified · ${distance.round()} m from location point'
                              : 'Wajah Terverifikasi · ${distance.round()} m dari titik lokasi')
                          : (isEn ? 'Self Presence Data' : 'Data Presensi Mandiri'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: faceVerified
                            ? const Color(0xFF15803D)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (inLat != null && inLng != null) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepTeal,
                    side: const BorderSide(color: Color(0xFF14B8A6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () => _openMaps(inLat!, inLng!),
                  icon: Icon(UIcons.regularRounded.marker, size: 14.sp),
                  label: Text(
                    isEn ? 'Check-in Map' : 'Peta Masuk',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (outLat != null && outLng != null) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepTeal,
                      side: const BorderSide(color: Color(0xFF14B8A6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () => _openMaps(outLat!, outLng!),
                    icon: Icon(UIcons.regularRounded.marker, size: 14.sp),
                    label: Text(
                      isEn ? 'Check-out Map' : 'Peta Keluar',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
