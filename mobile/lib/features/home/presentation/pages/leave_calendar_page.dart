import 'package:flutter/material.dart';
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
      final result = await widget.api.getList(
        '/leave-calendar?month=${dateOnly(month).substring(0, 7)}',
      );
      if (mounted && requestEpoch == epoch) {
        setState(() => entries = result);
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
    final weekdayStr = _dayNamesLong[date.weekday];
    final monthStr = _monthNames[date.month - 1];
    return '$weekdayStr, ${date.day} $monthStr ${date.year}';
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '??';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  int _calculateDurationDays(String startStr, String endStr) {
    final start = DateTime.tryParse(startStr);
    final end = DateTime.tryParse(endStr);
    if (start == null || end == null) return 1;
    final diff = end.difference(start).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  String _formatFriendlyDateRange(String startStr, String endStr) {
    final start = DateTime.tryParse(startStr);
    final end = DateTime.tryParse(endStr);
    if (start == null) return '$startStr – $endStr';

    const shortMonths = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    if (end == null || startStr == endStr) {
      return '${start.day} ${shortMonths[start.month]} ${start.year}';
    }

    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${start.day} – ${end.day} ${shortMonths[start.month]} ${start.year}';
      }
      return '${start.day} ${shortMonths[start.month]} – ${end.day} ${shortMonths[end.month]} ${start.year}';
    }
    return '${start.day} ${shortMonths[start.month]} ${start.year} – ${end.day} ${shortMonths[end.month]} ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayRows = onDate(selected);
    final locationName = text(
      widget.workspace.attendancePolicy,
      'name',
      text(widget.workspace.settings, 'locationName', 'Kantor Pusat'),
    );

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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Kalender Cuti',
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
              'Jadwal & Rekan Cuti Kantor',
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
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 19,
                  color: Color(0xFF334155),
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
              // ==================== 0. HEADER INFO KANTOR / LOKASI ====================
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCCFBF1)),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        size: 16,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Penugasan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            locationName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
                                'PILIH TANGGAL REVIU',
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
                              const SizedBox(width: 8),
                              _buildPresetChip(
                                label: 'Akhir Bulan',
                                isSelected: _isSameDay(
                                  selected,
                                  DateTime(
                                    month.year,
                                    month.month,
                                    DateUtils.getDaysInMonth(
                                      month.year,
                                      month.month,
                                    ),
                                  ),
                                ),
                                onTap: () => _selectPreset(
                                  DateTime(
                                    month.year,
                                    month.month,
                                    DateUtils.getDaysInMonth(
                                      month.year,
                                      month.month,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 14),

                        // 1.3 Month Navigator Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
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
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCircleNavButton(
                                  icon: Icons.chevron_left_rounded,
                                  tooltip: 'Bulan sebelumnya',
                                  onTap: () => move(-1),
                                ),
                                const SizedBox(width: 8),
                                _buildCircleNavButton(
                                  icon: Icons.chevron_right_rounded,
                                  tooltip: 'Bulan berikutnya',
                                  onTap: () => move(1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 1.4 Days of Week Header
                        Row(
                          children: _dayNames.map((d) {
                            return Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
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
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Expanded(
                              child: Text(
                                'Ada rekan kerja yang cuti',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
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
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Coba lagi muat data cuti'),
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // ==================== 2. SEKSI DAFTAR REKAN CUTI ====================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFCCFBF1),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 15,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cuti pada ${selected.day} ${_monthNames[selected.month - 1]}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
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
                        color: todayRows.isNotEmpty
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: todayRows.isNotEmpty
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${todayRows.length} Cuti',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: todayRows.isNotEmpty
                              ? const Color(0xFF15803D)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Hanya menampilkan cuti yang telah disetujui. Alasan dan dokumen pribadi dirahasiakan.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),

              // ==================== 3. KARTU DETAIL REKAN CUTI ====================
              if (!loading && error == null && todayRows.isEmpty)
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
                  child: const Column(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 36,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Semua Rekan Kantor Hadir',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Tidak ada rekan satu lokasi yang cuti pada tanggal ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

              for (final entry in todayRows) ...[
                Builder(
                  builder: (context) {
                    final startDateStr = text(entry, 'startDate');
                    final endDateStr = text(entry, 'endDate');
                    final durationDays = _calculateDurationDays(startDateStr, endDateStr);
                    final formattedDateRange = _formatFriendlyDateRange(startDateStr, endDateStr);
                    final department = text(entry, 'department', 'Divisi');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Profil Karyawan & Durasi (Simetris Sejajar Tengah)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Squircle Avatar 42x42 dengan Status Dot
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDFA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFCCFBF1),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(text(entry, 'name')),
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F766E),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Nama, Durasi Cuti, & Departemen
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Baris Nama + Durasi Cuti (Berdampingan rapi tanpa space berlebih)
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          text(entry, 'name'),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFFBBF7D0),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 5,
                                                height: 5,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF15803D),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4.5),
                                              Text(
                                                '$durationDays Hari',
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF15803D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        department,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 11),

                          // 2. Rentang Tanggal (Soft Slate Container)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 14,
                                  color: Color(0xFF0D9488),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    formattedDateRange,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : const Color(0xFFE2E8F0),
            width: 1.1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleNavButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
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
        // Tanggal bulan sebelumnya (Muted Zinc)
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
        // Tanggal bulan aktif
        final dayNum = i - startingWeekday + 1;
        final cellDate = DateTime(month.year, month.month, dayNum);
        final isSelected = _isSameDay(cellDate, selected);
        final isToday = _isSameDay(cellDate, today);
        final count = onDate(cellDate).length;

        dayWidgets.add(
          _buildDayCell(
            text: '$dayNum',
            date: cellDate,
            isCurrentMonth: true,
            isSelected: isSelected,
            isToday: isToday,
            count: count,
            onTap: () {
              setState(() {
                selected = cellDate;
              });
            },
          ),
        );
      } else {
        // Tanggal bulan berikutnya (Muted Zinc)
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
          ? '${date.day} ${_monthNames[month.month - 1]} ${month.year}, $count rekan cuti'
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
                    : (count > 0
                        ? const Color(0xFFF0FDF4)
                        : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? null
                : isToday
                    ? Border.all(color: const Color(0xFF0D9488), width: 1.2)
                    : (count > 0
                        ? Border.all(
                            color: const Color(0xFFBBF7D0),
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
                          : (count > 0 ? FontWeight.w600 : FontWeight.w500),
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFF0D9488)
                              : (count > 0
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 4,
                child: count > 0
                    ? Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      )
                    : (isToday && !isSelected
                        ? Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D9488),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null),
              ),
            ],
          ),
        ),
      ),
    );

    return cellWidget;
  }
}

typedef LeaveCalendarPage = LeaveCalendarScreen;
