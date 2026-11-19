import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/data/datasources/attendance_service.dart';
import 'package:mdm_hris/features/attendance/presentation/pages/auto_face_page.dart';
import 'daily_attendance.dart';
import 'modal/attendance_modal_drag_handle.dart';
import 'modal/attendance_modal_step1_view.dart';
import 'modal/attendance_modal_step2_view.dart';

/// 2-Step Attendance Modal Bottom Sheet
/// Step 1: Manual GPS Location Verification (AttendanceModalStep1View)
/// Step 2: Face Verification Guide & Tutorial (AttendanceModalStep2View) -> Opens AutoFaceScreen
class AttendanceModalBottomSheet extends StatefulWidget {
  const AttendanceModalBottomSheet({
    super.key,
    required this.api,
    required this.workspace,
    this.initialType,
  });

  final ApiClient api;
  final Workspace workspace;
  final String? initialType;

  @override
  State<AttendanceModalBottomSheet> createState() => _AttendanceModalBottomSheetState();
}

class _AttendanceModalBottomSheetState extends State<AttendanceModalBottomSheet> {
  late final AttendanceService _service = AttendanceService(widget.api);
  late Workspace _currentWorkspace = widget.workspace;

  int _step = 1;
  Position? _position;
  String? _gpsError;
  bool _isLocating = false;

  final TextEditingController _earlyReasonController = TextEditingController();
  final GlobalKey<FormState> _earlyFormKey = GlobalKey<FormState>();

  Workspace get _w => _currentWorkspace;
  Json get _policy => _w.attendancePolicy;
  DailyAttendance get _daily => DailyAttendance(_w);
  String get _punchType => widget.initialType ?? _daily.nextType ?? 'in';

  bool get _isEarly {
    if (_punchType != 'out') return false;
    final end = text(_policy, 'workEnd', '');
    final serverTime = text(_w.data, 'serverTime', '');
    return end.isNotEmpty && serverTime.length >= 16 && serverTime.substring(11, 16).compareTo(end) < 0;
  }

  bool get _isFaceEnrolled => !_w.faceAvailable || _w.employee['faceEnrolled'] == true;
  bool get _isSafeLocation => _position != null && locationError(_position!, _policy) == null;
  bool get _canProceed => _isSafeLocation && !_isLocating && _isFaceEnrolled;

  double? get _distance {
    if (_position == null || _policy['latitude'] is! num || _policy['longitude'] is! num) return null;
    return Geolocator.distanceBetween(
      _position!.latitude, _position!.longitude,
      number(_policy, 'latitude'), number(_policy, 'longitude'),
    );
  }

  @override
  void initState() {
    super.initState();
    unawaited(_locateGPS());
  }

  @override
  void dispose() {
    _earlyReasonController.dispose();
    super.dispose();
  }

  Future<void> _locateGPS() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _gpsError = null;
    });

    try {
      final latest = Workspace(await widget.api.workspace());
      if (!mounted) return;
      setState(() => _currentWorkspace = latest);

      final pos = await _service.locate(
        onSample: (sample) {
          if (!mounted) return;
          setState(() {
            _position = sample;
            _gpsError = null;
          });
        },
      );

      if (!mounted) return;
      final err = locationError(pos, latest.attendancePolicy);
      setState(() {
        _position = pos;
        _gpsError = err;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _gpsError = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _openCameraScreen() async {
    if (_isEarly && !(_earlyFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => AutoFaceScreen(
          title: _punchType == 'in' ? 'Absensi Masuk' : 'Absensi Keluar',
          onCapture: (photo) => _service.punch(
            _punchType,
            photo,
            earlyReason: _earlyReasonController.text.trim(),
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final officeName = text(_policy, 'name', 'Kantor Pusat MDM');
    final dist = _distance;
    final isSafe = _isSafeLocation;
    final radius = number(_policy, 'radius');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AttendanceModalDragHandle(),
              SizedBox(height: 12.w),
              if (_step == 1)
                AttendanceModalStep1View(
                  officeName: officeName,
                  distance: dist,
                  isSafe: isSafe,
                  isFaceEnrolled: _isFaceEnrolled,
                  gpsError: _gpsError,
                  radius: radius,
                  isLocating: _isLocating,
                  canProceed: _canProceed,
                  fallbackLabel: _daily.label,
                  onRefresh: _locateGPS,
                  onProceed: () => setState(() => _step = 2),
                )
              else
                AttendanceModalStep2View(
                  punchType: _punchType,
                  officeName: officeName,
                  distance: dist?.round() ?? 0,
                  isEarly: _isEarly,
                  isFaceEnrolled: _isFaceEnrolled,
                  earlyFormKey: _earlyFormKey,
                  earlyReasonController: _earlyReasonController,
                  workEnd: text(_policy, 'workEnd', 'jam pulang'),
                  onBack: () => setState(() => _step = 1),
                  onOpenCamera: _openCameraScreen,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
