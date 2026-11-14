import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'form_ui_components.dart';

class OvertimeDateDurationCard extends StatelessWidget {
  final TextEditingController hoursController;
  final String dateText;
  final VoidCallback onPickDate;
  final VoidCallback onPickDuration;

  const OvertimeDateDurationCard({
    super.key,
    required this.hoursController,
    required this.dateText,
    required this.onPickDate,
    required this.onPickDuration,
  });

  @override
  Widget build(BuildContext context) {
    final parsedHours = int.tryParse(hoursController.text) ??
        (double.tryParse(hoursController.text.replaceAll(',', '.'))?.round() ?? 0);
    final displayHours = parsedHours > 0
        ? '$parsedHours Jam'
        : (hoursController.text.isNotEmpty ? '${hoursController.text} Jam' : 'Pilih jam');

    return buildFormCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: buildFormPickerBox(
                  label: 'Tanggal Lembur',
                  icon: UIcons.regularRounded.calendar,
                  valueText: dateText,
                  onTap: onPickDate,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Stack(
                  children: [
                    buildFormPickerBox(
                      label: 'Durasi Lembur',
                      icon: UIcons.regularRounded.clock,
                      valueText: displayHours,
                      onTap: onPickDuration,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 0,
                      child: Opacity(
                        opacity: 0.0,
                        child: TextFormField(
                          controller: hoursController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Durasi lembur (jam)',
                          ),
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            return n == null || n < 1 || n > 24
                                ? 'Isi durasi 1 hingga 24 jam'
                                : null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                  displayHours,
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
      ),
    );
  }
}
