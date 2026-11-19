# Panduan Arsitektur dan Standar Kode (Flutter HRIS App)

Anda adalah AI Assistant spesialis Flutter tingkat lanjut. Untuk setiap permintaan penulisan kode, refactoring, atau pembuatan fitur baru dalam proyek ini, Anda **WAJIB** mematuhi struktur folder dan aturan manajemen berikut. DILARANG mengambil jalan pintas atau membuat struktur yang keluar dari standar ini.

---

## 1. Skema Arsitektur Utama (Feature-First Clean Architecture)
Proyek ini membagi kode berdasarkan "Fitur" (di dalam `lib/features/`), bukan berdasarkan tipe file. Setiap fitur baru yang memiliki interaksi API atau logika kompleks WAJIB memiliki 3 layer:
- **Domain (`/domain`)**: Berisi aturan bisnis murni. Hanya boleh berisi `Entities`, `Repositories` (Contracts/Abstracts), dan `UseCases`. Tidak boleh ada dependensi ke framework Flutter, package UI, atau eksternal (seperti Dio/HTTP) di sini.
- **Data (`/data`)**: Berisi implementasi dari sumber eksternal. Terdiri dari `Models` (representasi JSON beserta `fromJson`/`toJson`), `DataSources` (Remote/Local), dan `RepositoriesImpl` (implementasi kontrak dari layer domain).
- **Presentation (`/presentation`)**: Berisi UI dan State Management. Terdiri dari folder `pages/`, `widgets/`, dan `bloc/`.

## 2. Aturan UI & Pemecahan Widget (Widget Granularity) - WAJIB DITAATI!
DILARANG KERAS membuat satu file UI (`Page` atau `Screen`) raksasa (monolithic). File UI tidak boleh melebihi 200 baris kode. Anda WAJIB memecah UI menjadi komponen-komponen kecil yang independen.

Ikuti hierarki pemecahan widget berikut:
- **Shared/Core Widgets (`lib/core/widgets/`)**: 
  Jika widget bersifat umum dan akan digunakan di lebih dari satu fitur (contoh: `PrimaryButton`, `CustomTextField`, `LoadingOverlay`, `SkeletonSpace`), letakkan di sini.
- **Feature-Specific Widgets (`lib/features/[nama_fitur]/presentation/widgets/`)**: 
  Jika widget hanya digunakan khusus untuk fitur tersebut (contoh: `DashboardHeader`, `AttendanceCard`, `StatisticChart`), JANGAN letakkan di dalam file `Page`. Buat folder `widgets/` di dalam layer `presentation` fitur tersebut dan pisahkan masing-masing menjadi file `.dart` tersendiri.

**Aturan Penulisan Method `build()`:**
- Method `build()` di dalam file utama (seperti `dashboard_page.dart`) HANYA boleh berisi struktur kerangka utama (seperti `Scaffold`, `AppBar`, `BlocBuilder`, dan pemanggilan custom widget yang sudah dipecah).
- Dilarang menumpuk widget terlalu dalam (Deep Nesting).
- WAJIB gunakan **Class** (`class MyWidget extends StatelessWidget`) alih-alih **Method** (`Widget _buildMyWidget()`) saat memecah UI, agar performa rendering Flutter lebih optimal.

## 3. State Management (BLoC Pattern)
- Gunakan **BLoC** (Business Logic Component) sebagai state management utama.
- File BLoC harus dipisahkan menjadi 3 file: `_bloc.dart`, `_event.dart`, dan `_state.dart`.
- State harus direpresentasikan menggunakan class berbasis state (misal: `Initial`, `Loading`, `Success`, `Error`).
- UI (`Page`/`Widget`) HANYA bertugas menampilkan data dan menembakkan *Event*. Dilarang keras menaruh logika bisnis atau pemanggilan API langsung di dalam file UI.
- Pastikan semua transisi BLoC dicatat oleh `global_bloc_observer.dart` di `lib/app/config/`.

## 4. Manajemen Dependensi (Dependency Injection)
- Gunakan package (seperti `get_it`) untuk Dependency Injection.
- Setiap fitur wajib memiliki file injeksinya sendiri di root fitur tersebut (contoh: `lib/features/auth/auth_injection.dart`).
- File injeksi fitur ini nantinya akan dipanggil dan didaftarkan di entry point utama aplikasi.

## 5. Jaringan & API (Networking)
- Gunakan `dio_client.dart` yang berada di `lib/app/config/` untuk semua pemanggilan API (Remote Data Source). 
- DILARANG membuat instance Dio baru di dalam layer data. Selalu *inject* Dio Client global.
- Tangani error API di layer Data, lalu konversikan menjadi `Exception` (untuk level data) dan `Failure` (untuk level domain/UI) menggunakan file yang ada di `lib/core/errors/`.

## 6. UI, Tema & Komponen Global
- Gunakan warna, teks, dan tema dari `lib/core/theme/` (`app_colors.dart`, `app_text_styles.dart`). 
- DILARANG melakukan *hardcode* warna (misal: `Colors.blue` atau `Color(0xFF...)`) atau *hardcode* style teks langsung di dalam UI. Ambil dari core theme.

## 7. Konvensi Penamaan (Naming Conventions)
- **Folder/File**: Gunakan `snake_case` (contoh: `detail_attendance`, `auth_injection.dart`).
- **Class**: Gunakan `PascalCase` (contoh: `HistoryAttendancePage`, `AuthBloc`).
- Akhiri nama class sesuai peranannya: `...Page`, `...Widget`, `...Bloc`, `...Event`, `...State`, `...Entity`, `...Model`, `...RemoteDataSource`, `...Repository`.

---

## 8. Struktur Direktori Standar (Referensi)
Setiap fitur baru harus mengikuti struktur kerangka dasar ini:

```text
lib/
├── app/
│   └── config/                           # Konfigurasi global (Routing, Dio, BLoC Observer)
├── core/
│   ├── errors/                           # Failures & Exceptions
│   ├── theme/                            # AppColors, AppTextStyles, AppTheme
│   └── widgets/                          # Shared Widgets (Skeleton, PrimaryButton, dll)
├── features/
│   └── [nama_fitur]/
│       ├── data/
│       │   ├── datasources/              # Remote & Local DS
│       │   ├── models/                   # DTOs / JSON Models
│       │   └── repositories/             # Repository Implementation
│       ├── domain/
│       │   ├── entities/                 # Business Objects
│       │   ├── repositories/             # Repository Contracts
│       │   └── usecases/                 # Business Logic/Use Cases
│       ├── presentation/
│       │   ├── bloc/                     # Bloc, Event, State
│       │   ├── pages/                    # UI Utama (Kerangka Scaffold)
│       │   └── widgets/                  # UI Components spesifik fitur (Wajib dipisah!)
│       └── [nama_fitur]_injection.dart   # Setup DI khusus fitur ini
└── main.dart                             # Entry point
```

---

## 9. Instruksi Eksekusi AI (Langkah Pembuatan Fitur)
Setiap kali diminta untuk "Buat fitur X", Anda WAJIB mengerjakan dengan urutan berikut tanpa terkecuali:
1. Meminta izin atau langsung membuat folder fitur baru di `lib/features/[nama_fitur]/`.
2. Membuat kontrak di layer **Domain** (`Entities` -> `Repositories` -> `UseCases`).
3. Membuat implementasi di layer **Data** (`Models` -> `DataSources` -> `RepositoryImpl`).
4. Membuat **BLoC** di layer `presentation/bloc/`.
5. Membuat komponen UI kecil di `presentation/widgets/` (Terapkan *Widget Granularity*).
6. Menggabungkan komponen UI tersebut ke dalam `presentation/pages/[nama_fitur]_page.dart`.
7. Membuat file `[nama_fitur]_injection.dart` dan memastikan routing diupdate (jika diperlukan).
