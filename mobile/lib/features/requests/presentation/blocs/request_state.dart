import 'package:equatable/equatable.dart';

sealed class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {
  const RequestInitial();
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

class RequestActionFailure extends RequestState {
  final String message;
  const RequestActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
