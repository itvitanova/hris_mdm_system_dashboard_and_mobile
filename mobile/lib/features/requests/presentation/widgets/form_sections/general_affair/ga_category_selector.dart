import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../form_ui_components.dart';

const gaCategories = [
  'Pengadaan Barang',
  'Perbaikan & Servis',
  'Kebutuhan ATK',
  'Pemeliharaan Fasilitas',
  'Sarana Ruang Rapat',
];

IconData getGaCategoryIcon(String cat) {
  return switch (cat) {
    'Pengadaan Barang' => UIcons.regularRounded.shopping_bag,
    'Perbaikan & Servis' => UIcons.regularRounded.settings,
    'Kebutuhan ATK' => UIcons.regularRounded.edit,
    'Pemeliharaan Fasilitas' => UIcons.regularRounded.tool_box,
    'Sarana Ruang Rapat' => UIcons.regularRounded.building,
    _ => UIcons.regularRounded.boxes,
  };
}

class GaCategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool disabled;

  const GaCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFormSectionTitle('Kategori Kebutuhan GA *'),
        SizedBox(height: 8.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 8.w) / 2;
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: gaCategories.map((cat) {
                final isSelected = selectedCategory == cat;
                final icon = getGaCategoryIcon(cat);
                return SizedBox(
                  width: itemWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: disabled ? null : () => onCategorySelected(cat),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF0FDFA)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0D9488)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.4 : 1.0,
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
                                cat,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
