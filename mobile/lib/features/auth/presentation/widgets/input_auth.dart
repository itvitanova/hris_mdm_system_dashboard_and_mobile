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
    return SizedBox(
      width: 322.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: const TextStyle(color: Colors.black87)),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.w),
              color: widget.enabled ? Colors.white : const Color(0xFFF9FAFB),
              boxShadow: [
                widget.enabled && _focusNode.hasFocus
                    ? BoxShadow(
                        color: AppColors.deepTeal50,
                        spreadRadius: 4.w,
                        blurRadius: 0,
                        offset: const Offset(0, 0),
                      )
                    : const BoxShadow(color: Colors.transparent),
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: widget.isPassword ? _obsecureText : false,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              autofillHints: widget.autofillHints,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onFieldSubmitted,
              style: AppTextStyles.inputTextStyles.copyWith(
                color: widget.enabled ? AppColors.textPrimary : AppColors.textTertiary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                suffixIcon: widget.isPassword
                    ? IconButton(
                        onPressed: widget.enabled
                            ? () => setState(() {
                                _obsecureText = !_obsecureText;
                              })
                            : null,
                        icon: _obsecureText
                            ? Icon(
                                Icons.visibility,
                                color: widget.enabled
                                    ? AppColors.textSecondary
                                    : AppColors.textTertiary,
                              )
                            : Icon(
                                Icons.visibility_off,
                                color: widget.enabled
                                    ? AppColors.textSecondary
                                    : AppColors.textTertiary,
                              ),
                      )
                    : null,
                contentPadding: EdgeInsets.all(8.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: AppColors.inputColorBorder,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: BorderSide(
                    width: 1.5,
                    color: AppColors.inputColorBorder.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: const BorderSide(width: 1.5, color: AppColors.deepTeal),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
