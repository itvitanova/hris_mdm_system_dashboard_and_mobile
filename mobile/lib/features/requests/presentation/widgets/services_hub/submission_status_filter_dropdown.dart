import 'package:flutter/material.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_status.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

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
            child: _SubmissionStatusPanel(
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
  final AppLanguage language;

  const _SubmissionStatusPanel({
    required this.selected,
    required this.onSelect,
    this.language = AppLanguage.id,
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
                            gradient: isSelected
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF0F766E),
                                      Color(0xFF14B8A6),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.filterSlateBg,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white
                                      : _statusDotColor(status),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  status.getLabel(language),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
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
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF14B8A6),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.filterSlateBg,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
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
                    ? Colors.white
                    : AppColors.filterStatusGreen,
              ),
              child: Center(
                child: Container(
                  width: 3.6,
                  height: 3.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                language == AppLanguage.en
                    ? 'All Submission Statuses'
                    : 'Semua Status Pengajuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.filterItemText,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
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
