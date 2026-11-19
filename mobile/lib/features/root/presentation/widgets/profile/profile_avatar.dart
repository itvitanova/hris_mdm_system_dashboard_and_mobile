import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

/// Avatar profil dengan inisial dan status dot online/offline
class ProfileAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final bool isOnline;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.initials,
    this.size = 62.0,
    this.isOnline = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    final dotColor = isOnline ? const Color(0xFF00AA13) : const Color(0xFFEF4444);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: isOnline ? 'Online' : 'Internet Mati (Offline)',
        child: SizedBox(
          width: s,
          height: s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5.w,
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
                    fontSize: 20.sp,
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
                  key: const Key('profile_avatar_online_dot'),
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.w,
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
