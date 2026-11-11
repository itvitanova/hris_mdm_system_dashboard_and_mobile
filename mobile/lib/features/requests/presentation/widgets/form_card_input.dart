import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Komponen input kartu putih terstandarisasi untuk modul pengajuan.
/// 
/// Ketika terjadi validasi error:
/// - Kartu putih mendapatkan border merah (ukuran tetap stabil dan tidak melonjak).
/// - Pesan error teks merah dan ikon peringatan tampil rapi di luar tepat di bawah kartu.
/// - Menghilangkan pesan error internal di dalam card agar tidak merusak layout box.
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
        final bool hasError = field.hasError;
        final String? errorText = field.errorText;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${widget.controller.text.length}/${widget.maxLength} karakter',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        final containerChild = (widget.height != null && !isMultiline)
            ? Center(child: cardContent)
            : cardContent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: widget.height,
              clipBehavior: Clip.antiAlias,
              padding: isMultiline
                  ? EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFEF4444)
                      : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: containerChild,
            ),
            if (hasError && errorText != null) ...[
              SizedBox(height: 5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13.w,
                      color: const Color(0xFFEF4444),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        errorText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Komponen dropdown kartu putih terstandarisasi untuk modul pengajuan.
/// 
/// Menggunakan [DropdownButtonHideUnderline] dan layout tanpa [InputDecoration]
/// agar border rounded 10.r bersih, simetris, dan tidak tertabrak atau terpotong
/// oleh elemen persegi di sudut kartu saat status error aktif.
class FormCardDropdownInput<T> extends FormField<T> {
  final Key? dropdownKey;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;

  FormCardDropdownInput({
    super.key,
    this.dropdownKey,
    super.initialValue,
    required this.items,
    this.onChanged,
    super.validator,
    this.hintText,
    super.enabled = true,
  }) : super(
          builder: (FormFieldState<T> field) {
            final bool hasError = field.hasError;
            final String? errorText = field.errorText;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  height: 48.h,
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white,
                    border: Border.all(
                      color: hasError
                          ? const Color(0xFFEF4444)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<T>(
                        key: dropdownKey,
                        isExpanded: true,
                        value: field.value,
                        hint: hintText != null
                            ? Text(
                                hintText,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF94A3B8),
                                ),
                              )
                            : null,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20.sp,
                          color: const Color(0xFF64748B),
                        ),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        items: items,
                        onChanged: enabled
                            ? (T? val) {
                                field.didChange(val);
                                if (field.hasError) {
                                  field.validate();
                                }
                                onChanged?.call(val);
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                if (hasError && errorText != null) ...[
                  SizedBox(height: 5.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 13.w,
                          color: const Color(0xFFEF4444),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            errorText,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        );

  @override
  FormFieldState<T> createState() => _FormCardDropdownInputState<T>();
}

class _FormCardDropdownInputState<T> extends FormFieldState<T> {
  @override
  void didUpdateWidget(FormCardDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

/// Container pembungkus untuk input kustom agar memiliki visual border merah saat error
/// dan error teks di luar bawah card.
class FormCardContainer extends StatelessWidget {
  final Widget child;
  final bool hasError;
  final String? errorText;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const FormCardContainer({
    super.key,
    required this.child,
    this.hasError = false,
    this.errorText,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: height,
          clipBehavior: Clip.antiAlias,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.white,
            border: Border.all(
              color: hasError
                  ? const Color(0xFFEF4444)
                  : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
        if (hasError && errorText != null) ...[
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 13.w,
                  color: const Color(0xFFEF4444),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
