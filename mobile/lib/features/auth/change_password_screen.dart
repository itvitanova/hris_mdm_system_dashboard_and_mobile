import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../shared/widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.api});
  final ApiClient api;
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final form = GlobalKey<FormState>();
  final current = TextEditingController(),
      next = TextEditingController(),
      confirm = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.post('/auth/password', {
        'currentPassword': current.text,
        'newPassword': next.text,
      });
      await widget.api.forget();
      if (!mounted) return;
      notify(context, 'Password berhasil diganti. Silakan login kembali.');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ganti password')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Masukkan password saat ini dan password baru. Setelah berhasil, semua sesi akan keluar dan Anda perlu login kembali.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: current,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Password saat ini'),
            validator: (v) =>
                v == null || v.isEmpty ? 'Masukkan password saat ini.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: next,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Password baru'),
            validator: (v) =>
                v == null ||
                    utf8.encode(v).length < 12 ||
                    utf8.encode(v).length > 72
                ? 'Gunakan 12–72 byte.'
                : v == current.text
                ? 'Password baru harus berbeda.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: confirm,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Ulangi password baru',
            ),
            validator: (v) =>
                v != next.text ? 'Konfirmasi password tidak sama.' : null,
          ),
          const SizedBox(height: 24),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ErrorNotice(error!),
            ),
          FilledButton(
            onPressed: busy ? null : save,
            child: Text(busy ? 'Menyimpan…' : 'Simpan password'),
          ),
        ],
      ),
    ),
  );
}
