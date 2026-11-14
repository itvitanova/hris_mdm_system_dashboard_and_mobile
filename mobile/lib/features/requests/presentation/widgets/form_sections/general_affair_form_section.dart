import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'form_ui_components.dart';

const gaCategories = [
  'Pengadaan Barang',
  'Perbaikan & Servis',
  'Kebutuhan ATK',
  'Pemeliharaan Fasilitas',
  'Sarana Ruang Rapat',
];

const gaPriorities = ['Normal', 'Mendesak'];

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

class GaPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPrioritySelected;
  final bool disabled;

  const GaPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFormSectionTitle('Tingkat Prioritas *'),
        SizedBox(height: 8.h),
        Row(
          children: gaPriorities.map((prio) {
            final isSelected = selectedPriority == prio;
            final isUrgent = prio == 'Mendesak';
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: prio == gaPriorities.first ? 8.w : 0,
                  left: prio == gaPriorities.last ? 8.w : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: disabled ? null : () => onPrioritySelected(prio),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isUrgent
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF0FDFA))
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? (isUrgent
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF0D9488))
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.4 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isUrgent
                                ? UIcons.regularRounded.bolt
                                : UIcons.regularRounded.check,
                            size: 16.sp,
                            color: isSelected
                                ? (isUrgent
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF0D9488))
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            prio,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isUrgent
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF0F766E))
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class GaLocationCard extends StatelessWidget {
  final TextEditingController controller;
  final bool disabled;
  final VoidCallback? onChanged;

  const GaLocationCard({
    super.key,
    required this.controller,
    this.disabled = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildFormInputCard(
      child: TextFormField(
        controller: controller,
        enabled: !disabled,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: 'Lokasi Penempatan / Ruangan (Opsional)',
          hintText: 'Contoh: Gedung A, Lt. 3 - Ruang Operasional / Meja 12',
          prefixIcon: Icon(
            UIcons.regularRounded.marker,
            size: 18.sp,
            color: const Color(0xFF0D9488),
          ),
          helperText: 'Bantu tim GA menemukan titik sarana dengan tepat',
          helperStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5.sp,
            color: const Color(0xFF94A3B8),
          ),
        ),
        onChanged: (_) => onChanged?.call(),
      ),
    );
  }
}

class GeneralAffairSummaryBox extends StatelessWidget {
  final String category;
  final String priority;
  final String dateText;
  final String locationText;
  final String? attachmentName;

  const GeneralAffairSummaryBox({
    super.key,
    required this.category,
    required this.priority,
    required this.dateText,
    required this.locationText,
    this.attachmentName,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = priority == 'Mendesak';
    final hasLocation = locationText.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDFA), Color(0xFFE6FFFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFF99F6E4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080D9488),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  UIcons.regularRounded.boxes,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Ringkasan Kebutuhan GA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.5.h,
                ),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFEE2E2) : Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF99F6E4),
                    width: 0.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUrgent) ...[
                      Icon(
                        UIcons.regularRounded.bolt,
                        size: 11.sp,
                        color: const Color(0xFFDC2626),
                      ),
                      SizedBox(width: 3.w),
                    ],
                    Text(
                      priority,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isUrgent
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xD9FFFFFF),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFCCFBF1),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                getGaCategoryIcon(category),
                                size: 14.sp,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Kategori',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          category,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xD9FFFFFF),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFCCFBF1),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                UIcons.regularRounded.calendar,
                                size: 14.sp,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Tanggal Kebutuhan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          dateText,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFFCCFBF1),
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x04000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      UIcons.regularRounded.marker,
                      size: 15.sp,
                      color: const Color(0xFF0D9488),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi Penempatan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            hasLocation ? locationText.trim() : 'Sesuai meja kerja pemohon',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: hasLocation
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (attachmentName != null) ...[
                  SizedBox(height: 8.h),
                  const Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Color(0xFFF1F5F9),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        UIcons.regularRounded.clip,
                        size: 15.sp,
                        color: const Color(0xFF0D9488),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lampiran Berkas',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              attachmentName!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0x66CCFBF1),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: const Color(0xFF99F6E4),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Icon(
                    UIcons.regularRounded.info,
                    size: 14.sp,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Permohonan GA akan diverifikasi oleh tim operasional fasilitas sesuai ketersediaan sarana dan jadwal teknisi.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5.sp,
                      color: const Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
