import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../form_ui_components.dart';

const pettyCashCategories = [
  'Operasional Kantor',
  'Konsumsi Rapat',
  'ATK Darurat',
  'Transportasi Lokal',
];

IconData getPettyCashCategoryIcon(String category) {
  return switch (category) {
    'Operasional Kantor' => UIcons.regularRounded.briefcase,
    'Konsumsi Rapat' => UIcons.regularRounded.restaurant,
    'ATK Darurat' => UIcons.regularRounded.edit,
    'Transportasi Lokal' => UIcons.regularRounded.car,
    _ => UIcons.regularRounded.boxes,
  };
}

class PettyCashCategoryTile extends StatelessWidget {
  final String category;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const PettyCashCategoryTile({
    super.key,
    required this.category,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF0FDFA)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 1.2 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16.sp,
                  color: isSelected
                      ? const Color(0xFF0D9488)
                      : const Color(0xFF64748B),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    category,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFF334155),
                      height: 1.15,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    UIcons.regularRounded.check,
                    size: 14.sp,
                    color: const Color(0xFF0D9488),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PettyCashCategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool disabled;

  const PettyCashCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return buildFormCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih jenis kebutuhan kas kecil yang diajukan:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              PettyCashCategoryTile(
                category: 'Operasional Kantor',
                icon: UIcons.regularRounded.briefcase,
                isSelected: selectedCategory == 'Operasional Kantor',
                onTap: disabled ? null : () => onCategorySelected('Operasional Kantor'),
              ),
              SizedBox(width: 8.w),
              PettyCashCategoryTile(
                category: 'Konsumsi Rapat',
                icon: UIcons.regularRounded.restaurant,
                isSelected: selectedCategory == 'Konsumsi Rapat',
                onTap: disabled ? null : () => onCategorySelected('Konsumsi Rapat'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              PettyCashCategoryTile(
                category: 'ATK Darurat',
                icon: UIcons.regularRounded.edit,
                isSelected: selectedCategory == 'ATK Darurat',
                onTap: disabled ? null : () => onCategorySelected('ATK Darurat'),
              ),
              SizedBox(width: 8.w),
              PettyCashCategoryTile(
                category: 'Transportasi Lokal',
                icon: UIcons.regularRounded.car,
                isSelected: selectedCategory == 'Transportasi Lokal',
                onTap: disabled ? null : () => onCategorySelected('Transportasi Lokal'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
