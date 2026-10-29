import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../attendance_service.dart';
import '../pages/auto_face_page.dart';
import 'daily_attendance.dart';

/// 2-Step Attendance Modal Bottom Sheet
/// Step 1: Manual GPS Location Verification (Group.svg)
/// Step 2: Face Verification Guide & Tutorial (Modal 2.svg) -> Opens AutoFaceScreen
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
  State<AttendanceModalBottomSheet> createState() =>
      _AttendanceModalBottomSheetState();
}

class _AttendanceModalBottomSheetState
    extends State<AttendanceModalBottomSheet> {
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
    return end.isNotEmpty &&
        serverTime.length >= 16 &&
        serverTime.substring(11, 16).compareTo(end) < 0;
  }

  bool get _isFaceEnrolled {
    if (!_w.faceAvailable) return true;
    return _w.employee['faceEnrolled'] == true;
  }

  bool get _isSafeLocation {
    if (_position == null) return false;
    return locationError(_position!, _policy) == null;
  }

  bool get _canProceed =>
      _isSafeLocation && !_isLocating && _isFaceEnrolled;

  double? get _distance {
    if (_position == null ||
        _policy['latitude'] is! num ||
        _policy['longitude'] is! num) {
      return null;
    }
    return Geolocator.distanceBetween(
      _position!.latitude,
      _position!.longitude,
      number(_policy, 'latitude'),
      number(_policy, 'longitude'),
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
        setState(() {
          _gpsError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _goToStep2() {
    setState(() {
      _step = 2;
    });
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
              // Top drag handle pill (#CBD5E1, w:32, h:4)
              Center(
                child: Container(
                  width: 32.w,
                  height: 4.h,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              SizedBox(
                height: 12.w,
              ),
              if (_step == 1) ...[
                _buildStep1Header(),
                SizedBox(height: 12.h),
                _buildMapVisualCard(),
                SizedBox(height: 14.h),
                _buildLocationStatusBanner(),
                SizedBox(height: 16.h),
                _buildStep1Actions(),
              ] else ...[
                _buildStep2Header(),
                SizedBox(height: 10.h),
                _buildStep2VerifiedBadge(),
                SizedBox(height: 12.h),
                _buildTutorialBox(),
                if (_isEarly) ...[
                  SizedBox(height: 12.h),
                  _buildEarlyReasonInput(),
                ],
                SizedBox(height: 16.h),
                _buildStep2ActionButton(),
                SizedBox(height: 8.h),
                Text(
                  'Foto ini akan diverifikasi secara otomatis oleh sistem',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- STEP 1 WIDGETS ---

  Widget _buildStep1Header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verifikasi Lokasi & Waktu',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Mengecek posisi Anda terhadap radius kantor',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 1.0),
      ],
    );
  }

  Widget _buildMapVisualCard() {
    final officeName = text(_policy, 'name', 'Kantor Pusat MDM');
    final dist = _distance;
    final isSafe = _isSafeLocation;

    return Container(
      height: 135.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          Positioned(
            left: 55.w,
            top: 25.h,
            child: Container(
              width: 85.w,
              height: 85.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFF0D9488),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0F766E),
                  ),
                  child: Center(
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 35.w,
            top: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                officeName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (dist != null)
            Positioned(
              left: 105.w,
              top: 66.h,
              right: 85.w,
              child: CustomPaint(
                size: Size(130.w, 1.h),
                painter: _DashedLinePainter(
                  color: isSafe ? const Color(0xFF0D9488) : const Color(0xFFDC2626),
                ),
              ),
            ),
          Positioned(
            right: 50.w,
            top: 55.h,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSafe
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFEF4444),
                boxShadow: [
                  BoxShadow(
                    color: (isSafe
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.35),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (dist != null)
            Positioned(
              left: 135.w,
              top: 48.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSafe
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFFECACA),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSafe
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${dist.round()} m',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: isSafe
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusBanner() {
    if (!_isFaceEnrolled) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFFEE2E2), width: 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              margin: EdgeInsets.only(top: 1.h),
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.priority_high,
                  size: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wajah Belum Terdaftar',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7F1D1D),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Wajah Anda belum terdaftar di sistem. Hubungi admin untuk mendaftarkan foto wajah.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      color: const Color(0xFF991B1B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isSafe = _isSafeLocation;
    final dist = _distance;
    final radius = number(_policy, 'radius');

    if (!isSafe || _gpsError != null) {
      final msg = _gpsError ??
          (dist != null
              ? 'Anda berada ${dist.round()}m dari kantor (maksimal ${radius.round()}m). Silakan mendekat ke area kantor untuk absensi.'
              : 'Lokasi Anda belum dapat dipastikan dalam radius kantor.');

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFFEE2E2), width: 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              margin: EdgeInsets.only(top: 1.h),
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.priority_high,
                  size: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Di Luar Radius Kantor',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7F1D1D),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    msg,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5.sp,
                      color: const Color(0xFF991B1B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            margin: EdgeInsets.only(top: 1.h),
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check,
                size: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Memenuhi Syarat',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Posisi terverifikasi di ${text(_policy, "name", "Kantor")} (${dist?.round() ?? 0}m dari pusat radius).',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5.sp,
                    color: const Color(0xFF047857),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Actions() {
    final canProceed = _canProceed;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: OutlinedButton.icon(
            onPressed: _isLocating ? null : _locateGPS,
            icon: _isLocating
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Color(0xFF334155),
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    size: 18.sp,
                    color: const Color(0xFF334155),
                  ),
            label: Text(
              _isLocating ? 'Memperbarui Lokasi...' : 'Refresh Lokasi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: FilledButton.icon(
            onPressed: canProceed ? _goToStep2 : null,
            icon: Icon(
              canProceed ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
              size: 18.sp,
              color: canProceed ? Colors.white : const Color(0xFF94A3B8),
            ),
            label: Text(
              canProceed ? 'Lanjut ke Kamera' : _daily.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: canProceed ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF0D9488),
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 2 WIDGETS ---

  Widget _buildStep2Header() {
    final title = _punchType == 'in' ? 'Ambil Absen Masuk' : 'Ambil Absen Keluar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Back',
              child: InkWell(
                onTap: () => setState(() => _step = 1),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 18.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Posisikan wajah Anda di dalam bingkai',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        const Divider(color: Color(0xFFF1F5F9), height: 1.0, thickness: 1.0),
      ],
    );
  }

  Widget _buildStep2VerifiedBadge() {
    final officeName = text(_policy, 'name', 'Kantor Pusat MDM');
    final dist = _distance?.round() ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.check, size: 12.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Terverifikasi di $officeName • Dalam radius ${dist}m',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D9488),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Visual tutorial and framing box matching Modal 2.svg
  Widget _buildTutorialBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Viewfinder face target with 4 symmetrical corner brackets
          SizedBox(
            width: 88.w,
            height: 88.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FaceFrameBracketsPainter(),
                  ),
                ),
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                    border: Border.all(
                      color: const Color(0xFF0D9488),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.face_retouching_natural_rounded,
                      size: 28.sp,
                      color: const Color(0xFFCCFBF1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Tutorial title
          Text(
            'Panduan Verifikasi Wajah',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),

          // Tutorial bullet instructions
          Text(
            '1. Lepas masker & kacamata hitam\n2. Pastikan pencahayaan cukup terang\n3. Hadapkan wajah tegak ke kamera',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFCBD5E1),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),

          // Bottom guidance pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
            child: Text(
              'Pastikan wajah terlihat jelas dan pencahayaan cukup',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEarlyReasonInput() {
    final end = text(_policy, 'workEnd', 'jam pulang');

    return Form(
      key: _earlyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pulang Sebelum Jadwal ($end)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          TextFormField(
            controller: _earlyReasonController,
            minLines: 2,
            maxLines: 3,
            maxLength: 300,
            style: TextStyle(fontSize: 12.sp, fontFamily: 'Inter'),
            decoration: InputDecoration(
              hintText: 'Isi alasan pulang lebih awal (min. 5 karakter)...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5.sp,
                color: const Color(0xFF94A3B8),
              ),
              contentPadding: EdgeInsets.all(10.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
              ),
            ),
            validator: (v) => (v?.trim().length ?? 0) < 5
                ? 'Alasan wajib diisi minimal 5 karakter'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2ActionButton() {
    final title = _punchType == 'in' ? 'Ambil Absen Masuk' : 'Ambil Absen Keluar';

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: FilledButton(
        onPressed: !_isFaceEnrolled ? null : _openCameraScreen,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF0D9488),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 20.sp,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter to draw subtle map streets and rivers inside map visual card
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final borderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal street
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5 - 3),
      Offset(size.width, size.height * 0.5 - 3),
      borderPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5 + 3),
      Offset(size.width, size.height * 0.5 + 3),
      borderPaint,
    );

    // Vertical street
    canvas.drawLine(
      Offset(size.width * 0.38, 0),
      Offset(size.width * 0.38, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38 - 3, 0),
      Offset(size.width * 0.38 - 3, size.height),
      borderPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38 + 3, 0),
      Offset(size.width * 0.38 + 3, size.height),
      borderPaint,
    );

    // Secondary vertical street
    canvas.drawLine(
      Offset(size.width * 0.78, 0),
      Offset(size.width * 0.78, size.height),
      streetPaint,
    );

    // Subtle blue curved river on top left
    final riverPaint = Paint()
      ..color = const Color(0xFFDBEAFE)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.25,
        size.width * 0.45,
        0,
      )
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter to draw dashed connection line between office and user pin
class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Painter for face framing corner brackets (white brackets in Modal 2)
class _FaceFrameBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final len = 14.0.w;

    // Top-Left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(len, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, len), paint);

    // Top-Right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-len, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, len), paint);

    // Bottom-Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(len, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -len), paint);

    // Bottom-Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-len, 0), paint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}