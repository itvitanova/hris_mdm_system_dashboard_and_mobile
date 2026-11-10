import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/decide_request_usecase.dart';
import '../../domain/usecases/get_requests_usecase.dart';
import '../../domain/usecases/mark_seen_request_usecase.dart';
import '../../domain/usecases/submit_request_usecase.dart';
import 'request_event.dart';
import 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final SubmitRequestUseCase submitRequestUseCase;
  final DecideRequestUseCase decideRequestUseCase;
  final MarkSeenRequestUseCase? markSeenRequestUseCase;
  final GetRequestsUseCase? getRequestsUseCase;

  RequestBloc({
    required this.submitRequestUseCase,
    required this.decideRequestUseCase,
    this.markSeenRequestUseCase,
    this.getRequestsUseCase,
  }) : super(const RequestInitial()) {
    on<RequestLoadRequested>(_onLoadRequested);
    on<RequestSubmitRequested>(_onSubmitRequested);
    on<RequestDecideRequested>(_onDecideRequested);
    on<RequestMarkSeenRequested>(_onMarkSeenRequested);
    on<RequestResetStatus>(_onResetStatus);
  }

  Future<void> _onLoadRequested(
    RequestLoadRequested event,
    Emitter<RequestState> emit,
  ) async {
    if (getRequestsUseCase == null) return;
    emit(const RequestLoading());
    final result = await getRequestsUseCase!(
      kind: event.kind,
      status: event.status,
      review: event.review,
    );
    result.fold(
      (failure) => emit(RequestActionFailure(failure.message)),
      (data) => emit(RequestsLoaded(data, activeKind: event.kind)),
    );
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

  Future<void> _onMarkSeenRequested(
    RequestMarkSeenRequested event,
    Emitter<RequestState> emit,
  ) async {
    if (markSeenRequestUseCase == null) return;
    final result = await markSeenRequestUseCase!(
      id: event.id,
      token: event.token,
    );
    result.fold(
      (failure) => emit(RequestActionFailure(failure.message)),
      (_) => emit(const RequestMarkSeenSuccess()),
    );
  }

  void _onResetStatus(
    RequestResetStatus event,
    Emitter<RequestState> emit,
  ) {
    emit(const RequestInitial());
  }
}
