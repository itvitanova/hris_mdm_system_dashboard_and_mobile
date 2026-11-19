import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'petty_cash_preset_chips.dart';
import 'thousands_separator_input_formatter.dart';

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

  static const quickPresets = PettyCashPresetChips.quickPresets;

  @override
  State<PettyCashAmountCard> createState() => _PettyCashAmountCardState();
}

class _PettyCashAmountCardState extends State<PettyCashAmountCard> {
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey<FormFieldState<String>>();

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
      if (state != null && state.hasError) state.validate();
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
                  color: hasError ? const Color(0xFFEF4444) : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Rp', style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488))),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextFormField(
                          controller: widget.controller,
                          enabled: !widget.disabled,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
                          style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: const TextStyle(fontSize: 0, height: 0.001, color: Colors.transparent),
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 15.sp, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8)),
                          ),
                          onChanged: (_) {
                            if (field.hasError) field.validate();
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
                              child: Icon(UIcons.regularRounded.cross, size: 16.sp, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Pilih nominal cepat di bawah atau masukkan angka manual:',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11.sp, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  PettyCashPresetChips(
                    currentAmount: widget.currentAmount,
                    onAmountSelected: widget.onAmountSelected,
                    disabled: widget.disabled,
                  ),
                ],
              ),
            ),
            if (hasError && errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 5.h, left: 4.w, right: 4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(UIcons.regularRounded.exclamation, size: 13.w, color: const Color(0xFFEF4444)),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        errorText,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
