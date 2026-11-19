import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';

class DashboardAvatar extends StatelessWidget {
  final String name;
  final bool isOnline;
  final VoidCallback? onTap;

  const DashboardAvatar({
    super.key,
    required this.name,
    this.isOnline = true,
    this.onTap,
  });

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'HR';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final size = 52.w;
    final dotColor = isOnline ? const Color(0xFF00AA13) : const Color(0xFFEF4444);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: isOnline ? 'Online' : 'Internet Mati (Offline)',
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.filterGradientStart,
                      AppColors.filterGradientEnd,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Positioned(
                right: -1.w,
                bottom: -1.w,
                child: Container(
                  key: const Key('dashboard_avatar_online_dot'),
                  width: 11.w,
                  height: 11.w,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
