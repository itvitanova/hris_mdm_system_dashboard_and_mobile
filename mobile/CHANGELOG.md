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
