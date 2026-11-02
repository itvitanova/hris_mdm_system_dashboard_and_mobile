import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../attendance_service.dart';
import 'auto_face_page.dart';
import '../../../auth/presentation/pages/change_password_page.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.onLogout,
  });
  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;
  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  bool busy = false;
  Future<void> register() async {
    setState(() => busy = true);
    try {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AutoFaceScreen(
            title: 'Pendaftaran wajah',
            enrollment: true,
            onCapture: (photo) => AttendanceService(
              widget.api,
            ).enroll(text(widget.workspace.employee, 'id'), photo),
          ),
        ),
      );
      if (success == true) await widget.onRefresh();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pendaftaran wajah')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.face_retouching_natural, size: 90, color: brand),
        const SizedBox(height: 24),
        Text(
          'Halo, ${text(widget.workspace.actor, 'name')}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sebelum menggunakan aplikasi, daftarkan wajah Anda lewat kamera depan HP. Foto referensi disimpan di server dan dapat dilihat HR di dashboard. Setiap absensi akan dibandingkan dengan wajah ini.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Pastikan pencahayaan cukup dan wajah tidak tertutup. Penggantian referensi setelah pendaftaran hanya dapat dilakukan oleh admin.',
        ),
        const SizedBox(height: 24),
        if (!widget.workspace.faceAvailable) ...[
          const Text(
            'Layanan verifikasi wajah belum siap. Hubungi admin atau muat ulang status layanan.',
            style: TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: busy ? null : widget.onRefresh,
            child: const Text('Muat ulang status'),
          ),
        ],
        FilledButton.icon(
          onPressed: busy || !widget.workspace.faceAvailable ? null : register,
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Daftarkan wajah'),
        ),
        TextButton(
          onPressed: busy
              ? null
              : () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordScreen(api: widget.api),
                    ),
                  );
                  if (changed == true && mounted) widget.onLogout();
                },
          child: const Text('Ganti password'),
        ),
        TextButton(
          onPressed: busy
              ? null
              : () async {
                  try {
                    await widget.api.logout();
                    widget.onLogout();
                  } catch (e) {
                    if (context.mounted) notify(context, e);
                  }
                },
          child: const Text('Keluar'),
        ),
      ],
    ),
  );
}

typedef FaceEnrollmentPage = FaceEnrollmentScreen;
