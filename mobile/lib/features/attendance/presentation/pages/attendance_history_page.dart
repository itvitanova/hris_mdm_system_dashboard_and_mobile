import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../widgets/attendance_detail_modal.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../root/presentation/widgets/language_swap_button.dart';
import '../widgets/attendance_daily_card.dart';
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
    this.initialLanguage = AppLanguage.id,
  });

  final ApiClient api;
  final Workspace workspace;
  final AppLanguage initialLanguage;

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  late Workspace _workspace = widget.workspace;
  late AppLanguage _currentLanguage = widget.initialLanguage != AppLanguage.id
      ? widget.initialLanguage
      : AppLanguageController.currentLanguage;
  bool _isRefreshing = false;

  // Pagination state
  static const int _itemsPerPage = 5;
  int _currentPage = 1;

  // Filter state persis desain referensi
  MonthEnum? _monthSelected;
  AttendanceStatType? _attendanceSelected;
  late int _yearsSelected;
  late final List<int> _listYears;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage != AppLanguage.id
        ? widget.initialLanguage
        : AppLanguageController.currentLanguage;
    AppLanguageController.instance.addListener(_onGlobalLanguageChanged);
    _yearsSelected = DateTime.now().year;
    _listYears = List.generate(4, (index) => DateTime.now().year - index);
  }

  void _onGlobalLanguageChanged() {
    if (mounted && _currentLanguage != AppLanguageController.currentLanguage) {
      setState(() {
        _currentLanguage = AppLanguageController.currentLanguage;
      });
    }
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_onGlobalLanguageChanged);
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final updated = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          _workspace = updated;
          _currentPage = 1;
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
    return List<Map<String, dynamic>>.from(mine);
  }

  /// Modal detail kehadiran lengkap dengan informasi verifikasi MDM
  void _openAttendanceDetailModal(
      BuildContext context, Map<String, dynamic> raw) {
    showAttendanceDetailModal(context, raw, language: _currentLanguage);
  }

  /// Ekstraksi string tanggal presensi dari berbagai kemungkinan key API/lokal
  String _extractRawDate(Map<String, dynamic> r) {
    for (final key in ['date', 'attendanceDate', 'checkIn', 'createdAt']) {
      final val = text(r, key, '').trim();
      if (val.isNotEmpty && val != '—' && val != '-') {
        return val;
      }
    }
    return '';
  }

  /// Cek kecocokan tahun dan bulan pada tanggal presensi
  bool _matchesPeriod(String rawDate, int year, MonthEnum? month) {
    if (rawDate.isEmpty) return false;
    final parsed = DateTime.tryParse(rawDate);
    if (parsed != null) {
      if (parsed.year != year) return false;
      if (month != null && parsed.month != (month.index + 1)) return false;
      return true;
    }
    if (!rawDate.startsWith('$year')) return false;
    if (month != null) {
      final prefix = '$year-${(month.index + 1).toString().padLeft(2, '0')}';
      if (!rawDate.startsWith(prefix)) return false;
    }
    return true;
  }

  List<int> _calculateVisiblePages(int current, int total) {
    if (total <= 5) {
      return List.generate(total, (i) => i + 1);
    }
    int start = current - 2;
    int end = current + 2;
    if (start < 1) {
      start = 1;
      end = 5;
    } else if (end > total) {
      end = total;
      start = total - 4;
    }
    return List.generate(end - start + 1, (i) => start + i);
  }

  Widget _buildPaginationBar(
    int currentPage,
    int totalPages,
    int startIndex,
    int endIndex,
    int totalItems,
  ) {
    final hasPrev = currentPage > 1;
    final hasNext = currentPage < totalPages;
    final visiblePages = _calculateVisiblePages(currentPage, totalPages);
    final isEn = _currentLanguage == AppLanguage.en;

    return Container(
      key: const ValueKey('pagination_bar'),
      margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Teks Info di Atas (Halaman X dari Y & Menampilkan A-B dari N)
          Text(
            isEn
                ? 'Page $currentPage of $totalPages'
                : 'Halaman $currentPage dari $totalPages',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            totalItems == 0
                ? (isEn
                    ? 'No attendance records'
                    : 'Tidak ada catatan kehadiran')
                : (isEn
                    ? 'Showing ${startIndex + 1}\u2013$endIndex of $totalItems attendance records'
                    : 'Menampilkan ${startIndex + 1}\u2013$endIndex dari $totalItems catatan kehadiran'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 10.h),

          // 2. Row Pagination Tombol Angka: [<] [1] [2] [3] [>]
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Panah Kiri (<)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_prev_btn'),
                  onTap: hasPrev
                      ? () => setState(() => _currentPage = currentPage - 1)
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasPrev
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasPrev
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      UIcons.regularRounded.angle_small_left,
                      size: 20.sp,
                      color: hasPrev
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Kotak-Kotak Angka Halaman
              ...visiblePages.map((page) {
                final isActive = page == currentPage;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isActive
                          ? null
                          : () => setState(() => _currentPage = page),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF0D9488)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF0D9488)
                                : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5.sp,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(width: 6.w),

              // Tombol Panah Kanan (>)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_next_btn'),
                  onTap: hasNext
                      ? () => setState(() => _currentPage = currentPage + 1)
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasNext
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasNext
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      UIcons.regularRounded.angle_small_right,
                      size: 20.sp,
                      color: hasNext
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allRawAttendance = _getAttendanceRawList();

    // 1. Hitung ringkasan statistik (Sudah Absen, Tepat Waktu, Terlambat, Belum Absen)
    // Dihitung berdasarkan tahun dan bulan yang dipilih
    final periodFiltered = allRawAttendance.where((r) {
      final d = _extractRawDate(r);
      return _matchesPeriod(d, _yearsSelected, _monthSelected);
    }).toList();

    int countSudahAbsen = 0;
    int countTepatWaktu = 0;
    int countTerlambat = 0;
    int countBelumAbsen = 0;

    for (final r in periodFiltered) {
      final s = text(r, 'status').toLowerCase();
      final lateMin = (r['lateMinutes'] as num?)?.toInt() ?? 0;
      final isLate = (r['isLate'] == true) ||
          lateMin > 0 ||
          s == 'terlambat' ||
          s == 'telat' ||
          s == 'late' ||
          s.contains('terlambat') ||
          s.contains('telat');
      final checkIn = text(r, 'checkIn', '').trim();
      final checkOut = text(r, 'checkOut', '').trim();
      final hasCheckIn =
          checkIn.isNotEmpty && checkIn != '—' && checkIn != '-';
      final hasCheckOut =
          checkOut.isNotEmpty && checkOut != '—' && checkOut != '-';

      final isAttended = hasCheckIn ||
          hasCheckOut ||
          isLate ||
          s == 'hadir' ||
          s == 'terlambat' ||
          s == 'telat' ||
          s == 'late' ||
          s.contains('hadir');

      if (isAttended) {
        countSudahAbsen++;
        if (isLate) {
          countTerlambat++;
        } else {
          countTepatWaktu++;
        }
      } else {
        countBelumAbsen++;
      }
    }

    // 2. Terapkan filter status pada daftar catatan harian
    List<Map<String, dynamic>> displayedDailyRecords = List.from(periodFiltered);

    if (_attendanceSelected != null) {
      displayedDailyRecords = displayedDailyRecords.where((r) {
        final s = text(r, 'status').toLowerCase();
        final lateMin = (r['lateMinutes'] as num?)?.toInt() ?? 0;
        final isLate = (r['isLate'] == true) ||
            lateMin > 0 ||
            s == 'terlambat' ||
            s == 'telat' ||
            s == 'late' ||
            s.contains('terlambat') ||
            s.contains('telat');
        final checkIn = text(r, 'checkIn', '').trim();
        final checkOut = text(r, 'checkOut', '').trim();
        final hasCheckIn =
            checkIn.isNotEmpty && checkIn != '—' && checkIn != '-';
        final hasCheckOut =
            checkOut.isNotEmpty && checkOut != '—' && checkOut != '-';

        final isAttended = hasCheckIn ||
            hasCheckOut ||
            isLate ||
            s == 'hadir' ||
            s == 'terlambat' ||
            s == 'telat' ||
            s == 'late' ||
            s.contains('hadir');

        switch (_attendanceSelected!) {
          case AttendanceStatType.sudahAbsen:
            return isAttended;
          case AttendanceStatType.tepatWaktu:
            return isAttended && !isLate;
          case AttendanceStatType.terlambat:
            return isAttended && isLate;
          case AttendanceStatType.belumAbsen:
            return !isAttended;
        }
      }).toList();
    }

    final totalItems = displayedDailyRecords.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 99999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final paginatedItems = displayedDailyRecords.isEmpty
        ? <Map<String, dynamic>>[]
        : displayedDailyRecords.sublist(startIndex, endIndex);

    final policy = _workspace.attendancePolicy;
    final policyName = text(policy, 'name', 'Kantor Pusat MDM');
    final isDemo = _workspace.data['demo'] == true;
    final isEn = _currentLanguage == AppLanguage.en;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        leading: IconButton(
          icon: Icon(
            UIcons.regularRounded.angle_small_left,
            color: const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEn ? 'Attendance History' : 'Riwayat Kehadiran',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              isEn
                  ? 'Presence & Location Verification'
                  : 'Presensi & Verifikasi Lokasi',
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
                        UIcons.regularRounded.marker,
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
                                      UIcons.regularRounded.shield_check,
                                      size: 10.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      isEn
                                          ? 'Location & Face'
                                          : 'Lokasi & Wajah',
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
                            isEn
                                ? 'Radius and time zone follow assignment. Coordinates saved automatically.'
                                : 'Radius dan zona waktu mengikuti penugasan. Koordinat tersimpan otomatis.',
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
                        UIcons.regularRounded.info,
                        size: 13.sp,
                        color: const Color(0xFF2563EB),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'Initial history is sample data. "Sample" label does not indicate real verification.'
                              : 'Riwayat awal adalah data contoh. Label "Contoh" tidak menunjukkan verifikasi nyata.',
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
                      language: _currentLanguage,
                      isSelected:
                          _attendanceSelected == AttendanceStatType.sudahAbsen,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.sudahAbsen
                                  ? null
                                  : AttendanceStatType.sudahAbsen;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AttendanceStatCard(
                      type: AttendanceStatType.tepatWaktu,
                      count: countTepatWaktu,
                      language: _currentLanguage,
                      isSelected:
                          _attendanceSelected == AttendanceStatType.tepatWaktu,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.tepatWaktu
                                  ? null
                                  : AttendanceStatType.tepatWaktu;
                          _currentPage = 1;
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
                      language: _currentLanguage,
                      isSelected:
                          _attendanceSelected == AttendanceStatType.terlambat,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.terlambat
                                  ? null
                                  : AttendanceStatType.terlambat;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AttendanceStatCard(
                      type: AttendanceStatType.belumAbsen,
                      count: countBelumAbsen,
                      language: _currentLanguage,
                      isSelected:
                          _attendanceSelected == AttendanceStatType.belumAbsen,
                      onTap: () {
                        setState(() {
                          _attendanceSelected =
                              _attendanceSelected == AttendanceStatType.belumAbsen
                                  ? null
                                  : AttendanceStatType.belumAbsen;
                          _currentPage = 1;
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
                        '${isEn ? "Attendance History" : "Riwayat Absensi"}${_attendanceSelected != null ? " - ${_attendanceSelected!.getLabel(_currentLanguage)}" : ""}${_monthSelected != null ? " - ${_monthSelected!.getName(_currentLanguage)}" : ""} $_yearsSelected',
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
                            language: _currentLanguage,
                            onChanged: (val) {
                              setState(() {
                                _monthSelected = val;
                                _currentPage = 1;
                              });
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
                              setState(() {
                                _yearsSelected = val ?? DateTime.now().year;
                                _currentPage = 1;
                              });
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
                            language: _currentLanguage,
                            onChanged: (val) {
                              setState(() {
                                _attendanceSelected = val;
                                _currentPage = 1;
                              });
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
                                  _currentPage = 1;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    UIcons.regularRounded.refresh,
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
              if (displayedDailyRecords.isEmpty)
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
                          UIcons.regularRounded.calendar,
                          size: 24.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        isEn
                            ? 'No Attendance Records Yet'
                            : 'Belum Ada Catatan Kehadiran',
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
                        isEn
                            ? 'Attendance records will be automatically logged after checking in or out.'
                            : 'Catatan kehadiran akan otomatis tercatat setelah melakukan absensi masuk atau pulang.',
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
              else ...[
                ...paginatedItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rawRecord = entry.value;
                  final isHighlighted = index == 0 &&
                      currentPage == 1 &&
                      _monthSelected == null &&
                      _attendanceSelected == null;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: AttendanceDailyCard(
                      key: ValueKey(
                        'att_daily_${rawRecord['id'] ?? index}_${_extractRawDate(rawRecord)}',
                      ),
                      raw: rawRecord,
                      isHighlighted: isHighlighted,
                      language: _currentLanguage,
                      onTap: () {
                        _openAttendanceDetailModal(context, rawRecord);
                      },
                    ),
                  );
                }),
                _buildPaginationBar(
                  currentPage,
                  totalPages,
                  startIndex,
                  endIndex,
                  totalItems,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
