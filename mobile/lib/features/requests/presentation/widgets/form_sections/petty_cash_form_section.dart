import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/workspace.dart';
import 'form_ui_components.dart';

const pettyCashCategories = [
  'Operasional Kantor',
  'Konsumsi Rapat',
  'ATK Darurat',
  'Transportasi Lokal',
];

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (oldValue.text.length > newValue.text.length &&
        oldValue.selection.baseOffset > 0 &&
        oldValue.selection.baseOffset <= oldValue.text.length &&
        oldValue.text[oldValue.selection.baseOffset - 1] == '.') {
      final oldClean = oldValue.text.replaceAll('.', '');
      final deleteIndexInClean = oldValue.text
              .substring(0, oldValue.selection.baseOffset)
              .replaceAll('.', '')
              .length -
          1;

      if (deleteIndexInClean >= 0 && deleteIndexInClean < oldClean.length) {
        final newClean = oldClean.substring(0, deleteIndexInClean) +
            oldClean.substring(deleteIndexInClean + 1);

        if (newClean.isEmpty) {
          return const TextEditingValue(
            text: '',
            selection: TextSelection.collapsed(offset: 0),
          );
        }

        final number = int.tryParse(newClean);
        if (number == null) return oldValue;

        final formatted = _formatter.format(number);
        final newCursorPosition = _calculateNewCursor(
          oldValue.text,
          formatted,
          oldValue.selection.baseOffset - 1,
        );

        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: newCursorPosition),
        );
      }
    }

    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(cleanText);
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);
    final cursorPosition = _calculateNewCursor(
      newValue.text,
      formatted,
      newValue.selection.baseOffset,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  int _calculateNewCursor(String oldText, String newText, int oldCursor) {
    final digitCount = oldText
        .substring(0, oldCursor.clamp(0, oldText.length))
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    int currentDigit = 0;
    for (int i = 0; i < newText.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newText[i])) {
        currentDigit++;
        if (currentDigit == digitCount) {
          return i + 1;
        }
      }
    }
    return newText.length;
  }
}

String formatThousand(int value) {
  return NumberFormat('#,###', 'id_ID').format(value);
}

IconData getPettyCashCategoryIcon(String category) {
  return switch (category) {
    'Operasional Kantor' => Icons.business_center_outlined,
    'Konsumsi Rapat' => Icons.restaurant_outlined,
    'ATK Darurat' => Icons.edit_note_rounded,
    'Transportasi Lokal' => Icons.directions_car_outlined,
    _ => Icons.category_outlined,
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
                    Icons.check_circle_rounded,
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
                icon: Icons.business_center_outlined,
                isSelected: selectedCategory == 'Operasional Kantor',
                onTap: disabled ? null : () => onCategorySelected('Operasional Kantor'),
              ),
              SizedBox(width: 8.w),
              PettyCashCategoryTile(
                category: 'Konsumsi Rapat',
                icon: Icons.restaurant_outlined,
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
                icon: Icons.edit_note_rounded,
                isSelected: selectedCategory == 'ATK Darurat',
                onTap: disabled ? null : () => onCategorySelected('ATK Darurat'),
              ),
              SizedBox(width: 8.w),
              PettyCashCategoryTile(
                category: 'Transportasi Lokal',
                icon: Icons.directions_car_outlined,
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

class PettyCashAmountCard extends StatefulWidget {
  final TextEditingController controller;
  final int currentAmount;
  final ValueChanged<int> onAmountSelected;
  final VoidCallback onClear;
  final bool disabled;

  const PettyCashAmountCard({
    super.key,
    required this.controller,
    required this.currentAmount,
    required this.onAmountSelected,
    required this.onClear,
    this.disabled = false,
  });

  static const quickPresets = [50000, 100000, 250000, 500000];

  @override
  State<PettyCashAmountCard> createState() => _PettyCashAmountCardState();
}

class _PettyCashAmountCardState extends State<PettyCashAmountCard> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void didUpdateWidget(PettyCashAmountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) {
      final state = _fieldKey.currentState;
      if (state != null && state.hasError) {
        state.validate();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.controller.text,
      validator: (_) {
        final clean = widget.controller.text.replaceAll(RegExp(r'[^0-9]'), '');
        final n = int.tryParse(clean) ?? 0;
        return n < 1 || n > 1000000000000 ? 'Nominal tidak valid' : null;
      },
      builder: (FormFieldState<String> field) {
        final bool hasError = field.hasError;
        final String? errorText = field.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFEF4444)
                      : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Rp',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextFormField(
                          controller: widget.controller,
                          enabled: !widget.disabled,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: const TextStyle(
                              fontSize: 0,
                              height: 0.001,
                              color: Colors.transparent,
                            ),
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          onChanged: (val) {
                            if (field.hasError) {
                              field.validate();
                            }
                          },
                        ),
                      ),
                      if (widget.currentAmount > 0)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.disabled ? null : widget.onClear,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pilih nominal cepat di bawah atau masukkan angka manual:',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: PettyCashAmountCard.quickPresets.map((preset) {
                      final isMatch = widget.currentAmount == preset;
                      final label = switch (preset) {
                        50000 => 'Rp 50 rb',
                        100000 => 'Rp 100 rb',
                        250000 => 'Rp 250 rb',
                        500000 => 'Rp 500 rb',
                        _ => rupiah(preset),
                      };
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.disabled
                              ? null
                              : () => widget.onAmountSelected(preset),
                          borderRadius: BorderRadius.circular(6.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isMatch
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: isMatch
                                    ? const Color(0xFF0D9488)
                                    : const Color(0xFF99F6E4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5.sp,
                                fontWeight: isMatch
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isMatch
                                    ? Colors.white
                                    : const Color(0xFF0F766E),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (hasError && errorText != null) ...[
              SizedBox(height: 5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13.w,
                      color: const Color(0xFFEF4444),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        errorText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class PettyCashSummaryCard extends StatelessWidget {
  final int parsedAmount;
  final String category;
  final String dateText;

  const PettyCashSummaryCard({
    super.key,
    required this.parsedAmount,
    required this.category,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(
                  Icons.payments_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Ringkasan Pengajuan Kas Kecil',
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: const Color(0xFF99F6E4),
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
                child: Text(
                  'Petty Cash',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF99F6E4),
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ESTIMASI PENGAJUAN',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  rupiah(parsedAmount),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
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
                                getPettyCashCategoryIcon(category),
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
                                Icons.calendar_today_rounded,
                                size: 14.sp,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Tanggal',
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
                    Icons.info_outline_rounded,
                    size: 14.sp,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Pencairan kas kecil wajib disertai pertanggungjawaban nota fisik / bon transaksi setelah penggunaan dana.',
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
