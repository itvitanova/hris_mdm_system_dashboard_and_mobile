import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';

const _months = [
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
  late DateTime selected =
      DateTime.tryParse(text(widget.workspace.data, 'attendanceDate', '')) ??
      DateTime.now();
  late DateTime month = DateTime(selected.year, selected.month);
  List<Json> entries = [];
  bool loading = true;
  String? error;
  int epoch = 0;
  @override
  void initState() {
    super.initState();
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
      if (mounted && requestEpoch == epoch) setState(() => entries = result);
    } catch (e) {
      if (mounted && requestEpoch == epoch) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted && requestEpoch == epoch) setState(() => loading = false);
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
      month = DateTime(month.year, month.month + offset);
      selected = month;
      entries = [];
    });
    load();
  }

  @override
  Widget build(BuildContext context) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = month.weekday - 1;
    final todayRows = onDate(selected);
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender cuti')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeading(
                'Cuti rekan satu lokasi',
                subtitle: text(
                  widget.workspace.attendancePolicy,
                  'name',
                  text(widget.workspace.settings, 'locationName'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hanya cuti yang sudah disetujui. Alasan dan dokumen pribadi tidak ditampilkan.',
              ),
              const SizedBox(height: 20),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Bulan sebelumnya',
                          onPressed: () => move(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Text(
                            '${_months[month.month - 1]} ${month.year}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Bulan berikutnya',
                          onPressed: () => move(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final day in [
                          'Sen',
                          'Sel',
                          'Rab',
                          'Kam',
                          'Jum',
                          'Sab',
                          'Min',
                        ])
                          Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF52637A),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: offset + days,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 2,
                          ),
                      itemBuilder: (context, index) {
                        if (index < offset) return const SizedBox();
                        final date = DateTime(
                          month.year,
                          month.month,
                          index - offset + 1,
                        );
                        final count = onDate(date).length;
                        final active = dateOnly(date) == dateOnly(selected);
                        return Semantics(
                          label:
                              '${date.day} ${_months[month.month - 1]} ${month.year}, $count rekan cuti',
                          selected: active,
                          button: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => selected = date),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: active ? const Color(0xFFEAF1FF) : null,
                                borderRadius: BorderRadius.circular(12),
                                border: active
                                    ? Border.all(color: brand)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          fontWeight: active
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: const Color(0xFF182B49),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    height: 6,
                                    child: count > 0
                                        ? const CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Color(0xFF15803D),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xFF15803D),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ada rekan yang cuti',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (loading) const LinearProgressIndicator(),
              if (error != null) ...[
                ErrorNotice(error!),
                TextButton(onPressed: load, child: const Text('Coba lagi')),
              ],
              const SizedBox(height: 12),
              SectionHeading(
                'Cuti pada ${selected.day} ${_months[selected.month - 1]}',
              ),
              const SizedBox(height: 12),
              if (!loading && error == null && todayRows.isEmpty)
                const EmptyState(
                  'Tidak ada rekan satu lokasi yang cuti pada tanggal ini.',
                ),
              for (final entry in todayRows)
                Panel(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.event_available,
                        color: Color(0xFF15803D),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text(entry, 'name'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(text(entry, 'department')),
                            Text(
                              '${text(entry, 'startDate')} – ${text(entry, 'endDate')}',
                              style: const TextStyle(color: Color(0xFF52637A)),
                            ),
                          ],
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
  }
}

typedef LeaveCalendarPage = LeaveCalendarScreen;
