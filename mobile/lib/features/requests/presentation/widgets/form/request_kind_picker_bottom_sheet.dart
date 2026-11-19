import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

const requestKinds = [
  'Cuti',
  'Izin',
  'Lembur',
  'Reimbursement',
  'Medical Claim',
  'Petty Cash',
  'General Affair',
];

/// Bottom sheet dialog to select the active request kind
class RequestKindPickerBottomSheet extends StatelessWidget {
  final String currentKind;
  final ValueChanged<String> onSelected;

  const RequestKindPickerBottomSheet({
    super.key,
    required this.currentKind,
    required this.onSelected,
  });

  static void show(
    BuildContext context, {
    required String currentKind,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RequestKindPickerBottomSheet(
        currentKind: currentKind,
        onSelected: (kind) {
          onSelected(kind);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'PILIH JENIS PENGAJUAN',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requestKinds.length,
            separatorBuilder: (_, _) => Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final kind = requestKinds[index];
              final isSelected = kind == currentKind;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                title: Text(
                  kind,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                  ),
                ),
                trailing: isSelected
                    ? Icon(UIcons.regularRounded.check, size: 18.sp, color: const Color(0xFF2563EB))
                    : null,
                onTap: () => onSelected(kind),
              );
            },
          ),
        ],
      ),
    );
  }
}
