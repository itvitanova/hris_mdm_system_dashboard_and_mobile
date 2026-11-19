import 'package:flutter/material.dart';

class EarlyCheckoutDialog {
  static Future<String?> show({
    required BuildContext context,
    required String workEnd,
  }) async {
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
                  'Jadwal pulang lokasi Anda pukul $workEnd. Alasan akan dicatat bersama absensi.',
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
    return reason;
  }
}
