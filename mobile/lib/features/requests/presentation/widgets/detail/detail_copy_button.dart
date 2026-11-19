import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/widgets/core_widgets.dart';

/// Copy to clipboard icon button with tooltip and visual feedback
class DetailCopyButton extends StatefulWidget {
  const DetailCopyButton({
    super.key,
    required this.textToCopy,
    required this.label,
  });

  final String textToCopy;
  final String label;

  @override
  State<DetailCopyButton> createState() => _DetailCopyButtonState();
}

class _DetailCopyButtonState extends State<DetailCopyButton> {
  bool _copied = false;

  void _handleCopy() {
    if (widget.textToCopy.isEmpty) return;
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    notify(context, '${widget.label} ${widget.textToCopy} disalin.');
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = 13.5.w;
    final color = _copied ? const Color(0xFF047857) : const Color(0xFF0F766E);

    return Tooltip(
      message: 'Salin ${widget.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCopy,
          borderRadius: BorderRadius.circular(4.r),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _copied
                  ? Icon(
                      UIcons.regularRounded.check,
                      key: const ValueKey('check'),
                      size: size,
                      color: color,
                    )
                  : Icon(
                      UIcons.regularRounded.copy,
                      key: const ValueKey('copy'),
                      size: size,
                      color: color,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
