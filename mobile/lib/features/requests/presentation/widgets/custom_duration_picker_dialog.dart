import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'duration_picker/duration_picker_action_buttons.dart';
import 'duration_picker/duration_picker_hero_counter.dart';
import 'duration_picker/duration_picker_quick_grid.dart';

export 'duration_picker/duration_picker_action_buttons.dart';
export 'duration_picker/duration_picker_hero_counter.dart';
export 'duration_picker/duration_picker_hour_cell.dart';
export 'duration_picker/duration_picker_quick_grid.dart';

/// Membuka floating dialog pemilih durasi lembur dengan visual premium,
/// animasi scale & fade, hero counter terpusat, dan grid jam populer 4 kolom.
/// Mengembalikan durasi [int] jam yang dipilih, atau `null` jika dibatalkan.
Future<int?> showCustomDurationPickerDialog({
  required BuildContext context,
  int initialHours = 1,
}) {
  return showGeneralDialog<int>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup Dialog',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim1, anim2) {
      return CustomDurationPickerDialog(
        initialHours: initialHours < 1 ? 1 : (initialHours > 24 ? 24 : initialHours),
      );
    },
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curvedValue = Curves.easeOutCubic.transform(anim.value);
      return Transform.scale(
        scale: 0.94 + (0.06 * curvedValue),
        child: Opacity(
          opacity: anim.value,
          child: child,
        ),
      );
    },
  );
}

/// Floating Center Dialog Pemilih Durasi Lembur (Simetris & Tunggal)
class CustomDurationPickerDialog extends StatefulWidget {
  final int initialHours;

  const CustomDurationPickerDialog({
    super.key,
    required this.initialHours,
  });

  @override
  State<CustomDurationPickerDialog> createState() => _CustomDurationPickerDialogState();
}

class _CustomDurationPickerDialogState extends State<CustomDurationPickerDialog> {
  late int _selectedHours;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialHours;
  }

  void _increment() {
    if (_selectedHours < 24) {
      setState(() => _selectedHours++);
    }
  }

  void _decrement() {
    if (_selectedHours > 1) {
      setState(() => _selectedHours--);
    }
  }

  void _selectHour(int hours) {
    setState(() => _selectedHours = hours);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360.w,
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PILIH DURASI LEMBUR',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D9488),
                          letterSpacing: 1.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(null),
                        child: Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Icon(
                            UIcons.regularRounded.cross,
                            size: 15.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '$_selectedHours Jam Kerja',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Estimasi penugasan kerja lembur per hari',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  SizedBox(height: 16.h),
                  DurationPickerHeroCounter(
                    selectedHours: _selectedHours,
                    onDecrement: _decrement,
                    onIncrement: _increment,
                  ),
                  SizedBox(height: 18.h),
                  DurationPickerQuickGrid(
                    selectedHours: _selectedHours,
                    onSelectHour: _selectHour,
                  ),
                  SizedBox(height: 20.h),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  SizedBox(height: 16.h),
                  DurationPickerActionButtons(
                    onCancel: () => Navigator.of(context).pop(null),
                    onApply: () => Navigator.of(context).pop(_selectedHours),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
