import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_text_styles.dart';

/// Remember me checkbox with responsive hit area
class LoginRememberMeCheckbox extends StatelessWidget {
  const LoginRememberMeCheckbox({
    super.key,
    required this.isChecked,
    required this.isLoading,
    required this.onChanged,
  });

  final bool isChecked;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: isLoading ? null : (bool? value) => onChanged(value ?? false),
          activeColor: AppColors.filterTealAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          side: const BorderSide(
            color: Color(0xFFCBD5E1),
            width: 1.0,
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isLoading ? null : () => onChanged(!isChecked),
          child: Text(
            "Remember me",
            style: AppTextStyles.inter128RegularPrimary,
          ),
        ),
      ],
    );
  }
}
