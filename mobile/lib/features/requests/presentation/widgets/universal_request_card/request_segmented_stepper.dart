import 'package:flutter/material.dart';
import '../../../domain/entities/submission_kind.dart';
import '../../../domain/entities/universal_request_item.dart';
import 'single_stage_stepper.dart';
import 'two_stage_stepper.dart';

export 'single_stage_stepper.dart';
export 'two_stage_stepper.dart';

/// Segmented Stepper Murni & Tenang (Tanpa Centang / Tanpa Over-Status)
class RequestSegmentedStepper extends StatelessWidget {
  final UniversalRequestModel data;

  const RequestSegmentedStepper({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.kind == SubmissionKind.reimbursement) {
      return TwoStageStepper(data: data);
    }
    return SingleStageStepper(data: data);
  }
}
