import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Kartu Pemilih Rentang Tanggal Pengajuan Cuti / Izin / Periode
class LeaveDateRangeCard extends StatelessWidget {
  final String startLabel;
  final String endLabel;
  final String startDateText;
  final String endDateText;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final int leaveDays;
  final bool showDuration;

  const LeaveDateRangeCard({
    super.key,
    required this.startLabel,
    required this.endLabel,
    required this.startDateText,
    required this.endDateText,
    required this.onPickStart,
    required this.onPickEnd,
    required this.leaveDays,
    this.showDuration = true,
  });

  Widget _buildPickerBox({
    required String label,
    required IconData icon,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(icon, size: 14.sp, color: const Color(0xFF0D9488)),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        valueText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    UIcons.regularRounded.angle_small_down,
                    size: 16.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPickerBox(
                  label: startLabel,
                  icon: UIcons.regularRounded.calendar,
                  valueText: startDateText,
                  onTap: onPickStart,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPickerBox(
                  label: endLabel,
                  icon: UIcons.regularRounded.calendar,
                  valueText: endDateText,
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          if (showDuration) ...[
            SizedBox(height: 12.h),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF1F5F9),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        UIcons.regularRounded.clock,
                        size: 15.sp,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Total Durasi:',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '$leaveDays Hari Kerja',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D9488),
                    ),
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
