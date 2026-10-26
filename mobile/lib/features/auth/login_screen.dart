import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../shared/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api, required this.onLogin});
  final ApiClient api;
  final VoidCallback onLogin;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false, hidden = true;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.login(email.text, password.text);
      if (mounted) {
        password.clear();
        widget.onLogin();
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: form,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'MDM HR',
                      style: TextStyle(
                        color: brand,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ruang kerja karyawan',
                      style: TextStyle(color: muted),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Selamat datang',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF142541),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk untuk mengelola kehadiran, pengajuan, dan slip gaji Anda.',
                      style: TextStyle(color: Color(0xFF52637A), fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: email,
                      autofillHints: const [AutofillHints.username],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email karyawan',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Masukkan email yang valid'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: password,
                      autofillHints: const [AutofillHints.password],
                      obscureText: hidden,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: hidden
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          onPressed: () => setState(() => hidden = !hidden),
                          icon: Icon(
                            hidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Masukkan kata sandi' : null,
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ErrorNotice(error!),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: busy ? null : submit,
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Masuk'),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Gunakan akun karyawan yang diberikan HR.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
