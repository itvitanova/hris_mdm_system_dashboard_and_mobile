import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import '../../data/datasources/attendance_service.dart';
import '../widgets/attendance/attendance_face_punch_card.dart';
import '../widgets/attendance/attendance_location_card.dart';
import '../widgets/attendance/attendance_map_launcher.dart';
import '../widgets/attendance/early_checkout_dialog.dart';
import '../widgets/daily_attendance.dart';
import 'auto_face_page.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    required this.api,
    required this.workspace,
  });
  final ApiClient api;
  final Workspace workspace;
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with WidgetsBindingObserver {
  late final service = AttendanceService(widget.api);
  Position? position;
  String? error;
  bool busy = false, locating = false, scanning = false;
  Timer? timer;
  Workspace? currentWorkspace;
  Workspace get workspace => currentWorkspace ?? widget.workspace;
  bool get available => currentWorkspace != null && workspace.faceAvailable && workspace.employee['faceEnrolled'] == true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(locate());
    timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!scanning &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(locate());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !scanning) unawaited(locate());
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> locate() async {
    if (locating) return;
    setState(() => locating = true);
    try {
      final latest = Workspace(await widget.api.workspace());
      if (!mounted) return;
      setState(() => currentWorkspace = latest);
      final next = await service.locate(
        onSample: (sample) {
          if (!mounted) return;
          setState(() {
            position = sample;
            error = null;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        position = next;
        error = locationError(next, latest.attendancePolicy);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          position = null;
          error = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> openMap(double latitude, double longitude) =>
      AttendanceMapLauncher.openMap(
        context: context,
        latitude: latitude,
        longitude: longitude,
      );

  Future<void> start() async {
    if (busy || locating || !available) return;
    setState(() => busy = true);
    try {
      await locate();
      if (!mounted || !available || error != null || position == null) return;
      final type = DailyAttendance(workspace).nextType;
      if (type == null) return;
      var earlyReason = '';
      final end = text(workspace.attendancePolicy, 'workEnd', '');
      final serverTime = text(workspace.data, 'serverTime', '');
      final early =
          type == 'out' &&
          end.isNotEmpty &&
          serverTime.length >= 16 &&
          serverTime.substring(11, 16).compareTo(end) < 0;
      if (early) {
        final reason = await EarlyCheckoutDialog.show(
          context: context,
          workEnd: end,
        );
        if (reason == null || !mounted) return;
        earlyReason = reason;
      }
      if (!mounted) return;
      scanning = true;
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AutoFaceScreen(
            title: type == 'in' ? 'Absensi Masuk' : 'Absensi Keluar',
            onCapture: (photo) =>
                service.punch(type, photo, earlyReason: earlyReason),
          ),
        ),
      );
      if (result == true && mounted) await locate();
    } finally {
      scanning = false;
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daily = DailyAttendance(workspace);
    final policy = workspace.attendancePolicy;
    final anywhere = policy['allowAnyLocation'] == true;
    final safe =
        currentWorkspace != null &&
        position != null &&
        locationError(position!, policy) == null;
    final distance = position == null
        ? null
        : Geolocator.distanceBetween(
            position!.latitude,
            position!.longitude,
            number(policy, 'latitude'),
            number(policy, 'longitude'),
          );
    final canPunch =
        !busy && !locating && available && safe && !daily.completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AttendanceLocationCard(
            policy: policy,
            position: position,
            locating: locating,
            safe: safe,
            distance: distance,
            error: error,
            anywhere: anywhere,
            onOpenMap: openMap,
          ),
          AttendanceFacePunchCard(
            daily: daily,
            available: available,
            canPunch: canPunch,
            onPunch: start,
          ),
          Text(
            anywhere
                ? 'Verifikasi wajah dan GPS tetap wajib untuk absensi.'
                : 'Wajah tidak cocok atau lokasi di luar radius: absensi ditolak.',
            style: const TextStyle(color: Color(0xFF52637A), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

typedef AttendancePage = AttendanceScreen;
