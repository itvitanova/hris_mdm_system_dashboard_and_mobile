import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/workspace.dart';
import '../universal_request_card/universal_request_card.dart';
import 'detail_formatters.dart';

/// Top header row of overview card showing kind icon, date, and status badge
class DetailOverviewHeader extends StatelessWidget {
  const DetailOverviewHeader({
    super.key,
    required this.r,
    required this.kindConfig,
    required this.statusConfig,
  });

  final Json r;
  final RequestKindConfig kindConfig;
  final RequestStatusConfig statusConfig;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF14B8A6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x220F766E),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  kindConfig.icon,
                  size: 19.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kindConfig.typeTitle.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F766E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Diajukan pada ${requestDateLabel(text(r, 'createdAt'))}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 7.w,
            vertical: 3.h,
          ),
          decoration: BoxDecoration(
            color: statusConfig.badgeBg,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: statusConfig.badgeBorder,
              width: 0.8,
            ),
          ),
          child: Text(
            statusConfig.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w600,
              color: statusConfig.textColor,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}
