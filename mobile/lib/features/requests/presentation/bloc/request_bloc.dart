import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/decide_request_usecase.dart';
import '../../domain/usecases/submit_request_usecase.dart';
import 'request_event.dart';
import 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final SubmitRequestUseCase submitRequestUseCase;
  final DecideRequestUseCase decideRequestUseCase;

  RequestBloc({
    required this.submitRequestUseCase,
    required this.decideRequestUseCase,
  }) : super(const RequestInitial()) {
    on<RequestSubmitRequested>(_onSubmitRequested);
    on<RequestDecideRequested>(_onDecideRequested);
  }

  Future<void> _onSubmitRequested(
    RequestSubmitRequested event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestSubmitting());
    final result = await submitRequestUseCase(event.requestData);
    result.fold(
      (failure) => emit(RequestActionFailure(failure.message)),
      (_) => emit(const RequestSubmitSuccess()),
    );
  }

  Future<void> _onDecideRequested(
    RequestDecideRequested event,
    Emitter<RequestState> emit,
  ) async {
    emit(const RequestSubmitting());
    final result = await decideRequestUseCase(
      id: event.id,
      revision: event.revision,
      decision: event.decision,
      note: event.note,
    );
    result.fold(
      (failure) => emit(RequestActionFailure(failure.message)),
      (_) => emit(const RequestDecideSuccess()),
    );
  }
}
