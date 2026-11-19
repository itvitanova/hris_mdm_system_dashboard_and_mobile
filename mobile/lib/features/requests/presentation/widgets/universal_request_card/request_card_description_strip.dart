import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../../../domain/entities/submission_kind.dart';
import 'request_formatters.dart';

class RequestCardDescriptionStrip extends StatelessWidget {
  final String? rawDescription;
  final SubmissionKind kind;
  final AppLanguage language;

  const RequestCardDescriptionStrip({
    super.key,
    required this.rawDescription,
    required this.kind,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final raw = rawDescription;
    if (raw == null || raw.trim().isEmpty || raw == '-') {
      return const SizedBox.shrink();
    }
    final cleanedDesc = RequestDescriptionHelper.cleanCardDescription(raw);
    if (cleanedDesc.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 9.w,
          top: 2.h,
          bottom: 2.h,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: const Color(0xFFCBD5E1),
              width: 2.5.w,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              RequestDescriptionHelper.getDescriptionLabel(kind, language),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(height: 2.5.h),
            Text(
              '"$cleanedDesc"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
