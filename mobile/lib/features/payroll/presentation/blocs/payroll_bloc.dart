import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/download_payslip_usecase.dart';
import 'payroll_event.dart';
import 'payroll_state.dart';

class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  final DownloadPayslipUseCase downloadPayslipUseCase;

  PayrollBloc({required this.downloadPayslipUseCase})
      : super(const PayrollInitial()) {
    on<PayslipDownloadRequested>(_onDownloadRequested);
  }

  Future<void> _onDownloadRequested(
    PayslipDownloadRequested event,
    Emitter<PayrollState> emit,
  ) async {
    emit(const PayslipDownloading());
    final result = await downloadPayslipUseCase(event.slipId);
    result.fold(
      (failure) => emit(PayslipActionFailure(failure.message)),
      (bytes) => emit(PayslipDownloadSuccess(bytes)),
    );
  }
}
