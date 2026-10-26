# Approval organisasi dan reimbursement

## Konfigurasi oleh admin

1. Buka Karyawan, edit setiap karyawan, lalu tetapkan **Atasan langsung**.
   Jangan memilih diri sendiri; rantai yang berputar ditolak server. Pimpinan
   tertinggi boleh tanpa atasan, tetapi jalur pengajuannya harus menggunakan
   approver tertentu melalui konfigurasi alur.
2. Lengkapi telepon, nama bank, nama pemilik rekening, dan nomor rekening.
   Nomor rekening disimpan sebagai teks agar nol di depan tidak hilang.
   Rekening digunakan untuk payroll/reimbursement; aplikasi tidak mentransfer uang.
3. Tandai karyawan yang berwenang sebagai **Petugas verifikasi finance** dan
   pastikan mereka memiliki akun aktif. Finance tidak otomatis mendapat hak admin
   atau akses profil/gaji karyawan lain.
4. Buka **Alur Persetujuan**. Default seluruh jenis pengajuan menggunakan satu
   tahap atasan langsung. Reimbursement menambahkan tahap finance terakhir.
   Tambahkan tingkat atasan, atau pilih beberapa karyawan untuk suatu tahap.
   `Semua wajib menyetujui` mengharuskan keputusan seluruh anggota; `Cukup salah
   satu` menyelesaikan tahap setelah keputusan pertama yang menyetujui.
5. Pastikan setiap tujuan memiliki akun aktif sebelum digunakan. Tidak ada
   pengalihan otomatis ke admin jika atasan/finance belum lengkap. Pemohon sendiri
   ditolak sebagai approver; finance juga harus berbeda dari approver sebelumnya.

Data karyawan lama tidak diberi atasan atau rekening rekaan. Lengkapi data tersebut
sebelum pengajuan baru. Akun demo pada database baru menggunakan contoh atasan
EMP-001 dan finance EMP-015; akun finance demo adalah karyawan15@mdm.local dengan
kata sandi seed demo yang sudah ada. Database lama tidak ditimpa dengan fixture ini.

## Pengajuan dan keputusan

- Pemohon mengisi judul/keperluan. Untuk reimbursement, tambahkan satu atau lebih
  rincian: tanggal transaksi, deskripsi, kategori, jumlah rupiah, dan bukti.
  Maksimal 150 rincian sebagai batas ukuran teknis satu pengajuan.
- Bukti JPEG/PNG/PDF maksimal 2 MB per file diunggah melalui pemilih file bawaan.
  Bukti disimpan privat di PostgreSQL, terpisah dari response workspace. Pemohon,
  approver yang tercatat pada pengajuan, serta admin dapat mengunduhnya.
- Aplikasi menghitung total untuk pratinjau; server menghitung ulang dari rincian.
  Tanggal transaksi di masa depan, nilai tidak valid, atau bukti milik orang lain
  ditolak. Deskripsi yang tidak muat dalam kapasitas satu entri template ditolak
  saat pengiriman sehingga tidak menjadi masalah setelah disetujui.
- Struktur, identitas, rekening, dan nama calon approver disalin saat pengajuan
  dikirim. Perubahan profil/alur berlaku untuk pengajuan baru dan pengiriman ulang
  setelah revisi. Perubahan tidak mengubah dokumen pengajuan sebelumnya.
- Menu **Persetujuan** di dashboard dan ikon/kartu Persetujuan di mobile menampilkan
  tugas pengguna. Status keseluruhan tetap Menunggu hingga seluruh tahap selesai.
  Aksi hanya diterima dari approver yang ditugaskan pada tahap aktif.
- Tolak/Minta revisi memerlukan catatan. Pengajuan yang diminta revisi dapat
  diperbaiki pemohon di detail pengajuan lalu dikirim ulang. Semua tahap dimulai
  ulang dan keputusan sebelumnya tetap berada dalam riwayat.
- Identitas pemberi keputusan dan waktu selalu diambil server. Setiap aksi
  memeriksa nomor revisi. Transaksi PostgreSQL menserialkan keputusan dan pemotongan
  cuti untuk mencegah persetujuan ganda/saldo terpotong dua kali.
- Cuti dipotong hanya setelah persetujuan terakhir; aturan hari kalender dan
  deteksi tumpang tindih tetap mengikuti implementasi sebelumnya.

Ketentuan 14 hari kerja dan bukti asli yang tertulis di template ditampilkan kepada
pemohon. Batas 14 hari kerja **belum ditolak otomatis** karena kalender hari libur
kantor belum disediakan. Peninjau memeriksa ketentuan ini. Bukti unggahan tidak
mengubah kewajiban penyimpanan nota asli menurut kebijakan kantor.

## Dokumen final

Template asli disimpan sebagai `backend/internal/document/assets/reimburse-v1.xlsx`.
Versinya dicatat pada snapshot. Workbook final dibekukan di server pada persetujuan terakhir; PDF dibuat dari workbook tersebut dan hasil pertama disimpan untuk unduhan berikutnya. Pemohon, approver yang tercatat, dan admin dapat
mengunduh Excel atau PDF setelah persetujuan atasan dan verifikasi finance selesai.
Pengunduhan memerlukan sesi; mengetahui URL/ID saja tidak memberikan akses.

Layout memakai workbook kantor: logo, judul, kolom, bagian A–D, dan ketentuan
dipertahankan. Identitas, rekening, transaksi, total, nama peninjau, tanggal, serta
stempel status diisi otomatis. Sel tanggal memakai zona waktu kantor saat pengajuan.
Nilai dari pengguna ditulis sebagai teks, bukan formula Excel.

Halaman lanjutan mengulang format yang sama untuk lebih dari 15 baris, deskripsi
yang memerlukan beberapa baris, atau lebih dari dua tanda persetujuan. Total klaim
semua halaman diberi label jelas. Nama finance dan persetujuan yang dicetak adalah
orang yang benar-benar mengambil keputusan. Stempel ini menandai tindakan sistem;
tidak ada gambar tanda tangan orang yang dibuat atau ditempelkan.

Konversi memakai LibreOffice Calc pada image backend Docker. Dua konversi dapat
berjalan bersamaan, masing-masing menggunakan direktori dan profil sementara
terpisah serta batas waktu. File sementara dibersihkan setelah proses selesai.
Menjalankan API langsung dari Go di host memerlukan executable `libreoffice` pada
PATH untuk endpoint PDF reimbursement; Excel dan PDF payroll tidak memerlukannya.

Pengajuan lama tanpa snapshot/rincian tetap memakai review admin lama. Dokumen
reimbursement final baru tidak dibuat dari data lama yang tidak lengkap. Pengajuan
baru tidak dapat menggunakan jalur legacy dengan mengirim atribut versi dari klien.

## Batas dan pengujian penggunaan

Belum ada pembayaran/transfer bank, push notification, kalender hari libur, atau
delegasi otomatis saat approver nonaktif. Perubahan status karyawan menjadi nonaktif
menghalangi keputusan baru. Penetapan ulang tugas berjalan belum disediakan;
selesaikan pengajuan berjalan sebelum menonaktifkan akun/merombak alur penugasannya.
Bukti yang diunggah tetapi tidak jadi diajukan tetap tersimpan privat; penghapusan
berdasarkan kebijakan retensi belum dijadwalkan otomatis.

Uji penerimaan dengan karyawan, lead, dan finance: ajukan dua pengeluaran, minta
revisi, kirim ulang, setujui tiap tahap dari perangkat berbeda, lalu bandingkan
Excel/PDF final dengan rincian dan riwayat. Uji lead mengajukan sendiri kepada
atasannya. Pastikan pengguna lain tidak dapat mengunduh dokumen/bukti tersebut.
Periksa pemilih file dan share sheet pada HP fisik; iOS memerlukan build di Mac.
