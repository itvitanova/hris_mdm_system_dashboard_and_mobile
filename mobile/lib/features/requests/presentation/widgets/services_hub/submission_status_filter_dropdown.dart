import 'package:flutter/material.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_status.dart';

Color _statusDotColor(SubmissionStatus status) {
  switch (status) {
    case SubmissionStatus.disetujui:
      return AppColors.filterStatusGreen;
    case SubmissionStatus.menunggu:
      return AppColors.filterStatusAmber;
    case SubmissionStatus.perluRevisi:
      return AppColors.filterStatusOrange;
    case SubmissionStatus.ditolak:
      return AppColors.filterStatusRed;
  }
}

String _statusLabel(SubmissionStatus status) {
  return status.displayName;
}

/// Widget Dropdown Filter Status Pengajuan Mandiri
class SubmissionStatusFilterDropdown extends StatefulWidget {
  final SubmissionStatus? selected;
  final ValueChanged<SubmissionStatus?> onChanged;

  const SubmissionStatusFilterDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
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
            child: _SubmissionStatusPanel(
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
    final dotColor = widget.selected != null
        ? _statusDotColor(widget.selected!)
        : (isActive ? AppColors.filterTealAccent : AppColors.filterStatusGreen);

    return GestureDetector(
      key: _triggerKey,
      onTap: _toggle,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFF5F5F5),
              blurRadius: 9,
              offset: Offset(0, 0),
            ),
          ],
          color: Colors.white,
          border: isActive
              ? Border.all(
                  color: AppColors.filterTealAccent,
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            // Status dot
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
                    ? _statusLabel(widget.selected!)
                    : 'Semua Status Pengajuan',
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
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
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

class _SubmissionStatusPanel extends StatelessWidget {
  final SubmissionStatus? selected;
  final ValueChanged<SubmissionStatus?> onSelect;

  const _SubmissionStatusPanel({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = [
      SubmissionStatus.disetujui,
      SubmissionStatus.menunggu,
      SubmissionStatus.perluRevisi,
      SubmissionStatus.ditolak,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSemuaRow(),
          const SizedBox(height: 8),
          // 2x2 grid opsi status
          ...List.generate(2, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < 1 ? 6 : 0),
              child: Row(
                children: List.generate(2, (col) {
                  final index = row * 2 + col;
                  final status = statuses[index];
                  final isSelected = selected == status;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: col == 1 ? 6 : 0),
                      child: GestureDetector(
                        onTap: () => onSelect(status),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
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
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _statusDotColor(status),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.filterTealAccent
                                        : AppColors.filterItemText,
                                  ),
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.filterTealAccent
                    : AppColors.filterStatusGreen,
              ),
              child: Center(
                child: Container(
                  width: 3.6,
                  height: 3.6,
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
                'Semua Status Pengajuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.filterTealAccent
                      : AppColors.filterItemText,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 14,
                color: AppColors.filterTealAccent,
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
