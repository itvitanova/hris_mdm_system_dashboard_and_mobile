import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';
import 'filter_overlay_dismiss.dart';
import 'month_enum.dart';
import 'month_filter_panel.dart';

class MonthFilterDropdown extends StatefulWidget {
  final MonthEnum? selected;
  final ValueChanged<MonthEnum?> onChanged;
  final AppLanguage language;

  const MonthFilterDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
    this.language = AppLanguage.id,
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
    final renderBox = _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => FilterOverlayDismiss(
        onDismiss: _close,
        child: Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 8.w,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: MonthFilterPanel(
              selected: widget.selected,
              language: widget.language,
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
          color: isActive ? AppColors.filterFrostedTealBg : AppColors.filterSlateBg,
          border: Border.all(
            color: isActive ? AppColors.filterTealAccent : AppColors.filterSlateBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              UIcons.regularRounded.calendar,
              size: 14.w,
              color: isActive ? AppColors.filterTealAccent : AppColors.filterSlateIcon,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                widget.selected?.getName(widget.language) ??
                    (widget.language == AppLanguage.en ? 'All Months' : 'Semua Bulan'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.filterTealAccent : AppColors.filterDarkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isActive
                  ? UIcons.regularRounded.angle_small_up
                  : UIcons.regularRounded.angle_small_down,
              size: 18.w,
              color: isActive ? AppColors.filterTealAccent : AppColors.filterSlateIcon,
            ),
          ],
        ),
      ),
    );
  }
}
