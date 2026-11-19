import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

const reimbursementCategories = [
  'Transportasi',
  'Akomodasi & Hotel',
  'Konsumsi & Makan',
  'Komunikasi & Pulsa',
  'Entertainment & Klien',
  'Kesehatan & Medis',
  'Alat Tulis Kantor',
  'Operasional Lapangan',
  'Lain-lain',
];

/// Bottom sheet dialog to select expense category
class ReimbursementCategoryBottomSheet extends StatelessWidget {
  final String currentCategory;
  final ValueChanged<String> onSelected;

  const ReimbursementCategoryBottomSheet({
    super.key,
    required this.currentCategory,
    required this.onSelected,
  });

  static void show(
    BuildContext context, {
    required String currentCategory,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReimbursementCategoryBottomSheet(
        currentCategory: currentCategory,
        onSelected: (cat) {
          onSelected(cat);
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
            'PILIH KATEGORI BIAYA',
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
            itemCount: reimbursementCategories.length,
            separatorBuilder: (_, _) => Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final cat = reimbursementCategories[index];
              final isSelected = cat == currentCategory;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                title: Text(
                  cat,
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
                onTap: () => onSelected(cat),
              );
            },
          ),
        ],
      ),
    );
  }
}
