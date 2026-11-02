import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../attendance_service.dart';
import 'auto_face_page.dart';
import '../widgets/daily_attendance.dart';

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
  bool get available =>
      currentWorkspace != null &&
      workspace.faceAvailable &&
      workspace.employee['faceEnrolled'] == true;

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
      // Dashboard changes must apply even when this screen or login stays open.
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

  Future<void> openMap(double latitude, double longitude) async {
    final url = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw ApiException('Google Maps tidak dapat dibuka.');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Maps tidak dapat dibuka.')),
        );
      }
    }
  }

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
        final note = TextEditingController();
        final noteForm = GlobalKey<FormState>();
        final reason = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: const Text('Pulang sebelum jadwal'),
            content: Form(
              key: noteForm,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal pulang lokasi Anda pukul $end. Alasan akan dicatat bersama absensi.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: note,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Alasan pulang lebih awal',
                      ),
                      validator: (v) => (v?.trim().length ?? 0) < 5
                          ? 'Isi alasan minimal 5 karakter'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  if (noteForm.currentState!.validate()) {
                    Navigator.pop(context, note.text.trim());
                  }
                },
                child: const Text('Lanjutkan absensi'),
              ),
            ],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 250));
        note.dispose();
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
      // Stay on this page and render the next action from the saved server row.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: brand, size: 30),
                const SizedBox(height: 12),
                Text(
                  text(policy, 'name', 'Lokasi belum ditentukan'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jadwal ${text(policy, "workStart")} – ${text(policy, "workEnd", "jam pulang belum diatur")}',
                  style: const TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  anywhere
                      ? 'Anda diizinkan absensi dari lokasi mana saja. GPS aktual masuk dan keluar tetap dicatat.'
                      : 'Lokasi diperiksa otomatis. Absensi hanya diterima dalam radius ${number(policy, 'radius').round()} meter dari lokasi penugasan.',
                ),
                const SizedBox(height: 16),
                if (locating) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    position != null && position!.accuracy > 50
                        ? 'Meningkatkan akurasi GPS… Tunggu sebentar di dekat jendela atau area terbuka.'
                        : 'Memperbarui lokasi GPS…',
                  ),
                ],
                if (distance != null)
                  Text(
                    'Jarak ${distance.round()} m • akurasi ±${position!.accuracy.round()} m',
                    style: TextStyle(
                      color: safe
                          ? const Color(0xFF08745D)
                          : const Color(0xFFB42318),
                    ),
                  ),
                Text(
                  safe
                      ? (anywhere
                            ? 'GPS siap. Izin absensi dari lokasi mana saja aktif.'
                            : 'Anda berada di area kantor.')
                      : 'Menunggu lokasi yang memenuhi syarat.',
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ErrorNotice(error!),
                  ),
                if (policy['latitude'] is num &&
                    policy['longitude'] is num &&
                    number(policy, 'radius') > 0)
                  TextButton.icon(
                    onPressed: () => openMap(
                      number(policy, 'latitude'),
                      number(policy, 'longitude'),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Peta lokasi penugasan'),
                  ),
                if (position != null)
                  TextButton.icon(
                    onPressed: () =>
                        openMap(position!.latitude, position!.longitude),
                    icon: const Icon(Icons.my_location),
                    label: const Text('Peta lokasi saya'),
                  ),
                if (error != null)
                  TextButton(
                    onPressed: Geolocator.openAppSettings,
                    child: const Text('Pengaturan izin lokasi'),
                  ),
              ],
            ),
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.face_retouching_natural,
                  size: 40,
                  color: brand,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Cukup arahkan wajah',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Arahkan wajah ke kamera saat absensi. Sistem membandingkan dengan wajah terdaftar dan memeriksa lokasi kembali sebelum mencatat absensi.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(daily.description, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      busy || locating || !available || !safe || daily.completed
                      ? null
                      : start,
                  icon: Icon(
                    daily.completed
                        ? Icons.check_circle_outline
                        : daily.checkedIn
                        ? Icons.logout
                        : Icons.login,
                  ),
                  label: Text(daily.label),
                ),
                if (!available)
                  const Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Text(
                      'Wajah harus terdaftar dan layanan verifikasi harus siap sebelum absensi.',
                    ),
                  ),
              ],
            ),
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
