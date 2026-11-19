import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'payroll_overlay_dismiss.dart';
import 'period_filter_menu_panel.dart';

class PeriodFilterDropdown extends StatefulWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const PeriodFilterDropdown({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  State<PeriodFilterDropdown> createState() => _PeriodFilterDropdownState();
}

class _PeriodFilterDropdownState extends State<PeriodFilterDropdown> {
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
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => PayrollOverlayDismiss(
        onDismiss: _close,
        child: Positioned(
          left: (offset.dx - (180.w - size.width)).clamp(16.w, offset.dx),
          top: offset.dy + size.height + 6.w,
          width: 180.w > size.width ? 180.w : size.width,
          child: Material(
            color: Colors.transparent,
            child: PeriodFilterMenuPanel(
              options: widget.options,
              selected: widget.selected,
              onSelect: (period) {
                _close();
                widget.onChanged(period);
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
    if (mounted) {
      setState(() => _isOpen = false);
    } else {
      _isOpen = false;
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isOpen || widget.selected != 'Semua periode';

    return GestureDetector(
      key: _triggerKey,
      onTap: _toggle,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 11.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: isActive ? const Color(0xFFE1F2F5) : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              UIcons.regularRounded.calendar,
              size: 15.sp,
              color:
                  isActive ? const Color(0xFF0F766E) : const Color(0xFF64748B),
            ),
            SizedBox(width: 6.w),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 96.w),
              child: Text(
                widget.selected,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF0F766E)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              _isOpen
                  ? UIcons.regularRounded.angle_small_up
                  : UIcons.regularRounded.angle_small_down,
              size: 18.sp,
              color:
                  isActive ? const Color(0xFF0F766E) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}
