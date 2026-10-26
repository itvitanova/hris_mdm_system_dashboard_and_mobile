import 'package:equatable/equatable.dart';

sealed class PayrollEvent extends Equatable {
  const PayrollEvent();

  @override
  List<Object?> get props => [];
}

class PayslipDownloadRequested extends PayrollEvent {
  final String slipId;

  const PayslipDownloadRequested(this.slipId);

  @override
  List<Object?> get props => [slipId];
}
