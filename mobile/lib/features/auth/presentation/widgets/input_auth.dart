import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class InputAuth extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
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
    this.prefixIcon,
    this.keyboardType,
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
    final bool hasFocus = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
            letterSpacing: -0.1,
          ),
        ),
        SizedBox(height: 7.w),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: widget.enabled
                ? (hasFocus ? Colors.white : const Color(0xFFF8FAFC))
                : const Color(0xFFF1F5F9),
            boxShadow: [
              if (widget.enabled && hasFocus)
                BoxShadow(
                  color: AppColors.filterTealAccent.withValues(alpha: 0.14),
                  spreadRadius: 3.w,
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            autofillHints: widget.autofillHints,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            obscureText: widget.isPassword ? _obsecureText : false,
            validator: widget.validator,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: widget.enabled ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 19.w,
                      color: hasFocus ? AppColors.deepTeal : const Color(0xFF94A3B8),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      splashRadius: 20.r,
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
                        color: hasFocus
                            ? AppColors.deepTeal
                            : (widget.enabled
                                ? const Color(0xFF94A3B8)
                                : AppColors.textTertiary),
                      ),
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 13.w,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  width: 1.2.w,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  width: 1.w,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  width: 1.5.w,
                  color: AppColors.deepTeal,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
