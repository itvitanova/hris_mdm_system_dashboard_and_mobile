import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../widgets/attendance_detail_modal.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../root/presentation/widgets/dashboard_attendance_card.dart';
import '../widgets/attendance_stat_card.dart';
import '../widgets/filter_dropdowns.dart';

/// Halaman Riwayat Kehadiran (View All Attendance)
/// Mengadopsi visual style corporate teal (Stat Cards 2 kolom, Subtitle Banner,
/// Toolbar Filter 2 Baris persis desain referensi mobile),
/// serta diselaraskan dengan verifikasi data & kebijakan web MDM
/// (Lokasi Penugasan HQ/Service Point, Verifikasi Wajah, Radius Jarak, Pulang Awal, dan Peta).
class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({
    super.key,
    required this.api,
    required this.workspace,
  });

  final ApiClient api;
  final Workspace workspace;

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  late Workspace _workspace = widget.workspace;
  bool _isRefreshing = false;

  // Filter state persis desain referensi
  MonthEnum? _monthSelected;
  AttendanceStatType? _attendanceSelected;
  late int _yearsSelected;
  late final List<int> _listYears;

  @override
  void initState() {
    super.initState();
    _yearsSelected = DateTime.now().year;
    _listYears = List.generate(4, (index) => DateTime.now().year - index);
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final updated = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          _workspace = updated;
        });
      }
    } catch (_) {
      // Tetap gunakan data lama jika jaringan bermasalah
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  /// Ekstraksi seluruh list absensi karyawan saat ini
  List<Map<String, dynamic>> _getAttendanceRawList() {
    final mine = _workspace.mine('attendance');
    if (mine.isNotEmpty) {
      return List<Map<String, dynamic>>.from(mine);
    }

    // Jika akun belum memiliki absensi dan workspace dalam mode demo,
    // sediakan mock data realistis MDM agar tampilan dan filter dapat diuji.
    final bool isDemo = _workspace.data['demo'] == true;
    if (isDemo || mine.isEmpty) {
      final policy = _workspace.attendancePolicy;
      final policyName = text(policy, 'name', 'Kantor Pusat MDM Jakarta');
      final lat = number(policy, 'latitude');
      final lng = number(policy, 'longitude');
      final now = DateTime.now();

      return [
        {
          'id': 'att-mock-today',
          'employeeId': text(_workspace.actor, 'employeeId'),
          'employeeName': text(_workspace.actor, 'name'),
          'date': DateFormat('yyyy-MM-dd').format(now),
          'checkIn': '${DateFormat('yyyy-MM-dd').format(now)}T08:24:10+07:00',
          'checkOut': '${DateFormat('yyyy-MM-dd').format(now)}T17:45:00+07:00',
          'status': 'Hadir',
          'lateMinutes': 0,
          'earlyDeparture': false,
          'distance': 18.5,
          'faceVerified': true,
          'checkInLocation': {
            'latitude': lat != 0 ? lat : -6.137607,
            'longitude': lng != 0 ? lng : 106.799707,
            'policy': {'name': policyName, 'allowAnyLocation': false},
          },
          'checkOutLocation': {
            'latitude': lat != 0 ? lat : -6.137607,
            'longitude': lng != 0 ? lng : 106.799707,
            'policy': {'name': policyName, 'allowAnyLocation': false},
          },
        },
        {
          'id': 'att-mock-yesterday',
          'employeeId': text(_workspace.actor, 'employeeId'),
          'employeeName': text(_workspace.actor, 'name'),
          'date': DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 1))),
          'checkIn':
              '${DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)))}T09:12:00+07:00',
          'checkOut':
              '${DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)))}T18:05:00+07:00',
          'status': 'Terlambat',
          'lateMinutes': 12,
          'earlyDeparture': false,
          'distance': 25.0,
          'faceVerified': true,
          'checkInLocation': {
            'latitude': lat != 0 ? lat : -6.137607,
            'longitude': lng != 0 ? lng : 106.799707,
            'policy': {'name': policyName, 'allowAnyLocation': false},
          },
        },
        {
          'id': 'att-mock-2days-ago',
          'employeeId': text(_workspace.actor, 'employeeId'),
          'employeeName': text(_workspace.actor, 'name'),
          'date': DateFormat('yyyy-MM-dd')
              .format(now.subtract(const Duration(days: 2))),
          'checkIn':
              '${DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2)))}T08:30:00+07:00',
          'checkOut':
              '${DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2)))}T16:30:00+07:00',
          'status': 'Hadir',
          'lateMinutes': 0,
          'earlyDeparture': true,
          'earlyMinutes': 60,
          'earlyReason': 'Izin urusan keluarga mendesak',
          'distance': 15.0,
          'faceVerified': true,
          'checkInLocation': {
            'latitude': lat != 0 ? lat : -6.137607,
            'longitude': lng != 0 ? lng : 106.799707,
            'policy': {'name': policyName, 'allowAnyLocation': false},
          },
          'checkOutLocation': {
            'latitude': lat != 0 ? lat : -6.137607,
            'longitude': lng != 0 ? lng : 106.799707,
            'policy': {'name': policyName, 'allowAnyLocation': false},
          },
        },
      ];
    }

    return [];
  }

  /// Modal detail kehadiran lengkap dengan informasi verifikasi MDM
  void _openAttendanceDetailModal(
      BuildContext context, Map<String, dynamic> raw) {
    showAttendanceDetailModal(context, raw);
  }

  @override
  Widget build(BuildContext context) {
    final allRawAttendance = _getAttendanceRawList();

    // 1. Hitung ringkasan statistik (Sudah Absen, Tepat Waktu, Terlambat, Belum Absen)
    // Dihitung berdasarkan tahun yang dipilih
    final yearFiltered = allRawAttendance.where((r) {
      final d = text(r, 'date');
      return d.startsWith('$_yearsSelected');
    }).toList();

    int countSudahAbsen = 0;
    int countTepatWaktu = 0;
    int countTerlambat = 0;
    int countBelumAbsen = 0;

    for (final r in yearFiltered) {
      final s = text(r, 'status').toLowerCase();
      final lateMin = (r['lateMinutes'] as num?)?.toInt() ?? 0;
      final checkIn = text(r, 'checkIn', '').trim();
      final hasCheckIn =
          checkIn.isNotEmpty && checkIn != '—' && checkIn != '-';

      if (hasCheckIn || s == 'hadir' || s == 'terlambat') {
        countSudahAbsen++;
        if (lateMin > 0 || s == 'terlambat') {
          countTerlambat++;
        } else {
          countTepatWaktu++;
        }
      } else {
        countBelumAbsen++;
      }
    }

    // 2. Filter item untuk tampilan list
    final filteredRaw = allRawAttendance.where((r) {
      final d = text(r, 'date');
      if (!d.startsWith('$_yearsSelected')) return false;

      if (_monthSelected != null) {
        final monthPrefix =
            '$_yearsSelected-${(_monthSelected!.index + 1).toString().padLeft(2, '0')}';
        if (!d.startsWith(monthPrefix)) return false;
      }

      if (_attendanceSelected != null) {
        final s = text(r, 'status').toLowerCase();
        final lateMin = (r['lateMinutes'] as num?)?.toInt() ?? 0;
        final checkIn = text(r, 'checkIn', '').trim();
        final hasCheckIn =
            checkIn.isNotEmpty && checkIn != '—' && checkIn != '-';
        switch (_attendanceSelected!) {
          case AttendanceStatType.sudahAbsen:
            return hasCheckIn || s == 'hadir' || s == 'terlambat';
          case AttendanceStatType.tepatWaktu:
            return (hasCheckIn || s == 'hadir') &&
                lateMin == 0 &&
                s != 'terlambat';
          case AttendanceStatType.terlambat:
            return lateMin > 0 || s == 'terlambat';
          case AttendanceStatType.belumAbsen:
            return !hasCheckIn &&
                (s == 'alpha' ||
                    s == 'tidak hadir' ||
                    s.contains('absen') ||
                    s.isEmpty);
        }
      }

      return true;
    }).toList();

    final attendanceItems = DashboardAttendanceItem.fromAttendanceList(
      filteredRaw,
      treatLatestAsToday: _monthSelected == null && _attendanceSelected == null,
    );

    final policy = _workspace.attendancePolicy;
    final policyName = text(policy, 'name', 'Kantor Pusat MDM');
    final isDemo = _workspace.data['demo'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Riwayat Kehadiran',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Presensi & Verifikasi Lokasi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF0F766E),
          child: ListView(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 24.h),
            children: [
              // 1. Location Banner (Sesuai Web MDM)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFCCFBF1),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 20.sp,
                        color: AppColors.deepTeal,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  policyName,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 10.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Lokasi & Wajah',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Radius dan zona waktu mengikuti penugasan. Koordinat tersimpan otomatis.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5.sp,
                              color: const Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isDemo) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13.sp,
                        color: const Color(0xFF2563EB),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Riwayat awal adalah data contoh. Label "Contoh" tidak menunjukkan verifikasi nyata.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.sp,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 14.h),

              // 2. Summary Stat Cards (Grid 2 Kolom, 4 Status: Sudah Absen, Tepat Waktu, Terlambat, Belum Absen)
              Row(
                children: [
                  Expanded(
                    child: AttendanceStatCard(
                      type: AttendanceStatType.sudahAbsen,
                      count: countSudahAbsen,
                      isSelected:
                          _attendanceSelected == AttendanceStatType.sudahAbsen,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.sudahAbsen
                                  ? null
                                  : AttendanceStatType.sudahAbsen;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AttendanceStatCard(
                      type: AttendanceStatType.tepatWaktu,
                      count: countTepatWaktu,
                      isSelected:
                          _attendanceSelected == AttendanceStatType.tepatWaktu,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.tepatWaktu
                                  ? null
                                  : AttendanceStatType.tepatWaktu;
                        });
                      },
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
                      isSelected:
                          _attendanceSelected == AttendanceStatType.terlambat,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.terlambat
                                  ? null
                                  : AttendanceStatType.terlambat;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AttendanceStatCard(
                      type: AttendanceStatType.belumAbsen,
                      count: countBelumAbsen,
                      isSelected:
                          _attendanceSelected == AttendanceStatType.belumAbsen,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.belumAbsen
                                  ? null
                                  : AttendanceStatType.belumAbsen;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.w),

              // 3. Subtitle Banner Riwayat Absensi (Persis Desain Referensi)
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: const [AppShadows.shadow094],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3.5.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.deepTeal,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Riwayat Absensi${_attendanceSelected != null ? " - ${_attendanceSelected!.label}" : ""}${_monthSelected != null ? " - ${_monthSelected!.name}" : ""} $_yearsSelected',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.w),

              // 4. Pinned Filter Toolbar (Bulan, Tahun, Status, Reset persis desain referensi)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: const [AppShadows.shadow094],
                  color: AppColors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // === ROW 1: Month Dropdown + Year Dropdown ===
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: MonthFilterDropdown(
                            selected: _monthSelected,
                            onChanged: (val) {
                              setState(() => _monthSelected = val);
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: 110.w,
                          child: YearFilterDropdown(
                            selected: _yearsSelected,
                            years: _listYears,
                            onChanged: (val) {
                              setState(() =>
                                  _yearsSelected = val ?? DateTime.now().year);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.w),

                    // === ROW 2: Status Dropdown + Reset Button ===
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: StatusFilterDropdown(
                            selected: _attendanceSelected,
                            onChanged: (val) {
                              setState(() => _attendanceSelected = val);
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Reset Button (teal gradient)
                        Container(
                          width: 110.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.w),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.filterGradientStart,
                                AppColors.filterGradientEnd,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.w),
                              canRequestFocus: false,
                              onTap: () {
                                setState(() {
                                  _monthSelected = null;
                                  _attendanceSelected = null;
                                  _yearsSelected = DateTime.now().year;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 16.w,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // 5. Daftar Kartu Absensi atau Empty State
              if (attendanceItems.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 40.h,
                    horizontal: 20.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.event_busy_rounded,
                          size: 24.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Belum Ada Catatan Kehadiran',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Catatan kehadiran akan otomatis tercatat setelah melakukan absensi masuk atau pulang.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...attendanceItems.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: DashboardAttendanceCard(
                      key: ValueKey(
                          'att_history_${item.title}_${item.dateText}'),
                      item: item,
                      onTap: () {
                        if (item.rawData is Map) {
                          _openAttendanceDetailModal(
                            context,
                            Map<String, dynamic>.from(item.rawData as Map),
                          );
                        }
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
