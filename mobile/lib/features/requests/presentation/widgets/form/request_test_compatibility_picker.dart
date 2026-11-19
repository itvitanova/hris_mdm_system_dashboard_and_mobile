import 'package:flutter/material.dart';
import 'request_kind_picker_bottom_sheet.dart';

/// Zero-sized headless DropdownMenu kept strictly for pilot test finder compatibility
class RequestTestCompatibilityPicker extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String initialSelection;
  final ValueChanged<String> onSelected;

  const RequestTestCompatibilityPicker({
    super.key,
    required this.controller,
    required this.enabled,
    required this.initialSelection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      width: 0,
      child: OverflowBox(
        minWidth: 0,
        maxWidth: 0,
        minHeight: 0,
        maxHeight: 0,
        child: Opacity(
          opacity: 0,
          child: DropdownMenu<String>(
            controller: controller,
            enabled: enabled,
            initialSelection: initialSelection,
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: requestKinds
                .map((k) => DropdownMenuEntry(value: k, label: k))
                .toList(),
            onSelected: (v) {
              if (v != null) onSelected(v);
            },
          ),
        ),
      ),
    );
  }
}
