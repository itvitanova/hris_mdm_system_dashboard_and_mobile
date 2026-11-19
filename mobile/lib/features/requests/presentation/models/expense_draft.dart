import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/workspace.dart';

/// Presentation & Domain draft model for single reimbursement expense line item
class ExpenseDraft {
  ExpenseDraft(Json row)
      : description = TextEditingController(text: text(row, 'description', '')),
        category = TextEditingController(text: text(row, 'category', '')),
        qty = TextEditingController(
          text: ((row['qty'] as num?)?.toInt() ??
                  int.tryParse(row['qty']?.toString() ?? '') ??
                  1)
              .toString(),
        ),
        unitPrice = TextEditingController(
          text: _resolveInitialUnitPrice(row),
        ),
        specification = TextEditingController(text: text(row, 'specification', '')),
        amount = TextEditingController(
          text: number(row, 'amount') > 0 ? number(row, 'amount').toInt().toString() : '',
        ),
        date = DateTime.tryParse(text(row, 'date', '')) ?? DateTime.now(),
        receiptId = text(row, 'receiptId', '') {
    if (amount.text.isEmpty && unitPrice.text.isNotEmpty) {
      recalculateAmount();
    }
  }

  static String _resolveInitialUnitPrice(Json row) {
    final directUnitPrice =
        (row['unitPrice'] as num?)?.toInt() ?? int.tryParse(row['unitPrice']?.toString() ?? '');
    if (directUnitPrice != null && directUnitPrice > 0) {
      return directUnitPrice.toString();
    }
    final rawAmount = number(row, 'amount').toInt();
    final rawQty =
        (row['qty'] as num?)?.toInt() ?? int.tryParse(row['qty']?.toString() ?? '') ?? 1;
    if (rawAmount > 0 && rawQty == 1) {
      return rawAmount.toString();
    }
    return '';
  }

  final TextEditingController description;
  final TextEditingController category;
  final TextEditingController qty;
  final TextEditingController unitPrice;
  final TextEditingController specification;
  final TextEditingController amount;
  DateTime date;
  String receiptId;
  String receiptName = 'Bukti tersimpan';
  String? stagedPath;
  Uint8List? fileBytes;

  void recalculateAmount() {
    final q = int.tryParse(qty.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final p = int.tryParse(unitPrice.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (p > 0) {
      amount.text = (q * p).toString();
    } else {
      amount.text = '';
    }
  }

  void recalculateFromAmount() {
    final a = int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final q = int.tryParse(qty.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    if (a > 0 && q == 1 && unitPrice.text.isEmpty) {
      unitPrice.text = a.toString();
    }
  }

  Json json() {
    final q = int.tryParse(qty.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final p = int.tryParse(unitPrice.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final a = int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? (q * p);

    var desc = description.text.trim();
    final spec = specification.text.trim();
    final details = <String>[];
    if (spec.isNotEmpty) details.add(spec);
    if (q > 1) details.add('$q pcs');
    if (details.isNotEmpty) {
      if (desc.isEmpty) {
        desc = details.join(' · ');
      } else {
        desc = '$desc (${details.join(' · ')})';
      }
    }

    return {
      'date': dateOnly(date),
      'description': desc,
      'category': category.text.trim(),
      'amount': a,
      'receiptId': receiptId,
    };
  }

  void dispose() {
    description.dispose();
    category.dispose();
    qty.dispose();
    unitPrice.dispose();
    specification.dispose();
    amount.dispose();
  }
}
