import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'form_card_error_label.dart';

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
        if (hasError && errorText != null)
          FormCardErrorLabel(errorText: errorText!),
      ],
    );
  }
}
