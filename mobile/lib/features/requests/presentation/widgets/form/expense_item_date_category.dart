import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../models/expense_draft.dart';

const reimbursementCategories = [
  'Transportasi',
  'Keperluan Kantor (Habis Pakai)',
  'Alat Tulis Kantor',
  'Peralatan Kantor (Aset)',
  'Biaya Sewa',
  'Entertain',
  'Subscription',
  'Lainnya',
];

/// Expense date and category picker row
class ExpenseItemDateCategory extends StatelessWidget {
  final ExpenseDraft item;
  final bool isDisabled;
  final String Function(DateTime) formatDate;
  final void Function(ExpenseDraft) onPickExpenseDate;
  final VoidCallback onChanged;

  const ExpenseItemDateCategory({
    super.key,
    required this.item,
    required this.isDisabled,
    required this.formatDate,
    required this.onPickExpenseDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal transaksi *',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: isDisabled ? null : () => onPickExpenseDate(item),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  UIcons.regularRounded.calendar,
                  size: 14.sp,
                  color: const Color(0xFF64748B),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    formatDate(item.date),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        ButtonTheme(
          alignedDropdown: true,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: item.category.text.isNotEmpty
                ? item.category.text
                : null,
            hint: Text(
              'Pilih kategori',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Kategori *',
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFF0D9488),
                  width: 1.5,
                ),
              ),
            ),
            items:
                [
                  ...reimbursementCategories,
                  if (item.category.text.isNotEmpty &&
                      !reimbursementCategories.contains(item.category.text))
                    item.category.text,
                ].map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  );
                }).toList(),
            onChanged: isDisabled
                ? null
                : (v) {
                    item.category.text = v ?? '';
                    onChanged();
                  },
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Pilih kategori pengeluaran'
                : null,
          ),
        ),
      ],
    );
  }
}
