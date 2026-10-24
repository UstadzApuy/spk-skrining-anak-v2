# MASTER PROMPT — PENGEMBANGAN SPK SKRINING ANAK UPTD BLK-ABK KOTA BALIKPAPAN

## 1. PERAN DAN TUJUAN

Bertindak sebagai Senior Software Architect, Senior Laravel Developer, Database Engineer, dan UI/UX Engineer yang memiliki pengalaman membangun sistem informasi kesehatan, clinical decision support system, aplikasi berbasis Laravel, integrasi PostgreSQL, pengelolaan data klinis, dan migrasi database yang aman.

Tugasmu adalah melanjutkan pengembangan aplikasi **Sistem Pendukung Keputusan (SPK) Skrining Anak** untuk UPTD BLK-ABK Kota Balikpapan.

Aplikasi ini digunakan oleh tenaga kesehatan internal, khususnya perawat dan dokter, untuk mengelola sesi skrining, mengisi instrumen pemeriksaan, menghitung skor secara otomatis menggunakan rule-based scoring dan threshold, menampilkan hasil skrining, mencatat interpretasi dokter, serta mendokumentasikan tindak lanjut.

Sistem harus dikembangkan berdasarkan empat hal berikut:

1. Kode aplikasi yang sudah tersedia dan bekerja.
2. Struktur database layanan UPTD BLK-ABK dalam backup PostgreSQL `Backup3.sql`.
3. Alur kerja perawat dan dokter yang telah dijelaskan.
4. Referensi antarmuka klinis yang diberikan, meliputi direktori pasien, konfigurasi instrumen, pengisian kuesioner, dan ringkasan hasil klinis.

Jangan membangun aplikasi baru dari nol apabila komponen yang dibutuhkan sudah tersedia. Lakukan audit terhadap repositori sebelum mengubah kode. Pertahankan implementasi yang valid, refaktorkan bagian yang diperlukan, dan bangun fitur tambahan secara bertahap.

**Prioritas utama:** integritas data layanan, ketepatan perhitungan instrumen, keamanan akses, alur klinis yang dapat ditelusuri, dan antarmuka yang sesuai dengan kebutuhan UPTD.

---

## 2. KONTEKS PROYEK DAN TEKNOLOGI

### 2.1. Repositori aplikasi

Nama repositori:

`spk-skrining-anak-v2`

Stack yang telah digunakan atau terlihat dari struktur proyek:

- Backend: PHP 8.2 dan Laravel 12.
- Database: PostgreSQL.
- Frontend: Vue 3 dengan `<script setup>`.
- Inertia.js untuk komunikasi backend dan frontend.
- Tailwind CSS v4 untuk antarmuka.
- Vite untuk build frontend.
- Docker Compose untuk lingkungan pengembangan.
- PHPUnit/Pest melalui Laravel testing sesuai konfigurasi proyek.
- Git dan GitHub untuk pengelolaan versi.

Gunakan struktur, dependency, dan konfigurasi aktual dari repositori. Jangan mengasumsikan versi paket yang lebih baru tanpa memeriksa `composer.lock` dan `package-lock.json`.

Perintah pengembangan yang telah digunakan antara lain:

```bash
docker compose exec app php artisan test
docker compose exec app php artisan route:list
docker compose exec app php artisan migrate:status
npm run build
git diff --check
```

Jangan mengganti Dockerfile, konfigurasi database, dependency frontend, atau dependency backend tanpa alasan teknis yang jelas.

### 2.2. Fitur yang telah tersedia

Audit awal repositori menunjukkan bahwa komponen berikut sudah tersedia:

**Model:**

- `User`
- `Role`
- `Patient`
- `ParentGuardian`
- `Doctor`
- `Nurse`
- `ScreeningSession`
- `ScreeningSessionInstrument`
- `KpspScreening`
- `MchatScreening`
- `GpphScreening`
- `SdqScreening`
- `SrqScreening`

**Controller:**

- `LoginController`
- `DashboardController`
- `PatientController`
- `ScreeningSessionController`
- `SdqScreeningController`
- `SrqScreeningController`

**Layanan perhitungan:**

- `KpspAgeCalculator`
- `KpspScorer`
- `MchatScorer`
- `GpphScorer`
- `SdqScorer`
- `SrqScorer`
- `RuleBasedScoringService`
- `ScoringResult`
- `ScorerInterface`

**Halaman Vue:**

- `Patients/Index.vue`
- `Patients/Create.vue`
- `Patients/Edit.vue`
- `ScreeningSessions/Index.vue`
- `ScreeningSessions/Create.vue`
- `ScreeningSessions/Show.vue`
- `ScreeningSessions/Sdq.vue`
- `ScreeningSessions/Srq.vue`
- `ScreeningSessions/SrqCompleted.vue`
- halaman dashboard dan autentikasi lainnya.

Formulir SDQ dan SRQ telah memiliki alur backend, sementara KPSP, M-CHAT, dan GPPH masih membutuhkan audit sebelum dikembangkan lebih lanjut.

Jangan menyimpulkan bahwa suatu fungsi sudah lengkap hanya karena model atau service-nya tersedia. Periksa setiap controller, route, migrasi, form, relasi model, dan pengujiannya.

### 2.3. Progres Git

Repositori sebelumnya memiliki commit:

- `23ee184` — `feat: implement screening sessions and SDQ workflow`
- `c652fe9` — `feat: implement SRQ-20 screening workflow`

Setelah commit tersebut, migrasi berikut juga dibuat dan berhasil dijalankan pada database yang dikonfigurasi saat itu:

`2026_10_12_054704_add_created_by_user_id_to_screening_sessions_table.php`

Migrasi tersebut menambahkan `created_by_user_id` untuk mencatat pembuat sesi dan memetakan sesi historis melalui akun perawat yang tercatat.

Status Git dan database mungkin sudah berubah. Verifikasi dengan `git status`, `git log`, `git diff`, serta `php artisan migrate:status`. Jangan menganggap perubahan lokal sudah di-commit atau sudah ada di remote.

---

## 3. ARSITEKTUR INTEGRASI DATABASE

### 3.1. Keputusan arsitektur

Gunakan satu database PostgreSQL bernama `ta_bismillah` dengan dua skema:

- `public`: data sumber sistem layanan UPTD BLK-ABK.
- `spk`: seluruh data operasional yang khusus untuk aplikasi SPK Skrining Anak.

Arsitektur yang diinginkan:

```text
PostgreSQL: ta_bismillah
|
|-- public
|   |-- users
|   |-- roles
|   |-- patients
|   |-- parent_guardians
|   |-- doctors
|   |-- medical_records
|   |-- diagnoses
|   |-- sdq_screenings
|   |-- tabel layanan lainnya
|
|-- spk
    |-- screening_sessions
    |-- screening_session_instruments
    |-- kpsp_screenings
    |-- mchat_screenings
    |-- gpph_screenings
    |-- sdq_screenings
    |-- srq_screenings
    |-- screening_interpretations
    |-- screening_interpretation_histories
    |-- tabel pendukung SPK yang diperlukan
```

Daftar tabel di atas adalah rancangan awal. Verifikasi tabel, nama kolom, tipe data, constraint, dan relasi aktual sebelum menerapkannya.

**Prinsip mutlak:** tabel pada skema `public` tetap menjadi milik sistem layanan. Jangan menghapus, mengganti nama, mengosongkan, atau mengubah strukturnya hanya untuk menyesuaikan kode SPK.

### 3.2. Audit backup PostgreSQL

Berkas `Backup3.sql` diberikan sebagai backup database layanan.

Sebelum melakukan integrasi:

1. Verifikasi format berkas menggunakan alat PostgreSQL.
2. Periksa daftar objek, skema, struktur tabel, foreign key, unique constraint, check constraint, index, sequence, dan enum yang digunakan.
3. Periksa struktur pengguna, pasien, orang tua/wali, dokter, perawat jika tersedia, rekam medis, diagnosis, serta tabel SDQ.
4. Identifikasi semua tabel yang namanya berbenturan dengan tabel aplikasi SPK.
5. Jangan mencetak isi rekam medis, jawaban kuesioner nyata, informasi pribadi pasien, password, atau data sensitif saat melakukan audit.
6. Jika backup merupakan format custom PostgreSQL, gunakan `pg_restore` dan pulihkan ke database staging terpisah. Jangan menjalankan restore langsung ke database produksi.
7. Jangan mengubah `.env` untuk menunjuk ke `ta_bismillah` sebelum pemeriksaan dan pengujian integrasi selesai.

Jangan mengasumsikan ekstensi berkas mencerminkan format sebenarnya.

### 3.3. Model integrasi

Gunakan model Eloquent yang membedakan tabel sumber dan tabel SPK.

Model data sumber harus mengakses skema `public`, sedangkan model khusus SPK harus mengakses skema `spk`.

Periksa strategi koneksi Laravel yang paling sesuai dengan proyek aktual. Salah satu pendekatan yang dapat diuji adalah dua konfigurasi koneksi PostgreSQL yang menunjuk ke database fisik yang sama:

- Koneksi sumber dengan schema `public`.
- Koneksi SPK dengan `search_path` yang memprioritaskan `spk`, kemudian `public`.

Jika menggunakan pendekatan ini:

- Pastikan skema `spk` sudah tersedia sebelum repository migrasi SPK pertama dibuat.
- Pastikan model SPK selalu menggunakan koneksi yang benar.
- Pastikan model sumber menggunakan tabel yang memenuhi syarat skema `public`.
- Periksa bahwa relasi lintas-koneksi pada Eloquent berjalan sebagaimana diharapkan.
- Jangan memakai `whereHas`, join, atau transaksi lintas-koneksi tanpa menguji dukungannya.
- Semua operasi tulis yang menjadi satu kesatuan pada skema `spk` harus memakai koneksi dan transaksi yang konsisten.
- Foreign key lintas-skema harus diuji melalui SQL yang benar-benar dihasilkan Laravel.

Nama koneksi, nama database, schema, dan mekanisme migrasi final harus ditetapkan setelah audit. Jangan mengandalkan `search_path` yang belum diverifikasi.

### 3.4. Integrasi pengguna dan autentikasi

Gunakan akun sumber dari `public.users`, bukan membuat akun dokter dan perawat duplikat khusus untuk SPK.

Backup yang telah diperiksa menunjukkan kemungkinan perbedaan antara skema pengguna sumber dan skema aplikasi SPK saat ini. Model SPK menggunakan `role_id`, sedangkan metadata database layanan menunjukkan kolom peran pada `users`. Verifikasi keseluruhan skema sebelum melakukan perubahan.

Ketentuan:

1. Pertahankan ID pengguna sumber.
2. Sesuaikan `User`, `Role`, middleware, controller autentikasi, dan shared Inertia props terhadap struktur sebenarnya.
3. Jangan membuat migrasi yang menambahkan kembali tabel `users` atau `roles` yang sudah ada di `public`.
4. Jangan mengimpor akun SPK menjadi akun layanan secara otomatis.
5. Periksa algoritma hash kata sandi yang digunakan akun sumber dan pastikan kompatibilitas autentikasi Laravel.
6. Jika hash tidak kompatibel, rancang strategi autentikasi yang aman. Jangan mengubah password pengguna secara massal.
7. Akun orang tua/wali pada database layanan tidak otomatis mendapat akses login ke aplikasi SPK.

### 3.5. Integrasi pasien, orang tua/wali, dan dokter

Data master dibaca dari database layanan.

Untuk model pasien, audit perbedaan antara:

- `guardian_id` pada struktur sumber.
- `parent_guardian_id` pada struktur aplikasi SPK sebelumnya.
- kolom wajib seperti tempat lahir dan alamat pada sumber.
- data prematuritas dan usia gestasi yang digunakan oleh kalkulator KPSP.

Sesuaikan relasi berdasarkan struktur sumber aktual.

Secara default, pendaftaran dan perubahan master pasien tetap dilakukan melalui sistem layanan yang berwenang. Jangan menambahkan duplikasi pasien hanya untuk memenuhi form SPK. Jika nantinya diperlukan fitur membuat pasien dari SPK, integrasikan dengan validasi dan proses pencatatan sumber yang benar.

Untuk dokter:

- Identitas dokter dibaca dari `public.doctors`.
- Akun dokter dikaitkan melalui relasi pengguna sumber yang benar.
- Jangan menyamakan `doctor_id` dengan `users.id` jika kolom tersebut sebenarnya merujuk ke profil dokter.
- Pastikan riwayat pembuat sesi dan dokter peninjau disimpan secara terpisah.

Untuk perawat, periksa apakah profil perawat memang tersedia pada skema sumber. Jika tidak ada, gunakan akun pengguna berperan perawat sebagai penanggung jawab dengan validasi backend; jangan merujuk ke tabel yang tidak tersedia.

---

## 4. DESAIN DATABASE KHUSUS SPK

Rancang migrasi baru di jalur migrasi khusus SPK. Jangan menjalankan seluruh migrasi aplikasi lama terhadap database layanan karena file migrasi lama dapat mencoba membuat tabel `public` yang sudah tersedia.

Rancang migrasi dengan mempertimbangkan data yang sudah ada, foreign key ke skema `public`, dan proses rollback yang tidak menghapus sumber data.

### 4.1. `spk.screening_sessions`

Menyimpan satu sesi pemeriksaan untuk seorang pasien.

Kolom yang perlu dipertimbangkan:

| Kolom | Fungsi |
|---|---|
| `id` | Identitas sesi SPK |
| `patient_id` | Mengacu ke `public.patients.id` |
| `created_by_user_id` | Pengguna sumber yang membuat sesi |
| `nurse_user_id` | Akun perawat yang bertanggung jawab melakukan skrining |
| `doctor_id` | Dokter peninjau; null sebelum peninjauan jika diperbolehkan |
| `screening_date` | Tanggal pemeriksaan |
| `age_months` | Umur kronologis saat pemeriksaan |
| `status` | Status keseluruhan sesi |
| `notes` | Catatan awal pemeriksaan |
| `reviewed_at` | Waktu peninjauan diselesaikan |
| `created_at`, `updated_at` | Waktu pencatatan |

Nama kolom final dapat disesuaikan dengan pola proyek setelah audit. Jangan mempertahankan `nurse_id` hanya karena model lama memakainya jika ID-nya merujuk pada profil perawat dalam database SPK yang sudah tidak akan digunakan.

`created_by_user_id`, penanggung jawab skrining, dan dokter peninjau harus tetap menjadi konsep yang berbeda.

Beri foreign key menuju data sumber yang tepat. Tentukan aturan penghapusan yang mempertahankan integritas riwayat pemeriksaan.

### 4.2. `spk.screening_session_instruments`

Menyimpan instrumen yang dipilih dalam sesi.

Kolom:

- `id`
- `screening_session_id`
- `instrument_code`
- `status`
- `started_at`
- `completed_at`
- `created_at`
- `updated_at`

Kode instrumen:

- `KPSP`
- `MCHAT`
- `GPPH`
- `SDQ`
- `SRQ`

Status instrumen:

- `pending`
- `in_progress`
- `completed`
- `cancelled`

Terapkan unique constraint pada kombinasi sesi dan kode instrumen agar instrumen yang sama tidak didaftarkan dua kali dalam satu sesi.

### 4.3. Tabel hasil per instrumen

Pertahankan pemisahan hasil berikut:

- `spk.kpsp_screenings`
- `spk.mchat_screenings`
- `spk.gpph_screenings`
- `spk.sdq_screenings`
- `spk.srq_screenings`

Setiap tabel menyimpan jawaban, hasil perhitungan, kategori yang sesuai, rekomendasi instrumen jika berlaku, serta waktu pencatatan.

Audit setiap migrasi dan model saat ini sebelum menetapkan kolom akhir. Jangan mengganti nama kolom hasil atau mengubah rumus skoring hanya untuk menyeragamkan struktur.

Pertahankan unique constraint yang memungkinkan satu hasil final untuk tiap instrumen dalam satu sesi. Jika diperlukan riwayat beberapa kali pemeriksaan dalam sesi yang sama, rancang model versi atau percobaan pemeriksaan secara eksplisit, jangan membuat data duplikat tanpa aturan.

Hasil SDQ layanan yang sudah ada di `public.sdq_screenings` harus tetap aman. Jangan menimpanya dengan tabel hasil SDQ milik SPK.

### 4.4. Draf jawaban dan penyimpanan progres

Antarmuka target membutuhkan penyimpanan progres dan kemampuan melanjutkan pengisian.

Lakukan audit apakah skema hasil sekarang memungkinkan penyimpanan jawaban parsial. Jangan menyimpan skor final seolah-olah semua jawaban sudah lengkap.

Rancang mekanisme yang membedakan:

- jawaban sementara;
- jawaban yang sudah lengkap;
- hasil skoring final.

Salah satu pilihan adalah menyimpan `draft_answers`, `progress`, dan `last_saved_at` pada data instrumen sesi. Pilihan lain adalah tabel khusus draf jawaban. Tentukan berdasarkan skema aktual.

Ketentuan:

1. Jawaban parsial tidak menghasilkan kategori final.
2. Form yang dibuka kembali memulihkan jawaban draf.
3. Setiap draf terkait dengan sesi dan instrumen yang tepat.
4. Jawaban tidak boleh tertukar antara pasien, sesi, atau instrumen.
5. Ketika semua jawaban valid, backend menghitung skor kembali dan menyimpan hasil final dalam transaksi.
6. Manipulasi nilai skor melalui browser tidak boleh mengubah hasil yang disimpan.

### 4.5. Catatan interpretasi dokter

Buat tabel khusus `spk.screening_interpretations`.

Kolom yang disarankan:

- `id`
- `screening_session_id`
- `instrument_code`
- `doctor_id`
- `clinical_notes`
- `follow_up_decision`
- `follow_up_notes`
- `status`
- `completed_at`
- `created_at`
- `updated_at`

Satu sesi dapat memiliki catatan SDQ dan SRQ secara terpisah.

Gunakan unique constraint untuk satu kombinasi sesi dan instrumen apabila setiap instrumen hanya membutuhkan satu catatan interpretasi aktif.

Status catatan:

- `draft`: catatan sudah tersimpan tetapi penilaian belum selesai.
- `completed`: dokter menyatakan interpretasi instrumen selesai.

Dokter boleh menyimpan catatan SDQ tanpa menunggu SRQ selesai, dan sebaliknya.

Identitas dokter harus berasal dari profil dokter sumber. Catatan tidak boleh diedit oleh perawat melalui endpoint biasa.

Jika diperlukan audit klinis yang lebih kuat, buat tabel riwayat interpretasi untuk merekam perubahan, pengguna, waktu, dan versi catatan. Jangan menimpa riwayat tanpa jejak apabila versi terdahulu perlu dipertahankan.

### 4.6. Pemetaan dan rekonsiliasi data historis

Rancang proses migrasi data lama dengan tabel pemetaan identitas, misalnya `spk.legacy_id_mappings`.

Tabel ini dapat mencatat:

- sumber data lama;
- jenis entitas;
- ID historis;
- ID tujuan;
- metode pencocokan;
- status verifikasi;
- pengguna yang memeriksa pemetaan;
- waktu pencatatan.

Pencocokan pasien harus mengutamakan nomor rekam medis unik serta identitas pendukung. Jangan menggunakan ID numerik mentah dari database lama sebagai ID sumber baru.

Aturan migrasi data:

1. Pertahankan backup awal.
2. Jangan menulis ke tabel layanan hanya karena sebuah rekaman tidak cocok.
3. Jangan menggabungkan pasien berdasarkan nama saja.
4. Rekaman yang ambigu masuk daftar rekonsiliasi untuk pemeriksaan manual.
5. Data historis yang sudah berhasil dipindahkan harus dapat dikenali agar tidak diimpor dua kali.
6. Bandingkan jumlah rekaman sumber dan tujuan serta validasi foreign key.
7. Jangan menghapus database lama sampai hasil migrasi telah diverifikasi dan pemilik sistem menyetujui cutover.

---

## 5. ARSITEKTUR PENANGGUNG JAWAB DAN HAK AKSES

Aplikasi bersifat internal dan hanya diakses melalui perangkat tenaga kesehatan.

Orang tua atau pengasuh tidak perlu mempunyai akun login. Mereka mengisi kuesioner pada perangkat yang disediakan dan didampingi oleh perawat.

### 5.1. Dokter

Dokter memiliki kewenangan untuk:

- masuk dan keluar dari aplikasi menggunakan akun layanan;
- melihat direktori pasien;
- mencari dan memilih pasien;
- memulai sesi skrining;
- memilih perawat penanggung jawab;
- memilih instrumen yang diperlukan;
- melihat seluruh sesi skrining yang berwenang diaksesnya;
- melihat hasil semua instrumen;
- mengisi dan memperbarui interpretasi per instrumen;
- menyimpan catatan sementara;
- menyelesaikan peninjauan;
- menetapkan tindak lanjut berdasarkan pemeriksaan;
- melihat riwayat pemeriksaan;
- mencetak ringkasan klinis.

Dokter **tidak otomatis menjadi pengisi kuesioner** hanya karena membuat sesi. Pengisian instrumen tetap dilaksanakan perawat sesuai alur kerja UPTD.

### 5.2. Perawat

Perawat dapat:

- masuk dan keluar aplikasi;
- melihat direktori pasien;
- membuat sesi baru;
- bertindak sebagai penanggung jawab sesi yang dibuat sendiri;
- menjalankan sesi yang ditugaskan kepadanya;
- membantu orang tua mengisi SDQ dan SRQ melalui perangkat klinik;
- mengisi instrumen lain sesuai alur pemeriksaan;
- menyimpan serta melanjutkan pengisian;
- melihat hasil yang diperlukan untuk tugasnya;
- menyerahkan sesi kepada dokter untuk peninjauan.

Perawat tidak boleh mengubah interpretasi yang dibuat dokter melalui endpoint pengisian instrumen.

### 5.3. Orang tua/pengasuh

Orang tua/pengasuh:

- tidak mempunyai akun aplikasi SPK;
- tidak mengakses dashboard internal;
- hanya mengisi formulir yang sedang disiapkan perawat;
- tidak menerima akses ke riwayat, hasil klinis lengkap, atau catatan dokter;
- diarahkan ke layar konfirmasi pengisian dan menyerahkan kembali perangkat.

Setelah formulir selesai, layar harus dibersihkan dari data jawaban yang sensitif sebelum digunakan responden berikutnya. Jangan menampilkan skor klinis kepada responden kecuali telah ditetapkan secara resmi sebagai bagian alur layanan.

### 5.4. Otorisasi backend

Gunakan middleware peran, validasi kepemilikan sesi, dan pemeriksaan kewenangan pada setiap endpoint.

Jangan mengandalkan tombol atau komponen Vue sebagai satu-satunya pengamanan.

Pastikan:

- dokter dapat melihat sesi lintas perawat sesuai kewenangannya;
- perawat hanya dapat melakukan tindakan pengisian pada sesi yang ditugaskan kepadanya;
- dokter dapat membuat sesi tetapi tidak dapat mengakses endpoint pengisian SDQ/SRQ yang khusus perawat;
- dokter hanya dapat menulis interpretasi sebagai dokter yang terautentikasi;
- tamu dan akun orang tua ditolak;
- ID pasien atau sesi yang diubah di URL tidak membuka data milik sesi lain tanpa izin.

---

## 6. RANCANGAN HALAMAN APLIKASI

Seluruh antarmuka menggunakan Bahasa Indonesia. Referensi desain berbahasa Inggris hanya menjadi acuan visual, bukan sumber terminologi aplikasi.

Gunakan tampilan klinis yang bersih, profesional, responsif, dan mudah dioperasikan melalui komputer atau tablet di ruang pelayanan. Pertahankan komponen layout dan sistem desain yang sudah tersedia jika masih sesuai.

### 6.1. Halaman login

Halaman masuk untuk pengguna internal.

Komponen:

- nama aplikasi;
- identitas layanan;
- form email/username sesuai sistem sumber;
- password;
- indikator proses masuk;
- validasi kesalahan;
- pesan kredensial tidak valid;
- perlindungan terhadap autentikasi berulang yang tidak wajar sesuai kemampuan proyek.

Tidak ada pendaftaran akun publik untuk orang tua.

Setelah login, arahkan pengguna ke dashboard sesuai perannya.

### 6.2. Dashboard perawat dan dokter

Dashboard menampilkan ringkasan kerja, bukan data agregat yang menyesatkan.

Komponen yang dapat dikembangkan:

- jumlah pasien aktif;
- jumlah sesi hari ini;
- sesi yang sedang berlangsung;
- instrumen yang belum selesai;
- sesi yang menunggu tinjauan dokter;
- sesi yang sudah ditinjau;
- daftar aktivitas terbaru.

Bedakan metrik berdasarkan akses pengguna. Data pasien yang tidak perlu tidak boleh ditampilkan pada dashboard.

### 6.3. Direktori pasien — `Patients/Index.vue`

Jadikan direktori pasien sebagai titik awal utama, mengikuti gambar referensi pertama.

Komponen:

- sidebar navigasi;
- header halaman;
- breadcrumb;
- kolom pencarian;
- filter status pasien;
- filter sesi skrining jika diperlukan;
- ringkasan jumlah data;
- kartu pasien atau tabel yang responsif;
- tombol memulai sesi skrining;
- ringkasan skrining terakhir.

Data pada kartu:

- nama anak;
- nomor rekam medis;
- tanggal lahir;
- umur yang dihitung dari tanggal pemeriksaan bila tersedia;
- jenis kelamin;
- status pasien;
- tanggal pemeriksaan terakhir;
- status skrining terakhir.

Pencarian dapat menggunakan nama dan nomor rekam medis. Jika pencarian berdasarkan tanggal lahir ditambahkan, pastikan format serta validasinya benar.

Dokter dan perawat dapat memilih pasien. Tombol tindakan harus menyesuaikan peran.

Jangan menambahkan fitur membuat pasien duplikat ke `public.patients`. Data master berasal dari sistem layanan. Apabila dibutuhkan proses registrasi pasien dari SPK, perlakukan sebagai integrasi terpisah yang harus sesuai struktur dan aturan sistem layanan.

### 6.4. Halaman konfigurasi sesi — `ScreeningSessions/Create.vue`

Halaman ini mengikuti gambar referensi kedua.

Bagian atas:

- breadcrumb;
- identitas pasien terpilih;
- nomor rekam medis;
- umur anak;
- tahap konfigurasi sesi.

Bagian instrumen:

- KPSP;
- M-CHAT-R;
- GPPH (ACTRS);
- SDQ;
- SRQ-20.

Setiap kartu instrumen menampilkan:

- nama dan penjelasan instrumen;
- kelayakan umur;
- status ketersediaan;
- status sudah dikerjakan jika berupa pemeriksaan sebelumnya;
- informasi atau petunjuk tambahan;
- kontrol pemilihan instrumen.

Panel ringkasan sesi menampilkan:

- pasien;
- tanggal pemeriksaan;
- daftar instrumen terpilih;
- perkiraan durasi apabila datanya telah diverifikasi;
- ringkasan kelayakan instrumen;
- tombol memulai sesi.

Tambahkan catatan awal pemeriksaan yang diisi petugas jika diperlukan.

Ketentuan:

1. Perawat yang memulai sesi menjadi penanggung jawabnya sendiri secara otomatis.
2. Dokter yang memulai sesi harus memilih perawat penanggung jawab yang valid.
3. Identitas pengguna pembuat sesi dicatat terpisah.
4. Umur dan kelayakan instrumen dihitung ulang di backend.
5. Nilai `age_months`, `nurse_id` atau identitas penanggung jawab, `doctor_id`, dan status sesi tidak boleh menerima nilai yang dimanipulasi melalui request.
6. Sesi dan daftar instrumennya dibuat dalam satu transaksi.
7. Jika validasi gagal, jangan menyimpan sesi setengah jadi.

Kelayakan berdasarkan umur harus berasal dari aturan instrumen yang telah diverifikasi, bukan sekadar kondisi UI.

### 6.5. Halaman pengisian instrumen

Setiap instrumen memiliki antarmuka yang disesuaikan dengan kuesioner atau formulirnya.

Semua halaman pengisian harus mendukung:

- identitas sesi dan pasien secara terbatas;
- petunjuk pengisian;
- indikator progres;
- validasi jawaban;
- navigasi pertanyaan bila sesuai;
- penyimpanan progres;
- melanjutkan pengisian;
- pencegahan pengiriman ganda;
- konfirmasi saat meninggalkan halaman dengan perubahan yang belum tersimpan;
- penghitungan skor hanya di backend setelah syarat kelengkapan terpenuhi.

Untuk orang tua yang mengisi SDQ atau SRQ, gunakan halaman fokus tanpa navigasi internal aplikasi, tanpa akses ke dashboard, dan tanpa menampilkan skor akhir.

#### SDQ

- Tepat 25 pertanyaan.
- Setiap jawaban berupa nilai 0, 1, atau 2 sesuai kunci yang disetujui.
- Terapkan aturan pembalikan skor pada item yang memang ditetapkan dalam versi kuesioner.
- Tampilkan subskala dan total kesulitan.
- Simpan kategori sesuai threshold yang telah dikonfirmasi.
- Tampilkan peringatan bahwa hasil merupakan skrining, bukan diagnosis.

Gunakan kuesioner dan kunci skoring yang telah dipakai UPTD. Jangan mengganti versi instrumen atau menentukan threshold baru tanpa konfirmasi klinis.

#### SRQ-20

- Tepat 20 pertanyaan.
- Jawaban hanya Ya atau Tidak.
- Ya bernilai 1 dan Tidak bernilai 0.
- Pertanyaan berhubungan dengan keadaan responden sendiri selama 30 hari terakhir.
- Responden adalah orang tua/pengasuh, bukan kondisi mental anak.
- Skor 0–5 berada di bawah nilai pisah; skor 6–20 memenuhi nilai pisah berdasarkan sumber SRQ yang telah diberikan.
- Hasil tidak boleh disebut diagnosis klinis.
- Pertanyaan nomor 17 tentang pikiran mengakhiri hidup harus diperlakukan secara hati-hati. Rancang penanda untuk membantu peninjauan tenaga kesehatan setelah aturan respons klinis disepakati dengan UPTD. Jangan membuat keputusan penanganan darurat otomatis yang belum dikonfirmasi.
- Jangan menampilkan hasil kepada orang tua pada halaman konfirmasi pengisian.

#### KPSP

KPSP tidak boleh dibangun sebagai sepuluh pertanyaan generik yang sama untuk semua umur.

Audit dan implementasikan berdasarkan formulir umur, butir perkembangan, cara menghitung umur termasuk koreksi prematuritas, kategori, dan rekomendasi stimulasi yang sesuai dengan pedoman SDIDTK yang digunakan UPTD.

Umur bentuk KPSP yang terlihat pada layanan perhitungan saat ini adalah:

3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60, 66, dan 72 bulan.

Pertahankan hasil pengujian umur yang sudah ada. Jangan mengubah mekanisme umur terkoreksi atau pembulatan pemilihan formulir tanpa verifikasi terhadap pedoman resmi.

#### M-CHAT-R dan GPPH (ACTRS)

Audit layanan perhitungan yang sudah tersedia sebelum membuat controller atau halaman.

Untuk M-CHAT-R, pastikan implementasi mengikuti formulir, item, aturan skor, dan pertanyaan tindak lanjut yang benar-benar digunakan.

Untuk GPPH (ACTRS), pastikan versi kuesioner, butir, kunci skor, rentang umur, kategori, serta tindakan lanjutan sudah dikonfirmasi.

Jangan mengarang isi kuesioner, threshold, atau rekomendasi klinis. Jika dokumen yang diperlukan belum tersedia, buat daftar kebutuhan dan tandai implementasi tersebut sebagai belum siap digunakan untuk pemeriksaan klinis.

### 6.6. Halaman detail sesi — `ScreeningSessions/Show.vue`

Kembangkan halaman ini menjadi ringkasan sesi klinis.

Bagian identitas:

- nama anak;
- nomor rekam medis;
- tanggal lahir;
- jenis kelamin;
- umur saat pemeriksaan;
- tanggal pemeriksaan;
- pembuat sesi;
- perawat penanggung jawab;
- dokter peninjau;
- status sesi.

Bagian progres:

- daftar seluruh instrumen;
- status setiap instrumen;
- indikator kemajuan;
- waktu pengisian dan penyelesaian;
- tautan membuka hasil yang tersedia.

Bagian hasil:

- hasil skoring per instrumen;
- kategori dan rekomendasi yang sesuai;
- interpretasi dokter per instrumen;
- status catatan dokter;
- tindak lanjut.

Jangan menampilkan skor final untuk instrumen yang masih memiliki jawaban tidak lengkap.

### 6.7. Halaman interpretasi dokter

Buat halaman atau panel yang terkait dengan instrumen tertentu, bukan satu kolom catatan global untuk semua hasil.

Contoh:

- Interpretasi SDQ;
- Interpretasi SRQ;
- Interpretasi KPSP;
- Interpretasi M-CHAT-R;
- Interpretasi GPPH.

Setiap formulir menampilkan hasil instrumen yang sedang ditinjau.

Kolom yang tersedia:

- hasil pemeriksaan atau observasi klinis;
- interpretasi dokter;
- keputusan tindak lanjut;
- uraian tindak lanjut atau rujukan;
- status draf atau selesai.

Dokter dapat menyimpan draf, memperbaruinya, kemudian menandainya selesai. Penyelesaian satu instrumen tidak mengharuskan instrumen lain sudah selesai.

Pilihan tindak lanjut dapat meliputi pemantauan, penilaian lebih lanjut, pemeriksaan lanjutan, rujukan, atau tindakan lain yang sudah disetujui UPTD.

Jangan menetapkan daftar intervensi sebagai protokol medis final tanpa persetujuan tenaga kesehatan yang berwenang.

### 6.8. Ringkasan akhir dan laporan

Halaman laporan harus menggabungkan:

- informasi pasien;
- tanggal pemeriksaan;
- daftar instrumen dan statusnya;
- skor dan kategori hasil;
- interpretasi dokter;
- tindak lanjut per instrumen;
- identitas dokter yang meninjau;
- waktu penyelesaian.

Laporan harus membedakan fakta hasil perhitungan dari interpretasi profesional dokter.

Gunakan tampilan cetak yang rapi. Jika PDF diperlukan, audit dependency yang sudah tersedia sebelum menambahkan library baru.

Tombol penyelesaian akhir harus memiliki aturan yang jelas. Sesi tidak boleh berstatus selesai ditinjau sebelum persyaratan peninjauan yang disepakati terpenuhi. Jika sebagian instrumen tidak wajib atau belum tersedia, statusnya harus ditampilkan secara eksplisit.

---

## 7. ALUR KERJA KLINIS

### 7.1. Sesi skrining

Alur umum:

1. Petugas login.
2. Petugas mencari dan memilih pasien dari data layanan.
3. Petugas memulai sesi skrining.
4. Sistem menghitung umur berdasarkan tanggal pemeriksaan.
5. Petugas memilih instrumen yang sesuai.
6. Jika sesi dibuat oleh dokter, dokter menetapkan perawat penanggung jawab.
7. Sistem menyimpan identitas pembuat dan status awal sesi.
8. Perawat membuka instrumen.
9. Perawat mendampingi pengisian oleh orang tua atau melakukan pemeriksaan sesuai peran responden instrumen.
10. Jawaban disimpan sebagai draf selama pengisian.
11. Setelah jawaban lengkap, backend memvalidasi dan menghitung skor.
12. Hasil dan status instrumen disimpan.
13. Ketika persyaratan skrining terpenuhi, sesi ditandai menunggu tinjauan dokter.
14. Dokter memeriksa hasil instrumen.
15. Dokter mencatat interpretasi dan tindak lanjut secara terpisah.
16. Catatan dapat disimpan sebagai draf dan diperbarui.
17. Dokter menyelesaikan peninjauan saat persyaratan terpenuhi.
18. Sistem menyediakan ringkasan akhir dan laporan.

### 7.2. Alur SDQ

Berdasarkan alur kerja UPTD:

1. Orang tua/wali mengisi SDQ.
2. Perawat memastikan jawaban lengkap dan benar.
3. Backend menghitung skor berdasarkan kunci SDQ yang digunakan UPTD.
4. Sistem menentukan kategori masing-masing subskala dan total kesulitan sesuai aturan yang telah diverifikasi.
5. Dokter membandingkan hasil dengan informasi orang tua, keadaan anak, observasi, dan instrumen terkait.
6. Jika hasil menunjukkan kemungkinan masalah, dokter memutuskan penilaian atau tindak lanjut yang diperlukan.
7. Hasil disimpan sebagai informasi skrining, bukan diagnosis pasti.

### 7.3. Alur SRQ-20

1. Perawat menyediakan formulir SRQ-20 kepada orang tua atau pengasuh.
2. Orang tua/pengasuh mengisi pertanyaan mengenai keadaan dirinya selama 30 hari terakhir.
3. Perawat memastikan seluruh jawaban terisi.
4. Backend menghitung jumlah jawaban Ya dan membandingkannya dengan nilai pisah.
5. Dokter memeriksa hasil dan mempertimbangkan kondisi responden serta hubungannya dengan proses pendampingan anak.
6. Dokter menentukan tindak lanjut berdasarkan pemeriksaan dan kondisi klinis.
7. Skor SRQ tidak diperlakukan sebagai hasil pengukuran langsung kesehatan mental anak dan tidak menjadi diagnosis otomatis.

### 7.4. Hubungan hasil instrumen

Hasil KPSP, M-CHAT-R, GPPH, SDQ, dan SRQ dapat dipertimbangkan bersama dalam ringkasan pemeriksaan.

Namun, sistem tidak boleh menggabungkan seluruh skor menjadi satu skor risiko umum tanpa aturan model keputusan yang sah dan disetujui.

Setiap hasil tetap mempertahankan skor, kategori, dan penafsirannya sendiri. Keputusan akhir adalah tanggung jawab dokter.

---

## 8. ATURAN RULE-BASED SCORING

Gunakan arsitektur service yang telah tersedia:

- `ScorerInterface`
- `ScoringResult`
- `RuleBasedScoringService`

Setiap instrumen memiliki scorer terpisah. Controller tidak boleh menghitung skor secara manual dengan menggandakan aturan yang sudah berada di service.

Ketentuan implementasi:

1. Validasi kelengkapan jawaban.
2. Validasi tipe dan nilai setiap jawaban.
3. Hitung skor pada backend.
4. Tentukan kategori memakai aturan yang telah diverifikasi.
5. Hasilkan rekomendasi hanya jika aturan rekomendasinya telah dikonfirmasi.
6. Simpan jawaban mentah serta hasil skoring.
7. Uji nilai tepat pada setiap batas threshold.
8. Uji nilai di bawah dan di atas batas.
9. Uji jawaban kosong, jumlah salah, dan tipe data tidak valid.
10. Pastikan frontend tidak dapat menentukan skor final melalui request.

Pertahankan aturan SDQ dan SRQ yang telah diuji. Sebelum mengubah kategori atau skoring, bandingkan service dengan dokumen kuesioner dan pedoman yang digunakan UPTD.

Untuk KPSP, M-CHAT-R, dan GPPH, periksa validitas aturan saat ini sebelum menghubungkannya ke workflow produksi.

---

## 9. STATUS DAN SIKLUS HIDUP SESI

Gunakan status sesi yang sudah tersedia sebagai titik awal:

- `draft`
- `in_progress`
- `pending_parent`
- `pending_doctor_review`
- `reviewed`
- `cancelled`

Status instrumen tetap dibedakan dari status sesi.

Definisikan transisi status secara eksplisit. Jangan mengubah status hanya berdasarkan tampilan frontend.

Pertimbangkan aturan berikut:

- Sesi baru dimulai sebagai draf.
- Saat pengerjaan instrumen dimulai, status instrumen berubah menjadi sedang dikerjakan.
- Jawaban final yang valid mengubah status instrumen menjadi selesai.
- Jika seluruh persyaratan instrumen terpenuhi, sesi menunggu tinjauan dokter.
- Catatan dokter dapat disimpan sebagai draf tanpa menyelesaikan sesi.
- Status selesai ditinjau hanya dicapai melalui tindakan dokter yang berwenang.
- Sesi yang dibatalkan atau sudah selesai ditinjau tidak dapat diubah oleh perawat melalui endpoint pengisian biasa.

Pastikan status draf interpretasi tidak dianggap sama dengan status selesai ditinjau.

---

## 10. PENINGKATAN UI/UX

Gunakan empat gambar referensi sebagai acuan:

1. Direktori pasien dengan pencarian, filter, dan kartu pasien.
2. Konfigurasi pemilihan instrumen dengan status kelayakan dan ringkasan sesi.
3. Pengisian kuesioner dengan satu pertanyaan atau kelompok pertanyaan, progres, dan navigasi.
4. Ringkasan klinis berisi hasil, rekomendasi, catatan, riwayat, serta tombol menyimpan progres dan menyelesaikan laporan.

Terapkan prinsip berikut:

- Bahasa Indonesia konsisten.
- Tata letak bersih dan profesional.
- Sidebar navigasi dan breadcrumb jelas.
- Status menggunakan label tekstual, tidak hanya warna.
- Formulir dapat digunakan dengan keyboard dan tablet.
- Validasi muncul dekat dengan input terkait.
- Tombol tindakan jelas dan tidak ambigu.
- Indikator penyimpanan memberi tahu apakah jawaban telah tersimpan.
- Jangan memakai data pasien nyata sebagai data contoh pada screenshot atau test.
- Jangan menambahkan grafik yang tidak memiliki makna klinis atau operasional jelas.
- Jangan mengubah informasi klinis hanya untuk mengikuti tampilan referensi.

Gunakan Tailwind CSS dan komponen yang sudah tersedia. Hindari menambah library UI besar apabila kebutuhan bisa dipenuhi oleh stack saat ini.

---

## 11. RUTE DAN KONTROL AKSES

Audit rute yang sudah tersedia sebelum menambahkan yang baru.

Kelompokkan rute berdasarkan fungsi, contohnya:

**Pasien**

- daftar pasien;
- pencarian pasien;
- detail pasien jika dibutuhkan.

**Sesi skrining**

- daftar sesi;
- pembuatan sesi;
- penyimpanan sesi;
- detail sesi.

**Instrumen**

- formulir SDQ;
- penyimpanan SDQ;
- formulir SRQ;
- penyimpanan SRQ;
- rute instrumen lainnya sesuai implementasi.

**Dokter**

- tampilan hasil sesi;
- pembuatan dan pembaruan interpretasi;
- penyelesaian tinjauan;
- laporan akhir.

Nama rute di atas merupakan rancangan. Pertahankan nama rute yang sudah dipakai dan tambahkan rute baru secara konsisten.

Gunakan middleware autentikasi dan peran. Semua rute yang mengubah data wajib menerapkan validasi serta pemeriksaan akses terhadap sesi, instrumen, dan dokter/perawat yang terkait.

Perhatikan bahwa `ScreeningSessionController`, `SdqScreeningController`, dan `SrqScreeningController` saat ini telah memiliki pembatasan tertentu berdasarkan peran dan kepemilikan sesi. Jangan menghapusnya saat mengubah arsitektur database.

---

## 12. STRATEGI MIGRASI YANG AMAN

Migrasi database adalah bagian paling sensitif dari proyek ini.

### Tahap A — Audit

Sebelum mengubah kode:

1. Baca `.env` hanya untuk mengetahui nama variabel koneksi yang digunakan; jangan mencetak password.
2. Jalankan `git status` dan periksa perubahan lokal.
3. Periksa status migrasi database SPK yang sedang dipakai.
4. Audit seluruh tabel dan foreign key pada database layanan.
5. Periksa tabel bernama sama pada kedua struktur.
6. Dokumentasikan pemetaan model lama ke model baru.
7. Catat kolom, constraint, index, dan data yang berpotensi konflik.
8. Susun laporan singkat berisi risiko dan langkah pemulihan.

### Tahap B — Persiapan staging

1. Buat backup database sumber dan backup database SPK secara terpisah.
2. Pulihkan backup ke lingkungan staging.
3. Verifikasi jumlah data dan constraint.
4. Buat skema `spk`.
5. Pastikan user database yang digunakan memiliki hak akses minimal yang diperlukan.
6. Jangan menjalankan restore pada database produksi.
7. Jangan menjalankan migrasi lama yang membuat ulang tabel publik terhadap `ta_bismillah`.

### Tahap C — Migrasi struktural

1. Pisahkan migrasi khusus SPK dari migrasi lama yang membuat tabel master.
2. Buat tabel khusus SPK pada skema `spk`.
3. Referensikan pasien dan pengguna sumber melalui foreign key skema `public` apabila kompatibel dengan struktur dan hak akses database.
4. Validasi urutan pembuatan tabel serta relasi.
5. Audit hasil SQL yang dihasilkan Laravel sebelum penerapan.
6. Jalankan migrasi hanya terhadap koneksi dan path yang ditujukan bagi skema SPK.
7. Jangan menggunakan `migrate:fresh`, `db:wipe`, `DROP TABLE`, atau `TRUNCATE` terhadap database layanan.

### Tahap D — Migrasi data historis

1. Petakan pasien lama ke pasien sumber menggunakan identitas stabil.
2. Petakan akun pembuat, dokter, perawat, serta orang tua/wali melalui identitas yang terverifikasi.
3. Migrasikan sesi dan status instrumen.
4. Migrasikan jawaban, skor, kategori, dan rekomendasi.
5. Migrasikan catatan yang memang tersedia.
6. Catat baris yang tidak dapat dipetakan.
7. Validasi jumlah baris, foreign key, unique constraint, serta distribusi status.
8. Pertahankan data yang belum terpetakan untuk rekonsiliasi manual.
9. Bandingkan beberapa sampel hasil skoring antara data lama dan data tujuan.
10. Jangan menghapus database atau tabel lama sampai seluruh validasi selesai dan cutover disetujui.

### Tahap E — Cutover

1. Uji workflow secara lengkap di staging.
2. Verifikasi integrasi login dan hak akses.
3. Verifikasi hasil skoring setiap instrumen.
4. Verifikasi tampilan dan laporan.
5. Dokumentasikan cara mengembalikan konfigurasi aplikasi jika cutover gagal.
6. Alihkan koneksi aplikasi hanya setelah backup, validasi, dan persetujuan tersedia.

Skema `public` tetap menjadi sumber master dan tidak boleh diubah hanya untuk mempermudah implementasi SPK.

---

## 13. PRIVASI DAN KEAMANAN

Aplikasi menyimpan informasi kesehatan anak dan orang tua/pengasuh. Perlakukan semua data sebagai informasi sensitif.

Wajib diterapkan:

- pembatasan akses berbasis peran;
- validasi server-side;
- pencegahan akses IDOR;
- perlindungan CSRF sesuai mekanisme Laravel;
- sesi login dan logout yang aman;
- pengelolaan error tanpa mengekspos query atau kredensial;
- pemisahan hasil responden SRQ dari hasil anak;
- tidak menampilkan skor pada layar konfirmasi responden;
- tidak memaparkan data rekam medis yang tidak dibutuhkan;
- audit perubahan interpretasi dokter;
- foreign key dan transaction pada operasi penting;
- backup dan retensi data sesuai kebijakan UPTD;
- konfigurasi produksi tanpa debug yang membocorkan data.

Jangan menyertakan password, token, isi `.env`, atau data pasien asli ke source control maupun log pengembangan.

---

## 14. PENGUJIAN WAJIB

Gunakan test yang sudah tersedia sebagai baseline. Pada riwayat sebelumnya, test untuk umur KPSP, skoring SDQ, skoring SRQ, autentikasi, pasien, dan sesi telah digunakan.

Jalankan baseline sebelum mengubah kode. Setelah setiap tahap, jalankan test yang relevan dan keseluruhan suite.

### Unit test

Uji:

- perhitungan umur dan koreksi prematuritas;
- pemilihan formulir KPSP;
- skor dan kategori masing-masing instrumen;
- jawaban yang kurang atau berlebih;
- tipe data salah;
- threshold tepat di batas;
- konsistensi hasil scorer.

### Feature test

Uji:

- login akun layanan;
- akses dokter dan perawat;
- akun orang tua ditolak;
- pencarian pasien;
- pembuatan sesi oleh perawat;
- pembuatan sesi oleh dokter dengan penanggung jawab perawat;
- pencatatan pembuat sesi;
- manipulasi `patient_id`, `nurse_user_id`, `doctor_id`, `age_months`, dan `status`;
- pemisahan hak akses pengisian dan interpretasi;
- akses perawat terhadap sesi yang ditugaskan;
- akses dokter terhadap sesi yang berwenang ditinjau;
- penyimpanan dan pemulihan draf;
- transaksi saat menyimpan hasil;
- penyelesaian sesi;
- pencatatan interpretasi per instrumen;
- keamanan halaman konfirmasi responden;
- integritas migrasi dan pemetaan data.

### Integrasi database

Uji khusus bahwa:

- `public.patients` tetap dapat diakses dan tidak berubah secara tidak sengaja;
- `public.users` tetap menjadi sumber akun;
- `public.sdq_screenings` tidak tertimpa oleh tabel SPK;
- tabel hasil SPK berada di `spk`;
- foreign key lintas-skema valid;
- query Eloquent tidak salah membaca tabel dengan nama sama;
- transaksi pada skema SPK berjalan utuh;
- migrasi bisa dijalankan secara terprediksi di staging.

### Build dan pemeriksaan

Gunakan perintah yang sesuai dengan lingkungan proyek, misalnya:

```bash
docker compose exec app php artisan test
docker compose exec app php artisan route:list
docker compose exec app php artisan migrate:status
npm run build
git diff --check
```

Perintah yang berkaitan dengan migrasi harus diarahkan ke database staging yang benar dan diperiksa sebelum dieksekusi.

---

## 15. KRITERIA PENERIMAAN

Pengembangan dianggap memenuhi kebutuhan apabila:

1. Data pasien, dokter, pengguna, dan orang tua/wali berasal dari sumber layanan yang sama.
2. Tidak ada duplikasi master data yang tidak diperlukan.
3. Seluruh tabel operasional SPK berada di skema `spk`.
4. Tidak ada tabel pada `public` yang tertimpa atau dihapus.
5. Dokter dan perawat mempunyai hak akses yang sesuai dengan tugas masing-masing.
6. Dokter bisa memulai sesi dan menentukan perawat penanggung jawab.
7. Perawat bisa mengerjakan sesi yang menjadi tanggung jawabnya.
8. Orang tua dapat mengisi formulir dengan pendampingan tanpa memperoleh akses ke dashboard internal.
9. Hasil skoring dihitung pada backend dan dapat diuji ulang.
10. Jawaban draf tidak dianggap sebagai hasil final.
11. Interpretasi dokter tersimpan terpisah untuk tiap instrumen.
12. Catatan sementara dapat disimpan sebelum semua instrumen selesai.
13. Ringkasan klinis hanya menampilkan hasil yang telah tersedia.
14. Laporan mencantumkan hasil instrumen serta interpretasi secara jelas.
15. Data historis dapat dipetakan dan direkonsiliasi tanpa kehilangan data.
16. Tes yang relevan lulus dan build frontend berhasil.
17. Proses migrasi dapat diaudit dan mempunyai rencana pemulihan.

---

## 16. METODE KERJA AI CODING AGENT

Kerjakan sebagai rangkaian tahap yang dapat diperiksa, bukan satu perubahan besar yang sulit ditelusuri.

### Tahap 1 — Audit dan perencanaan

Periksa:

- status Git;
- struktur model dan controller;
- route;
- konfigurasi koneksi;
- migrasi;
- sumber backup;
- tabel yang berkonflik;
- test yang tersedia.

Hasilkan pemetaan tabel dan relasi sumber-ke-SPK. Tunjukkan risiko sebelum mengubah database.

Jika detail skema sumber tidak dapat dibuktikan, tandai sebagai belum terverifikasi. Jangan mengarang kolom atau relasi.

### Tahap 2 — Integrasi database

Siapkan koneksi dan migrasi khusus SPK. Uji di staging. Jangan alihkan aplikasi produksi dan jangan memigrasikan seluruh data historis sebelum pemetaan disetujui.

### Tahap 3 — Model dan autentikasi

Sesuaikan model sumber dan SPK, middleware, autentikasi, relasi, serta penanggung jawab sesi. Jalankan test sebelum membuat halaman baru.

### Tahap 4 — Direktori pasien dan konfigurasi sesi

Bangun pengalaman pemilihan pasien dan konfigurasi instrumen sesuai referensi desain. Hubungkan dengan data layanan aktual dan validasi umur di backend.

### Tahap 5 — Workflow pengisian instrumen

Pertahankan SDQ dan SRQ yang sudah ada, lalu tambahkan dukungan draf, penyimpanan progres, dan mekanisme pemulihan. Implementasikan instrumen lainnya setelah aturan skoring dan formulirnya terverifikasi.

### Tahap 6 — Ringkasan klinis dan interpretasi dokter

Bangun halaman detail sesi, hasil instrumen, catatan interpretasi terpisah, tindak lanjut, dan aturan penyelesaian sesi.

### Tahap 7 — Laporan akhir

Bangun tampilan cetak atau PDF dan pastikan laporan merepresentasikan hasil yang tersimpan di database, bukan hasil perhitungan frontend yang belum divalidasi.

### Tahap 8 — Validasi keseluruhan

Jalankan seluruh test, audit route, build frontend, pemeriksaan Git, dan pengujian integrasi di staging. Buat catatan fitur yang selesai, yang belum selesai, serta risiko tersisa.

Setelah setiap tahap, laporkan:

1. perubahan yang dilakukan;
2. file yang ditambahkan atau diubah;
3. alasan perubahan;
4. hasil pengujian;
5. status data dan migrasi;
6. langkah berikutnya.

Jangan melakukan `git commit` atau `git push` tanpa instruksi eksplisit.

---

## 17. BATASAN YANG TIDAK BOLEH DILANGGAR

- Jangan menjalankan migrasi destruktif pada `ta_bismillah`.
- Jangan menganggap `Backup3.sql` sebagai SQL teks biasa sebelum memeriksa formatnya.
- Jangan memindahkan akun pengguna dengan mencocokkan ID numerik saja.
- Jangan membuat duplikasi pasien.
- Jangan menyatukan tabel SDQ layanan dan SDQ SPK.
- Jangan mengubah algoritma skoring yang telah disepakati hanya untuk menyederhanakan implementasi.
- Jangan menghasilkan diagnosis klinis otomatis dari skor.
- Jangan mengarang formulir, threshold, usia kelayakan, atau rekomendasi klinis.
- Jangan membuka akses pengisian instrumen kepada dokter hanya karena dokter boleh membuat sesi.
- Jangan menjadikan `created_by_user_id` sebagai pengganti identitas perawat atau dokter peninjau.
- Jangan menyamakan jawaban SRQ orang tua dengan kondisi mental anak.
- Jangan menghapus hasil historis, jawaban, dan catatan tanpa persetujuan.
- Jangan menyelesaikan fitur hanya dengan membuat tampilan Vue tanpa validasi backend dan test.

---

## 18. TUGAS PERTAMA YANG HARUS DILAKUKAN

Mulai dengan **audit repositori dan skema database**, bukan langsung menulis migrasi.

Periksa keadaan kode dan database yang benar-benar tersedia. Verifikasi:

1. Apakah `created_by_user_id` sudah ada pada model dan migrasi saat ini.
2. Bagaimana status migrasi dan nama database yang sedang dipakai.
3. Apakah backup sumber benar-benar PostgreSQL custom format.
4. Struktur aktual `public.users`, `public.patients`, `public.parent_guardians`, `public.doctors`, serta semua tabel yang berpotensi berbenturan dengan SPK.
5. Apakah tersedia tabel profil perawat pada database layanan.
6. Struktur `public.sdq_screenings` dan hubungan foreign key-nya.
7. Bagaimana seluruh migrasi SPK lama akan dipisahkan dari migrasi untuk skema `spk`.
8. Bagaimana data historis akan dipetakan dengan aman.

Berikan laporan audit, tabel pemetaan, diagram arsitektur, daftar konflik, rancangan migrasi, dan urutan implementasi yang spesifik terhadap kode aktual.

Setelah audit, mulai implementasi tahap pertama yang aman dan dapat diuji. Jangan berhenti hanya pada saran umum apabila struktur dan informasi yang dibutuhkan sudah tersedia. Jika keputusan klinis atau struktur sumber benar-benar belum diketahui, berhenti hanya pada bagian yang terpengaruh dan jelaskan informasi yang perlu dikonfirmasi.

**Target akhirnya:** SPK Skrining Anak yang terintegrasi dengan database layanan UPTD BLK-ABK, memiliki antarmuka klinis yang terpadu, menjalankan rule-based scoring dan threshold secara teruji, mendukung pekerjaan perawat dan dokter, mempertahankan integritas rekam pemeriksaan, dan tidak merusak data atau workflow sistem layanan yang sudah berjalan.