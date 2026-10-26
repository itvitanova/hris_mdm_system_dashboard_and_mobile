import 'package:equatable/equatable.dart';

sealed class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

class RequestSubmitRequested extends RequestEvent {
  final Map<String, dynamic> requestData;

  const RequestSubmitRequested(this.requestData);

  @override
  List<Object?> get props => [requestData];
}

class RequestDecideRequested extends RequestEvent {
  final String id;
  final int revision;
  final String decision;
  final String note;

  const RequestDecideRequested({
    required this.id,
    required this.revision,
    required this.decision,
    this.note = '',
  });

  @override
  List<Object?> get props => [id, revision, decision, note];
}
