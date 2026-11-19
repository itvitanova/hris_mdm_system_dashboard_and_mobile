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
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 240.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
              Flexible(
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
                      softWrap: true,
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
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 4.5.h,
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
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: statusConfig.textColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
