import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets.dart';
import '../../../auth/change_password_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
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
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool loggingOut = false;

  Workspace get w => widget.workspace;

  Future<void> logout() async {
    setState(() => loggingOut = true);
    try {
      await widget.api.logout();
      if (mounted) widget.onLogout();
    } catch (e) {
      if (mounted) notify(context, e);
    } finally {
      if (mounted) setState(() => loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Panel(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.deepTeal50,
                    child: Icon(Icons.person_outline, color: AppColors.deepTeal, size: 38),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text(w.actor, 'name'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    text(w.actor, 'email'),
                    style: const TextStyle(color: Color(0xFF52637A)),
                  ),
                  const SizedBox(height: 20),
                  DetailLine('ID karyawan', text(w.employee, 'id')),
                  DetailLine('Departemen', text(w.employee, 'department')),
                  DetailLine('Jabatan', text(w.employee, 'position')),
                  DetailLine('Telepon', text(w.employee, 'phone')),
                  DetailLine('Bank', text(w.employee, 'bankName')),
                  DetailLine('Pemilik rekening', text(w.employee, 'bankAccountName')),
                  DetailLine('Nomor rekening', text(w.employee, 'bankAccountNumber')),
                  DetailLine('Alamat', text(w.employee, 'address')),
                  DetailLine('Status PTKP', text(w.employee, 'ptkp')),
                  DetailLine('NIK', text(w.employee, 'employeeNumber', 'Belum diisi')),
                  DetailLine(
                    'Hubungan kerja',
                    text(w.employee, 'employmentType', 'Belum diisi'),
                  ),
                  DetailLine(
                    'Pendaftaran wajah',
                    w.employee['faceEnrolled'] == true
                        ? 'Terdaftar'
                        : 'Belum terdaftar',
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Hubungi HR untuk memperbarui data pribadi.',
                style: TextStyle(color: Color(0xFF52637A)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(api: widget.api),
                  ),
                );
                if (changed == true && mounted) widget.onLogout();
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Ganti password'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: loggingOut ? null : logout,
              icon: const Icon(Icons.logout),
              label: Text(loggingOut ? 'Keluar…' : 'Keluar akun'),
            ),
          ],
        ),
      ),
    );
  }
}
