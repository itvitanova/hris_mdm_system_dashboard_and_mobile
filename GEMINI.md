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

## 4. UI Component Protection & Invariants
- **Strict Navbar Icon Preservation**:
  - Dilarang keras mengubah, mengganti, atau merefaktor icon-icon pada Bottom Navigation Bar (`RootPage` navbar: Beranda, Pengajuan, Persetujuan, Slip Gaji, Profil), baik aset SVG maupun pengaturannya, kecuali diminta secara khusus dan eksplisit oleh pengguna.

## 5. Feature-First Clean Architecture & Code Standards
Seluruh implementasi, perbaikan, dan refactor pada mobile wajib mematuhi panduan di `docs/architecture/ai_guidelines_architecture_rules.md`:
1. **Feature-First Clean Architecture**:
   - Struktur folder per fitur di `lib/features/[nama_fitur]/`: `domain/` (entities, repositories, usecases), `data/` (models, datasources, repositories), `presentation/` (bloc, pages, widgets), dan `[nama_fitur]_injection.dart`.
   - Dilarang menaruh file screen atau service langsung di root folder fitur.
2. **Widget Granularity & UI Rules**:
   - Dilarang membuat file UI (Page/Screen) monolithic > 200 baris kode.
   - Pecah UI menjadi class widget mandiri (`StatelessWidget`), bukan private helper method (`Widget _buildX()`).
   - Pisahkan shared widget ke `lib/core/widgets/` dan widget spesifik fitur ke `lib/features/[nama_fitur]/presentation/widgets/`.
3. **BLoC State Management**:
   - Pisahkan menjadi 3 file: `_bloc.dart`, `_event.dart`, dan `_state.dart`.
   - State berbasis class (Initial, Loading, Success, Error). UI hanya menampilkan data dan dispatch event.
4. **Dependency Injection**:
   - Gunakan `get_it` via `[nama_fitur]_injection.dart` dan didaftarkan di entry point aplikasi.
5. **Networking & API**:
   - Gunakan `dio_client.dart` di `lib/app/config/`. Jangan instansiasi Dio baru di data layer. Error API di-mapping ke `Exception` (data) & `Failure` (domain/UI) di `lib/core/errors/`.
6. **Theme & Komponen Global**:
   - Gunakan theme dari `lib/core/theme/` (`app_colors.dart`, `app_text_styles.dart`). Dilarang hardcode warna dan text style di UI.
7. **Naming Conventions**:
   - File/folder `snake_case`, Class `PascalCase` dengan suffix peran (`...Page`, `...Widget`, `...Bloc`, `...Event`, `...State`, `...Entity`, `...Model`, `...Repository`).

