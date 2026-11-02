import '../../domain/entities/attendance_policy_entity.dart';

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

class AttendancePolicyModel extends AttendancePolicyEntity {
  const AttendancePolicyModel({
    required super.id,
    required super.code,
    required super.name,
    required super.kind,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.radius,
    required super.timezone,
    required super.workStart,
    required super.workEnd,
    required super.active,
    required super.allowAnyLocation,
  });

  factory AttendancePolicyModel.fromJson(Map<String, dynamic> json) {
    return AttendancePolicyModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['locationName']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      radius: _parseDouble(json['radius']),
      timezone: json['timezone']?.toString() ?? '',
      workStart: json['workStart']?.toString() ?? '',
      workEnd: json['workEnd']?.toString() ?? '',
      active: json.containsKey('active') ? _parseBool(json['active']) : true,
      allowAnyLocation: _parseBool(json['allowAnyLocation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'kind': kind,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'timezone': timezone,
      'workStart': workStart,
      'workEnd': workEnd,
      'active': active,
      'allowAnyLocation': allowAnyLocation,
    };
  }

  AttendancePolicyModel copyWith({
    String? id,
    String? code,
    String? name,
    String? kind,
    String? address,
    double? latitude,
    double? longitude,
    double? radius,
    String? timezone,
    String? workStart,
    String? workEnd,
    bool? active,
    bool? allowAnyLocation,
  }) {
    return AttendancePolicyModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      timezone: timezone ?? this.timezone,
      workStart: workStart ?? this.workStart,
      workEnd: workEnd ?? this.workEnd,
      active: active ?? this.active,
      allowAnyLocation: allowAnyLocation ?? this.allowAnyLocation,
    );
  }
}
