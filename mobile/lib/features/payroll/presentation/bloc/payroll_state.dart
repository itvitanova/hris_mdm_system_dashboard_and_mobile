import 'dart:typed_data';
import 'package:equatable/equatable.dart';

sealed class PayrollState extends Equatable {
  const PayrollState();

  @override
  List<Object?> get props => [];
}

class PayrollInitial extends PayrollState {
  const PayrollInitial();
}

class PayslipDownloading extends PayrollState {
  const PayslipDownloading();
}

class PayslipDownloadSuccess extends PayrollState {
  final Uint8List bytes;

  const PayslipDownloadSuccess(this.bytes);

  @override
  List<Object?> get props => [bytes];
}

class PayslipActionFailure extends PayrollState {
  final String message;

  const PayslipActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
