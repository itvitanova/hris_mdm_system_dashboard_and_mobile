import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class InputAuth extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final Key? fieldKey;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const InputAuth({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.validator,
    this.enabled = true,
    this.fieldKey,
    this.keyboardType,
    this.prefixIcon,
    this.autofillHints,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<InputAuth> createState() => _InputAuthState();
}

class _InputAuthState extends State<InputAuth> {
  late final FocusNode _focusNode;
  late bool _obsecureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleStateChange);
    widget.controller.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleStateChange);
    _focusNode.dispose();
    widget.controller.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: widget.fieldKey,
      initialValue: widget.controller.text,
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (FormFieldState<String> field) {
        final bool isFocused = widget.enabled && _focusNode.hasFocus;
        final bool hasError = field.hasError;
        final String? errorText = field.errorText;

        return SizedBox(
          width: 322.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  fontWeight: isFocused ? FontWeight.w600 : FontWeight.w500,
                  color: hasError
                      ? AppColors.red
                      : (isFocused
                          ? AppColors.filterTealAccent
                          : const Color(0xFF334155)),
                ),
              ),
              SizedBox(height: 8.h),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: 48.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: widget.enabled
                      ? (isFocused ? Colors.white : const Color(0xFFF8FAFC))
                      : const Color(0xFFF1F5F9),
                  border: Border.all(
                    width: isFocused ? 1.6 : 1.2,
                    color: hasError
                        ? AppColors.red
                        : (isFocused
                            ? AppColors.filterTealAccent
                            : const Color(0xFFE2E8F0)),
                  ),
                  boxShadow: [
                    isFocused
                        ? BoxShadow(
                            color: (hasError
                                    ? AppColors.red
                                    : AppColors.filterTealAccent)
                                .withValues(alpha: 0.18),
                            spreadRadius: 3.5.w,
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          )
                        : const BoxShadow(color: Colors.transparent),
                  ],
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      keyboardType: widget.keyboardType,
                      autofillHints: widget.autofillHints,
                      textInputAction: widget.textInputAction,
                      onSubmitted: widget.onFieldSubmitted,
                      obscureText: widget.isPassword ? _obsecureText : false,
                      onChanged: (val) {
                        if (field.hasError) {
                          field.validate();
                        }
                      },
                      cursorColor: hasError
                          ? AppColors.red
                          : AppColors.filterTealAccent,
                      cursorWidth: 1.8,
                      style: AppTextStyles.inputTextStyles.copyWith(
                        color: widget.enabled
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        prefixIcon: widget.prefixIcon,
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                        ),
                        suffixIcon: widget.isPassword
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: widget.enabled
                                    ? () => setState(() {
                                        _obsecureText = !_obsecureText;
                                      })
                                    : null,
                                icon: Icon(
                                  _obsecureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20.w,
                                  color: isFocused
                                      ? (hasError
                                          ? AppColors.red
                                          : AppColors.filterTealAccent)
                                      : (widget.enabled
                                          ? AppColors.textSecondary
                                          : AppColors.textTertiary),
                                ),
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.w,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasError && errorText != null) ...[
                SizedBox(height: 5.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13.w,
                      color: AppColors.red,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        errorText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
