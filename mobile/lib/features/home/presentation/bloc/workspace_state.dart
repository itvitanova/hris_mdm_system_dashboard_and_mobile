import 'package:equatable/equatable.dart';
import '../../../../core/workspace.dart';

sealed class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();
}

class WorkspaceLoaded extends WorkspaceState {
  final Workspace workspace;
  const WorkspaceLoaded(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

class WorkspaceError extends WorkspaceState {
  final String message;
  final Workspace? previousWorkspace;
  const WorkspaceError(this.message, {this.previousWorkspace});

  @override
  List<Object?> get props => [message, previousWorkspace];
}
