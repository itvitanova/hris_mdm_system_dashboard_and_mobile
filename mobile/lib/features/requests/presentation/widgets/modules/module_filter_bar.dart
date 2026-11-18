import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../domain/entities/submission_status.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../services_hub/submission_status_filter_dropdown.dart';

/// Row containing status filter dropdown and refresh button
class ModuleFilterBar extends StatelessWidget {
  const ModuleFilterBar({
    super.key,
    required this.selectedStatus,
    required this.language,
    required this.onChanged,
    required this.onRefresh,
  });

  final SubmissionStatus? selectedStatus;
  final AppLanguage language;
  final ValueChanged<SubmissionStatus?> onChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SubmissionStatusFilterDropdown(
            selected: selectedStatus,
            language: language,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 10.w),
        ModuleFilterIconButton(
          icon: UIcons.regularRounded.refresh,
          onTap: onRefresh,
        ),
      ],
    );
  }
}

/// Square icon button with border used alongside dropdowns
class ModuleFilterIconButton extends StatelessWidget {
  const ModuleFilterIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF475569)),
        ),
      ),
    );
  }
}
