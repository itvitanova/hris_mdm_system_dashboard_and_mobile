import 'package:intl/intl.dart';

typedef Json = Map<String, dynamic>;
String text(Json row, String key, [String fallback = '—']) =>
    row[key]?.toString().isNotEmpty == true ? row[key].toString() : fallback;
double number(Json row, String key) => (row[key] as num?)?.toDouble() ?? 0;
String rupiah(num value) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
).format(value);
String dateOnly(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
String timeLabel(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  return date == null ? '—' : DateFormat('HH:mm').format(date.toLocal());
}

class Workspace {
  Workspace(this.data);
  final Json data;
  Json get actor => Json.from((data['actor'] as Map?) ?? {});
  Json get settings => Json.from((data['settings'] as Map?) ?? {});
  Json get attendancePolicy => data['attendancePolicy'] is Map
      ? Json.from(data['attendancePolicy'])
      : {...settings, 'name': settings['locationName']};
  List<Json> rows(String key) => ((data[key] as List?) ?? []).cast<Json>();
  List<Json> mine(String key) =>
      rows(key).where((r) => r['employeeId'] == actor['employeeId']).toList();
  Json get employee => rows(
    'employees',
  ).firstWhere((e) => e['id'] == actor['employeeId'], orElse: () => {});
  bool get faceAvailable => data['faceAvailable'] == true;
}
