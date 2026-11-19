import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import 'submission_status_panel.dart';

export 'submission_status_panel.dart';

/// Widget Dropdown Filter Status Pengajuan Mandiri
class SubmissionStatusFilterDropdown extends StatefulWidget {
  final SubmissionStatus? selected;
  final ValueChanged<SubmissionStatus?> onChanged;
  final AppLanguage language;

  const SubmissionStatusFilterDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
    this.language = AppLanguage.id,
  });

  @override
  State<SubmissionStatusFilterDropdown> createState() =>
      _SubmissionStatusFilterDropdownState();
}

class _SubmissionStatusFilterDropdownState
    extends State<SubmissionStatusFilterDropdown> {
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
          top: offset.dy + size.height + 8,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: SubmissionStatusPanel(
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
    if (mounted) {
      setState(() => _isOpen = false);
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
    final isActive = _isOpen;
    final hasFilter = widget.selected != null;
    final dotColor = hasFilter
        ? statusDotColor(widget.selected!)
        : (isActive ? AppColors.filterTealAccent : AppColors.filterStatusGreen);

    return GestureDetector(
      key: _triggerKey,
      onTap: _toggle,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: hasFilter
                  ? const Color(0xFF0F766E).withValues(alpha: 0.12)
                  : const Color(0xFFF5F5F5),
              blurRadius: 9,
              offset: const Offset(0, 0),
            ),
          ],
          color: Colors.white,
          border: isActive || hasFilter
              ? Border.all(
                  color: AppColors.filterTealAccent,
                  width: 1.5,
                )
              : Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.selected != null
                    ? widget.selected!.getLabel(widget.language)
                    : (widget.language == AppLanguage.en
                        ? 'All Submission Statuses'
                        : 'Semua Status Pengajuan'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? AppColors.filterTealAccent
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isActive
                  ? UIcons.regularRounded.angle_small_up
                  : UIcons.regularRounded.angle_small_down,
              size: 20,
              color: isActive
                  ? AppColors.filterTealAccent
                  : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

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
