import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';
import '../widgets/attendance_detail_modal.dart';
import '../widgets/attendance_stat_card.dart';
import '../widgets/filter_dropdowns.dart';
import '../widgets/history/attendance_filter_toolbar.dart';
import '../widgets/history/attendance_history_app_bar.dart';
import '../widgets/history/attendance_history_query_helper.dart';
import '../widgets/history/attendance_history_records_section.dart';
import '../widgets/history/attendance_location_banner.dart';
import '../widgets/history/attendance_subtitle_banner.dart';
import '../widgets/history/attendance_summary_stat_cards.dart';

/// Halaman Riwayat Kehadiran (View All Attendance)
/// Menampilkan statistik kehadiran, filter periode/status, serta daftar catatan absensi.
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

  static const int _itemsPerPage = 5;
  int _currentPage = 1;

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

  void _openAttendanceDetailModal(
      BuildContext context, Map<String, dynamic> raw) {
    showAttendanceDetailModal(context, raw, language: _currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final allRawAttendance =
        List<Map<String, dynamic>>.from(_workspace.mine('attendance'));

    final periodFiltered = allRawAttendance.where((r) {
      final d = AttendanceHistoryQueryHelper.extractRawDate(r);
      return AttendanceHistoryQueryHelper.matchesPeriod(
          d, _yearsSelected, _monthSelected);
    }).toList();

    final stats = AttendanceHistoryQueryHelper.calculateStats(periodFiltered);

    final displayedDailyRecords = AttendanceHistoryQueryHelper.filterByStatus(
        periodFiltered, _attendanceSelected);

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
      appBar: AttendanceHistoryAppBar(
        isEn: isEn,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF0F766E),
          child: ListView(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 24.h),
            children: [
              AttendanceLocationBanner(
                policyName: policyName,
                isDemo: isDemo,
                language: _currentLanguage,
              ),
              SizedBox(height: 14.h),
              AttendanceSummaryStatCards(
                countSudahAbsen: stats.countSudahAbsen,
                countTepatWaktu: stats.countTepatWaktu,
                countTerlambat: stats.countTerlambat,
                countBelumAbsen: stats.countBelumAbsen,
                selectedType: _attendanceSelected,
                language: _currentLanguage,
                onSelectType: (type) => setState(() {
                  _attendanceSelected =
                      (_attendanceSelected == type) ? null : type;
                  _currentPage = 1;
                }),
              ),
              SizedBox(height: 14.h),
              AttendanceSubtitleBanner(
                attendanceSelected: _attendanceSelected,
                monthSelected: _monthSelected,
                yearsSelected: _yearsSelected,
                language: _currentLanguage,
              ),
              SizedBox(height: 10.h),
              AttendanceFilterToolbar(
                monthSelected: _monthSelected,
                attendanceSelected: _attendanceSelected,
                yearsSelected: _yearsSelected,
                listYears: _listYears,
                language: _currentLanguage,
                onMonthChanged: (m) => setState(() {
                  _monthSelected = m;
                  _currentPage = 1;
                }),
                onYearChanged: (y) => setState(() {
                  if (y != null) _yearsSelected = y;
                  _currentPage = 1;
                }),
                onStatusChanged: (s) => setState(() {
                  _attendanceSelected = s;
                  _currentPage = 1;
                }),
                onReset: () => setState(() {
                  _monthSelected = null;
                  _attendanceSelected = null;
                  _yearsSelected = DateTime.now().year;
                  _currentPage = 1;
                }),
              ),
              SizedBox(height: 14.h),
              AttendanceHistoryRecordsSection(
                displayedDailyRecords: displayedDailyRecords,
                paginatedItems: paginatedItems,
                currentPage: currentPage,
                totalPages: totalPages,
                startIndex: startIndex,
                endIndex: endIndex,
                totalItems: totalItems,
                monthSelected: _monthSelected,
                attendanceSelected: _attendanceSelected,
                language: _currentLanguage,
                onCardTap: (rawRecord) =>
                    _openAttendanceDetailModal(context, rawRecord),
                onPageChanged: (page) => setState(() => _currentPage = page),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
