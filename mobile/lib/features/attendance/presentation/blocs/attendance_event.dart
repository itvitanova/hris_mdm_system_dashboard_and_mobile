import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendancePunchRequested extends AttendanceEvent {
  final String type;
  final XFile photo;
  final String earlyReason;

  const AttendancePunchRequested({
    required this.type,
    required this.photo,
    this.earlyReason = '',
  });

  @override
  List<Object?> get props => [type, photo, earlyReason];
}

class AttendanceEnrollRequested extends AttendanceEvent {
  final String employeeId;
  final XFile photo;

  const AttendanceEnrollRequested({
    required this.employeeId,
    required this.photo,
  });

  @override
  List<Object?> get props => [employeeId, photo];
}
