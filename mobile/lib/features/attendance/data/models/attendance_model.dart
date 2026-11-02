import '../../domain/entities/attendance_entity.dart';
import 'attendance_policy_model.dart';

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

bool _parseBool(dynamic value, [bool defaultValue = false]) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value.toString().toLowerCase() == 'true';
}

class AttendanceLocationModel extends AttendanceLocationEntity {
  const AttendanceLocationModel({
    required super.latitude,
    required super.longitude,
    required super.accuracy,
    required super.distance,
    super.policy,
  });

  factory AttendanceLocationModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLocationModel(
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      accuracy: _parseDouble(json['accuracy']),
      distance: _parseDouble(json['distance']),
      policy: json['policy'] is Map<String, dynamic>
          ? AttendancePolicyModel.fromJson(json['policy'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'distance': distance,
      if (policy != null)
        'policy': policy is AttendancePolicyModel
            ? (policy as AttendancePolicyModel).toJson()
            : {
                'id': policy!.id,
                'code': policy!.code,
                'name': policy!.name,
                'kind': policy!.kind,
                'address': policy!.address,
                'latitude': policy!.latitude,
                'longitude': policy!.longitude,
                'radius': policy!.radius,
                'timezone': policy!.timezone,
                'workStart': policy!.workStart,
                'workEnd': policy!.workEnd,
                'active': policy!.active,
                'allowAnyLocation': policy!.allowAnyLocation,
              },
    };
  }
}

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    super.employeeName,
    required super.date,
    super.checkIn,
    super.checkOut,
    required super.status,
    required super.latitude,
    required super.longitude,
    required super.accuracy,
    required super.distance,
    required super.faceVerified,
    required super.earlyDeparture,
    required super.earlyMinutes,
    super.earlyReason,
    super.scheduledEnd,
    super.checkInLocation,
    super.checkOutLocation,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString(),
      date: json['date']?.toString() ?? '',
      checkIn: json['checkIn']?.toString(),
      checkOut: json['checkOut']?.toString(),
      status: json['status']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      accuracy: _parseDouble(json['accuracy']),
      distance: _parseDouble(json['distance']),
      faceVerified: _parseBool(json['faceVerified']),
      earlyDeparture: _parseBool(json['earlyDeparture']),
      earlyMinutes: _parseInt(json['earlyMinutes']),
      earlyReason: json['earlyReason']?.toString(),
      scheduledEnd: json['scheduledEnd']?.toString(),
      checkInLocation: json['checkInLocation'] is Map<String, dynamic>
          ? AttendanceLocationModel.fromJson(
              json['checkInLocation'] as Map<String, dynamic>,
            )
          : null,
      checkOutLocation: json['checkOutLocation'] is Map<String, dynamic>
          ? AttendanceLocationModel.fromJson(
              json['checkOutLocation'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      if (employeeName != null) 'employeeName': employeeName,
      'date': date,
      if (checkIn != null) 'checkIn': checkIn,
      if (checkOut != null) 'checkOut': checkOut,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'distance': distance,
      'faceVerified': faceVerified,
      'earlyDeparture': earlyDeparture,
      'earlyMinutes': earlyMinutes,
      if (earlyReason != null) 'earlyReason': earlyReason,
      if (scheduledEnd != null) 'scheduledEnd': scheduledEnd,
      if (checkInLocation != null)
        'checkInLocation': checkInLocation is AttendanceLocationModel
            ? (checkInLocation as AttendanceLocationModel).toJson()
            : {
                'latitude': checkInLocation!.latitude,
                'longitude': checkInLocation!.longitude,
                'accuracy': checkInLocation!.accuracy,
                'distance': checkInLocation!.distance,
              },
      if (checkOutLocation != null)
        'checkOutLocation': checkOutLocation is AttendanceLocationModel
            ? (checkOutLocation as AttendanceLocationModel).toJson()
            : {
                'latitude': checkOutLocation!.latitude,
                'longitude': checkOutLocation!.longitude,
                'accuracy': checkOutLocation!.accuracy,
                'distance': checkOutLocation!.distance,
              },
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? date,
    String? checkIn,
    String? checkOut,
    String? status,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? distance,
    bool? faceVerified,
    bool? earlyDeparture,
    int? earlyMinutes,
    String? earlyReason,
    String? scheduledEnd,
    AttendanceLocationEntity? checkInLocation,
    AttendanceLocationEntity? checkOutLocation,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      distance: distance ?? this.distance,
      faceVerified: faceVerified ?? this.faceVerified,
      earlyDeparture: earlyDeparture ?? this.earlyDeparture,
      earlyMinutes: earlyMinutes ?? this.earlyMinutes,
      earlyReason: earlyReason ?? this.earlyReason,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
    );
  }
}
