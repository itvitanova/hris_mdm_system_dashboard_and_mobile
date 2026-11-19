import 'package:flutter/material.dart';
import 'date_picker/date_picker_action_buttons.dart';
import 'date_picker/date_picker_calendar_grid.dart';
import 'date_picker/date_picker_dialog_header.dart';
import 'date_picker/date_picker_month_header.dart';
import 'date_picker/date_picker_preset_chips.dart';

export 'date_picker/date_picker_action_buttons.dart';
export 'date_picker/date_picker_calendar_grid.dart';
export 'date_picker/date_picker_day_cell.dart';
export 'date_picker/date_picker_dialog_header.dart';
export 'date_picker/date_picker_helpers.dart';
export 'date_picker/date_picker_month_header.dart';
export 'date_picker/date_picker_preset_chips.dart';

/// Membuka dialog pemilih tanggal kustom dengan visual modern & interaktif.
Future<DateTime?> showCustomDatePickerDialog({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'PILIH TANGGAL',
}) {
  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup Dialog',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim1, anim2) {
      return CustomDatePickerDialog(
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2020),
        lastDate: lastDate ?? DateTime(2035),
        title: title,
      );
    },
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curvedValue = Curves.easeOutCubic.transform(anim.value);
      return Transform.scale(
        scale: 0.94 + (0.06 * curvedValue),
        child: Opacity(
          opacity: anim.value,
          child: child,
        ),
      );
    },
  );
}

/// Floating Center Dialog Pemilih Tanggal
class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title = 'PILIH TANGGAL',
  });

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _onPrevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  void _selectPreset(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _viewMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DatePickerDialogHeader(
                    title: widget.title,
                    selectedDate: _selectedDate,
                    onClose: () => Navigator.of(context).pop(null),
                  ),
                  const SizedBox(height: 14),
                  DatePickerPresetChips(
                    selectedDate: _selectedDate,
                    onSelectPreset: _selectPreset,
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 14),
                  DatePickerMonthHeader(
                    viewMonth: _viewMonth,
                    onPrevMonth: _onPrevMonth,
                    onNextMonth: _onNextMonth,
                  ),
                  const SizedBox(height: 16),
                  DatePickerCalendarGrid(
                    viewMonth: _viewMonth,
                    selectedDate: _selectedDate,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    onSelectDate: (d) => setState(() => _selectedDate = d),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 16),
                  DatePickerActionButtons(
                    onCancel: () => Navigator.of(context).pop(null),
                    onApply: () => Navigator.of(context).pop(_selectedDate),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
