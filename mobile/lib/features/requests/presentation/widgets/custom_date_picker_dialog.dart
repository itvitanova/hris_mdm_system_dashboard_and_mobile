import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';

/// Membuka dialog pemilih tanggal kustom dengan visual modern & interaktif.
/// Mengembalikan objek [DateTime] jika pengguna menekan "Terapkan", atau `null` jika dibatalkan.
Future<DateTime?> showCustomDatePickerDialog({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'PILIH TANGGAL',
}) {
  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup Dialog',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim1, anim2) {
      return CustomDatePickerDialog(
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2020),
        lastDate: lastDate ?? DateTime(2035),
        title: title,
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

/// Floating Center Dialog Pemilih Tanggal
class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title = 'PILIH TANGGAL',
  });

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;

  static const List<String> _monthNames = [
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
    'Desember'
  ];

  static const List<String> _dayNames = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab'
  ];

  static const List<String> _dayNamesLong = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _onPrevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  void _selectPreset(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _viewMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDisplayDate(DateTime date) {
    final weekdayStr = _dayNamesLong[date.weekday % 7];
    final monthStr = _monthNames[date.month - 1].substring(0, 3);
    return '$weekdayStr, ${date.day} $monthStr ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Bagian Atas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D9488),
                          letterSpacing: 1.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(null),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Icon(
                            UIcons.regularRounded.cross,
                            size: 15,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Display Tanggal Terpilih
                  Text(
                    _formatDisplayDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Preset Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip(
                          label: 'Hari Ini',
                          isSelected: _isSameDay(_selectedDate, today),
                          onTap: () => _selectPreset(today),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: 'Besok',
                          isSelected: _isSameDay(_selectedDate, tomorrow),
                          onTap: () => _selectPreset(tomorrow),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: '7 Hari ke Depan',
                          isSelected: _isSameDay(_selectedDate, nextWeek),
                          onTap: () => _selectPreset(nextWeek),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 14),

                  // 2. Month Navigator Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_monthNames[_viewMonth.month - 1]} ${_viewMonth.year}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildCircleNavButton(
                            icon: UIcons.regularRounded.angle_small_left,
                            onTap: _onPrevMonth,
                          ),
                          const SizedBox(width: 8),
                          _buildCircleNavButton(
                            icon: UIcons.regularRounded.angle_small_right,
                            onTap: _onNextMonth,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Days of Week Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _dayNames.map((d) {
                      return SizedBox(
                        width: 38,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // 4. Calendar Days Grid
                  _buildCalendarGrid(today),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 16),

                  // 5. Dual-Button Action
                  Row(
                    children: [
                      // Tombol Batal
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8FAFC),
                            foregroundColor: const Color(0xFF64748B),
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tombol Terapkan
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0F766E), // Teal 700
                                Color(0xFF14B8A6), // Teal 500
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488)
                                    .withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).pop(_selectedDate),
                              borderRadius: BorderRadius.circular(10),
                              child: const Center(
                                child: Text(
                                  'Terapkan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
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

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFA),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCCFBF1)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFF0D9488),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime today) {
    final firstDayOfMonth = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_viewMonth.year, _viewMonth.month);
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 for Minggu

    final prevMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    final daysInPrevMonth =
        DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final totalCells = (startingWeekday + daysInMonth > 35) ? 42 : 35;
    final dayWidgets = <Widget>[];

    for (int i = 0; i < totalCells; i++) {
      if (i < startingWeekday) {
        final dayNum = daysInPrevMonth - (startingWeekday - 1) + i;
        dayWidgets.add(
          _buildDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            isEnabled: false,
            onTap: null,
          ),
        );
      } else if (i < startingWeekday + daysInMonth) {
        final dayNum = i - startingWeekday + 1;
        final cellDate = DateTime(_viewMonth.year, _viewMonth.month, dayNum);
        final isSelected = _isSameDay(cellDate, _selectedDate);
        final isToday = _isSameDay(cellDate, today);
        final isBeforeFirst = cellDate.isBefore(
          DateTime(widget.firstDate.year, widget.firstDate.month,
              widget.firstDate.day),
        );
        final isAfterLast = cellDate.isAfter(
          DateTime(widget.lastDate.year, widget.lastDate.month,
              widget.lastDate.day),
        );
        final isEnabled = !isBeforeFirst && !isAfterLast;

        dayWidgets.add(
          _buildDayCell(
            text: '$dayNum',
            isCurrentMonth: true,
            isSelected: isSelected,
            isToday: isToday,
            isEnabled: isEnabled,
            onTap: isEnabled
                ? () {
                    setState(() {
                      _selectedDate = cellDate;
                    });
                  }
                : null,
          ),
        );
      } else {
        final dayNum = i - (startingWeekday + daysInMonth) + 1;
        dayWidgets.add(
          _buildDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            isEnabled: false,
            onTap: null,
          ),
        );
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell({
    required String text,
    required bool isCurrentMonth,
    required bool isSelected,
    required bool isToday,
    bool isEnabled = true,
    required VoidCallback? onTap,
  }) {
    if (!isCurrentMonth || !isEnabled) {
      return Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFCBD5E1),
          ),
        ),
      );
    }

    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F766E),
                Color(0xFF14B8A6),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFF0FDFA) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: const Color(0xFF0D9488), width: 1.2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color:
                    isToday ? const Color(0xFF0D9488) : const Color(0xFF1E293B),
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 3.5,
                height: 3.5,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D9488),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
