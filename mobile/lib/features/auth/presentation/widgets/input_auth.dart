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
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = widget.enabled && _focusNode.hasFocus;

    return SizedBox(
      width: 322.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: isFocused ? FontWeight.w600 : FontWeight.w500,
              color: isFocused
                  ? AppColors.filterTealAccent
                  : const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: widget.enabled
                  ? (isFocused ? Colors.white : const Color(0xFFF8FAFC))
                  : const Color(0xFFF1F5F9),
              boxShadow: [
                isFocused
                    ? BoxShadow(
                        color: AppColors.filterTealAccent.withValues(alpha: 0.18),
                        spreadRadius: 3.5.w,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      )
                    : const BoxShadow(color: Colors.transparent),
              ],
            ),
            child: TextFormField(
              key: widget.fieldKey,
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              autofillHints: widget.autofillHints,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onFieldSubmitted,
              obscureText: widget.isPassword ? _obsecureText : false,
              validator: widget.validator,
              cursorColor: AppColors.filterTealAccent,
              cursorWidth: 1.8,
              style: AppTextStyles.inputTextStyles.copyWith(
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
              decoration: InputDecoration(
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
                              ? AppColors.filterTealAccent
                              : (widget.enabled
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary),
                        ),
                      )
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    width: 1.2,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    width: 1.0,
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    width: 1.6,
                    color: AppColors.filterTealAccent,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    width: 1.2,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
