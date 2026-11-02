import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_workspace_usecase.dart';
import 'workspace_event.dart';
import 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final GetWorkspaceUseCase getWorkspaceUseCase;

  WorkspaceBloc({required this.getWorkspaceUseCase})
      : super(const WorkspaceInitial()) {
    on<WorkspaceFetchRequested>(_onFetchRequested);
    on<WorkspaceRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onFetchRequested(
    WorkspaceFetchRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(const WorkspaceLoading());
    final result = await getWorkspaceUseCase();
    result.fold(
      (failure) => emit(WorkspaceError(failure.message)),
      (workspace) => emit(WorkspaceLoaded(workspace)),
    );
  }

  Future<void> _onRefreshRequested(
    WorkspaceRefreshRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    final prev = state is WorkspaceLoaded
        ? (state as WorkspaceLoaded).workspace
        : (state is WorkspaceError
            ? (state as WorkspaceError).previousWorkspace
            : null);

    final result = await getWorkspaceUseCase();
    result.fold(
      (failure) =>
          emit(WorkspaceError(failure.message, previousWorkspace: prev)),
      (workspace) => emit(WorkspaceLoaded(workspace)),
    );
  }
}
