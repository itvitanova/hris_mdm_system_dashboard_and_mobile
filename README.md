# PeopleOS · HRIS MDM

Aplikasi HRIS/HRMS berbahasa Indonesia dengan antarmuka biru profesional, backend Go berlapis, frontend Next.js App Router, komponen shadcn/ui yang disesuaikan, dan PWA untuk akses karyawan dari ponsel.

Aplikasi **Flutter Android/iOS** tersedia terpisah di [`mobile`](mobile/README.md), memakai API Go dan PostgreSQL yang sama. Mendukung absensi dengan pemeriksaan mock location, pengajuan karyawan, profil, dan slip PDF. Play Integrity belum diintegrasikan; batas perlindungan dan petunjuk build dijelaskan pada README mobile.

**Status: MVP yang dapat dijalankan dan dikembangkan.** Integrasi penyedia biometrik serta kebijakan payroll perusahaan perlu dikonfigurasi sebelum pemakaian operasional. Tidak ada verifikasi wajah palsu atau tombol bypass absensi.

Pratinjau: [dashboard desktop](docs/images/dashboard.png) · [ruang karyawan di ponsel](docs/images/mobile.png).

## Menjalankan dengan Docker

Prasyarat: Docker Desktop dengan Linux containers dan Docker Compose. Jalankan dari root proyek:

```powershell
Copy-Item .env.example .env
```

Isi `POSTGRES_PASSWORD` dengan password unik yang aman untuk URL (misalnya hexadecimal). Untuk data contoh, set `DEMO_SEED=true`. Untuk pemasangan tanpa demo, gunakan `DEMO_SEED=false`, isi `BOOTSTRAP_ADMIN_EMAIL` dan `BOOTSTRAP_ADMIN_PASSWORD` minimal 12 karakter. File `.env` lokal tidak masuk version control. Jangan menimpa `.env` yang sudah digunakan.

```powershell
docker compose up --build -d --wait
docker compose ps
```

Compose menjalankan PostgreSQL 17, API Go, dan Next.js production standalone. PostgreSQL dan API hanya tersedia di jaringan internal Docker. Frontend dipublikasikan pada `127.0.0.1:3000`. Urutan startup menunggu health check database dan API, termasuk pemeriksaan koneksi database.

Buka **http://localhost:3000**. Tombol **Admin demo** dan **Karyawan demo** tersedia hanya jika API dijalankan dengan `DEMO_SEED=true`.

| Akses demo | Email | Kata sandi |
| --- | --- | --- |
| Admin | admin@mdm.local | DemoHris2026! |
| Karyawan | nadia@mdm.local | DemoHris2026! |

Data contoh: 18 karyawan fiktif, riwayat absensi 7 hari, pengajuan, serta stok GA. Semua absensi seed ditandai sebagai **Contoh**, bukan verifikasi biometrik. Data PostgreSQL disimpan pada named volume `hrismdm_postgres-data` dan bertahan setelah restart atau rebuild. Jangan gunakan akun demo pada deployment operasional.

Bootstrap hanya membuat admin jika belum ada akun. Backend menggunakan `DATABASE_URL` melalui driver pgx, tanpa fallback database lokal. Contoh konfigurasi development tersedia pada `backend/.env.example` dan `frontend/.env.example`; backend membaca environment proses, bukan file `.env` secara otomatis. Dalam Docker, Compose memasukkan environment tersebut.

Perintah operasional:

```powershell
docker compose logs --tail 100 backend frontend postgres
docker compose restart
docker compose stop
docker compose start --wait
```

Jangan menghapus volume PostgreSQL bila data masih diperlukan. Ubah `WEB_PORT` dan `APP_ORIGIN` bersama-sama jika menggunakan port frontend lain.

## Fitur

| Modul | Fitur yang sudah tersedia |
| --- | --- |
| Dashboard | KPI dari database, grafik 7 hari, komposisi departemen, pengajuan terbaru, ulang tahun bulan ini, ekspor CSV |
| Karyawan | Tambah/edit profil, tanggal lahir, alamat, kontak, departemen, jabatan, status, gaji pokok, saldo cuti, pembuatan akun admin/karyawan |
| Master Data | Submenu departemen, jabatan, dan Service Point / HQ (koordinat, radius, zona waktu, jam masuk), kode/nama unik, tambah/edit, aktif/nonaktif, hapus data yang belum dipakai; formulir karyawan memilih master melalui dropdown |
| Kehadiran | Kamera depan, GPS, masuk/pulang, pencocokan wajah dan liveness melalui provider, riwayat harian, filter dan ekspor |
| Cuti | Pengajuan rentang tanggal, validasi saldo, deteksi tumpang tindih saat persetujuan, pengurangan saldo secara atomik |
| Reimbursement | Nominal, keperluan/referensi bukti dan persetujuan; dibayar di luar payroll |
| Petty cash | Pengajuan dana, keperluan, persetujuan dan catatan keputusan |
| General Affair | Katalog barang habis pakai, stok minimum, mutasi masuk/keluar, pencegahan stok negatif, riwayat, pengajuan kebutuhan |
| Lembur | Pengajuan jam per tanggal, persetujuan, estimasi komponen payroll |
| Payroll | Gaji pokok, tunjangan/bonus manual per periode, lembur disetujui, PPh21 TER/manual, BPJS/JHT/JP terperinci, impor XLSX, slip PDF formal, CSV dan finalisasi terkunci |
| PWA | Manifest, ikon, instalasi layar utama, ruang karyawan responsif, kamera/GPS, halaman offline |
| Akses | Login bcrypt, sesi cookie HttpOnly, logout/revokasi, peran admin/karyawan, pembatasan data milik sendiri, audit mutasi |

Karyawan hanya menerima profil, absensi, pengajuan, dan payroll miliknya dari API. Menyembunyikan menu bukan satu-satunya pembatasan: pemeriksaan akses dilakukan kembali di service backend. Pengajuan sendiri tidak dapat disetujui oleh admin yang mengajukan; buat akun admin kedua untuk kebutuhan tersebut.

## Arsitektur

```text
backend/
  cmd/api/                 # composition root, konfigurasi, shutdown
  internal/domain/         # entity dan kontrak Store
  internal/service/        # aturan bisnis per modul
    master_data.go         # registri master, CRUD, validasi referensi, backfill
    auth.go                # autentikasi dan provisioning
    app.go                 # karyawan, pengaturan, transaksi/audit
    attendance.go          # geofence dan FaceProvider
    requests.go            # cuti / reimbursement / petty cash / GA / lembur
    payroll.go             # payroll dan finalisasi
    inventory.go           # stok dan mutasi
  internal/repository/     # adapter PostgreSQL/pgx dan migrasi SQL
  internal/transport/      # HTTP routing, decoding, cookie, pembatasan akses
frontend/
  src/app/                 # Next.js App Router, layout dan tema
  src/components/ui/       # komponen shadcn-style yang dimiliki proyek
  src/components/          # dashboard, workspace, modul data, forms, kamera
  src/lib/                 # tipe, API client, ekspor, utilitas
  public/                  # manifest, ikon, service worker, halaman offline
  tests/                   # skenario browser Playwright
```

Alur dependensi: **HTTP → service → kontrak domain ← repository PostgreSQL**. Module service tidak bergantung pada transport atau driver database. `FaceProvider` juga dapat diganti tanpa mengubah aturan kehadiran.

Master departemen dan jabatan dikelola admin pada menu **Master Data**. Karyawan memakai `departmentId` dan `positionId`; nama tampilan diselesaikan dari master oleh server. Saat startup, departemen/jabatan pada karyawan versi lama otomatis dibuatkan master dan dihubungkan secara idempoten tanpa mengganti ID master pada restart. Perubahan nama master mengikuti profil karyawan, sedangkan snapshot payroll historis dipertahankan. Master yang masih direferensikan karyawan tidak boleh dihapus; nonaktifkan untuk menghentikan pemilihan baru. Penempatan lama pada master nonaktif tetap dapat dipertahankan saat mengedit profil.

Untuk menambahkan jenis master berikutnya, daftarkan kind dan label pada `backend/internal/service/master_data.go` serta submenu pada `frontend/src/lib/master-data.ts`, lalu perluas tipe View dan referensi entity bila diperlukan. Endpoint bersama `GET/POST /api/master-data/{kind}` dan `DELETE /api/master-data/{kind}/{id}` memakai allowlist kind, otorisasi admin, audit, serta transaksi yang sama.

PostgreSQL menyimpan `records(collection, id, data JSONB)` dengan primary key gabungan, validasi payload objek, serta timestamp pembuatan/perubahan. Migrasi SQL tertanam dijalankan saat startup dan dicatat di `schema_migrations`. Driver pgx menggunakan connection pool. Transaksi menggabungkan perubahan saldo/stok, keputusan dan audit; transaction-level advisory lock per schema melindungi operasi baca-ubah-tulis antar-instance API. Lock ini masih menserialisasi seluruh write bisnis per schema. Pembacaan daftar belum dipaginasi; tabel ternormalisasi, pencarian/paginasi SQL, dan lock per resource merupakan pengembangan berikutnya.

## Absensi: radius dan wajah

1. Admin mengelola **Master Data → Service Point / HQ**: kode, nama, alamat, latitude/longitude, radius (default 100 m; 10–10000 m), zona WIB/WITA/WIT, dan jam masuk. Lokasi yang disimpan melalui dashboard otomatis aktif tanpa centang tambahan. Lokasi HQ lama dimigrasikan otomatis beserta penempatan karyawan lama. Pengaturan lokasi pada halaman Pengaturan tetap tersinkron dengan HQ bawaan.
2. Admin mendaftarkan data karyawan dan membuat akun melalui dashboard. Tidak ada registrasi akun mandiri.
3. Pada login pertama di Flutter, karyawan mendaftarkan wajah melalui kamera depan HP. Server menyimpan foto referensi di koleksi privat `face_references`; admin dapat melihatnya pada detail karyawan → **Lihat foto referensi wajah**. Pendaftaran awal tidak memerlukan lokasi kantor. Penggantian referensi setelah terdaftar hanya diizinkan untuk admin.
4. Server memvalidasi koordinat, foto, status enrollment, akurasi GPS maksimal 50 m, dan rumus Haversine. Untuk izin lokasi terbatas: **jarak + akurasi GPS ≤ radius penugasan**.
5. Server memanggil provider untuk pencocokan identitas dan liveness. Baru setelah keduanya berhasil, absensi dicatat. Satu masuk dan satu pulang per tanggal di zona waktu lokasi penugasan.

Admin memilih `servicePointId` di data karyawan. Switch **Izinkan absensi dari lokasi mana saja** (`allowAnyLocation`) default nonaktif dan hanya admin yang boleh mengubahnya. Izin ini hanya melewati batas radius: GPS valid/akurat dan verifikasi wajah tetap wajib. Lokasi nonaktif tidak menerima absensi. Server membaca ulang izin setelah verifikasi wajah sebelum mencatat absensi. Tanggal dan keterlambatan mengikuti zona waktu dan jam masuk lokasi penugasan.

Setiap absensi menyimpan snapshot terpisah `checkInLocation` dan `checkOutLocation`: koordinat aktual, akurasi, jarak, serta lokasi/izin yang berlaku saat itu. Perubahan master atau penempatan tidak mengubah riwayat tersebut. Dashboard menampilkan tautan Google Maps untuk master lokasi, profil penugasan, serta lokasi aktual masuk dan keluar; koordinat juga tersedia di ekspor CSV. Riwayat lama tanpa koordinat keluar tidak dibuatkan titik keluar perkiraan. Endpoint `/api/service-points` menyediakan GET (karyawan hanya lokasi sendiri), POST, dan DELETE `/{id}` (admin). Lokasi terpakai tidak dapat dihapus.

Flutter memeriksa GPS otomatis ketika halaman absensi dibuka, setiap 15 detik selama halaman aktif, serta sebelum membuka kamera dan saat mengirim foto. Tidak ada tombol periksa lokasi atau mode pratinjau absensi. Wajah tidak cocok, gagal anti-spoofing, atau lokasi tidak memenuhi radius akan menolak absensi.

Compose menyertakan layanan internal `face-service` dengan DeepFace SFace untuk pencocokan wajah dan FasNet untuk passive anti-spoofing. Model diunduh saat build, bukan ketika karyawan mengirim absensi. Isi `FACE_PROVIDER_KEY` di `.env` dengan secret acak yang sama untuk backend dan layanan wajah, lalu jalankan `docker compose up -d --build`. Layanan ini tidak membuka port ke host dan tidak menyimpan foto sendiri. Foto referensi disimpan di PostgreSQL HRIS, hanya dikirim ke layanan internal ketika dibandingkan. Layanan eksternal tetap dapat digunakan melalui `FACE_PROVIDER_URL`. Uji akurasi matching dan anti-spoofing pada perangkat/pencahayaan target sebelum operasional; passive anti-spoofing bukan challenge sekali pakai dan belum mencegah replay payload.

User dapat mengganti password melalui **Profil → Ganti password**, juga dari layar pendaftaran wajah. Password lama wajib benar, password baru 12–72 byte dan berbeda. Setelah berhasil semua sesi akun dicabut, lalu user login kembali. Endpoint: `POST /api/auth/password` dengan `currentPassword` dan `newPassword`.

### Kontrak provider

```text
FACE_PROVIDER_URL=http://face:8000
FACE_PROVIDER_KEY=<service-token>
```

Backend mengirim `POST {URL}/enroll` dan `POST {URL}/verify` dengan header `Authorization: Bearer {KEY}`:

```json
{
  "employeeId": "EMP-002",
  "image": "data:image/jpeg;base64,...",
  "referenceImage": "data:image/jpeg;base64,..."
}
```

`referenceImage` diisi oleh backend dari database hanya pada verifikasi; klien tidak memilih referensinya. Enrollment yang diterima: HTTP 200 dengan `{"success":true}`. Verifikasi yang diterima: HTTP 200 dengan **semua** `{"success":true,"matched":true,"live":true}`. Timeout 20 detik, respons gagal/missing flag selalu ditolak. Provider bertanggung jawab atas kualitas matching dan passive liveness. Foto kandidat absensi tidak disimpan pada database HRIS atau audit log; foto referensi awal disimpan privat bersama waktu enrollment, terpisah dari payload workspace. Referensi lama tanpa foto perlu didaftarkan ulang oleh admin.

Geolokasi browser dapat dipalsukan. PWA ini melakukan validasi jarak di server tetapi belum memiliki device attestation, deteksi mock location, atau mekanisme anti-replay biometrik berbasis challenge sekali pakai. Verifikasi provider nyata dan pengujian lapangan pada perangkat target tetap diperlukan.

## Batas aturan bisnis awal

- **Cuti** menggunakan hari kalender inklusif; belum ada kalender hari libur, jadwal shift, akrual, jenis cuti terpisah atau persetujuan bertingkat.
- **Lembur** di payroll memakai rumus estimasi `gaji pokok / 173 × 1,5 × jam disetujui`. Ini placeholder kebijakan perusahaan, bukan implementasi peraturan upah lembur. Satu pengajuan berlaku untuk satu tanggal.
- **Payroll** mengikuti aturan komponen pada bagian di bawah. Prorata, potongan ketidakhadiran, THR, tambahan komponen di luar empat pendapatan, dan penyesuaian slip yang telah final belum disediakan. Persetujuan lembur setelah finalisasi membutuhkan proses koreksi terpisah yang belum tersedia.
- **Finalisasi payroll** tidak mentransfer dana. **Persetujuan petty cash/reimbursement** juga bukan bukti pembayaran. **Persetujuan GA** tidak mengeluarkan barang otomatis; petugas mencatat mutasi stok terpisah.
- Bukti pengajuan berupa keterangan/referensi teks; upload lampiran privat, tanda tangan dan penyimpanan berkas belum tersedia.
- Notifikasi dalam aplikasi mencerminkan pengajuan menunggu saat data dimuat; belum ada email, push notification, atau realtime socket.
- Belum ada reset kata sandi mandiri, SSO/MFA, pengelolaan masa kerja multi-kontrak, multi-kantor, atau proses penghapusan biometrik. Admin melakukan provisioning akun baru; perubahan email profil ikut memperbarui email login.

## Payroll dan PPh21

1. Lengkapi **Status PTKP** pada profil karyawan. Pilihannya TK/0, TK/1, TK/2, TK/3, K/0, K/1, K/2, K/3. Profil lama tidak diisi otomatis dengan asumsi status pajak. Status pada slip merupakan snapshot; perubahan PTKP khusus satu draft tidak mengubah profil karyawan untuk bulan berikutnya.
2. Buat draft per periode. **Bruto = gaji pokok + tunjangan + lembur + bonus**. Tunjangan dan bonus mulai **Rp0 pada setiap periode baru**. Gunakan **Edit komponen** untuk mengisi nilai per karyawan. Lembur diambil dari pengajuan disetujui berdasarkan tanggalnya dengan rumus existing. Reimbursement tidak masuk bruto, potongan, maupun THP payroll.
3. Januari-November memakai **PPh21 = bruto x tarif TER**. Kategori A: TK/0, TK/1, K/0; B: TK/2, TK/3, K/1, K/2; C: K/3. Tabel diambil dari `TARIF TER PPH 21.xlsx`, direkam bersama hash sumber pada `backend/internal/service/tax/ter.json`, dan ditanam ke binary API. Ambang workbook adalah batas bawah eksklusif: tepat Rp5.400.000 kategori A tetap 0%, di atasnya masuk 0,25%. Semua hasil uang dibulatkan ke rupiah terdekat.
4. Potongan sesuai kebijakan yang disepakati: **BPJS Kesehatan 1% gaji pokok, JHT 2% gaji pokok, JP 1% gaji pokok**. Ketiganya dihitung dari gaji pokok saja dan tidak memakai plafon iuran otomatis. Bruto pajak dibatasi pada empat komponen pendapatan yang diminta; tidak ditambahkan komponen iuran perusahaan.
5. Desember otomatis meminta **PPh21 manual periode tersebut**, bukan total pajak setahun. Untuk karyawan berhenti sebelum Desember, HR dapat menandai **Masa pajak terakhir** pada draft. HR juga dapat memakai mode manual untuk koreksi bulan biasa dengan catatan alasan. PPh21 negatif hanya diizinkan pada masa pajak terakhir dan menambah THP sebagai pengembalian kelebihan potong. Nilai **0 harus diisi eksplisit**; kosong berarti belum lengkap.
6. **Total potongan = PPh21 + BPJS Kesehatan + JHT + JP**. **THP = bruto - total potongan**. Draft tanpa PTKP atau nominal pajak manual yang diperlukan ditandai belum lengkap dan tidak dapat difinalkan. Angka THP draft yang pajaknya belum lengkap masih dapat berubah.
7. **Template Excel / Impor PPh21** tersedia setelah memilih satu periode dengan draft Desember atau draft bertanda masa pajak terakhir. Template `.xlsx` memuat `ID Karyawan`, `Nama Karyawan`, `Periode`, `PTKP`, `PPh21`, `Catatan`, `Revisi`. Isi PTKP, nominal rupiah bulat, dan catatan. ID/periode/revisi jangan diubah. Maksimal 3 MB / 5000 baris. Formula, ID duplikat, periode berbeda, revisi kedaluwarsa, serta slip final ditolak. Seluruh impor atomik: satu kesalahan membatalkan semua perubahan.
8. Menghitung ulang periode yang sama memperbarui gaji pokok/lembur dan mempertahankan tunjangan, bonus, dan input pajak HR pada draft. Input tersebut tidak terbawa ke periode baru. Periode dengan slip final tetap dikunci dari perhitungan ulang. Revisi slip melindungi data dari perubahan bersamaan oleh beberapa admin.
9. Atur nama PT/perusahaan, alamat dan logo PNG/JPEG (maksimal 300 KB) di **Pengaturan** sebelum membuat draft. Identitas perusahaan disimpan pada slip sehingga dokumen final tidak berubah ketika pengaturan diubah. Untuk memperbarui identitas pada draft yang sudah ada, hitung ulang periode sebelum finalisasi. PDF A4 memuat identitas karyawan, PTKP, kategori/tarif, pendapatan, masing-masing potongan, total, THP, status serta pencatat finalisasi. Draft memiliki label DRAFT. Unduhan memerlukan sesi login; karyawan hanya dapat mengunduh slipnya sendiri.

Draft format lama otomatis diperbarui saat startup dan versi aslinya diarsipkan pada koleksi `payroll_legacy`. Slip historis yang sudah final dipertahankan dengan perhitungan lama dan ditandai sebagai historis. Font PDF Lato disertakan dengan lisensi OFL pada `backend/internal/document/assets/OFL.txt`.

## PWA dan deployment

PWA memakai aplikasi web yang sama, bukan APK terpisah. Buka **Ruang karyawan → Pasang aplikasi**. Chrome/Android mendukung install prompt bila memenuhi syarat; Safari/iPhone melalui Bagikan → Tambahkan ke Layar Utama.

Kamera, GPS, dan instalasi membutuhkan **HTTPS** pada ponsel. `http://localhost` dapat dipakai di komputer pengembangan, tetapi IP LAN HTTP tidak cukup untuk kamera/GPS. Untuk uji ponsel gunakan reverse proxy HTTPS ke Next.js dan set `APP_ORIGIN` sesuai domain. Frontend mem-proxy `/api/*` ke backend sehingga cookie tetap same-origin.

Gunakan `docker compose up --build -d --wait` untuk deployment. Frontend memakai Next.js standalone dan berjalan sebagai user non-root; API juga berjalan sebagai user non-root. Lindungi volume PostgreSQL dan backup karena berisi data HR sensitif. Deployment ini tidak menyiapkan sertifikat TLS secara otomatis.

Atur `COOKIE_SECURE=true` di belakang HTTPS dan `APP_ORIGIN=https://domain-anda`. Pada reverse proxy pertahankan origin/host dan batasi akses backend ke jaringan internal. Rate limit login disediakan untuk satu proses, tetapi identitas IP di belakang proxy belum memakai trusted-proxy middleware; tambahkan pembatasan di edge untuk produksi.

Service worker hanya menyimpan ikon dan halaman offline publik. Data API, foto, halaman terautentikasi dan pengajuan tidak disimpan offline. Saat koneksi terputus pengguna diminta menyambungkan kembali.

## Pengujian

```powershell
docker compose --profile test run --build --rm backend-test
```

Test backend dan `go vet` berjalan dalam Docker terhadap PostgreSQL test terpisah dengan penyimpanan tmpfs. Setiap test integrasi memakai schema acak yang dibersihkan setelah selesai. Test mencakup rollback transaksi, JSONB upsert, isolasi data, revokasi sesi, larangan self-approval, pemotongan cuti sekali, mutasi stok dari service independen, payroll draft/final, geofence, penolakan liveness, serta duplikasi absensi. Provider wajah palsu hanya digunakan dalam test. `go test` di luar Docker membutuhkan `TEST_DATABASE_URL`; test integrasi ditandai skip jika variabel tersebut tidak diisi.

```powershell
cd frontend
npm ci
npm run typecheck
npx playwright install chromium
$env:TEST_DATABASE_URL = 'postgres://hris_test:hris_test_local@127.0.0.1:55432/hris_test?sslmode=disable'
npm run test:e2e
```

Jalankan profil test Docker terlebih dahulu agar `postgres-test` tersedia pada localhost:55432. Playwright membutuhkan Go 1.25+ dan Node.js 22+ di host; ia menjalankan API demo pada 8081 dan Next.js pada 3001, dengan schema PostgreSQL baru per run. Menguji login, karyawan, stok, payroll, reimbursement → persetujuan, pembatasan akses, serta layout ponsel dan PWA. Artefak browser berada di `frontend/test-results`. Schema Playwright berada pada database tmpfs test dan hilang ketika container database test dihentikan. Aplikasi utama tetap berjalan sepenuhnya di Docker.

## Migrasi satu kali dari database versi awal

Runtime aplikasi dan semua test integrasi sudah menggunakan PostgreSQL. File SQLite lama, bila ada, hanya dipertahankan sebagai backup. `scripts/export-legacy.mjs` adalah alat migrasi opsional yang membaca file lama secara read-only memakai Node.js 22.14+, bukan dependency runtime aplikasi.

Sebelum memulai backend pada database PostgreSQL baru yang kosong:

```powershell
docker compose up -d --wait postgres
docker compose build backend
```

Jalankan `node scripts/migrate-legacy.mjs`, lalu mulai stack. Script menyimpan ekspor JSON pada `backend/data/legacy-export.json` dan meneruskannya sebagai byte UTF-8 ke importer Docker, sehingga aman dari perubahan encoding pipeline PowerShell. Importer menolak target yang sudah berisi data dan melakukan seluruh impor dalam satu transaksi. Sesi login lama tidak diimpor sehingga pengguna harus login kembali. Jangan menjalankan seed/bootstrap lebih dahulu pada target yang akan diimpor. File database lama tidak dihapus atau dimodifikasi.

## Referensi framework

- [Next.js App Router](https://nextjs.org/docs/app/getting-started)
- [shadcn/ui — manual installation](https://ui.shadcn.com/docs/installation/manual)

Versi dependency aktual dikunci di `frontend/package-lock.json` dan `backend/go.sum`.
