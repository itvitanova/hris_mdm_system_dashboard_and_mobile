import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/expense_draft.dart';

/// Pricing details (Qty, Unit Price, Amount, Specification) for an expense item
class ExpenseItemPricingSection extends StatelessWidget {
  final ExpenseDraft item;
  final bool isDisabled;
  final VoidCallback onChanged;

  const ExpenseItemPricingSection({
    super.key,
    required this.item,
    required this.isDisabled,
    required this.onChanged,
  });

  InputDecoration _inputDecoration(String label, {String? hint, String? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      prefixStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      ),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      border: InputBorder.none,
    );
  }

  TextStyle _textStyle(FontWeight weight, Color color) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 12.sp,
      fontWeight: weight,
      color: color,
    );
  }

  Widget _inputBox({required Widget child, Color? bg}) {
    return Container(
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputBox(
          child: TextFormField(
            controller: item.description,
            enabled: !isDisabled,
            maxLength: 500,
            style: _textStyle(FontWeight.w500, const Color(0xFF0F172A)),
            decoration: _inputDecoration('Deskripsi *', hint: 'Misal: Makan malam meeting client, tiket kereta dinas'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            onChanged: (_) => onChanged(),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _inputBox(
                child: TextFormField(
                  key: const Key('reimbursement_qty_field'),
                  controller: item.qty,
                  enabled: !isDisabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: _textStyle(FontWeight.w600, const Color(0xFF0F172A)),
                  decoration: _inputDecoration('Qty', hint: '1'),
                  onChanged: (_) {
                    item.recalculateAmount();
                    onChanged();
                  },
                  validator: (v) {
                    final q = int.tryParse((v ?? '').trim()) ?? 0;
                    return q < 1 ? 'Min 1' : null;
                  },
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 7,
              child: _inputBox(
                child: TextFormField(
                  key: const Key('reimbursement_unit_price_field'),
                  controller: item.unitPrice,
                  enabled: !isDisabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: _textStyle(FontWeight.w600, const Color(0xFF0F172A)),
                  decoration: _inputDecoration(
                    'Harga satuan (Rp) *',
                    hint: '0',
                    prefix: 'Rp ',
                  ),
                  onChanged: (_) {
                    item.recalculateAmount();
                    onChanged();
                  },
                  validator: (v) {
                    final clean = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    return ((int.tryParse(clean) ?? 0) < 1) ? 'Harga satuan wajib diisi' : null;
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _inputBox(
          child: TextFormField(
            key: const Key('reimbursement_specification_field'),
            controller: item.specification,
            enabled: !isDisabled,
            style: _textStyle(FontWeight.w500, const Color(0xFF0F172A)),
            decoration: _inputDecoration('Brand / Type & Spesifikasi', hint: 'Opsional: cantumkan seri / spesifikasi barang'),
          ),
        ),
        SizedBox(height: 12.h),
        _inputBox(
          bg: const Color(0xFFF8FAFC),
          child: TextFormField(
            key: const Key('reimbursement_amount_field'),
            controller: item.amount,
            readOnly: true,
            enabled: !isDisabled,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: _textStyle(FontWeight.w700, const Color(0xFF0F172A)),
            decoration: _inputDecoration('Jumlah (Rp) *', prefix: 'Rp '),
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }
}
