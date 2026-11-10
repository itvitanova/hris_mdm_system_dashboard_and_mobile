import 'package:equatable/equatable.dart';

sealed class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

class RequestLoadRequested extends RequestEvent {
  final String? kind;
  final String? status;
  final String? review;

  const RequestLoadRequested({
    this.kind,
    this.status,
    this.review,
  });

  @override
  List<Object?> get props => [kind, status, review];
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

class RequestMarkSeenRequested extends RequestEvent {
  final String id;
  final String token;

  const RequestMarkSeenRequested({
    required this.id,
    required this.token,
  });

  @override
  List<Object?> get props => [id, token];
}

class RequestResetStatus extends RequestEvent {
  const RequestResetStatus();
}
