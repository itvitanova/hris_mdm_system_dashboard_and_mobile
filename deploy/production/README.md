# HRIS MDM — deployment produksi

Domain: https://hris.mdmcorp.co.id
Server: ubuntu@43.173.20.104 (SSH port 22)
Direktori: /opt/hrismdm
Release aplikasi: pilot-20261025-b2013
Frontend: pilot-20261025-nav (FRONTEND_RELEASE; opsional, default HRIS_RELEASE).
APK: 1.2.0, build dasar Flutter 2013, signing key pilot yang sama.

## Layanan dan jaringan

Docker Compose menjalankan frontend Next.js, backend Go, PostgreSQL 17, dan
provider wajah DeepFace/TensorFlow. Semua memakai restart policy dan log rotation.
Frontend hanya dipublikasikan ke 127.0.0.1:8000; Nginx host melayani HTTPS.
Database, API, dan provider wajah tidak memiliki port publik.

CPU VM AMD EPYC mengekspos AVX/AVX2. Build model dan pemeriksaan provider berhasil.
COMPOSE_PROFILES=face dan FACE_PROVIDER_URL=http://face:8000 harus aktif.
APP_ORIGIN=https://hris.mdmcorp.co.id, COOKIE_SECURE=true, DEMO_SEED=false.

DNS A hris.mdmcorp.co.id sudah menuju 43.173.20.104 saat migrasi, sehingga tidak
memerlukan perubahan record. Nginx kini melayani HRIS langsung; domain lama
hrms.mdmcorp.co.id dialihkan ke domain HRIS. Sertifikat dan pembaruan otomatis
menggunakan Certbot host, dengan webroot /var/www/letsencrypt.

## Konfigurasi dan database

.env berisi credential privat dengan izin 600. compose.yaml dan init-db.sh
tersedia di direktori yang sama. Role aplikasi hrismdm memiliki database sendiri
dan tidak memiliki SUPERUSER/CREATEDB/CREATEROLE. Role hris_admin dipakai untuk
administrasi database. Volume persisten: hrismdm-prod_postgres-data.

Akun dan konfigurasi HRIS dipulihkan dari snapshot akhir server 192.168.1.33.
Data sumber dibekukan sebelum dump; hash diverifikasi sebelum restore. Backend
sumber tetap berhenti agar tidak ada dua database aktif menerima perubahan.
Server lama mengalihkan domain jtsid.secaudit.web.id ke domain HRIS baru.
PostgreSQL lama dan arsip migrasi dipertahankan sebagai cadangan.

Frappe HR telah dihapus dari seluruh 10 container proyek hrms, termasuk
konfigurator yang berhenti. Cadangan database MariaDB, sites, /opt/hrms, dan
konfigurasi Nginx/sertifikat tersimpan di backups/frappe-before-hris-*.
Volume lama dipertahankan untuk pemulihan; timer backup Frappe dinonaktifkan.
Data Frappe tidak diimpor sebagai data karyawan HRIS secara otomatis.

## Operasional

    cd /opt/hrismdm
    docker compose ps
    docker compose logs --tail 100 backend frontend face postgres
    docker compose up -d --wait
    ./backup.sh
    systemctl status hrismdm-backup.timer

Backup database berjalan pukul 02.30 Asia/Jakarta. File custom pg_dump ada di
backups/hrismdm-*.dump. Retensi masih manual; salin backup ke tujuan terpisah
sesuai kebijakan kantor. Backup .env dan material signing Android secara privat.
File akses admin diberikan terpisah; jangan membagikannya kepada peserta pilot.

Untuk pemulihan, buat database recovery baru lalu gunakan pg_restore. Jangan
menimpa volume produksi atau memakai down -v. Dump migrasi awal tersedia sebagai
backups/migration-source.dump. Backup sebelum Frappe dihapus disimpan terpisah.

## Pembaruan

Build dan uji image, beri tag release baru yang tidak ditimpa, transfer arsip
image melalui SSH, verifikasi SHA256, lalu docker load. Jalankan backup sebelum
mengubah HRIS_RELEASE di .env dan docker compose up -d --wait. Simpan image versi
sebelumnya dan tinjau kompatibilitas schema sebelum downgrade.

Provider wajah dapat dibangun dari face-source di server. Model dipersiapkan
saat image dibangun. Jika startup gagal, periksa log; jangan melewati pemeriksaan
wajah/liveness atau mengembalikan hasil cocok buatan.

## APK dan penerimaan pilot

APK ditandatangani dengan key yang sama untuk pembaruan mendatang. Cadangan key
ada di private/android dan komputer pengembangan; password tidak masuk Git.
Distribusi:
- /downloads/mdm-hr-1.2.0-arm64.apk
- /downloads/mdm-hr-1.2.0-armv7.apk
- /downloads/mdm-hr-latest-arm64.apk (tautan pembaruan pilot)
- /downloads/SHA256SUMS

APK memakai HTTPS domain baru dan tidak membutuhkan komputer atau adb reverse.
APK debug lama memiliki signature berbeda dan harus dihapus sebelum memasang
release. Release pilot sebelumnya dengan signing key yang sama dapat diperbarui.

Admin perlu menyiapkan lokasi/radius kantor, karyawan dan akun, atasan langsung,
rekening, petugas finance, serta alur persetujuan. Lihat panduan approval di
repositori: docs/approval-reimbursement.md. Akun demo tidak aktif.

Validasi produksi mencakup login/logout, cookie aman, penolakan origin asing,
request 4 MiB melalui proxy, dashboard browser, dan koneksi API melalui klien
Flutter. Provider diuji sehat, menolak key tidak sah dan gambar kosong. Kamera,
GPS, enrollment wajah orang nyata, dan alur approval lintas HP tetap harus diuji
bersama peserta pilot. iOS membutuhkan build dan signing di Mac.

Pemeriksaan akhir: 59 tes mobile lulus (satu tes live dilewati pada suite umum),
tes live API dijalankan terpisah dan lulus, Flutter analyze bersih, konversi
workbook contoh ke PDF berhasil dalam container produksi, serta simulasi
pembaruan sertifikat Certbot berhasil. SHA256 kedua APK di server sesuai dengan
hasil build lokal. Tidak ada data karyawan contoh yang ditambahkan saat smoke test.

Panduan rilis 25 Oktober: docs/pilot-improvements-2026-10-25.md.
