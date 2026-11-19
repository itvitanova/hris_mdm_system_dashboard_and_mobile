import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'request_card_config.dart';

class RequestCardHeader extends StatelessWidget {
  final UniversalRequestModel data;
  final RequestKindConfig kindConfig;
  final RequestStatusConfig statusConfig;
  final bool showApplicant;
  final AppLanguage language;

  const RequestCardHeader({
    super.key,
    required this.data,
    required this.kindConfig,
    required this.statusConfig,
    required this.showApplicant,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryMetaRaw = kindConfig
        .secondaryMeta(data)
        ?.replaceAll(RegExp(r'^[·\-\s]+'), '')
        .trim();
    final isApprovalMode = showApplicant &&
        data.employeeName.isNotEmpty &&
        data.employeeName != '—';
    final hasDept = data.department != null &&
        data.department!.isNotEmpty &&
        data.department != '—' &&
        data.department != '-';
    final applicantDisplay = isApprovalMode
        ? (hasDept
            ? '${data.employeeName} (${data.department})'
            : data.employeeName)
        : kindConfig.typeTitle;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 220.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  children: [
                    Text(
                      data.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5.w,
                      children: [
                        Text(
                          applicantDisplay,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isApprovalMode ? 11.5 : 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F766E),
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (secondaryMetaRaw != null && secondaryMetaRaw.isNotEmpty) ...[
                          const Text(
                            '•',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            secondaryMetaRaw,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 3.5.h,
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
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusConfig.textColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
