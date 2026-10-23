# MDM HR Mobile

Aplikasi Flutter Android/iOS untuk employee self-service. Folder ini terpisah dari `frontend` Next.js. Memakai backend Go dan PostgreSQL yang sama, tanpa database atau akun terpisah. Tampilan Material 3 berwarna biru, dengan menu Beranda, Pengajuan, Slip gaji, dan Profil.

[Pratinjau beranda Flutter](../docs/images/flutter-mobile.png) menggunakan data contoh.

## Fitur yang tersedia

- Login menggunakan akun HRIS; sesi server disimpan melalui Android Keystore/iOS Keychain, bukan password. Logout mencabut sesi server. Sesi kedaluwarsa mengembalikan pengguna ke login.
- Satu tombol absensi mengikuti catatan hari ini: **Absensi Masuk → Absensi Keluar → Absensi Selesai**. Setelah masuk/pulang berhasil, halaman memperbarui status dari server; setelah selesai, tombol dinonaktifkan. Tanggal mengikuti `attendanceDate` dari server dalam zona waktu Service Point / HQ penugasan. Beranda menyegarkan status saat kembali dari halaman absensi, saat aplikasi kembali aktif, dan setiap menit ketika beranda terlihat.
- Saat tombol absensi ditekan, kamera depan tampil langsung di aplikasi dengan kotak panduan. Satu wajah harus berada di tengah, cukup dekat, menghadap kamera, dan stabil selama 1,2 detik sebelum kandidat foto diambil otomatis. Tidak ada tombol shutter, aplikasi kamera eksternal, pilihan galeri, atau rekaman audio/video.
- Akun tetap dibuat admin di dashboard. Login pertama mengarahkan user ke pendaftaran wajah dari kamera depan HP. Foto referensi tersimpan privat di server dan dapat dilihat admin di detail karyawan. Penggantian wajah terdaftar hanya oleh admin.
- Kandidat foto diverifikasi server terhadap referensi karyawan yang login dan passive anti-spoofing sebelum absensi dicatat. Compose menyertakan layanan DeepFace SFace/FasNet. Deteksi posisi wajah pada ponsel hanya membantu pengambilan foto. Mode pratinjau absensi telah dihapus.
- Pemeriksaan jarak kantor otomatis saat halaman dibuka, diperbarui setiap 15 detik saat aktif, serta diulang sebelum kamera dan pengiriman foto. Koordinat kantor dimuat ulang dari server pada setiap pemeriksaan dan pengiriman, sehingga perubahan admin langsung berlaku tanpa login ulang. Tidak ada tombol periksa lokasi manual.
- User dapat mengganti password di Profil maupun layar pendaftaran wajah, dengan password lama dan konfirmasi password baru. Setelah berhasil semua sesi dicabut dan user login kembali.
- Setelah kandidat diambil, kamera berhenti memindai selama verifikasi. Penolakan/kegagalan tidak memicu pengiriman berulang otomatis; pengguna dapat memilih **Pindai ulang**. Lokasi diambil ulang sebelum permintaan dikirim, dan backend tetap memeriksa lokasi serta wajah. Kandidat foto sementara dihapus sesudah proses selesai.
- Menolak lokasi yang ditandai `isMocked`, usia lokasi lebih dari 30 detik, akurasi lebih dari 50 m, atau jarak + akurasi melebihi radius lokasi penugasan (default 100 m). Pengecekan radius dilewati hanya jika admin mengaktifkan izin absensi dari lokasi mana saja; pengambilan GPS, pemeriksaan akurasi, dan verifikasi wajah tetap wajib. Lokasi diambil ulang setelah foto dan sebelum pengiriman. Radius dihitung ulang oleh backend.
- Jika pembacaan pertama kurang akurat, GPS dilanjutkan dengan pembaruan setiap 2 detik hingga pembacaan memenuhi akurasi atau batas waktu total 25 detik tercapai. Layar menampilkan perkembangan akurasi. Pemantauan dihentikan sesudah berhasil, gagal, atau batas waktu; jika akurasi tetap buruk, absensi tetap ditolak.
- Pengajuan cuti, reimbursement, petty cash, General Affair, lembur; riwayat status dan catatan HR. Persetujuan admin tetap di web.
- Rincian payroll pribadi dan simpan/bagikan PDF resmi dari backend. Reimbursement tidak dimasukkan payroll baru. PDF hanya dibagikan setelah pengguna memilih tindakan pada share sheet.
- Profil pribadi dan riwayat kehadiran. Semua data diperbarui secara online; tarik layar ke bawah untuk menyegarkan. Tidak ada antrean absensi offline.

Lokasi penugasan dan izin diperbarui dari server pada setiap pemeriksaan. Halaman absensi menyediakan tombol Google Maps untuk titik Service Point / HQ serta titik GPS aktual. Koordinat aktual masuk dan keluar disimpan terpisah oleh server, termasuk untuk izin lokasi mana saja.

## Menjalankan Android

Flutter yang digunakan saat pengembangan: 3.44.8 / Dart 3.12.2. Pasang Android SDK, JDK 17+, dan terima lisensi Android SDK pada mesin Anda. Jalankan Docker dari root seperti biasa, lalu:

```powershell
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

`10.0.2.2` adalah alamat host dari Android Emulator. API diakses melalui proxy Next.js `/api`, sehingga backend tidak perlu dipublikasikan langsung. Default konfigurasi debug menggunakan alamat tersebut. HTTP hanya diizinkan pada Android debug.

Untuk ponsel Android yang terhubung USB dengan USB debugging:

```powershell
adb reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Cara USB ini tidak memerlukan perubahan port Docker yang saat ini hanya terikat ke localhost. Untuk ponsel melalui Wi-Fi atau produksi, gunakan domain API HTTPS yang dapat dijangkau ponsel melalui reverse proxy. `localhost` pada ponsel menunjuk ponsel itu sendiri, bukan komputer Docker.

Untuk membuat dan memasang APK uji coba pada HP yang tersambung USB (jalankan dari folder `mobile`):

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://127.0.0.1:3000
adb reverse tcp:3000 tcp:3000
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n id.mdm.hris.mdm_hris/.MainActivity
```

Pilih **Izinkan** pada HP jika diminta otorisasi USB debugging atau pemasangan aplikasi. Komputer, Docker, dan kabel USB harus tetap terhubung untuk konfigurasi uji coba ini. Menggunakan APK ini tanpa pemetaan `adb reverse` tidak dapat menjangkau API komputer.

Akun demo mengikuti server: `nadia@mdm.local` / `DemoHris2026!` jika demo seed aktif. Tidak ada kredensial yang disisipkan ke aplikasi.

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

APK debug berada di `build/app/outputs/flutter-apk/app-debug.apk`. Ini untuk pengujian internal, bukan distribusi Play Store. Uji lokasi, kamera, penolakan mock location, izin ditolak, dan koneksi terputus pada ponsel fisik sebelum operasional.

## iOS dan rilis

Project iOS, keterangan izin kamera/lokasi, entitlements Keychain, dan Podfile tersedia. Pemindai menggunakan ML Kit, sehingga minimum iOS 15.5; jalankan `pod install` dari folder `ios` pada Mac setelah `flutter pub get`. Build dan pengujian iOS memerlukan macOS, Xcode, Apple signing/provisioning. Gunakan endpoint HTTPS. Build iOS belum divalidasi pada Windows.

Sebelum distribusi Android, tetapkan application ID final dan signing key perusahaan melalui `android/key.properties` (lihat `key.properties.example`). File key dan password diabaikan version control. Build release menolak HTTP dan tidak menggunakan debug signing key.

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://hr.example.com
```

## Batas keamanan dan tahap Play Integrity

Deteksi `isMocked` menghalangi lokasi tiruan yang dilaporkan OS, tetapi bukan bukti lokasi yang tidak dapat dipalsukan. Aplikasi modifikasi atau perangkat yang disusupi masih dapat melewati pemeriksaan klien. iOS tidak dijanjikan memiliki deteksi identik Android. Memasang Flutter **belum menjadikan absensi kebal fake GPS**.

Play Integrity belum diintegrasikan atau diberi hasil simulasi. Integrasi produksi berikutnya membutuhkan application ID final, proyek Google Cloud/Play Console, aplikasi ditandatangani dan didistribusikan melalui jalur Play yang sesuai, serta verifikasi token di backend yang diikat ke sesi dan payload absensi untuk mencegah replay. Keputusan penerimaan harus dibuat server. Play Integrity bukan pengesahan koordinat GPS.

Endpoint absensi web/PWA masih aktif. Selama endpoint tersebut belum mewajibkan bukti integritas server, pengguna dapat mencoba jalur web di luar pemeriksaan Flutter. Jika kebijakannya absensi hanya dari mobile, wajibkan bukti integritas untuk seluruh jalur absensi sebelum menonaktifkan fitur web. Pengajuan web dapat tetap tersedia. Jangan mengandalkan header `platform`, boolean `isMocked`, atau nama aplikasi yang dikirim klien sebagai pengganti attestation.

Provider wajah/liveness dikonfigurasi melalui `FACE_PROVIDER_URL` dan `FACE_PROVIDER_KEY` pada server. Default Compose menggunakan layanan internal `face`; isi secret acak `FACE_PROVIDER_KEY` sebelum build. User mendaftarkan wajah pertama melalui HP setelah akunnya dibuat admin. Aplikasi memblokir absensi jika layanan/pendaftaran belum tersedia. Pengambilan kandidat otomatis menggunakan kamera embedded dan ML Kit face detection; pencocokan identitas ditentukan server. Provider yang membutuhkan challenge/video aktif perlu integrasi SDK khusus. Passive anti-spoofing belum mencegah replay payload; pengujian perangkat nyata tetap diperlukan.

Struktur kode: `lib/core` (API dan data workspace), `lib/features` (auth, home, attendance, requests, payroll), `lib/shared` (komponen UI).
