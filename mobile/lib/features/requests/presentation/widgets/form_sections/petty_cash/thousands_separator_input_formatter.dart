import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatThousand(int value) {
  return NumberFormat('#,###', 'id_ID').format(value);
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat('#,###', 'id_ID');

  static String format(int value) {
    return _formatter.format(value);
  }

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
