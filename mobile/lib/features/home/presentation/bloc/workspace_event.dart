import 'package:equatable/equatable.dart';

sealed class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class WorkspaceFetchRequested extends WorkspaceEvent {
  const WorkspaceFetchRequested();
}

class WorkspaceRefreshRequested extends WorkspaceEvent {
  const WorkspaceRefreshRequested();
}
