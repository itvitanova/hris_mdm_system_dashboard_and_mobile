import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/enroll_face_usecase.dart';
import '../../domain/usecases/punch_attendance_usecase.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final PunchAttendanceUseCase punchAttendanceUseCase;
  final EnrollFaceUseCase enrollFaceUseCase;

  AttendanceBloc({
    required this.punchAttendanceUseCase,
    required this.enrollFaceUseCase,
  }) : super(const AttendanceInitial()) {
    on<AttendancePunchRequested>(_onPunchRequested);
    on<AttendanceEnrollRequested>(_onEnrollRequested);
  }

  Future<void> _onPunchRequested(
    AttendancePunchRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceSubmitting());
    final result = await punchAttendanceUseCase(
      type: event.type,
      photo: event.photo,
      earlyReason: event.earlyReason,
    );
    result.fold(
      (failure) => emit(AttendanceFailureState(failure.message)),
      (_) => emit(const AttendancePunchSuccess()),
    );
  }

  Future<void> _onEnrollRequested(
    AttendanceEnrollRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceSubmitting());
    final result = await enrollFaceUseCase(event.employeeId, event.photo);
    result.fold(
      (failure) => emit(AttendanceFailureState(failure.message)),
      (_) => emit(const AttendanceEnrollSuccess()),
    );
  }
}
