import 'package:equatable/equatable.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceSubmitting extends AttendanceState {
  const AttendanceSubmitting();
}

class AttendancePunchSuccess extends AttendanceState {
  const AttendancePunchSuccess();
}

class AttendanceEnrollSuccess extends AttendanceState {
  const AttendanceEnrollSuccess();
}

class AttendanceFailureState extends AttendanceState {
  final String message;
  const AttendanceFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
