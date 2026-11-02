import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'attendance_stat_card.dart';

/// Enum Bulan untuk filter riwayat presensi
enum MonthEnum {
  januari,
  februari,
  maret,
  april,
  mei,
  juni,
  juli,
  agustus,
  september,
  oktober,
  november,
  desember;

  String get name {
    switch (this) {
      case MonthEnum.januari:
        return 'Januari';
      case MonthEnum.februari:
        return 'Februari';
      case MonthEnum.maret:
        return 'Maret';
      case MonthEnum.april:
        return 'April';
      case MonthEnum.mei:
        return 'Mei';
      case MonthEnum.juni:
        return 'Juni';
      case MonthEnum.juli:
        return 'Juli';
      case MonthEnum.agustus:
        return 'Agustus';
      case MonthEnum.september:
        return 'September';
      case MonthEnum.oktober:
        return 'Oktober';
      case MonthEnum.november:
        return 'November';
      case MonthEnum.desember:
        return 'Desember';
    }
  }

  String get shortName {
    const shortLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return shortLabels[index];
  }
}

// ─── Status dot colors ──────────────────────────────────────────────────────
Color _statusDotColor(AttendanceStatType status) {
  switch (status) {
    case AttendanceStatType.sudahAbsen:
      return AppColors.filterStatusGreen;
    case AttendanceStatType.tepatWaktu:
      return AppColors.filterStatusBlue;
    case AttendanceStatType.terlambat:
      return AppColors.filterStatusAmber;
    case AttendanceStatType.belumAbsen:
      return AppColors.filterStatusRed;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  MONTH FILTER DROPDOWN  (4×3 Grid + "Semua Bulan")
// ═══════════════════════════════════════════════════════════════════════════════
class MonthFilterDropdown extends StatefulWidget {
  final MonthEnum? selected;
  final ValueChanged<MonthEnum?> onChanged;

  const MonthFilterDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<MonthFilterDropdown> createState() => _MonthFilterDropdownState();
}

class _MonthFilterDropdownState extends State<MonthFilterDropdown> {
  final _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final renderBox =
        _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _OverlayDismiss(
        onDismiss: _close,
        child: Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 8.w,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: _MonthPanel(
              selected: widget.selected,
              onSelect: (value) {
                _close();
                widget.onChanged(value);
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isOpen;
    return GestureDetector(
      key: _triggerKey,
      onTap: _toggle,
      child: Container(
        height: 40.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: isActive
              ? AppColors.filterFrostedTealBg
              : AppColors.filterSlateBg,
          border: Border.all(
            color: isActive
                ? AppColors.filterTealAccent
                : AppColors.filterSlateBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14.w,
              color: isActive
                  ? AppColors.filterTealAccent
                  : AppColors.filterSlateIcon,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                widget.selected?.name ?? 'Semua Bulan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.filterTealAccent
                      : AppColors.filterDarkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isActive
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18.w,
              color: isActive
                  ? AppColors.filterTealAccent
                  : AppColors.filterSlateIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPanel extends StatelessWidget {
  final MonthEnum? selected;
  final ValueChanged<MonthEnum?> onSelect;

  const _MonthPanel({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final currentMonthIndex = DateTime.now().month - 1; // 0-based

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: AppColors.filterSlateBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Semua Bulan" row
          _buildSemuaBulanRow(),
          SizedBox(height: 8.w),
          // 4×3 grid
          ...List.generate(3, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < 2 ? 6.w : 0),
              child: Row(
                children: List.generate(4, (col) {
                  final index = row * 4 + col;
                  final month = MonthEnum.values[index];
                  final isSelected = selected == month;
                  final isCurrentMonth =
                      index == currentMonthIndex && selected == null;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: col < 3 ? 8.w : 0),
                      child: GestureDetector(
                        onTap: () => onSelect(month),
                        child: Container(
                          height: 34.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: (isSelected || isCurrentMonth)
                                ? AppColors.filterTealAccent
                                : AppColors.filterSlateBg,
                          ),
                          child: Text(
                            month.shortName,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5.sp,
                              fontWeight: (isSelected || isCurrentMonth)
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: (isSelected || isCurrentMonth)
                                  ? AppColors.white
                                  : AppColors.filterItemText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSemuaBulanRow() {
    final isSelected = selected == null;
    return GestureDetector(
      onTap: () => onSelect(null),
      child: Container(
        height: 34.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: isSelected
              ? AppColors.filterFrostedTealBg
              : AppColors.filterSlateBg,
          border: isSelected
              ? Border.all(color: AppColors.filterFrostedTealBorder, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Semua Bulan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.filterTealAccent
                      : AppColors.filterItemText,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 14.w, color: AppColors.filterTealAccent),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  YEAR FILTER DROPDOWN  (Vertical list)
// ═══════════════════════════════════════════════════════════════════════════════
class YearFilterDropdown extends StatefulWidget {
  final int selected;
  final List<int> years;
  final ValueChanged<int?> onChanged;

  const YearFilterDropdown({
    super.key,
    required this.selected,
    required this.years,
    required this.onChanged,
  });

  @override
  State<YearFilterDropdown> createState() => _YearFilterDropdownState();
}

class _YearFilterDropdownState extends State<YearFilterDropdown> {
  final _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final renderBox =
        _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _OverlayDismiss(
        onDismiss: _close,
        child: Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 8.w,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: _YearPanel(
              selected: widget.selected,
              years: widget.years,
              onSelect: (value) {
                _close();
                widget.onChanged(value);
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isOpen;
    return GestureDetector(
      key: _triggerKey,
      onTap: _toggle,
      child: Container(
        height: 40.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: isActive
              ? AppColors.filterFrostedTealBg
              : AppColors.filterSlateBg,
          border: Border.all(
            color: isActive
                ? AppColors.filterTealAccent
                : AppColors.filterSlateBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.selected.toString(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.filterTealAccent
                      : AppColors.filterDarkText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Icon(
              isActive
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18.w,
              color: isActive
                  ? AppColors.filterTealAccent
                  : AppColors.filterSlateIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _YearPanel extends StatelessWidget {
  final int selected;
  final List<int> years;
  final ValueChanged<int> onSelect;

  const _YearPanel({
    required this.selected,
    required this.years,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: AppColors.filterSlateBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: years.map((year) {
          final isSelected = year == selected;
          return Padding(
            padding: EdgeInsets.only(bottom: year != years.last ? 4.w : 0),
            child: GestureDetector(
              onTap: () => onSelect(year),
              child: Container(
                height: 36.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  color: isSelected
                      ? AppColors.filterTealAccent
                      : AppColors.filterSlateBg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      year.toString(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : (year == DateTime.now().year
                                ? AppColors.filterItemText
                                : AppColors.filterSlateIcon),
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 8.w),
                      Icon(Icons.check, size: 12.w, color: AppColors.white),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STATUS FILTER DROPDOWN  (2×3 Grid + "Semua Kehadiran")
// ═══════════════════════════════════════════════════════════════════════════════
class StatusFilterDropdown extends StatefulWidget {
  final AttendanceStatType? selected;
  final ValueChanged<AttendanceStatType?> onChanged;

  const StatusFilterDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<StatusFilterDropdown> createState() => _StatusFilterDropdownState();
}

class _StatusFilterDropdownState extends State<StatusFilterDropdown> {
  final _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final renderBox =
        _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _OverlayDismiss(
        onDismiss: _close,
        child: Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 8.w,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: _StatusPanel(
              selected: widget.selected,
              onSelect: (value) {
                _close();
                widget.onChanged(value);
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isOpen;
    final dotColor = widget.selected != null
        ? _statusDotColor(widget.selected!)
        : (isActive ? AppColors.filterTealAccent : AppColors.filterStatusGreen);

    return GestureDetector(
      key: _triggerKey,
      onTap: _toggle,
      child: Container(
        height: 40.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: isActive
              ? AppColors.filterFrostedTealBg
              : AppColors.filterSlateBg,
          border: Border.all(
            color: isActive
                ? AppColors.filterTealAccent
                : AppColors.filterSlateBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
              child: Center(
                child: Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                widget.selected?.label ?? 'Semua Kehadiran',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.filterTealAccent
                      : AppColors.filterDarkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isActive
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18.w,
              color: isActive
                  ? AppColors.filterTealAccent
                  : AppColors.filterSlateIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final AttendanceStatType? selected;
  final ValueChanged<AttendanceStatType?> onSelect;

  const _StatusPanel({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: AppColors.filterSlateBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Semua Kehadiran" row
          _buildSemuaRow(),
          SizedBox(height: 8.w),
          // 2×2 grid of statuses
          ...List.generate(2, (row) {
            final statuses = AttendanceStatType.values;
            return Padding(
              padding: EdgeInsets.only(bottom: row < 1 ? 6.w : 0),
              child: Row(
                children: List.generate(2, (col) {
                  final index = row * 2 + col;
                  final status = statuses[index];
                  final isSelected = selected == status;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: col == 0 ? 8.w : 0),
                      child: GestureDetector(
                        onTap: () => onSelect(status),
                        child: Container(
                          height: 36.w,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: isSelected
                                ? AppColors.filterFrostedTealBg
                                : AppColors.filterSlateBg,
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.filterFrostedTealBorder,
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _statusDotColor(status),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  status.label,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.5.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.filterTealAccent
                                        : AppColors.filterItemText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSemuaRow() {
    final isSelected = selected == null;
    return GestureDetector(
      onTap: () => onSelect(null),
      child: Container(
        height: 36.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: isSelected
              ? AppColors.filterFrostedTealBg
              : AppColors.filterSlateBg,
          border: isSelected
              ? Border.all(color: AppColors.filterFrostedTealBorder, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.filterTealAccent
                    : AppColors.filterStatusGreen,
              ),
              child: Center(
                child: Container(
                  width: 3.6.w,
                  height: 3.6.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Semua Kehadiran',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.filterTealAccent
                      : AppColors.filterItemText,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 14.w, color: AppColors.filterTealAccent),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  OVERLAY DISMISS HELPER
// ═══════════════════════════════════════════════════════════════════════════════
class _OverlayDismiss extends StatelessWidget {
  final VoidCallback onDismiss;
  final Widget child;

  const _OverlayDismiss({required this.onDismiss, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        child,
      ],
    );
  }
}
