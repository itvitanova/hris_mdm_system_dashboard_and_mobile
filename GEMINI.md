# Repository Guidelines & Operational Rules

## 1. Testing & Verification Efficiency
- **Targeted Testing Only during Development**:
  - Jangan menjalankan seluruh test suite (`flutter test`) untuk perubahan satu fitur atau penyesuaian UI lokal.
  - Gunakan `flutter analyze` untuk verifikasi sintaks & tipe, atau jalankan test spesifik yang relevan (misal: `flutter test test/request_form_test.dart`).
  - Jalankan full `flutter test` hanya saat merombak modul bersama/core, sebelum release besar, atau jika diminta secara eksplisit oleh pengguna.

## 2. Strict Scope Boundary
- **Kerjakan Hanya Sesuai Permintaan Eksplisit**:
  - Jangan memodifikasi, merombak, atau "meng-improve" styling, layout, atau logika komponen di luar cakupan yang diminta pengguna (misal: jika diminta mengubah header, jangan menyentuh card summary cuti atau list riwayat).
  - Elemen desain yang sudah ditetapkan dan disetujui sebelumnya harus dijaga integritasnya.

## 3. Git & Reference Isolation
- **Zero Mention of External References**:
  - Dilarang keras menyebutkan nama project referensi, nama klien eksternal, atau path direktori referensi di dalam pesan commit git, branch name, komentar kode, penamaan file, maupun respons.
  - Semua pesan commit dan dokumentasi harus murni merefleksikan domain dan fitur internal repository ini.
