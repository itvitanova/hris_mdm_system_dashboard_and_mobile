import 'package:equatable/equatable.dart';
import 'attendance_policy_entity.dart';

class AttendanceLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double distance;
  final AttendancePolicyEntity? policy;

  const AttendanceLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.distance,
    this.policy,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, distance, policy];
}

class AttendanceEntity extends Equatable {
  final String id;
  final String employeeId;
  final String? employeeName;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double distance;
  final bool faceVerified;
  final bool earlyDeparture;
  final int earlyMinutes;
  final String? earlyReason;
  final String? scheduledEnd;
  final AttendanceLocationEntity? checkInLocation;
  final AttendanceLocationEntity? checkOutLocation;

  const AttendanceEntity({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.distance,
    required this.faceVerified,
    required this.earlyDeparture,
    required this.earlyMinutes,
    this.earlyReason,
    this.scheduledEnd,
    this.checkInLocation,
    this.checkOutLocation,
  });

  @override
  List<Object?> get props => [
    id,
    employeeId,
    employeeName,
    date,
    checkIn,
    checkOut,
    status,
    latitude,
    longitude,
    accuracy,
    distance,
    faceVerified,
    earlyDeparture,
    earlyMinutes,
    earlyReason,
    scheduledEnd,
    checkInLocation,
    checkOutLocation,
  ];
}
