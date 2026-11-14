import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';

class LeaveCalendarScreen extends StatefulWidget {
  const LeaveCalendarScreen({
    super.key,
    required this.api,
    required this.workspace,
  });

  final ApiClient api;
  final Workspace workspace;

  @override
  State<LeaveCalendarScreen> createState() => _LeaveCalendarState();
}

class _LeaveCalendarState extends State<LeaveCalendarScreen> {
  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _dayNames = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _dayNamesLong = [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  late DateTime selected;
  late DateTime month;
  List<Json> entries = [];
  List<Json> birthdays = [];
  bool loading = true;
  String? error;
  int epoch = 0;

  @override
  void initState() {
    super.initState();
    selected =
        DateTime.tryParse(text(widget.workspace.data, 'attendanceDate', '')) ??
        DateTime.now();
    month = DateTime(selected.year, selected.month, 1);
    load();
  }

  Future<void> load() async {
    final requestEpoch = ++epoch;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final monthStr = dateOnly(month).substring(0, 7);
      final results = await Future.wait([
        widget.api
            .getList('/leave-calendar?month=$monthStr')
            .catchError((_) => <Map<String, dynamic>>[]),
        widget.api
            .getList('/birthday-calendar?month=$monthStr')
            .catchError((_) => <Map<String, dynamic>>[]),
      ]);
      if (mounted && requestEpoch == epoch) {
        setState(() {
          entries = results[0];
          birthdays = results[1];
        });
      }
    } catch (e) {
      if (mounted && requestEpoch == epoch) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted && requestEpoch == epoch) {
        setState(() => loading = false);
      }
    }
  }

  List<Json> onDate(DateTime day) => entries
      .where(
        (e) =>
            text(e, 'startDate').compareTo(dateOnly(day)) <= 0 &&
            text(e, 'endDate').compareTo(dateOnly(day)) >= 0,
      )
      .toList();

  List<Json> birthdaysOnDate(DateTime day) {
    final d = dateOnly(day);
    final fromApi = birthdays.where((b) => text(b, 'date') == d).toList();
    final results = <Json>[...fromApi];

    final emps = widget.workspace.rows('employees');
    for (final emp in emps) {
      final bDate = text(emp, 'birthDate', '');
      if (bDate.length >= 10) {
        final m = int.tryParse(bDate.substring(5, 7));
        final dy = int.tryParse(bDate.substring(8, 10));
        if (m == day.month && dy == day.day) {
          results.add({
            'name': text(emp, 'name', 'Rekan Kerja'),
            'department': text(emp, 'department', ''),
            'position': text(emp, 'position', ''),
            'birthDate': bDate,
            'date': d,
          });
        }
      }
    }

    final leaveEntries = onDate(day);
    for (final le in leaveEntries) {
      final name = text(le, 'name', 'Rekan Kerja');
      if (!results.any((r) => text(r, 'name') == name)) {
        results.add({
          'name': name,
          'department': text(le, 'department', ''),
          'position': text(le, 'position', ''),
          'date': d,
        });
      }
    }
    return results;
  }

  List<Json> birthdaysInMonth(DateTime targetMonth) {
    final emps = widget.workspace.rows('employees');
    final results = <Json>[];
    for (final emp in emps) {
      final bDate = text(emp, 'birthDate', '');
      if (bDate.length >= 10) {
        final m = int.tryParse(bDate.substring(5, 7));
        if (m == targetMonth.month) {
          final dy = int.tryParse(bDate.substring(8, 10)) ?? 1;
          results.add({
            'name': text(emp, 'name', 'Rekan Kerja'),
            'department': text(emp, 'department', ''),
            'position': text(emp, 'position', ''),
            'birthDate': bDate,
            'day': dy,
          });
        }
      }
    }
    for (final le in entries) {
      final sDate = text(le, 'startDate', '');
      if (sDate.length >= 10) {
        final m = int.tryParse(sDate.substring(5, 7));
        if (m == targetMonth.month) {
          final dy = int.tryParse(sDate.substring(8, 10)) ?? 1;
          final name = text(le, 'name', 'Rekan Kerja');
          if (!results.any((r) => text(r, 'name') == name)) {
            results.add({
              'name': name,
              'department': text(le, 'department', ''),
              'position': text(le, 'position', ''),
              'day': dy,
            });
          }
        }
      }
    }
    results.sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
    return results;
  }

  void move(int offset) {
    setState(() {
      month = DateTime(month.year, month.month + offset, 1);
      selected = DateTime(month.year, month.month, 1);
      entries = [];
    });
    load();
  }

  void _selectPreset(DateTime date) {
    final targetMonth = DateTime(date.year, date.month, 1);
    final isDifferentMonth =
        targetMonth.year != month.year || targetMonth.month != month.month;

    setState(() {
      selected = date;
      if (isDifferentMonth) {
        month = targetMonth;
        entries = [];
      }
    });

    if (isDifferentMonth) {
      load();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDisplayDate(DateTime date) {
    final dayName = _dayNamesLong[date.weekday];
    final dayNum = date.day;
    final monthName = _monthNames[date.month - 1];
    final year = date.year;
    return '$dayName, $dayNum $monthName $year';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayBirthdays = birthdaysOnDate(selected);
    final monthlyBirthdays = birthdaysInMonth(month);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        titleSpacing: 0,
        centerTitle: false,
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
          children: const [
            Text(
              'Kalender Ulang Tahun',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 1.5),
            Text(
              'Jadwal Ulang Tahun Rekan Kerja',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: load,
                child: Icon(
                  UIcons.regularRounded.refresh,
                  size: 19,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          color: const Color(0xFF0D9488),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
              // ==================== 1. KARTU KALENDER EKSEKUTIF ====================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1.1 Header Bagian Atas: Kategori & Tanggal Terpilih
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'PILIH TANGGAL',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0D9488),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            if (loading)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0D9488),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Display Tanggal Terpilih
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatDisplayDate(selected),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 1.2 Quick Action Preset Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildPresetChip(
                                label: 'Hari Ini',
                                isSelected: _isSameDay(selected, today),
                                onTap: () => _selectPreset(today),
                              ),
                              const SizedBox(width: 8),
                              _buildPresetChip(
                                label: 'Awal Bulan',
                                isSelected: _isSameDay(
                                  selected,
                                  DateTime(month.year, month.month, 1),
                                ),
                                onTap: () => _selectPreset(
                                  DateTime(month.year, month.month, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 1.3 Baris Navigasi Bulan & Tahun
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMonthNavButton(
                                icon: UIcons.regularRounded.angle_small_left,
                                onTap: () => move(-1),
                              ),
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${_monthNames[month.month - 1]} ${month.year}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _buildMonthNavButton(
                                icon: UIcons.regularRounded.angle_small_right,
                                onTap: () => move(1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 1.4 Baris Header Nama Hari
                        Row(
                          children: _dayNames.map((d) {
                            final isWeekend = d == 'Sab' || d == 'Min';
                            return Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: isWeekend
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),

                        // 1.5 Calendar Days Grid
                        _buildCalendarGrid(today),

                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 10),

                        // 1.6 Legend Indicator Row
                        Wrap(
                          spacing: 14,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Ulang tahun rekan 🎂',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D9488),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Hari ini',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 14),
                ErrorNotice(error!),
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: load,
                    icon: Icon(UIcons.regularRounded.refresh, size: 16),
                    label: const Text('Coba lagi muat data'),
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // ==================== 2. SEKSI DAFTAR REKAN ULANG TAHUN ====================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      UIcons.regularRounded.cake_birthday,
                      size: 15,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ulang Tahun pada ${selected.day} ${_monthNames[selected.month - 1]}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: todayBirthdays.isNotEmpty
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: todayBirthdays.isNotEmpty
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${todayBirthdays.length} Rekan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: todayBirthdays.isNotEmpty
                              ? const Color(0xFFB45309)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Rekan kerja yang merayakan hari ulang tahun.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),

              // Kartu Detail Ulang Tahun Tanggal Terpilih
              if (!loading && error == null && todayBirthdays.isNotEmpty) ...[
                for (final b in todayBirthdays)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              UIcons.regularRounded.cake_birthday,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selamat Ulang Tahun! 🎂',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                text(b, 'name', 'Rekan Kerja'),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                              if (text(b, 'department', '').isNotEmpty)
                                Text(
                                  text(b, 'department', ''),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              if (!loading && error == null && todayBirthdays.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        UIcons.regularRounded.cake_birthday,
                        size: 36,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tidak Ada Ulang Tahun',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tidak ada rekan yang berulang tahun pada tanggal ${selected.day} ${_monthNames[selected.month - 1]}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

              // ==================== 3. SEMUA ULANG TAHUN BULAN INI ====================
              Builder(
                builder: (context) {
                  final otherMonthlyBirthdays = monthlyBirthdays
                      .where((b) => (b['day'] as int? ?? 0) != selected.day)
                      .toList();
                  if (loading || error != null || otherMonthlyBirthdays.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Icon(
                            UIcons.regularRounded.gift,
                            size: 16,
                            color: const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Ulang Tahun Lainnya (${_monthNames[month.month - 1]})',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${otherMonthlyBirthdays.length} Rekan',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (final b in otherMonthlyBirthdays)
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            final dayNum = b['day'] as int? ?? 1;
                            setState(() {
                              selected = DateTime(month.year, month.month, dayNum);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isSameDay(
                                  selected,
                                  DateTime(month.year, month.month, b['day'] as int? ?? 1),
                                )
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${b['day']} ${_monthNames[month.month - 1].substring(0, 3)}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        text(b, 'name', 'Rekan Kerja'),
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      if (text(b, 'department', '').isNotEmpty)
                                        Text(
                                          text(b, 'department', ''),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  UIcons.regularRounded.cake_birthday,
                                  size: 16,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D9488)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCCFBF1)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF0D9488),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime today) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final startingWeekday = (firstDayOfMonth.weekday - 1) % 7; // 0 for Senin

    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final daysInPrevMonth =
        DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final totalCells = (startingWeekday + daysInMonth > 35) ? 42 : 35;
    final dayWidgets = <Widget>[];

    for (int i = 0; i < totalCells; i++) {
      if (i < startingWeekday) {
        final dayNum = daysInPrevMonth - (startingWeekday - 1) + i;
        dayWidgets.add(
          _buildDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            count: 0,
            onTap: null,
          ),
        );
      } else if (i < startingWeekday + daysInMonth) {
        final dayNum = i - startingWeekday + 1;
        final cellDate = DateTime(month.year, month.month, dayNum);
        final isSelected = _isSameDay(cellDate, selected);
        final isToday = _isSameDay(cellDate, today);
        final bDays = birthdaysOnDate(cellDate);
        final count = bDays.length;
        final hasBirthday = count > 0;

        dayWidgets.add(
          _buildDayCell(
            text: '$dayNum',
            date: cellDate,
            isCurrentMonth: true,
            isSelected: isSelected,
            isToday: isToday,
            count: count,
            hasBirthday: hasBirthday,
            onTap: () {
              setState(() {
                selected = cellDate;
              });
            },
          ),
        );
      } else {
        final dayNum = i - (startingWeekday + daysInMonth) + 1;
        dayWidgets.add(
          _buildDayCell(
            text: '$dayNum',
            isCurrentMonth: false,
            isSelected: false,
            isToday: false,
            count: 0,
            onTap: null,
          ),
        );
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell({
    required String text,
    DateTime? date,
    required bool isCurrentMonth,
    required bool isSelected,
    required bool isToday,
    required int count,
    bool hasBirthday = false,
    required VoidCallback? onTap,
  }) {
    if (!isCurrentMonth) {
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ),
      );
    }

    final cellWidget = Semantics(
      label: date != null
          ? '${date.day} ${_monthNames[month.month - 1]} ${month.year}${hasBirthday ? ", $count rekan ulang tahun" : ""}'
          : text,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF14B8A6),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : isToday
                    ? const Color(0xFFF0FDFA)
                    : (hasBirthday
                        ? const Color(0xFFFFFBEB)
                        : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? null
                : isToday
                    ? Border.all(color: const Color(0xFF0D9488), width: 1.2)
                    : (hasBirthday
                        ? Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 0.8,
                          )
                        : null),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w700
                          : (hasBirthday ? FontWeight.w700 : FontWeight.w500),
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFF0D9488)
                              : (hasBirthday
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasBirthday)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (!hasBirthday && isToday && !isSelected)
                      Container(
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return cellWidget;
  }
}

typedef BirthdayCalendarScreen = LeaveCalendarScreen;
typedef LeaveCalendarPage = LeaveCalendarScreen;
