import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/workspace.dart';

/// Membuka Modal Detail Kehadiran lengkap dengan informasi verifikasi MDM,
/// peta koordinat, kebijakan lokasi penugasan, dan status kepulangan.
void showAttendanceDetailModal(
  BuildContext context,
  Map<String, dynamic> raw,
) {
  final dateStr = text(raw, 'date');
  DateTime? dt = DateTime.tryParse(dateStr);
  String formattedDate = dateStr;
  if (dt != null) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = days[(dt.weekday - 1).clamp(0, 6)];
    final monthName = months[(dt.month - 1).clamp(0, 11)];
    formattedDate =
        '$dayName, ${dt.day.toString().padLeft(2, '0')} $monthName ${dt.year}';
  }

  final checkIn = text(raw, 'checkIn', '—');
  final checkOut = text(raw, 'checkOut', '—');
  final status = text(raw, 'status', 'Hadir');
  final lateMinutes = (raw['lateMinutes'] as num?)?.toInt() ?? 0;
  final earlyDeparture = raw['earlyDeparture'] == true;
  final earlyMinutes = (raw['earlyMinutes'] as num?)?.toInt() ?? 0;
  final earlyReason = text(raw, 'earlyReason', '');
  final faceVerified = raw['faceVerified'] == true;
  final distance = (raw['distance'] as num?)?.toDouble() ?? 0;

  final checkInLoc = raw['checkInLocation'] as Map?;
  final checkOutLoc = raw['checkOutLocation'] as Map?;

  final policyName = checkInLoc != null && checkInLoc['policy'] is Map
      ? text(
          checkInLoc['policy'] as Map<String, dynamic>,
          'name',
          'Kantor Pusat MDM',
        )
      : 'Kantor Pusat MDM';

  final inLat = (checkInLoc?['latitude'] as num?)?.toDouble() ??
      (raw['latitude'] as num?)?.toDouble();
  final inLng = (checkInLoc?['longitude'] as num?)?.toDouble() ??
      (raw['longitude'] as num?)?.toDouble();

  final outLat = (checkOutLoc?['latitude'] as num?)?.toDouble();
  final outLng = (checkOutLoc?['longitude'] as num?)?.toDouble();

  Future<void> openMaps(double lat, double lng) async {
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Header: Judul & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Kehadiran',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: status == 'Terlambat'
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: status == 'Terlambat'
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFBBF7D0),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  lateMinutes > 0 ? 'Terlambat $lateMinutes m' : status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: status == 'Terlambat'
                        ? const Color(0xFFB45309)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Box Waktu Masuk & Pulang
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JAM MASUK',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        timeLabel(checkIn),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32.h,
                  color: const Color(0xFFCBD5E1),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JAM PULANG',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        timeLabel(checkOut),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notice Pulang Awal jika ada
          if (earlyDeparture) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16.sp,
                    color: const Color(0xFFE11D48),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Pulang $earlyMinutes menit lebih awal${earlyReason.isNotEmpty ? ': "$earlyReason"' : ''}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBE123C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // Detail Lokasi Penugasan & Verifikasi
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
                      Icons.apartment_rounded,
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
                      Icons.shield_outlined,
                      size: 15.sp,
                      color: faceVerified
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Text(
                        faceVerified
                            ? 'Wajah Terverifikasi · ${distance.round()} m dari titik lokasi'
                            : 'Data Presensi Mandiri',
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

          // Tombol Peta Masuk & Keluar
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
                    onPressed: () => openMaps(inLat, inLng),
                    icon: Icon(Icons.map_outlined, size: 14.sp),
                    label: Text(
                      'Peta Masuk',
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
                      onPressed: () => openMaps(outLat, outLng),
                      icon: Icon(Icons.map_outlined, size: 14.sp),
                      label: Text(
                        'Peta Keluar',
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

          SizedBox(height: 18.h),

          // Sticky Bottom Tutup Button
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF14B8A6),
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}
