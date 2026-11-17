import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'request_form_action_buttons.dart';

/// Styled docked bottom navigation bar container for request form submit/cancel actions
class RequestFormBottomBar extends StatelessWidget {
  final bool busy;
  final bool uploading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const RequestFormBottomBar({
    super.key,
    required this.busy,
    required this.uploading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          )
        ],
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 12.h),
          child: RequestFormActionButtons(
            busy: busy,
            uploading: uploading,
            onCancel: onCancel,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }
}
