import 'package:equatable/equatable.dart';

sealed class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {
  const RequestInitial();
}

class RequestLoading extends RequestState {
  const RequestLoading();
}

class RequestsLoaded extends RequestState {
  final List<Map<String, dynamic>> requests;
  final String? activeKind;

  const RequestsLoaded(this.requests, {this.activeKind});

  @override
  List<Object?> get props => [requests, activeKind];
}

class RequestSubmitting extends RequestState {
  const RequestSubmitting();
}

class RequestSubmitSuccess extends RequestState {
  const RequestSubmitSuccess();
}

class RequestDecideSuccess extends RequestState {
  const RequestDecideSuccess();
}

class RequestMarkSeenSuccess extends RequestState {
  const RequestMarkSeenSuccess();
}

class RequestActionFailure extends RequestState {
  final String message;
  const RequestActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
