import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'detail_copy_button.dart';

/// Key-value information row with optional icon, copy button, and colon separator
class DetailInfoRow extends StatelessWidget {
  const DetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.copyValue,
    this.action,
    this.showColon = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? copyValue;
  final Widget? action;
  final bool showColon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13.5.w, color: const Color(0xFF94A3B8)),
            SizedBox(width: 6.w),
          ],
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (showColon)
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: showColon
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value.isNotEmpty ? value : '—',
                    textAlign: showColon ? TextAlign.start : TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (copyValue != null && copyValue!.isNotEmpty) ...[
                  SizedBox(width: 5.w),
                  DetailCopyButton(
                    textToCopy: copyValue!,
                    label: label,
                  ),
                ] else if (action != null) ...[
                  SizedBox(width: 5.w),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bank account row representation inside applicant bank card
class DetailBankModalRow extends StatelessWidget {
  const DetailBankModalRow({
    super.key,
    required this.label,
    required this.value,
    this.copyValue,
  });

  final String label;
  final String value;
  final String? copyValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 6,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5.sp,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (copyValue != null && copyValue!.isNotEmpty) ...[
                SizedBox(width: 4.w),
                DetailCopyButton(
                  textToCopy: copyValue!,
                  label: label,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
