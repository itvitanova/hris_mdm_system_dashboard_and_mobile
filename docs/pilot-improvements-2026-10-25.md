# Perbaikan pilot 25 Oktober 2026

Permintaan pengguna: jadwal pulang/alasan pulang awal; jabatan berdasarkan
departemen; pilihan dengan pencarian di form tambah/edit; PKWT/PKWTT; kalender
cuti rekan satu lokasi; ekspor Excel lengkap; impor karyawan + template; detail
pengajuan dan bukti foto; dialog revisi; indikator revisi/notifikasi; penanggung
jawab tahap aktif di dashboard; filter bulan reimbursement; rincian profesional.

## Keputusan implementasi

Pilih halaman berorientasi tugas: ringkasan status dan siapa yang ditunggu,
rincian pengeluaran berbentuk daftar, bukti dapat dipratinjau, dokumen final
sebagai tindakan jelas. Alternatif mempertahankan tabel lebar ditolak karena
temuan pengguna: tanggal dan finance memerlukan scroll horizontal. Komponen
pilihan dapat dicari dipakai bersama, bukan dibuat berbeda untuk setiap form.
Bukti: laporan dan arahan pengguna serta kode aplikasi; belum ada studi pengguna.

Jam pulang diatur per lokasi, tidak mengarang jadwal lokasi produksi. Lokasi
lama tanpa jam pulang tetap kompatibel sampai admin melengkapinya. Pulang awal
dicatat dengan alasan, bukan dianggap pulang tepat waktu. PKWT/PKWTT disimpan
terpisah dari Aktif/Probation/Nonaktif. Kalender rekan satu lokasi hanya membuka
identitas dan tanggal cuti yang disetujui, tanpa alasan/dokumen pribadi.

Impor melalui template XLSX, pratinjau dan validasi sebelum simpan; kesalahan
baris dijelaskan dan tidak menghasilkan impor sebagian. Tidak mengubah password
atau menerbitkan akun massal diam-diam. Notifikasi awal berada di dalam aplikasi;
push sistem operasi belum dijanjikan tanpa konfigurasi layanan push.

## Daftar kerja

- [x] Backend: jam pulang, alasan/penanda pulang awal, tipe hubungan kerja.
- [x] Backend: jabatan per departemen, migrasi data lama yang aman.
- [x] Backend: ekspor/impor XLSX lengkap dan validasi atomik.
- [x] Backend: kalender cuti per lokasi dan penanda pembaruan pengajuan.
- [x] Dashboard: pilihan dengan pencarian, dependensi departemen/jabatan.
- [x] Dashboard: field baru, impor/ekspor, tahap aktif, filter bulan.
- [x] Dashboard: rincian/dokumen dan pratinjau bukti.
- [x] Mobile: kalender cuti, pulang awal, indikator/notifikasi pengajuan.
- [x] Mobile: form/detail/approval, foto bukti dan dialog revisi.
- [x] Validasi: backend, web, mobile, render dan akses lintas pengguna.
- [x] Rilis produksi, migrasi/cadangan, APK dan verifikasi publik.

Data produksi pengguna dipertahankan. Tidak menjalankan reset pilot lagi.


## Panduan HR setelah pembaruan

1. Buka Service Point / HQ, lalu isi jam pulang tiap lokasi (misalnya 18:00
   untuk lokasi yang memang memiliki jadwal tersebut). Jadwal saat ini berada
   pada hari yang sama. Lokasi lama tetap tanpa jam pulang sampai diatur admin;
   sistem tidak mengarang jam kerja kantor. Pulang sebelum jadwal meminta alasan
   5–500 karakter dan menyimpan menit lebih awal serta snapshot jadwal.
2. Master Jabatan sekarang memiliki Departemen. Data yang sudah digunakan
   dihubungkan berdasarkan departemen karyawan; jabatan bersama dapat dipisah
   menjadi entri per departemen. Jabatan lama yang belum digunakan dan belum
   terhubung perlu dilengkapi melalui Edit Jabatan. Mengganti departemen pada
   form karyawan mengosongkan pilihan jabatan agar tidak menyimpan pasangan salah.
3. Lengkapi NIK dan PKWT/PKWTT pada karyawan. Hubungan kerja terpisah dari status
   Aktif/Probation/Nonaktif dan tidak ditebak untuk karyawan lama.
4. Ekspor Excel pada Karyawan menghasilkan XLSX dengan 27 kolom, termasuk NIK,
   identitas, lokasi, atasan, hubungan kerja, telepon, rekening, PTKP, gaji, saldo
   cuti, dan status verifikasi wajah (tanpa gambar biometrik).
5. Impor Karyawan → Unduh template dan panduan. Sheet Karyawan berisi input,
   Panduan menjelaskan aturan, Referensi memuat kode master/lokasi dan ID atasan.
   Maksimal 500 baris/2 MB. Gunakan NIK/email unik, kode aktif, jabatan sesuai
   departemen, hubungan kerja, PTKP dan rekening lengkap. Isi telepon agar
   reimbursement dapat diajukan. Impor pimpinan terlebih dahulu jika belum
   terdaftar. Impor hanya menambahkan karyawan; pembuatan akun tetap terpisah.
   Periksa file → perbaiki seluruh kesalahan → Impor. Server memvalidasi kembali
   saat penyimpanan dan membatalkan seluruh batch bila ada kesalahan.
6. Kalender Cuti pada beranda/mobile menandai tanggal hijau dan menampilkan
   rekan satu lokasi yang cutinya sudah disetujui. Alasan dan dokumen cuti tidak
   dikirim melalui API kalender.
7. Notifikasi berada di dalam aplikasi: badge menu dan kartu, serta daftar
   pembaruan. Data disegarkan saat kembali ke aplikasi dan tiap 30 detik saat
   beranda aktif. Penanda dibaca tersimpan di server dan mengikuti event yang
   benar-benar ditampilkan. Push ke notification tray OS belum diintegrasikan.
8. Pemohon dan approver dapat membuka foto bukti, memperbesar, menyimpan atau
   membagikannya; PDF dibuka melalui browser/share sheet/aplikasi PDF. Bukti
   sebelum pengajuan hanya dapat dibuka pemiliknya. Bukti pengajuan mengikuti
   izin pemohon, approver yang ditugaskan dan admin.
9. Dashboard menampilkan tahap aktif dan calon pemberi keputusan yang masih
   ditunggu. Nama pemberi keputusan sebelumnya tetap di riwayat. Filter Bulan
   pengajuan reimbursement memakai tanggal pengajuan dalam zona waktu kantor.
   Rincian dan dokumen dibuka dalam dialog dengan daftar pengeluaran dan
   timeline persetujuan, tanpa tabel rincian yang mengharuskan scroll horizontal.

## Validasi dan batas penerimaan

- Backend: `go test -count=1 ./...` dengan PostgreSQL test terpisah; pemeriksaan
  tambahan pada impor, kalender, penanda dibaca, dan bukti privat; `go vet`.
- Browser: 11 tes Playwright lulus dalam batch terpisah (7 alur dasar, 2 fitur
  pilot, 2 payroll), termasuk dropdown mencari pilihan, jabatan nonaktif,
  ekspor/template XLSX, penolakan impor rusak, perpindahan ke finance, pratinjau
  bukti, filter bulan, dan dialog 390 px tanpa scroll horizontal.
- Mobile: suite 59 tes lulus dan satu integrasi API dilewati pada suite umum,
  termasuk pencarian jenis tanpa hasil. Analyze bersih.
  Widget diuji pada 360 dp dan skala teks hingga 3,2×.
- Render fixture: `tmp/mobile-leave-calendar.png`, `tmp/mobile-approval-detail.png`,
  `tmp/mobile-approval-flow-finance.png`, `tmp/mobile-reimbursement-form.png`,
  `tmp/web-employee-search.png`, `tmp/web-reimbursement-detail-390.png`.
  Fixture memakai nama contoh dan tidak ditambahkan ke produksi.
- Pemeriksaan publik mengonfirmasi demo=false, login admin, relasi master,
  workbook dan template dapat dibaca, kalender dibatasi lokasi, impor tidak
  valid ditolak, serta 4 karyawan/4 wajah/1 pengajuan sebelumnya tetap ada.
- Uji pengguna kantor, pembaca layar manual, share sheet/PDF pada HP nyata dan
  alur pulang awal dengan kamera/GPS fisik belum diverifikasi pada rilis ini.

## RYUX Delivery Gate

| Area | Hasil dan bukti |
| --- | --- |
| PRODUCT | PASS · permintaan pengguna dan kode aplikasi; bukti Strong untuk kebutuhan produk ini |
| UX | PASS · tindakan utama, status tahap, penerima berikutnya, dan pemulihan kesalahan terdefinisi |
| CONTENT | PASS · label berbasis tugas, aturan impor dan kalender dijelaskan, tanpa aturan bisnis rekaan |
| UI | PASS · task UI, kartu/panel dan timeline; signature warna/tema yang sudah ada; tanpa ilustrasi baru |
| DESIGN SYSTEM | PASS · SearchSelect dipakai bersama pada form tambah/edit; komponen mobile dan tema yang ada |
| ACCESSIBILITY | PASS terbatas · label kontrol, keyboard, teks besar diuji; pembaca layar manual belum diverifikasi |
| RESPONSIVE | PASS · web 390 px dan desktop; mobile 360 dp, skala teks 3,2× |
| EDGE CASES | PASS · matriks di bawah; akses dan rollback divalidasi di server |
| CODE QUALITY | PASS · pengujian PostgreSQL, browser, mobile, TypeScript/Next build dan analyze |
| VISUAL QA | PASS · render Flutter RepaintBoundary dan Playwright; fixture, bukan klaim hasil riset pengguna |
| ANTI-SLOP | PASS · tidak menambah metrik, testimoni, dekorasi tanpa tujuan, atau data contoh produksi |
| FINAL | PASS untuk lingkup pemeriksaan di atas; batas perangkat nyata dan usability tetap dicatat |

Matriks tampilan × status: form karyawan × departemen kosong/terpilih/diganti;
master × aktif/nonaktif/legacy; impor × kosong/rusak/valid/error per baris/rollback;
kalender × memuat/kosong/berisi/gagal/bulan berubah; pengajuan × tahap aktif,
berikutnya, revisi, ditolak, disetujui, pembaruan dibaca/belum; bukti × gambar,
PDF, akses ditolak, gagal; absensi × jadwal belum diatur/pulang awal/alasan kosong/
pulang sesuai jadwal. Loading/retry menggunakan komponen aplikasi yang ada.

Uji pilot berikut: HR mengimpor dua karyawan; staf mengajukan dua bukti; atasan
meminta revisi; staf menemukan penanda, melihat bukti dan mengirim ulang; lead
menyetujui; finance ditampilkan sebagai tahap aktif; finance menyetujui; pemohon
mengunduh dokumen. Uji pula cuti yang disetujui muncul hanya di lokasi yang sama,
serta absensi pulang awal meminta dan menyimpan alasan yang dapat dibaca HR.


## Rilis publik yang diverifikasi

- Server: `pilot-20261025-b2013` pada https://hris.mdmcorp.co.id.
- APK: 1.2.0, Flutter build 2013, arm64 versionCode 4013, signing key pilot tetap.
- Android arm64 SHA256: `7c08dd5d9793d5af83b899fdc789f2b2de4e516ec96106dd2d53cf23e9cdd29b`.
- Android armv7 SHA256: `25e0feeb5dbb9b2972760c4d2a5b12f50bb8b7642953f4c84eb1c98ac38ebd53`.
- Unduhan: `/downloads/mdm-hr-1.2.0-arm64.apk` dan
  `/downloads/mdm-hr-1.2.0-armv7.apk`; tautan latest diarahkan ke rilis ini.
- Cadangan prarilis PostgreSQL dan env privat dibuat sebelum aktivasi; archive
  restore-list diperiksa. Berkas cadangan berada di `/opt/hrismdm/backups/`.
- Paket final image server disimpan pada
  `/opt/hrismdm/releases/pilot-20261025-b2013-final-images.tar.gz` beserta SHA256.
  Backend final dibentuk dari binary Linux hasil build Docker yang SHA256-nya
  dicocokkan pada server; frontend memakai image build Next.js yang diuji.
- Data produksi tidak di-reset. Jam pulang dan hubungan kerja karyawan lama
  perlu diisi HR sesuai keadaan sebenarnya sebelum pengujian kebijakannya.
