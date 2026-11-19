import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/widgets/core_widgets.dart';
import 'package:mdm_hris/core/workspace.dart';
import '../widgets/calendar/calendar_app_bar.dart';
import '../widgets/calendar/calendar_executive_card.dart';
import '../widgets/calendar/calendar_monthly_birthdays_list.dart';
import '../widgets/calendar/calendar_query_helper.dart';
import '../widgets/calendar/calendar_selected_day_birthdays.dart';

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

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayBirthdays = CalendarQueryHelper.birthdaysOnDate(
      workspace: widget.workspace,
      entries: entries,
      birthdays: birthdays,
      day: selected,
    );
    final monthlyBirthdays = CalendarQueryHelper.birthdaysInMonth(
      workspace: widget.workspace,
      entries: entries,
      targetMonth: month,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CalendarAppBar(onRefresh: load),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          color: const Color(0xFF0D9488),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
              CalendarExecutiveCard(
                selected: selected,
                month: month,
                today: today,
                loading: loading,
                workspace: widget.workspace,
                entries: entries,
                birthdays: birthdays,
                onSelectDate: (d) => setState(() => selected = d),
                onSelectPreset: _selectPreset,
                onMoveMonth: move,
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
              CalendarSelectedDayBirthdays(
                selected: selected,
                todayBirthdays: todayBirthdays,
                loading: loading,
                hasError: error != null,
              ),
              CalendarMonthlyBirthdaysList(
                month: month,
                selected: selected,
                monthlyBirthdays: monthlyBirthdays,
                loading: loading,
                hasError: error != null,
                onSelectDate: (d) => setState(() => selected = d),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef BirthdayCalendarScreen = LeaveCalendarScreen;
typedef LeaveCalendarPage = LeaveCalendarScreen;
