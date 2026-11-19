import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';
import '../attendance_stat_card.dart';

class AttendanceSummaryStatCards extends StatelessWidget {
  const AttendanceSummaryStatCards({
    super.key,
    required this.countSudahAbsen,
    required this.countTepatWaktu,
    required this.countTerlambat,
    required this.countBelumAbsen,
    required this.selectedType,
    required this.language,
    required this.onSelectType,
  });

  final int countSudahAbsen;
  final int countTepatWaktu;
  final int countTerlambat;
  final int countBelumAbsen;
  final AttendanceStatType? selectedType;
  final AppLanguage language;
  final ValueChanged<AttendanceStatType> onSelectType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AttendanceStatCard(
                type: AttendanceStatType.sudahAbsen,
                count: countSudahAbsen,
                language: language,
                isSelected: selectedType == AttendanceStatType.sudahAbsen,
                onTap: () => onSelectType(AttendanceStatType.sudahAbsen),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AttendanceStatCard(
                type: AttendanceStatType.tepatWaktu,
                count: countTepatWaktu,
                language: language,
                isSelected: selectedType == AttendanceStatType.tepatWaktu,
                onTap: () => onSelectType(AttendanceStatType.tepatWaktu),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: AttendanceStatCard(
                type: AttendanceStatType.terlambat,
                count: countTerlambat,
                language: language,
                isSelected: selectedType == AttendanceStatType.terlambat,
                onTap: () => onSelectType(AttendanceStatType.terlambat),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AttendanceStatCard(
                type: AttendanceStatType.belumAbsen,
                count: countBelumAbsen,
                language: language,
                isSelected: selectedType == AttendanceStatType.belumAbsen,
                onTap: () => onSelectType(AttendanceStatType.belumAbsen),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
