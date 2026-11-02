import 'package:equatable/equatable.dart';

class AttendancePolicyEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String kind;
  final String address;
  final double latitude;
  final double longitude;
  final double radius;
  final String timezone;
  final String workStart;
  final String workEnd;
  final bool active;
  final bool allowAnyLocation;

  const AttendancePolicyEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.kind,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.timezone,
    required this.workStart,
    required this.workEnd,
    required this.active,
    required this.allowAnyLocation,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    kind,
    address,
    latitude,
    longitude,
    radius,
    timezone,
    workStart,
    workEnd,
    active,
    allowAnyLocation,
  ];
}
