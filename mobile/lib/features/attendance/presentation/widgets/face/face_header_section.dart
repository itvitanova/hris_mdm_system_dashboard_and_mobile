import 'package:flutter/material.dart';

class FaceHeaderSection extends StatelessWidget {
  const FaceHeaderSection({
    super.key,
    required this.enrollment,
  });

  final bool enrollment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          enrollment ? 'Daftarkan wajah Anda' : 'Cukup arahkan wajah Anda',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          enrollment
              ? 'Foto ini disimpan sebagai referensi untuk mencocokkan wajah saat absensi. Posisikan satu wajah dan tahan sebentar.'
              : 'Posisikan satu wajah di tengah kotak dan tahan sebentar. Pemindaian berjalan otomatis.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFCBD5E1)),
        ),
      ],
    );
  }
}
