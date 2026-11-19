import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'form_card_container.dart';

/// Komponen dropdown kartu putih terstandarisasi untuk modul pengajuan.
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
            return FormCardContainer(
              height: 48.h,
              hasError: field.hasError,
              errorText: field.errorText,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
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
                      UIcons.regularRounded.angle_small_down,
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
