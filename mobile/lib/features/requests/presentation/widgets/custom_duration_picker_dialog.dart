import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

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

  String _getCategoryLabel(int hours) {
    if (hours <= 2) return 'Lembur Ringan';
    if (hours <= 4) return 'Lembur Reguler';
    return 'Lembur Intensif';
  }

  Widget _buildHourCell(int h) {
    final isSel = _selectedHours == h;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectHour(h),
          borderRadius: BorderRadius.circular(8.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                width: isSel ? 1.2 : 0.8,
              ),
              boxShadow: isSel
                  ? const [
                      BoxShadow(
                        color: Color(0x200D9488),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$h Jam',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                  color: isSel ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
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
                  // 1. Header Dialog
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

                  // Display Headline Durasi Terpilih
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

                  // 2. Hero Counter Visual (Angka Besar Terpusat Presisi & Simetris)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0FDFA), Color(0xFFE6FFFA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: const Color(0xFF99F6E4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Minus [-]
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _selectedHours > 1 ? _decrement : null,
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: _selectedHours > 1 ? Colors.white : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: _selectedHours > 1
                                      ? const Color(0xFF99F6E4)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: _selectedHours > 1
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x100D9488),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                UIcons.regularRounded.minus,
                                size: 20.sp,
                                color: _selectedHours > 1
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),

                        // Center Big Number Display (Presisi di Tengah)
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$_selectedHours',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 38.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F766E),
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Jam',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF14B8A6),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: const Color(0xFF99F6E4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  _getCategoryLabel(_selectedHours),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Plus [+]
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _selectedHours < 24 ? _increment : null,
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                gradient: _selectedHours < 24
                                    ? const LinearGradient(
                                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: _selectedHours >= 24 ? const Color(0xFFF1F5F9) : null,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: _selectedHours < 24
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x280F766E),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                UIcons.regularRounded.plus,
                                size: 20.sp,
                                color: _selectedHours < 24 ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // 3. Pilihan Jam Cepat (1 - 12 Jam) (Grid 4 Kolom x 3 Baris Seimbang)
                  Text(
                    'Pilihan Jam Cepat (1 - 12 Jam)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Row 1: 1, 2, 3, 4
                  Row(
                    children: [
                      _buildHourCell(1),
                      SizedBox(width: 8.w),
                      _buildHourCell(2),
                      SizedBox(width: 8.w),
                      _buildHourCell(3),
                      SizedBox(width: 8.w),
                      _buildHourCell(4),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Row 2: 5, 6, 7, 8
                  Row(
                    children: [
                      _buildHourCell(5),
                      SizedBox(width: 8.w),
                      _buildHourCell(6),
                      SizedBox(width: 8.w),
                      _buildHourCell(7),
                      SizedBox(width: 8.w),
                      _buildHourCell(8),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Row 3: 9, 10, 11, 12
                  Row(
                    children: [
                      _buildHourCell(9),
                      SizedBox(width: 8.w),
                      _buildHourCell(10),
                      SizedBox(width: 8.w),
                      _buildHourCell(11),
                      SizedBox(width: 8.w),
                      _buildHourCell(12),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  SizedBox(height: 16.h),

                  // 4. Footer Tombol Aksi (50:50 Seimbang Sempurna Identik Cuti)
                  Row(
                    children: [
                      // Tombol Batal
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
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
                      SizedBox(width: 12.w),
                      // Tombol Terapkan Durasi (Gradient Teal)
                      Expanded(
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
                              onTap: () => Navigator.of(context).pop(_selectedHours),
                              borderRadius: BorderRadius.circular(10.r),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Terapkan',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w600,
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
                    ],
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
