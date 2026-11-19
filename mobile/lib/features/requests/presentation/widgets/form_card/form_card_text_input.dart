import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'form_card_container.dart';

/// Komponen input kartu putih terstandarisasi untuk modul pengajuan.
class FormCardTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final bool showCounter;
  final Key? fieldKey;
  final Key? inputKey;
  final TextStyle? style;
  final TextStyle? hintStyle;

  const FormCardTextInput({
    super.key,
    required this.controller,
    this.hintText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.keyboardType,
    this.focusNode,
    this.showCounter = false,
    this.fieldKey,
    this.inputKey,
    this.style,
    this.hintStyle,
  });

  @override
  State<FormCardTextInput> createState() => _FormCardTextInputState();
}

class _FormCardTextInputState extends State<FormCardTextInput> {
  final GlobalKey<FormFieldState<String>> _internalFieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(FormCardTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      final state = (widget.fieldKey is GlobalKey<FormFieldState<String>>)
          ? (widget.fieldKey as GlobalKey<FormFieldState<String>>).currentState
          : _internalFieldKey.currentState;
      if (state != null && state.hasError) {
        state.validate();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: widget.fieldKey ?? _internalFieldKey,
      initialValue: widget.controller.text,
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (FormFieldState<String> field) {
        final bool isMultiline = widget.minLines > 1;

        Widget inputField = TextFormField(
          key: widget.inputKey,
          controller: widget.controller,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textAlignVertical:
              isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
          buildCounter: (
            context, {
            required currentLength,
            required isFocused,
            maxLength,
          }) => null,
          style: widget.style ??
              TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.sp,
                fontWeight:
                    isMultiline ? FontWeight.w400 : FontWeight.w500,
                color: const Color(0xFF0F172A),
                height: isMultiline ? 1.4 : null,
              ),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            errorStyle: const TextStyle(
              fontSize: 0,
              height: 0.001,
              color: Colors.transparent,
            ),
            contentPadding: isMultiline
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(horizontal: 14.w),
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  color: const Color(0xFF94A3B8),
                ),
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: widget.prefixIcon != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: widget.suffixIcon,
          ),
          onChanged: (val) {
            if (field.hasError) {
              field.validate();
            }
            widget.onChanged?.call(val);
          },
        );

        Widget cardContent = inputField;

        if (widget.showCounter && widget.maxLength != null) {
          cardContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              inputField,
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${widget.controller.text.length}/${widget.maxLength} karakter',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          );
        }

        final containerChild = (widget.height != null && !isMultiline)
            ? Center(child: cardContent)
            : cardContent;

        return FormCardContainer(
          height: widget.height,
          hasError: field.hasError,
          errorText: field.errorText,
          padding: isMultiline
              ? EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h)
              : EdgeInsets.zero,
          child: containerChild,
        );
      },
    );
  }
}
