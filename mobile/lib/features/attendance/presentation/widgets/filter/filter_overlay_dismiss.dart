import 'package:flutter/material.dart';

/// Overlay Dismiss Helper for Filter Dropdowns
class FilterOverlayDismiss extends StatelessWidget {
  final VoidCallback onDismiss;
  final Widget child;

  const FilterOverlayDismiss({
    super.key,
    required this.onDismiss,
    required this.child,
  });

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
