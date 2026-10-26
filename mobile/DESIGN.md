# MDM HR mobile — arah desain RYUX

Redesign Flutter, 23 Oktober 2026. Pengguna meminta RYUX dan menyerahkan
keputusan desain kepada pelaksana. Arah di bawah adalah keputusan desain,
bukan hasil riset pengguna atau perubahan kebijakan HR.

## Konteks dan bukti

Sumber: `README.md`, `lib/app.dart`, `lib/shared/widgets.dart`, seluruh layar
yang diubah, dan pengujian Flutter. Tidak ada referensi aplikasi eksternal,
Figma, pen.dev, atau RYUX MCP yang dipakai.

Yang dipertahankan: empat tujuan navigasi, bahasa Indonesia, warna biru MDM,
tarik untuk menyegarkan, formulir berdasarkan jenis pengajuan, status absensi
dari server, dan alur kamera/GPS. Data pribadi dan nilai payroll tetap dari API.

Masalah yang terbaca dari kode lama: salam dan identitas mendapat bidang warna
paling besar; status serta jam absensi tidak ditampilkan bersama tindakan di
beranda; pintasan menggunakan chip; pengaturan password mendahului identitas;
gaji bersih berada setelah seluruh rincian. Warna status oranye/merah terang
dan teks abu muda perlu ditinjau kontrasnya.

## Kriteria dan pilihan

Kriteria: (1) tindakan absensi terbaca jelas bersama status hari ini,
(2) navigasi yang dikenal tetap tersedia, (3) pengajuan mudah ditemukan,
(4) komponen konsisten, (5) isi dapat dibaca pada layar kecil dan teks besar.

| Pilihan | Hierarki absensi | Navigasi | Pintasan | Konsistensi | Teks besar |
| --- | --- | --- | --- | --- | --- |
| Fokus tugas: status, tindakan, ringkasan, layanan | Kuat | Kuat | Kuat | Kuat | Kuat, grid berubah menjadi daftar |
| Dashboard ringkasan: statistik dan riwayat di atas | Lemah, tindakan lebih jauh | Kuat | Cukup | Kuat | Cukup, ringkasan lebih padat |
| Ekspresi merek: salam besar dan bidang dekoratif | Cukup | Kuat | Cukup | Cukup | Lemah, dekorasi memakan ruang |

Pilihan pertama diterapkan sesuai delegasi pengguna. Perbandingan ini adalah
penilaian struktur, bukan studi pengguna; alternatif tidak dirender berdampingan.
Trade-off: ringkasan dan riwayat berada setelah tindakan utama. Keyakinan sedang;
bukti berasal dari produk ini, tanpa bukti pembanding eksternal.

## Sistem visual dan perilaku

- Biru aksi `#2563EB`, tinta/navy `#182B49`, teks sekunder `#52637A`, kanvas
  `#F5F7FB`, garis pemisah `#E3E9F2`. Navy berasal dari keluarga warna teks yang
  sudah ada dan memusatkan perhatian pada kartu kehadiran.
- Font Roboto dengan fallback platform; isi 14/16, judul 20, display 26.
  Layar lama memiliki beberapa ukuran tambahan yang dipertahankan agar tema
  bersama tidak mengubah seluruh komposisi sekaligus. Batas tiga ukuran isi
  dikecualikan untuk label form, jumlah uang, dan judul yang berbeda peran.
- Jarak utama 4/8/12/16/20/24; kartu 20, tombol dan input 12, status 8.
  Padding 20 menjaga isi sejajar dengan margin layar.
- Satu set ikon Material; garis luar sebagai standar, ikon terisi untuk tujuan
  navigasi aktif. Tidak ada ilustrasi, logo rekaan, gradien, atau animasi baru.
- Energi tenang, variasi ritme melalui kartu absensi gelap dan bagian lainnya
  putih. Warna status selalu disertai label tertulis.
- Tombol utama minimal 52 dp, tombol sekunder 48 dp. ErrorNotice menggunakan
  ikon, pesan tertulis, dan live region. SectionHeading memiliki semantik judul.
- Lebar Android minimum yang diuji 360 dp; render utama 390 × 844.
  Pada font besar, ringkasan dan pintasan menjadi satu kolom; metadata membungkus.
  Teks penuh tetap tersedia melalui gulir. Tidak ada pemotongan nama/nilai.
- Empat tab tetap berada di bawah. Tidak ada aksi absensi yang disamarkan sebagai tab.
  Peralihan dan feedback memakai perilaku bawaan Material; pengujian gerak pada
  perangkat nyata belum dilakukan.

Asumsi desain: kegiatan harian paling penting adalah memeriksa/mencatat kehadiran.
Ini didukung susunan fitur lama, tetapi belum diuji melalui wawancara pengguna.
Tidak ada kapabilitas baru yang diasumsikan. Nama, saldo cuti, dan pengajuan pada
PNG pratinjau adalah **data contoh dari fixture pengujian**, bukan data produksi.

## Pemeriksaan dan batas verifikasi

Render Flutter diperiksa pada 390 × 844: beranda, login, pengajuan berisi,
profil, dan slip gaji kosong. Masalah font pada render pertama diperbaiki dan
dirender ulang. Tanda panah rentang tanggal diganti `s.d.` agar terbaca pada
font pratinjau. Pengujian widget menelusuri empat tab pada 360 dp dengan skala
teks 1×, 2×, dan 3,2×; mencakup nilai payroll Rp1,25 miliar dan detail slip.

Validasi kode: `flutter analyze --no-pub` tanpa temuan; `flutter test --no-pub`
meluluskan 40 pengujian, dengan satu pengujian API Docker dilewati karena mode
integrasi tidak diaktifkan. Pengujian API secara langsung tidak diklaim.
Build APK debug juga berhasil dengan `API_BASE_URL=http://127.0.0.1:3000`;
konfigurasi ini mengikuti koneksi USB `adb reverse` di README dan belum dipasang
atau diuji langsung pada HP dalam pekerjaan ini.

Perhitungan kontras sRGB: teks sekunder/putih 6,13:1, biru/putih 5,17:1,
teks terang/kartu navy 10,42:1, putih/navy 14,18:1. Warna status dipilih gelap;
audit aksesibilitas lengkap dengan TalkBack/VoiceOver belum dilakukan.

Hitungan pada beranda: satu aksen biru, satu keluarga abu kebiruan, radius
12/20 menurut peran, satu display 26, isi 14/20, satu set ikon, tanpa emoji,
logo rekaan, atau gradien. Pills hanya dipakai untuk status; kartu mengelompokkan
status/tindakan dan ringkasan terkait. Sistem merek mengikuti produk yang ada.

| Area RYUX | Hasil | Bukti / batas |
| --- | --- | --- |
| PRODUCT | PASS | Alur/data dari repo, bukti Thin; prioritas belum diteliti dengan pengguna |
| UX | PASS | Status dan tindakan berdampingan; navigasi empat tab dipertahankan |
| CONTENT | PASS | Label tindakan dan state lama dipertahankan, bantuan form diperjelas |
| UI | PASS | Fokus tugas; tanda khas berupa pasangan waktu masuk/pulang pada kartu kehadiran; ilustrasi tidak ada |
| DESIGN SYSTEM | PASS | Tema pusat, Panel, StatusPill, SectionHeading, ErrorNotice |
| ACCESSIBILITY | NOT VERIFIED | Kontras dan reflow dicek; pembaca layar/fokus perangkat belum diuji |
| RESPONSIVE | PASS | Widget test 360 dp sampai teks 3,2×; render 390 dp |
| EDGE CASES | PASS | State lama dan kontrak API dipertahankan; matriks di bawah |
| CODE QUALITY | PASS | Flutter analyze dan pengujian Flutter; lihat hasil eksekusi pada laporan perubahan |
| VISUAL QA | NOT VERIFIED | Lima render utama diperiksa; kamera, semua error, dan detail payroll belum diperiksa visual di perangkat |
| ANTI-SLOP | PASS | Data asli melalui API; data contoh hanya di test/pratinjau; hitungan di atas |
| FINAL | NOT VERIFIED | Uji pengguna dan uji perangkat nyata masih diperlukan |

| Layar/aksi | Memuat | Kosong | Gagal | Berhasil |
| --- | --- | --- | --- | --- |
| Sesi/workspace | Spinner | Tidak berlaku: wajib workspace | Pesan + Coba lagi | Home atau pendaftaran wajah |
| Login | Tombol dinonaktifkan + spinner | Form awal | ErrorNotice, input dipertahankan | Workspace |
| Kehadiran | Status pemeriksaan GPS | Belum masuk | Pesan lokasi/izin + pemulihan yang tersedia | Masuk → keluar → selesai |
| Pengajuan | RefreshIndicator | EmptyState + Buat pengajuan | Pesan refresh, data lama tetap tampil | Kartu status dan catatan HR |
| Form pengajuan | Mengirim, tombol nonaktif | Form awal | ErrorNotice/validasi, input tetap | Pesan konfirmasi dan kembali |
| Slip gaji | RefreshIndicator | EmptyState | Pesan refresh | Daftar, rincian, gaji bersih |
| PDF | Menyiapkan, tombol nonaktif | Tidak berlaku: berasal dari slip | Snackbar, bisa mencoba lagi | Share sheet bawaan |
| Password/logout | Tombol sibuk | Tidak berlaku | Pesan, bisa mencoba lagi | Keluar sesi sesuai perilaku sebelumnya |

## Uji pengguna berikutnya

Lakukan observasi dengan lima karyawan sebagai uji kualitatif. Jangan memberi
nama tombol atau langkah dalam skenario:

1. Baru tiba di kantor dan ingin mencatat kehadiran. Berhasil bila memilih
   tindakan yang sesuai dan memahami apakah pencatatan sudah selesai.
2. Ingin libur dua hari dan memeriksa perkembangannya. Berhasil bila mengirim
   jenis/tanggal yang benar lalu menemukan statusnya.
3. Ingin memeriksa pendapatan bulan tertentu dan menyimpan dokumennya. Berhasil
   bila menemukan nilai bersih serta share sheet PDF tanpa bantuan.
4. Melihat lokasi atau koneksi gagal. Berhasil bila memahami pesan dan menemukan
   jalur pemulihan yang ada tanpa mengira absensi telah tercatat.

Catat keberhasilan tugas, kebutuhan bantuan, salah pilih, dan waktu penyelesaian;
jangan menyimpulkan peningkatan terukur sebelum ada data pembanding.

## Persetujuan dan reimbursement — 24 Oktober 2026

Menu Persetujuan muncul berdasarkan kapabilitas dari server, melalui tindakan di
beranda dan badge jumlah tugas. Empat tab utama tetap tersedia bagi lead untuk
absensi dan pengajuan pribadinya. Inbox memisahkan tugas menunggu dengan riwayat;
detail memperlihatkan pemohon, rincian, bukti privat, urutan persetujuan, dan
riwayat keputusan. Penolakan dan permintaan revisi memerlukan alasan. Pengajuan
yang direvisi membuka kembali form dengan rincian sebelumnya.

Form reimbursement memakai rincian berulang dengan tanggal, deskripsi, kategori,
nominal, dan satu bukti per rincian. Total dihitung langsung; rekening berasal
dari profil karyawan. Dokumen final tersedia sesudah seluruh tahap selesai.
Pengunduhan menggunakan share sheet sistem dengan ekstensi PDF/XLSX yang sesuai.

| Gerbang | Hasil dan bukti |
| --- | --- |
| UX dan konten | Status tahap, tindakan sesuai kewenangan, alasan revisi, dan pesan gagal tersedia; belum diuji dengan pengguna kantor |
| Reflow | Form, detail, dan inbox lulus widget test 360 dp dengan skala teks 3,2× |
| Akses dan konkurensi | Server menguji pemisahan pemohon/approver/finance, versi keputusan, dan larangan akses dokumen pengguna lain |
| Kualitas kode | Flutter analyze bersih; 45 tes lulus, satu tes integrasi API dilewati; APK Android arm64 berhasil dibangun |
| Visual | Render form, inbox, dan detail diperiksa; PDF dua halaman diperiksa termasuk logo, rincian, rekening berawalan nol, dan stempel |
| Perangkat | Pemilih file, share sheet, dan alur persetujuan pada HP fisik belum diverifikasi; perangkat USB tidak terdeteksi saat pemeriksaan akhir |
| Batas penerimaan | Pembaca layar, uji pengguna kantor, dan build iOS masih perlu verifikasi |

Tambahkan skenario observasi: staf mengirim dua pengeluaran; lead meminta revisi;
staf mengirim ulang; lead dan finance menyetujui; staf menemukan PDF final. Lalu
uji lead mengajukan cuti kepada atasannya tanpa kehilangan akses absensi.

## Pemulihan pemindai — 24 Oktober 2026, versi 1.1.3

Stack trace release di layar pendaftaran ditelusuri melalui mapping R8 ke
inisialisasi logger ML Kit dengan SharedPrefManager null. Aturan keep menjaga
graf komponen ML Kit/Firebase pada build release. Pemindai memakai pesan
pemulihan singkat, dan judul putih terbaca pada latar gelap.

Flutter analyze bersih; 48 tes lulus, satu tes live API dilewati. Widget test
menguji pesan gagal dan tindakan pindai ulang pada 360 dp dengan teks 3,2×.
Probe native di Xiaomi Android 13 melewati pemrosesan NV21 dan PNG tanpa
InputImageConverterError; pemeriksaan awal jumlah wajah pada PNG kosong gagal
karena model melaporkan deteksi. Probe selanjutnya melaporkan jumlah deteksi
secara terpisah: pemeriksaan ini menguji konversi/inisialisasi SDK, bukan akurasi
model atau identitas. Pendaftaran wajah nyata dan absensi perlu diuji pengguna.

## Kejelasan alur persetujuan — 24 Oktober 2026, versi 1.1.4

Sumber observed: pengguna bingung dengan “Semua wajib menyetujui” dan “Cukup
salah satu”, lalu menyetujui penjelasan berdasarkan jumlah orang dan status.
Pilihan: satu orang disebut langsung pada tahap aktif; beberapa orang tetap
menampilkan daftar nama dan aturan penyelesaian dengan hitungan persetujuan
unik yang sah. Tahap berikutnya menunggu tahap sebelumnya. Status selesai,
ditolak, revisi, dan proses yang terhenti tidak meminta tindakan baru.
Trade-off: informasi lebih panjang untuk grup, tetapi tidak menampilkan istilah
konfigurasi any/all tanpa konteks. Aturan persetujuan server tetap digunakan.

| Gerbang RYUX | Hasil dan bukti |
| --- | --- |
| PRODUCT | PASS · permintaan dan pilihan pengguna menjadi spesifikasi · Strong |
| UX | PASS · nama penanggung jawab dan status tahap berasal dari snapshot API |
| CONTENT | PASS · tidak ada lagi label aturan tanpa konteks |
| UI | PASS · task UI; komponen Panel dan tipografi aplikasi; tanpa ilustrasi |
| DESIGN SYSTEM | PASS · memakai komponen dan tema yang sudah ada |
| ACCESSIBILITY | PASS · lingkup perubahan teks; uji teks 3,2×, struktur semantik tetap; pembaca layar belum diuji |
| RESPONSIVE | PASS · widget test 360 dp, teks 3,2×, dua atasan termasuk nama panjang |
| EDGE CASES | PASS · satu/banyak/kosong, persetujuan parsial, tahap berikut, selesai, ditolak, revisi dan terhenti diuji |
| CODE QUALITY | PASS · Flutter analyze bersih; 6 tes ringkasan dan 5 tes alur terkait lulus |
| VISUAL QA | PASS · render Flutter RepaintBoundary 390 dp, teks normal; tahap atasan aktif dan finance berikutnya diperiksa |
| ANTI-SLOP | PASS · tidak menambah dekorasi, aturan bisnis, atau data produksi; fixture render diberi nama contoh |
| FINAL | PASS · sebatas pemeriksaan di atas; belum diuji pengguna kantor/perangkat fisik untuk perubahan ini |

Matriks tampilan × status: detail × satu approver aktif menyebut nama; detail ×
grup all menampilkan jumlah; detail × grup any menjelaskan salah satu petugas;
detail × tahap berikut menunggu tahap sebelumnya; detail × selesai menampilkan
hasil; detail × revisi/ditolak/terhenti tidak menampilkan instruksi persetujuan
aktif. Keadaan loading/error dan tombol keputusan memakai alur yang ada.
Render uji lokal: `tmp/mobile-approval-flow-finance.png` (fixture, bukan produksi).
Observasi pilot: minta staf menjelaskan siapa yang perlu bertindak sekarang dan
apakah finance boleh dilewati; ukur pemahaman sebelum menyimpulkan perbaikan UX.


## Pilot 25 Oktober 2026 — versi 1.2.0

Kalender cuti, pembaruan pengajuan, foto bukti, pemulihan revisi, dan alasan
pulang awal mengikuti permintaan pengguna. Keputusan, bukti render, matriks
keadaan dan Delivery Gate dicatat di `../docs/pilot-improvements-2026-10-25.md`.
