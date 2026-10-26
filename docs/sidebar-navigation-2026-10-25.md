# Sidebar dashboard — 25 Oktober 2026

Permintaan pengguna: hapus kartu Company workspace yang membuka pengaturan,
lalu masukkan Persetujuan dan Alur Persetujuan ke WORKSPACE setelah Cuti.
Sumber observed: screenshot dan permintaan pengguna, workspace.tsx serta CSS.
Perubahan kecil dengan arah eksplisit; alternatif desain tidak diperlukan.

Hasil: WORKSPACE → Dashboard, Karyawan/Profil saya, Kehadiran, Cuti,
Persetujuan, Alur Persetujuan. Persetujuan tetap mengikuti approvalAccess;
Alur Persetujuan dan Pengaturan tetap admin. Badge tugas tidak berubah.
Kartu duplikat dan CSS yang hanya dipakai kartu tersebut dihapus. Pengaturan
tetap menjadi satu pintu konfigurasi pada bagian bawah sidebar.

Validasi: dua tes Playwright untuk urutan, satu akses Pengaturan, kontrol
karyawan serta tampilan menu pada desktop dan 390 px lulus. Next.js production
build/TypeScript lulus. Render fixture tmp/sidebar-workspace-admin.png dan
tmp/sidebar-workspace-mobile.png diperiksa; fixture tidak masuk data produksi.

Deployment frontend: pilot-20261025-nav. FRONTEND_RELEASE bersifat opsional dan
fallback ke HRIS_RELEASE; pemisahan ini memungkinkan frontend diperbarui tanpa
mengganti backend/face. Konfigurasi lama dicadangkan sebelum aktivasi. Tidak ada
perubahan database atau APK. Backend, frontend, face dan PostgreSQL sehat.

| RYUX Delivery Gate | Hasil |
| --- | --- |
| PRODUCT | PASS · arah eksplisit pengguna, bukti Strong untuk kebutuhan ini |
| UX | PASS · satu pintu konfigurasi, menu persetujuan punya kelompok |
| CONTENT | PASS · nama kelompok dan menu tetap konsisten |
| UI | PASS · task UI; memakai sidebar dan ikon yang ada; tanpa ilustrasi |
| DESIGN SYSTEM | PASS · memakai nav-item dan nav-group yang ada |
| ACCESSIBILITY | PASS terbatas · tombol/label tetap; pembaca layar manual tidak diuji |
| RESPONSIVE | PASS · desktop dan menu 390 px dirender serta diperiksa |
| EDGE CASES | PASS · admin dan karyawan; badge dan route Pengaturan diperiksa |
| CODE QUALITY | PASS · 2 tes navigasi dan production build lulus |
| VISUAL QA | PASS · screenshot Playwright desktop dan 390 px diperiksa |
| ANTI-SLOP | PASS · menghapus duplikasi tanpa dekorasi atau aturan bisnis baru |
| FINAL | PASS untuk pemeriksaan di atas; belum diuji dengan pengguna kantor |

Matriks: sidebar × admin menampilkan dua menu sesuai kewenangan; sidebar ×
karyawan biasa tidak membuka konfigurasi alur; sidebar × layar kecil memakai
drawer dan urutan yang sama. Loading/error aplikasi memakai perilaku sebelumnya.
