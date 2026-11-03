## [v1.2.1] - 2026-11-03
**Build:** `2014` (iOS Build `2014`, Android Build `2014`)  
**Target Environment:** Production  
**Spesifikasi OS:** Android minSdk 21 (Android 5.0) / iOS 15.5+

### Added
- Fitur "Tandai Semua Sudah Dibaca" (*Mark All as Read*) pada modul Notifikasi Pengajuan:
  - Tombol aksi cerdas di AppBar dengan status aktif (aksen *frosted teal*) saat ada notifikasi belum dibaca, dan status non-aktif (*disabled* abu-abu) saat semua notifikasi sudah terbaca.
  - Sinkronisasi server persisten via endpoint `POST /api/requests/{id}/seen` dengan token pembaruan pengajuan.
  - Feedback floating SnackBar konfirmasi elegan: *"Semua notifikasi telah ditandai dibaca"*.
  - Sinkronisasi data real-time ke workspace lokal sehingga badge counter belum dibaca di Bottom Navigation Bar langsung nol.
- Modernisasi antarmuka tab Slip Gaji (Payroll):
  - Banner ringkasan utama (*Hero Summary Banner*) dengan tema teal gradient, rincian gaji periode terkini, dan total dokumen.
  - Search Bar pencarian periode dan slip gaji dengan tombol reset/clear dinamis.
  - Dropdown filter periode interaktif berbasis *floating overlay panel* dengan dismiss barrier transparan.
- Halaman Rincian Slip Gaji (*Payslip Detail Screen*):
  - Kartu rincian Take Home Pay dengan aksen lingkaran frosted glass.
  - Kartu metadata perusahaan, karyawan, departemen, dan status PTKP.
  - Kartu rincian komponen penambahan pendapatan (Gaji pokok, tunjangan, lembur, bonus) dengan badge hijau.
  - Kartu rincian komponen pemotongan (PPh21, BPJS Kesehatan, JHT, JP) dengan badge merah.
  - Tombol aksi unduh dan bagikan dokumen slip gaji resmi dalam format PDF via native share dialog.
- Isolasi branch mockup terpisah (`mockup`) untuk keperluan preview antarmuka dengan data statis tanpa mengganggu basis kode utama.

### Changed
- Transisi 100% modul mobile dari data mock/dummy lokal ke data real workspace API (Presensi, Katalog Pengajuan, Riwayat Pengajuan, dan Notifikasi).
- Desain kartu putih pada seluruh modul Slip Gaji diubah menjadi borderless dengan elevasi soft ambient shadow (tanpa garis outline abu-abu kaku).
- Penyelarasan tinggi dan sudut kelengkungan (border radius 12.r) antara Search Bar dan Filter Periode Dropdown menggunakan `IntrinsicHeight` agar simetris dan rapi di semua resolusi layar.
- Mengembalikan ikon tombol kembali (*back button*) pada header rincian slip gaji menggunakan panah standar Material (`Icons.arrow_back_rounded`) agar seragam dengan halaman aplikasi lainnya.
- Tampilan transisi halus filter "Belum Dibaca" pada notifikasi menuju empty state *"Tidak ada notifikasi yang belum dibaca"* saat aksi tandai dibaca dijalankan.

### Fixed
- Memperbaiki sinkronisasi badge counter notifikasi di Persistent Bottom Navigation Bar agar langsung berkurang seketika tanpa perlu restart aplikasi.
- Memperbaiki penanganan error background sync saat menandai status notifikasi terbaca.
- Memperbaiki ketidaksesuaian styling search input pada slip gaji agar identik dengan search bar pada halaman Persetujuan.

### Performance & Security
- *Optimistic UI update* pada aksi notifikasi dan slip gaji untuk memastikan responsivitas instan tanpa jeda pemrosesan jaringan.
- Validasi `updateToken` 64-karakter pada penandaan notifikasi terbaca untuk mencegah konflik state atau race condition data.

## [v1.2.0] - 2026-11-02
**Build:** `2013` (iOS Build `2013`, Android Build `2013`)  
**Target Environment:** Production  
**Spesifikasi OS:** Android minSdk 21 (Android 5.0) / iOS 15.5+

### Added
- Modul Services Hub (Katalog Layanan Pengajuan 1 halaman) dengan 5 modul pengajuan terpisah: Cuti, Izin Sakit, Lembur, Klaim Medis, dan Perjalanan Dinas.
- Indikator counter status 2x2 (Total, Menunggu, Disetujui, Ditolak) pada setiap modul layar pengajuan.
- Dropdown overlay filter status interaktif yang tersinkronisasi otomatis secara real-time dengan kartu counter pengajuan.
- Modal bottom sheet presensi 2 tahap (validasi koordinat lokasi GPS dan konfirmasi presensi).
- Kartu ringkasan aktivitas absensi 2 hari terakhir pada dashboard.
- Widget compact attendance card dan animasi shimmer loading saat proses memuat data beranda.
- Penambahan menu Approvals dan Slip Gaji (Payroll) pada Persistent Bottom Navigation Bar 5-tab.
- Form pengajuan modular per kategori request yang dilengkapi dengan custom date picker dan time selector.

### Changed
- Redesain antarmuka Login dengan tema teal gradient, kurva wave header, abstract card layout, dan logo HRIS MDM SYSTEM.
- Pembaruan header dashboard: sapaan karyawan, ikon notifikasi lonceng, dan penataan selektor bahasa.
- Redesain tombol pintasan cepat (*quick request buttons*) menggunakan ikon Flaticon UIcons dengan signature card style.
- Pembaruan tampilan kartu pengajuan (*Universal Request Card*) menggunakan *soft ambient shadow* tanpa garis tepi kaku.
- Penyeragaman gaya Corporate Clean AppBar di seluruh layar dengan elevasi halus dan tombol kembali melengkung (*rounded back button*).
- Modernisasi layout antarmuka tab Profil karyawan dan menu pengaturan akun.

### Fixed
- Memperbaiki masalah *infinite redirect loop* pada BLoC autentikasi saat transisi proses login dan logout.
- Menangani *session revocation cascade* dan error redirect berulang ketika pengguna keluar dari akun.
- Memperbaiki field input form login dengan memisahkan teks error di bawah container agar tinggi kotak form tidak berubah saat validasi gagal.
- Memperbaiki *text clipping* dan menghilangkan titik-titik (*ellipsis*) pada badge status kehadiran, jam absensi, dan deskripsi katalog layanan.
- Menghilangkan *whitespace / bottom scroll padding* berlebih di atas persistent bottom navigation bar pada dashboard.
- Memulihkan sinkronisasi kartu saldo kuota cuti tahunan dan panel ringkasan approval di beranda.

### Performance & Security
- Menerapkan `persistent_bottom_nav_bar` untuk mengeliminasi rebuild/re-render widget halaman saat pengguna beralih antar-tab navigasi.
- Standarisasi penanganan error HTTP 401 Unauthorized dan pembersihan session token yang aman dari secure storage saat logout.
- Konfigurasi Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) pada project iOS untuk mematuhi standar privasi App Store terbaru.

### Dependencies & Tech Debt
- Migrasi arsitektur aplikasi mobile secara menyeluruh ke pola Clean Architecture (`data`, `domain`, `presentation`).
- Penerapan state management reaktif modular menggunakan `flutter_bloc` (^9.1.1), `equatable` (^3.0.0), dan service locator `get_it` (^9.3.0).
- Penambahan dependensi paket UI: `uicons` (^1.0.1), `flutter_svg` (^2.3.0), dan `google_fonts` (^8.1.0).
- Pembersihan (*cleanup*) direktori tabs lama yang redundant demi menjaga keteraturan basis kode.

### Removed
- Menghapus opsi bahasa yang tidak relevan dari dropdown selektor bahasa pada header dashboard.
- Menghapus tombol pintasan lama (*legacy quick requests*) yang digantikan oleh kartu aktivitas riwayat presensi 2 hari.
- Menghapus garis outline border yang kaku pada kartu daftar pengajuan.
