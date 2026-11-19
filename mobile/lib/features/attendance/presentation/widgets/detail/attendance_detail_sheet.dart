import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';
import 'attendance_detail_header.dart';
import 'attendance_detail_location_card.dart';
import 'attendance_detail_time_box.dart';

class AttendanceDetailSheet extends StatelessWidget {
  const AttendanceDetailSheet({
    super.key,
    required this.raw,
    this.language,
  });

  final Map<String, dynamic> raw;
  final AppLanguage? language;

  static String _formatDate(String dateStr, bool isEn) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final days = isEn
        ? const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        : const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = isEn
        ? const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
        : const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final dayName = days[(dt.weekday - 1).clamp(0, 6)];
    final monthName = months[(dt.month - 1).clamp(0, 11)];
    return '$dayName, ${dt.day.toString().padLeft(2, '0')} $monthName ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final activeLanguage = language ?? AppLanguageController.currentLanguage;
    final isEn = activeLanguage == AppLanguage.en;
    final dateStr = text(raw, 'date');
    final formattedDate = _formatDate(dateStr, isEn);

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
        ? text(checkInLoc['policy'] as Map<String, dynamic>, 'name', 'Kantor Pusat MDM')
        : 'Kantor Pusat MDM';

    final inLat = (checkInLoc?['latitude'] as num?)?.toDouble() ?? (raw['latitude'] as num?)?.toDouble();
    final inLng = (checkInLoc?['longitude'] as num?)?.toDouble() ?? (raw['longitude'] as num?)?.toDouble();
    final outLat = (checkOutLoc?['latitude'] as num?)?.toDouble();
    final outLng = (checkOutLoc?['longitude'] as num?)?.toDouble();

    return Container(
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
            AttendanceDetailHeader(
              formattedDate: formattedDate,
              status: status,
              lateMinutes: lateMinutes,
              isEn: isEn,
            ),
            SizedBox(height: 16.h),
            AttendanceDetailTimeBox(
              checkIn: checkIn,
              checkOut: checkOut,
              earlyDeparture: earlyDeparture,
              earlyMinutes: earlyMinutes,
              earlyReason: earlyReason,
              isEn: isEn,
            ),
            SizedBox(height: 12.h),
            AttendanceDetailLocationCard(
              policyName: policyName,
              faceVerified: faceVerified,
              distance: distance,
              inLat: inLat,
              inLng: inLng,
              outLat: outLat,
              outLng: outLng,
              isEn: isEn,
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    isEn ? 'Close' : 'Tutup',
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
    );
  }
}
