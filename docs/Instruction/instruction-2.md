# MASTER PROMPT — PENGEMBANGAN SPK SKRINING ANAK UPTD BLK-ABK KOTA BALIKPAPAN

## 1. Peran dan tujuan

Bertindak sebagai Senior Software Architect, Senior Laravel Developer, Database Engineer, dan Clinical Decision Support System (CDSS) Engineer.

Lanjutkan pengembangan aplikasi **Sistem Pendukung Keputusan (SPK) Skrining Anak** untuk UPTD BLK-ABK Kota Balikpapan.

Aplikasi bertujuan membantu tenaga kesehatan mengelola sesi pemeriksaan, melakukan skrining menggunakan instrumen yang sesuai, menghitung skor secara otomatis dengan metode rule-based scoring dan threshold, menyimpan hasil, mendukung interpretasi dokter, serta mendokumentasikan tindak lanjut.

Implementasi wajib berdasarkan:

1. Kode repositori yang tersedia.
2. Struktur database layanan UPTD BLK-ABK dalam berkas `Backup3.sql`.
3. Dokumen instrumen dan pedoman yang disediakan.
4. Alur kerja perawat dan dokter.
5. Keputusan arsitektur integrasi database dan desain antarmuka yang telah disepakati.

**Jangan membangun ulang proyek dari nol.** Audit sistem terlebih dahulu, pertahankan komponen yang sudah benar, dan ubah kode hanya berdasarkan kebutuhan yang telah diverifikasi.

Jangan mengarang butir kuesioner, aturan skor, ambang batas, kategori, rentang umur, atau rekomendasi klinis. Jika sumber bertentangan, catat pertentangannya dan jangan menetapkan aturan klinis baru tanpa dasar atau persetujuan yang diperlukan.

---

## 2. Kondisi awal repositori

Repositori: `spk-skrining-anak-v2`.

Teknologi utama:

- PHP 8.2
- Laravel 12
- PostgreSQL
- Vue 3 dengan Composition API
- Inertia.js
- Tailwind CSS v4
- Vite
- Docker Compose
- PHPUnit/Pest sesuai konfigurasi aktual proyek

Periksa `composer.lock`, `package-lock.json`, `.env` tanpa mencetak rahasia, konfigurasi database, dan status Git sebelum mengubah apa pun.

### 2.1. Komponen yang sudah tersedia

Audit awal repositori menunjukkan keberadaan:

**Model:** `User`, `Role`, `Patient`, `ParentGuardian`, `Doctor`, `Nurse`, `ScreeningSession`, `ScreeningSessionInstrument`, `KpspScreening`, `MchatScreening`, `GpphScreening`, `SdqScreening`, dan `SrqScreening`.

**Controller:** `LoginController`, `DashboardController`, `PatientController`, `ScreeningSessionController`, `SdqScreeningController`, dan `SrqScreeningController`.

**Layanan perhitungan:** `KpspAgeCalculator`, `KpspScorer`, `MchatScorer`, `GpphScorer`, `SdqScorer`, `SrqScorer`, `RuleBasedScoringService`, `ScorerInterface`, dan `ScoringResult`.

**Halaman Vue:** halaman autentikasi, dashboard berdasarkan peran, direktori pasien, pembuatan sesi, daftar sesi, detail sesi, SDQ, SRQ, serta konfirmasi penyelesaian SRQ.

Kondisi kode dan implementasi terkini harus diverifikasi kembali karena dapat berbeda dari audit sebelumnya.

Commit acuan yang pernah tersedia:

- `23ee184` — `feat: implement screening sessions and SDQ workflow`
- `c652fe9` — `feat: implement SRQ-20 screening workflow`

Migrasi `2026_10_12_054704_add_created_by_user_id_to_screening_sessions_table.php` juga pernah dijalankan pada database yang dikonfigurasi saat itu. Periksa status aktual sebelum membuat migrasi baru.

---

## 3. Sumber spesifikasi instrumen

Pelajari seluruh berkas berikut sebelum mengubah atau membuat layanan perhitungan dan halaman pengisian.

1. `INSTRUMEN SDQ DAN SKORING(20261011-171303).pdf`
2. `ilide.info-self-rating-questionnaire-srq-20-pr_a7713a70bc4bc118d63c22fda2f91451(9).pdf`
3. `Autism_M-Chat-R(2).pdf`
4. `M-CHAT-R_F_Scoring-March-2025.v1(1).xlsx`
5. `GPPH_ACTRS(2).pdf`
6. `Rentang Umur(2).pdf`

Gunakan `Backup3.sql` untuk memeriksa struktur sumber data layanan.

Berkas KPSP yang terperinci akan diberikan kemudian. Karena itu, jangan mengembangkan formulir, aturan skor, tabel rekomendasi stimulasi, atau seluruh variasi umur KPSP dalam tahap ini.

### 3.1. Hierarki sumber dan penanganan konflik

Pisahkan tiga hal:

- **Aturan pada sumber:** ketentuan yang benar-benar tertulis dalam dokumen.
- **Aturan yang sekarang digunakan aplikasi:** perilaku scorer dan threshold yang telah diterapkan serta diuji.
- **Aturan operasional final:** ketentuan yang telah disepakati untuk digunakan oleh UPTD.

Jangan menganggap ketiganya selalu identik.

Jika ditemukan konflik:

1. Dokumentasikan lokasi dan uraian konflik.
2. Tunjukkan dampaknya terhadap hasil kategori atau rekomendasi.
3. Pertahankan perilaku yang sudah diuji selama kompatibilitasnya perlu dijaga.
4. Minta penetapan aturan yang berwenang sebelum mengubah ketentuan klinis.
5. Jangan membiarkan aplikasi menghasilkan keputusan klinis yang belum mempunyai aturan final.

Gunakan konfigurasi atau versi aturan yang dapat ditelusuri. Hasil pemeriksaan historis harus tetap dapat diketahui menggunakan versi instrumen dan aturan yang berlaku saat pemeriksaan dilakukan.

---

# 4. Spesifikasi instrumen skrining

Implementasikan instrumen berdasarkan data dan algoritma yang sesuai. Setiap instrumen mempunyai scorer sendiri dan tidak boleh menggunakan threshold milik instrumen lain.

## 4.1. SDQ — Strengths and Difficulties Questionnaire

### A. Tujuan instrumen

SDQ merupakan kuesioner untuk mengidentifikasi kemungkinan masalah emosional dan perilaku anak serta menilai perilaku prososial.

Dalam ruang lingkup aplikasi saat ini, SDQ yang diaktifkan adalah versi usia 4 tahun sampai sebelum 11 tahun, dengan formulir yang sesuai untuk orang tua atau pengasuh.

Berkas sumber juga memuat formulir usia 11–18 tahun. Jangan otomatis mengaktifkan rentang ini karena perluasan usia merupakan perubahan ruang lingkup. Jika kelak diaktifkan, gunakan formulir yang sesuai dengan kelompok umur dan respondennya.

SDQ bukan instrumen diagnosis pasti.

### B. Jumlah butir dan pilihan jawaban

- Jumlah butir: 25.
- Pilihan jawaban: Tidak Benar, Agak Benar, Selalu Benar.
- Nilai dasar: 0, 1, 2.
- Nilai jawaban harus dikonversi sesuai kunci untuk setiap butir.
- Semua jawaban wajib terisi sebelum hasil final dihitung.

Gunakan teks pertanyaan dari formulir SDQ yang disediakan. Jangan membuat ulang pertanyaan berdasarkan tebakan atau menggunakan versi usia 11–18 untuk formulir anak usia 4–10 tahun.

### C. Lima subskala

Masing-masing subskala memiliki lima butir dengan skor 0–10.

| Subskala | Kode | Nomor butir |
|---|---|---|
| Gejala Emosional | E | 3, 8, 13, 16, 24 |
| Masalah Perilaku | C | 5, 7, 12, 18, 22 |
| Hiperaktivitas | H | 2, 10, 15, 21, 25 |
| Masalah Teman Sebaya | P | 6, 11, 14, 19, 23 |
| Perilaku Prososial | Pro | 1, 4, 9, 17, 20 |

Total skor kesulitan adalah:

`Total Kesulitan = E + C + H + P`

Rentang total skor kesulitan adalah 0–40. Skor Pro tidak dimasukkan dalam total kesulitan.

### D. Pembalikan skor

Butir yang menggunakan pembalikan skor:

`7, 11, 14, 21, 25`

Untuk butir tersebut, konversi nilai mentah menggunakan:

`Skor Butir = 2 - Nilai Jawaban`

Jadi, jawaban bernilai 0 menjadi 2, jawaban 1 tetap 1, dan jawaban 2 menjadi 0.

Semua butir lainnya menggunakan nilai mentah 0, 1, atau 2 sesuai urutan jawaban yang benar.

Lakukan pembalikan skor sebelum menghitung skor subskala. Jangan menerapkan pembalikan dua kali, dan jangan menyimpulkan arah skor dari posisi radio button di Vue.

### E. Kategori SDQ untuk usia 4 sampai sebelum 11 tahun

Gunakan tabel berikut sebagai baseline implementasi aplikasi yang sudah diuji, sambil menyimpan temuan ketidaksesuaian sumber dalam daftar verifikasi klinis.

| Komponen | Normal | Ambang/Borderline | Abnormal |
|---|---:|---:|---:|
| Total Kesulitan | 0–13 | 14–15 | 16–40 |
| Gejala Emosional (E) | 0–3 | 4 | 5–10 |
| Masalah Perilaku (C) | 0–2 | 3 | 4–10 |
| Hiperaktivitas (H) | 0–5 | 6 | 7–10 |
| Masalah Teman Sebaya (P) | 0–2 | 3 | 4–10 |
| Prososial (Pro) | 6–10 | 5 | 0–4 |

Interpretasi Prososial berbeda arah dengan skor kesulitan: skor yang lebih tinggi masuk kategori normal, sedangkan skor rendah masuk kategori abnormal.

**Konflik sumber wajib dicatat:**

1. Dokumen total kesulitan menuliskan skor 14–15 sebagai borderline dan 15–40 sebagai abnormal. Skor 15 berada pada dua kategori. Baseline aplikasi menggunakan 14–15 borderline dan mulai 16 abnormal karena aturan itu telah diuji.
2. Tabel masalah perilaku memberi label usia `<10 tahun`, sedangkan formulir dan ruang lingkup aplikasi mencakup anak usia 4 sampai sebelum 11 tahun. Karena itu, kelompok usia 10 tahun memerlukan konfirmasi penerapan aturan klinis.
3. Formulir usia 11–18 mempunyai kategori yang berbeda untuk beberapa komponen. Jangan menerapkan batas usia remaja kepada versi anak usia 4–10.
4. Jangan mengubah kategori yang sudah diuji hanya untuk menyamakan teks sumber yang tidak konsisten.

Sertakan temuan tersebut dalam laporan audit dan minta konfirmasi UPTD sebelum mengubah batas klinisnya.

### F. Aturan kategori dan penyimpanan

Backend harus menghasilkan sekurang-kurangnya:

- jawaban mentah 25 butir;
- skor hasil pembalikan setiap butir;
- skor E, C, H, P, dan Pro;
- kategori setiap subskala;
- total kesulitan dan kategorinya;
- versi instrumen dan versi aturan skoring.

Apabila rekomendasi klinis yang spesifik belum disetujui, jangan membuat rekomendasi baru secara otomatis. Hasil skrining harus disajikan sebagai bahan penilaian dokter.

---

## 4.2. SRQ-20 — Self-Reporting Questionnaire

### A. Tujuan dan responden

SRQ-20 adalah kuesioner laporan diri untuk mengidentifikasi kemungkinan gangguan mental emosional atau distres pada **orang yang mengisi kuesioner**, bukan untuk mengukur kondisi mental anak secara langsung.

Dalam alur aplikasi UPTD:

1. Perawat membuka instrumen SRQ-20.
2. Perawat menyerahkan perangkat kepada orang tua atau pengasuh.
3. Orang tua atau pengasuh mengisi sendiri jawaban mengenai kondisi dirinya selama 30 hari terakhir.
4. Perawat tidak menjawab menggantikan responden.
5. Sistem menghitung dan menyimpan skor.
6. Dokter menilai hasil bersama informasi klinis yang tersedia dan menentukan tindak lanjut.

Orang tua/pengasuh tidak perlu mempunyai akun login.

### B. Jumlah butir dan pilihan jawaban

- Jumlah butir: tepat 20.
- Pilihan: Ya atau Tidak.
- Periode rujukan: 30 hari terakhir.
- Ya bernilai 1.
- Tidak bernilai 0.
- Skor minimum: 0.
- Skor maksimum: 20.

Gunakan 20 pertanyaan yang terdapat pada berkas SRQ-20 terlampir. Susunan butir tidak boleh berubah tanpa adanya versi instrumen baru yang disetujui.

Daftar butir sesuai sumber:

1. Sering merasa sakit kepala.
2. Kehilangan nafsu makan.
3. Tidur tidak nyenyak.
4. Mudah merasa takut.
5. Merasa cemas, tegang, atau khawatir.
6. Tangan gemetar.
7. Mengalami gangguan pencernaan.
8. Sulit berpikir jernih.
9. Merasa tidak bahagia.
10. Lebih sering menangis.
11. Sulit menikmati aktivitas sehari-hari.
12. Kesulitan mengambil keputusan.
13. Aktivitas atau tugas sehari-hari terbengkalai.
14. Merasa tidak mampu berperan dalam kehidupan.
15. Kehilangan minat terhadap banyak hal.
16. Merasa tidak berharga.
17. Mempunyai pikiran untuk mengakhiri hidup.
18. Merasa lelah sepanjang waktu.
19. Merasa tidak enak di perut.
20. Mudah lelah.

Teks tampilan akhir harus mengikuti naskah yang disetujui, bukan sekadar parafrasa daftar ringkas di atas.

### C. Penghitungan skor

Gunakan rumus:

`Skor SRQ-20 = Jumlah jawaban Ya`

Contoh aturan:

- 5 jawaban Ya menghasilkan skor 5.
- 6 jawaban Ya menghasilkan skor 6.
- 12 jawaban Ya menghasilkan skor 12.

Jangan memberikan bobot yang berbeda pada item. Semua 20 item memiliki bobot sama dalam skor total.

### D. Kategori SRQ-20

Dokumen sumber menetapkan nilai pisah 5/6.

| Skor | Kategori internal | Label tampilan |
|---|---|---|
| 0–5 | `di_bawah_nilai_pisah` | Di bawah nilai pisah |
| 6–20 | `gangguan_mental_emosional_distres` | Memenuhi nilai pisah |

Nilai 6 atau lebih menandakan hasil skrining memenuhi ambang yang memerlukan perhatian lebih lanjut.

Kategori di atas merupakan kategori hasil skrining. Jangan menyebutnya diagnosis gangguan jiwa, dan jangan menganggap skor 0–5 membuktikan bahwa responden tidak memiliki masalah kesehatan mental.

### E. Subskala SRQ

Dokumen juga mencantumkan pengelompokan deskriptif berdasarkan butir:

| Subskala | Nomor butir |
|---|---|
| Gejala depresi | 6, 9, 10, 14, 15, 16, 17 |
| Gejala cemas | 3, 4, 5 |
| Gejala somatik | 1, 2, 7, 19 |
| Gejala kognitif | 8, 12, 13 |
| Gejala penurunan energi | 8, 11, 12, 13, 18, 20 |

Butir dapat muncul pada lebih dari satu subskala sebagaimana tertulis di dokumen. Jangan menghapus atau mengubah pengelompokan tersebut tanpa verifikasi.

Dokumen yang tersedia tidak memberikan threshold kategori tersendiri untuk kelima subskala. Oleh karena itu:

- Subskala dapat dihitung sebagai informasi deskriptif apabila dibutuhkan.
- Jangan membuat kategori normal, borderline, atau abnormal untuk subskala.
- Jangan menjadikan skor subskala sebagai keputusan klinis otomatis.

### F. Penanganan khusus pertanyaan nomor 17

Pertanyaan nomor 17 membahas pikiran untuk mengakhiri hidup. Hasil jawaban ini harus tetap disimpan dan tersedia bagi dokter yang berwenang.

Jangan mengabaikan jawaban tersebut hanya karena skor total berada di bawah nilai pisah. Namun, jangan pula membuat diagnosis atau mengirim keputusan penanganan darurat otomatis tanpa protokol klinis yang telah disetujui UPTD.

Sediakan mekanisme penanda untuk pemeriksaan tenaga kesehatan sesuai protokol yang nantinya disepakati.

### G. Tampilan hasil dan privasi

Sesudah pengisian selesai:

- tampilkan konfirmasi bahwa jawaban berhasil disimpan;
- jangan menampilkan skor dan kategori pada halaman responden;
- arahkan responden mengembalikan perangkat kepada perawat;
- bersihkan state jawaban sensitif ketika perangkat digunakan responden berikutnya.

Pada halaman internal, dokter harus dapat melihat skor, kategori, jawaban yang berwenang ditinjau, serta interpretasi dan tindak lanjut yang telah dicatat.

---

## 4.3. M-CHAT-R dan M-CHAT-R/F

### A. Tujuan dan umur

M-CHAT-R adalah kuesioner laporan orang tua/pengasuh mengenai perilaku anak untuk skrining risiko gangguan spektrum autisme.

Berkas rentang umur menyebut pelaksanaan M-CHAT Revised pada anak usia 16–30 bulan. Tabel jadwal SDIDTK menandai pemeriksaan pada kunjungan usia 18 dan 24 bulan.

Gunakan 16–30 bulan sebagai rentang pemeriksaan yang tertera pada algoritma sumber. Jangan menyamakan jadwal kunjungan rutin dengan izin untuk mengubah rentang umur instrumen.

Backend tetap harus menghitung umur anak berdasarkan tanggal lahir dan tanggal pemeriksaan serta menolak pemilihan instrumen di luar rentang yang ditetapkan.

### B. Struktur instrumen

- Jumlah pertanyaan: 20.
- Responden: orang tua atau pengasuh.
- Pilihan jawaban: Ya atau Tidak.
- Isi pertanyaan berfokus pada perilaku dan respons anak.

Gunakan teks pertanyaan dari `Autism_M-Chat-R(2).pdf`. Jangan menggunakan butir SDQ, SRQ, atau GPPH untuk mengisi formulir M-CHAT.

### C. Konflik algoritma yang harus ditangani secara eksplisit

Terdapat dua sumber algoritma yang berbeda:

**Sumber A — Buku Bagan SDIDTK**

Dokumen menyebut penghitungan jumlah jawaban Tidak pada semua pertanyaan, kecuali nomor 2, 5, dan 12.

Kategori yang tercantum:

- skor 0–2: risiko rendah;
- skor 3–20: risiko sedang-tinggi.

Sumber ini mengarahkan hasil risiko sedang-tinggi untuk rujukan ke rumah sakit tumbuh kembang level 1.

**Sumber B — Workbook M-CHAT-R/F, diperbarui Maret 2025**

Workbook memuat alur lebih terperinci:

- skor awal 0–2: risiko rendah, tidak memerlukan follow-up rutin berdasarkan algoritma tersebut;
- skor awal 3–7: perlu pemeriksaan follow-up untuk butir berisiko;
- skor awal 8–20: rujuk segera untuk evaluasi diagnostik dan penilaian kelayakan intervensi dini;
- skor follow-up 0–1: tidak dirujuk melalui algoritma tersebut, kecuali terdapat kekhawatiran klinis lain;
- skor follow-up 2 atau lebih: rujuk untuk evaluasi diagnostik.

**Jangan mencampur kedua algoritma.** Perbedaan tidak boleh diatasi dengan menambahkan atau menghilangkan butir berdasarkan tebakan.

### D. Implementasi yang diharapkan

Audit `MchatScorer` dan tes yang sekarang tersedia. Buat matriks perbandingan antara aturan existing, Buku Bagan SDIDTK, dan workbook M-CHAT-R/F.

Rancang versi aturan yang terpisah, misalnya:

- `sdidtk_buku_bagan`;
- `mchat_r_f_2025`.

Versi final yang aktif untuk pelayanan harus disetujui UPTD. Jangan menetapkan salah satu versi sebagai aturan klinis final tanpa mencatat keputusan tersebut.

Workbook Maret 2025 harus diperiksa secara teknis. Jangan menyalin rumus spreadsheet begitu saja: audit formula setiap item, total skor, serta tindakan yang dihasilkan. Jika ada sel skor berupa nilai tetap, formula tidak lengkap, atau hasil yang tidak sesuai dengan aturan yang diverifikasi, laporkan dan implementasikan logika yang sudah diperiksa melalui service backend dan pengujian tersendiri.

### E. Pemetaan jawaban M-CHAT-R/F

Untuk algoritma M-CHAT-R/F modern, pemetaan jawaban berisiko yang digunakan sebagai baseline verifikasi adalah:

- Jawaban Tidak berisiko pada butir: 1, 3, 4, 6, 7, 8, 9, 10, 11, 14, 15, 17, 19, 20.
- Jawaban Ya berisiko pada butir: 2, 5, 12, 13, 16, 18.

Masing-masing jawaban berisiko menyumbang 1 poin dan jawaban yang tidak berisiko menyumbang 0 poin.

Pemetaan tersebut harus diuji terhadap workbook yang dilampirkan sebelum digunakan. Pemetaan ini berbeda dari aturan pengecualian butir 2, 5, dan 12 yang tercantum pada Buku Bagan SDIDTK. Jangan menerapkannya secara tidak sengaja pada algoritma SDIDTK.

### F. Follow-up

Workbook menyediakan kolom hasil follow-up, tetapi isi lengkap pertanyaan follow-up tidak tersedia dalam daftar berkas ini.

Jangan membuat sendiri butir pertanyaan follow-up.

Jika kuesioner follow-up resmi belum tersedia:

- formulir skrining awal boleh diimplementasikan;
- hasil 3–7 harus ditandai memerlukan follow-up;
- aplikasi tidak boleh berpura-pura bahwa follow-up sudah dilakukan;
- implementasi lengkap M-CHAT-R/F harus menunggu tersedianya butir follow-up yang disahkan.

Semua hasil M-CHAT-R/F adalah hasil skrining risiko, bukan diagnosis autisme.

---

## 4.4. GPPH — Abbreviated Conners’ Teacher Rating Scale (ACTRS)

### A. Tujuan dan rentang umur

GPPH digunakan dalam konteks deteksi dini kemungkinan gangguan pemusatan perhatian dan hiperaktivitas pada anak prasekolah.

Formulir yang disediakan memakai nama *Abbreviated Conners’ Teacher Rating Scale*. Dalam alur SDIDTK yang diberikan, informasi perilaku anak ditanyakan kepada orang tua atau pengasuh.

Rentang implementasi yang direncanakan pada desain aplikasi adalah 36–72 bulan. Rentang ini harus divalidasi dengan kebijakan UPTD sebelum dianggap aturan klinis final. Tabel jadwal pada dokumen menandai pemeriksaan pada usia 36, 48, 60, dan 72 bulan; jadwal tersebut tidak dengan sendirinya membuktikan bahwa seluruh umur di antaranya telah disahkan untuk penggunaan operasional.

### B. Sepuluh butir

Gunakan sepuluh kegiatan yang diamati pada formulir ACTRS:

1. Tidak kenal lelah atau aktivitas berlebihan.
2. Mudah menjadi gembira dan impulsif.
3. Mengganggu anak-anak lain.
4. Gagal menyelesaikan kegiatan yang telah dimulai atau rentang perhatian pendek.
5. Menggerakkan anggota badan atau kepala terus-menerus.
6. Kurang memperhatikan dan mudah teralihkan.
7. Permintaan harus segera dipenuhi atau mudah frustrasi.
8. Sering dan mudah menangis.
9. Suasana hati berubah cepat dan drastis.
10. Ledakan kekesalan atau perilaku eksplosif yang tidak terduga.

Setiap butir menggunakan skala nilai 0–3.

- 0: keadaan tidak ditemukan pada anak;
- 1: keadaan kadang-kadang ditemukan;
- 2: keadaan sering ditemukan;
- 3: keadaan selalu ada.

Total terdiri atas penjumlahan sepuluh butir, sehingga rentang skor 0–30.

Jangan mengubah urutan butir, arah skor, atau skala respons tanpa dasar sumber yang telah diverifikasi.

### C. Kategori hasil

Algoritma GPPH dalam Buku Bagan SDIDTK mempunyai tiga kemungkinan hasil:

| Kondisi | Kategori | Tindakan menurut sumber |
|---|---|---|
| Nilai total <13 dan pemeriksa tidak merasa ragu | Normal | Berikan pujian, lanjutkan stimulasi sesuai umur, jadwalkan kunjungan berikutnya |
| Nilai total <13 tetapi pemeriksa masih merasa ragu | Meragukan | Intervensi dini masalah perilaku dan emosi; evaluasi ulang setelah satu bulan |
| Nilai total ≥13 | Kemungkinan GPPH | Rujuk ke rumah sakit tumbuh kembang level 1 |

Dokumen menyebut hasil evaluasi yang tetap meragukan setelah satu bulan perlu dirujuk ke rumah sakit tumbuh kembang level 1.

### D. Input tambahan wajib

Jangan menggunakan total skor sebagai satu-satunya dasar untuk membedakan kategori normal dan meragukan.

Sediakan input terpisah untuk menunjukkan apakah pemeriksa masih merasa ragu terhadap hasil pemeriksaan.

Aturan:

```text
Jika total >= 13:
    kategori = kemungkinan_gpph
Jika total < 13 dan pemeriksa_merasa_ragu = true:
    kategori = meragukan
Jika total < 13 dan pemeriksa_merasa_ragu = false:
    kategori = normal
```

Nilai `pemeriksa_merasa_ragu` harus berasal dari input tenaga kesehatan yang berwenang, bukan dihasilkan secara otomatis oleh sistem.

Tindak lanjut yang disimpan harus sesuai dengan kategori dan ditampilkan sebagai rekomendasi dari sumber instrumen. Dokter tetap bertanggung jawab menentukan tindakan klinis.

---

## 4.5. KPSP — belum masuk tahap implementasi

KPSP sengaja ditunda pada tahap ini.

Jangan mengembangkan:

- formulir KPSP untuk setiap kelompok umur;
- teks pertanyaan per formulir;
- aturan pemilihan formulir;
- klasifikasi hasil;
- rekomendasi stimulasi;
- seluruh alur umur terkoreksi dan prematuritas.

Pertahankan implementasi KPSP yang sudah tersedia dan jangan menghapus service, model, atau tes yang sudah benar.

Jangan membuat formulir generik yang digunakan untuk semua umur. Jangan menampilkan KPSP sebagai implementasi lengkap jika formulir dan aturan finalnya belum tersedia.

Buat daftar dependensi untuk implementasi KPSP pada tahap berikutnya setelah spesifikasi tiap kelompok umur diberikan.

---

# 5. Ketentuan umum engine rule-based scoring

Gunakan arsitektur service yang sudah tersedia:

- `ScorerInterface`
- `ScoringResult`
- `RuleBasedScoringService`

Setiap scorer bertanggung jawab untuk:

1. Memvalidasi struktur dan jumlah jawaban.
2. Memvalidasi tipe serta nilai jawaban.
3. Memastikan jawaban lengkap sebelum hasil final dihitung.
4. Menghitung skor berdasarkan kunci instrumen.
5. Mengklasifikasikan skor sesuai versi aturan aktif.
6. Menghasilkan rekomendasi hanya jika rekomendasi tersebut tercantum dalam aturan yang disetujui.
7. Mengembalikan hasil terstruktur kepada controller.
8. Menyimpan hasil final beserta versi instrumen dan aturan.

Jangan menanamkan logika scoring pada controller atau Vue. Frontend hanya menampilkan form, memvalidasi input dasar untuk kenyamanan pengguna, mengirim jawaban, dan menampilkan hasil yang dikembalikan backend.

Nilai skor dan kategori yang diterima browser tidak boleh dipercaya. Backend harus menghitung ulang hasil dari jawaban.

Sediakan pengujian nilai pada setiap batas kategori, di bawah batas, dan di atas batas.

---

# 6. Integrasi database layanan

## 6.1. Arsitektur yang dipilih

Gunakan satu database PostgreSQL bernama `ta_bismillah`.

- Skema `public` adalah milik sistem layanan UPTD BLK-ABK.
- Skema `spk` menyimpan seluruh data operasional khusus SPK.

Jangan menghapus, mengganti nama, atau menimpa tabel sumber hanya untuk memudahkan implementasi aplikasi.

Audit `Backup3.sql` terlebih dahulu. Periksa format berkas, tabel, kolom, constraint, foreign key, index, sequence, enum, dan hubungan datanya. Jika backup berbentuk custom format PostgreSQL, gunakan staging yang terpisah untuk memeriksanya.

Periksa secara khusus struktur:

- `public.users`;
- `public.roles`, jika ada;
- `public.patients`;
- `public.parent_guardians`;
- `public.doctors`;
- profil perawat jika tersedia;
- rekam medis;
- diagnosis;
- `public.sdq_screenings`;
- seluruh tabel lain yang bernama sama dengan tabel SPK lama.

## 6.2. Model dan autentikasi sumber

Gunakan akun layanan sebagai sumber autentikasi.

Sesuaikan model `User`, `Role`, `Patient`, `ParentGuardian`, dan `Doctor` berdasarkan struktur sumber aktual. Jangan menganggap `role_id`, `doctor_id`, `nurse_id`, `guardian_id`, dan `parent_guardian_id` mempunyai arti yang sama.

Jangan membuat akun duplikat untuk dokter dan perawat. Jangan mengubah hash password secara massal.

Pastikan konfigurasi Laravel mengakses tabel sumber pada skema `public` dan seluruh tabel SPK pada skema `spk`. Uji strategi koneksi atau pemilihan skema yang digunakan, terutama jika terdapat nama tabel sama pada kedua skema.

Jangan mengandalkan perilaku `search_path` atau relasi lintas koneksi Eloquent yang belum dibuktikan melalui pengujian.

## 6.3. Tabel operasional SPK

Rancang migrasi khusus SPK sekurang-kurangnya untuk:

- `spk.screening_sessions`;
- `spk.screening_session_instruments`;
- `spk.sdq_screenings`;
- `spk.srq_screenings`;
- `spk.mchat_screenings`;
- `spk.gpph_screenings`;
- `spk.screening_interpretations`;
- riwayat interpretasi jika diperlukan;
- penyimpanan draf jawaban jika diperlukan;
- pemetaan identitas data historis jika diperlukan.

Skema dan kolom akhir harus mengikuti hasil audit, bukan menyalin migrasi lama yang membuat tabel pada `public`.

### 6.4. Struktur sesi dan tanggung jawab

Sesi perlu membedakan identitas berikut:

- pasien sumber;
- pengguna yang membuat sesi;
- perawat yang bertanggung jawab terhadap pelaksanaan skrining;
- dokter yang meninjau dan menafsirkan hasil.

Pertahankan `created_by_user_id` untuk mengidentifikasi pembuat sesi jika sudah sesuai dengan struktur aktual. Jangan menjadikannya pengganti identitas perawat atau dokter.

Pertimbangkan pada `spk.screening_sessions`:

- ID sesi;
- referensi pasien;
- pengguna pembuat;
- referensi perawat penanggung jawab;
- dokter peninjau jika sudah ditetapkan;
- tanggal pemeriksaan;
- umur saat pemeriksaan;
- status sesi;
- catatan awal;
- waktu penyelesaian tinjauan;
- timestamps.

Foreign key harus merujuk pada ID dari entitas sumber yang benar. Gunakan aturan penghapusan yang melindungi data historis.

### 6.5. Instrumen dan hasil

`spk.screening_session_instruments` menyimpan instrumen yang dipilih per sesi, statusnya, waktu mulai, dan waktu selesai.

Gunakan unique constraint untuk mencegah instrumen yang sama terdaftar dua kali dalam satu sesi.

Setiap hasil instrumen setidaknya menyimpan jawaban, skor, kategori, versi instrumen, versi aturan, dan waktu pencatatan. Simpan juga rekomendasi apabila aturan rekomendasi sudah disahkan.

Jangan mencampur `public.sdq_screenings` dengan `spk.sdq_screenings`. Hasil SDQ layanan harus tetap utuh dan tidak boleh ditimpa oleh hasil SPK.

### 6.6. Jawaban draf

Dukung penyimpanan progres untuk pengisian kuesioner.

Bedakan:

- jawaban sementara;
- jawaban lengkap;
- hasil final.

Jawaban sementara tidak boleh menghasilkan skor final atau kategori definitif.

Saat formulir dibuka kembali, pulihkan jawaban draf untuk sesi dan instrumen yang tepat. Lindungi data agar tidak tertukar antar pasien, responden, sesi, maupun instrumen.

Ketika jawaban lengkap, hitung skor ulang di backend dan simpan jawaban final beserta hasilnya dalam transaksi yang konsisten.

### 6.7. Interpretasi dokter dan riwayat

Catatan dokter disimpan terpisah untuk tiap instrumen.

Rancang `spk.screening_interpretations` dengan konsep:

- sesi;
- kode instrumen;
- dokter penulis;
- catatan klinis;
- keputusan tindak lanjut;
- uraian tindak lanjut;
- status draf atau selesai;
- waktu penyelesaian;
- timestamps.

Dokter boleh menyimpan catatan sementara sebelum seluruh instrumen selesai.

Dokter dapat meninjau hasil SDQ dan SRQ secara terpisah, tanpa harus menunggu instrumen lainnya. Setiap perubahan catatan klinis harus dapat ditelusuri sesuai kebijakan audit UPTD.

---

# 7. Hak akses dan alur kerja

Aplikasi hanya untuk tenaga kesehatan internal. Orang tua atau pengasuh tidak memerlukan akun login.

## 7.1. Dokter

Dokter dapat:

- login dan logout;
- melihat serta mencari pasien;
- memilih pasien;
- membuat sesi skrining;
- memilih instrumen yang diperlukan;
- memilih perawat penanggung jawab;
- melihat sesi dan hasil instrumen;
- menginterpretasikan setiap hasil;
- menyimpan catatan sementara;
- menyelesaikan tinjauan;
- menentukan tindak lanjut;
- melihat riwayat dan laporan.

Membuat sesi tidak otomatis menjadikan dokter pengisi kuesioner. Perawat tetap melaksanakan proses pengisian instrumen sesuai alur UPTD.

## 7.2. Perawat

Perawat dapat:

- login dan logout;
- melihat serta mencari pasien;
- membuat sesi dengan dirinya sebagai penanggung jawab;
- mengisi instrumen yang ditugaskan;
- mendampingi pengisian SDQ dan SRQ oleh orang tua;
- menyimpan jawaban draf;
- melanjutkan pengisian;
- menyelesaikan instrumen;
- menyerahkan hasil kepada dokter untuk ditinjau.

Perawat tidak boleh mengubah atau menyelesaikan interpretasi dokter melalui endpoint instrumen.

## 7.3. Orang tua atau pengasuh

Orang tua/pengasuh:

- tidak mengakses dashboard internal;
- tidak memiliki akun login SPK;
- mengisi kuesioner yang disiapkan perawat;
- menerima halaman konfirmasi penyelesaian;
- tidak ditampilkan skor klinis pada halaman konfirmasi.

## 7.4. Penegakan hak akses

Gunakan autentikasi, middleware role, validasi backend, dan pemeriksaan kepemilikan atau penugasan sesi.

Perawat hanya boleh mengerjakan sesi yang menjadi tanggung jawabnya. Dokter hanya boleh mencatat interpretasi menggunakan identitasnya sendiri. Dokter dapat melihat sesi lintas perawat sesuai kewenangan yang telah ditetapkan.

Jangan mengamankan fitur hanya melalui tombol yang disembunyikan pada Vue. Semua endpoint harus tetap aman jika dipanggil langsung.

---

# 8. Halaman dan pengalaman pengguna

Gunakan referensi desain klinis yang disediakan sebagai acuan visual, dengan antarmuka berbahasa Indonesia.

### 8.1. Direktori pasien

`Patients/Index.vue` menampilkan pasien sumber, pencarian berdasarkan nama atau nomor rekam medis, filter relevan, status skrining, serta tindakan memulai sesi.

Jangan membuat duplikasi pasien sebagai alternatif integrasi data layanan.

### 8.2. Konfigurasi sesi

`ScreeningSessions/Create.vue` menampilkan pasien terpilih, tanggal pemeriksaan, umur hasil perhitungan sistem, kartu instrumen, kelayakan umur, status ketersediaan, catatan awal, serta ringkasan sesi.

Bila perawat membuat sesi, tetapkan dirinya sebagai penanggung jawab. Bila dokter membuat sesi, sediakan pemilihan perawat penanggung jawab.

Validasi umur dilakukan di frontend untuk membantu pengguna dan di backend sebagai aturan wajib.

Jangan menyediakan instrumen sebagai siap digunakan bila formularium, algoritma skoring, atau aturan klinisnya belum siap.

### 8.3. Halaman pengisian instrumen

Setiap instrumen memiliki formulir yang sesuai dengan kuesioner sumber.

Wajib tersedia:

- petunjuk pengisian;
- seluruh butir yang sesuai;
- pilihan jawaban yang benar;
- indikator progres;
- validasi kelengkapan;
- penyimpanan dan pemulihan draf;
- perlindungan terhadap pengiriman ganda;
- konfirmasi penyelesaian;
- halaman responden tanpa navigasi internal.

Jangan menampilkan skor final sebelum seluruh persyaratan instrumen terpenuhi.

### 8.4. Detail sesi dan ringkasan klinis

`ScreeningSessions/Show.vue` perlu menampilkan identitas pasien, umur pemeriksaan, tanggal, pembuat sesi, perawat penanggung jawab, dokter peninjau, status sesi, status semua instrumen, hasil skoring, serta catatan dokter per instrumen.

Tampilkan hasil hanya untuk instrumen yang sudah memiliki data yang valid.

Bedakan dengan jelas:

- skor hasil perhitungan;
- kategori hasil skrining;
- interpretasi profesional;
- keputusan tindak lanjut.

### 8.5. Interpretasi dokter

Sediakan panel atau halaman per instrumen.

Dokter dapat mencatat hasil observasi klinis, interpretasi, keputusan tindak lanjut, dan uraian tindak lanjut.

Simpan draf tanpa harus menunggu seluruh instrumen selesai. Penyelesaian satu interpretasi tidak otomatis menyelesaikan semua interpretasi lain.

### 8.6. Laporan

Ringkasan laporan mencakup identitas pasien, tanggal pemeriksaan, umur, instrumen yang dijalankan, jawaban atau hasil yang sesuai kewenangan, skor, kategori, interpretasi dokter, tindak lanjut, dokter peninjau, dan waktu penyelesaian.

Jangan menjadikan skor otomatis sebagai diagnosis. Pastikan laporan menggambarkan data yang tersimpan di backend.

---

# 9. Status proses sesi

Pertahankan status yang sudah tersedia sebagai titik awal:

- `draft`
- `in_progress`
- `pending_parent`
- `pending_doctor_review`
- `reviewed`
- `cancelled`

Status instrumen tetap terpisah:

- `pending`
- `in_progress`
- `completed`
- `cancelled`

Definisikan transisi status secara eksplisit dan uji transisinya.

Sesi yang masih memiliki instrumen belum selesai tidak boleh dianggap selesai secara otomatis. Catatan dokter berstatus draf juga tidak sama dengan tinjauan selesai.

Perubahan status harus dilakukan oleh backend berdasarkan kondisi dan kewenangan yang valid.

---

# 10. Migrasi database yang aman

Jangan menjalankan migrasi destruktif pada `ta_bismillah`.

### Tahap 1 — Audit

- Periksa status Git.
- Periksa semua konfigurasi koneksi.
- Periksa status migrasi saat ini.
- Periksa format `Backup3.sql`.
- Audit struktur tabel sumber dan SPK lama.
- Identifikasi konflik nama dan ID.
- Susun pemetaan model, relasi, dan kolom.
- Dokumentasikan risiko dan langkah pemulihan.

### Tahap 2 — Staging

- Buat backup database sumber dan SPK.
- Pulihkan serta uji pada staging yang terpisah.
- Siapkan skema `spk`.
- Pisahkan migrasi khusus SPK dari migrasi lama yang membuat master data.
- Audit foreign key lintas skema, `search_path`, dan query yang dihasilkan.

### Tahap 3 — Struktur baru

Buat tabel khusus SPK di skema `spk` melalui migrasi yang dapat ditelusuri.

Jangan membuat ulang tabel pengguna, pasien, dokter, atau hasil SDQ sumber.

Jangan menggunakan `migrate:fresh`, `db:wipe`, `DROP TABLE`, atau `TRUNCATE` terhadap data layanan.

### Tahap 4 — Data historis

- Petakan pasien dengan identitas sumber yang stabil.
- Jangan mencocokkan pasien berdasarkan nama saja.
- Petakan akun pembuat, dokter, serta perawat melalui identitas yang benar.
- Pindahkan hasil dan status skrining lama berdasarkan pemetaan yang valid.
- Catat data yang ambigu untuk rekonsiliasi manual.
- Bandingkan jumlah baris sumber dan tujuan.
- Validasi foreign key dan sampel hasil perhitungan.
- Cegah impor ganda dengan mekanisme pemetaan dan idempotensi.

### Tahap 5 — Cutover

Alihkan koneksi aplikasi hanya setelah pengujian staging, validasi data, hak akses, perhitungan instrumen, dan rencana pemulihan selesai.

Jangan menghapus database lama atau memodifikasi data `public` hanya untuk menuntaskan implementasi SPK.

---

# 11. Privasi dan keamanan

Semua data pasien dan jawaban kuesioner diperlakukan sebagai informasi sensitif.

Wajib diterapkan:

- pembatasan akses berdasarkan peran;
- perlindungan dari akses sesi yang tidak sah;
- validasi server-side;
- perlindungan CSRF dan sesi autentikasi yang sesuai Laravel;
- pemisahan data responden SRQ dari data anak;
- tidak menampilkan skor pada halaman konfirmasi responden;
- transaksi database pada operasi kritis;
- pencatatan versi aturan skoring;
- audit perubahan interpretasi dokter;
- log tanpa password, token, atau isi rekam medis;
- backup dan kebijakan retensi data sesuai ketentuan UPTD.

Jangan memublikasikan kredensial, isi `.env`, atau data pasien dalam Git maupun keluaran diagnostik.

---

# 12. Pengujian wajib

Pertahankan semua tes valid yang sudah tersedia. Jangan menghapus pengujian hanya agar test suite menjadi hijau.

## 12.1. Tes SDQ

Uji:

- 25 jawaban lengkap;
- jawaban di luar rentang;
- seluruh item reverse-scored;
- skor maksimum dan minimum subskala;
- total kesulitan yang mengecualikan Pro;
- batas total 13, 14, 15, dan 16;
- batas masing-masing kategori;
- pembedaan versi usia;
- konsistensi hasil historis.

## 12.2. Tes SRQ-20

Uji:

- tepat 20 jawaban;
- semua jawaban harus boolean pada level service;
- skor 0 dan 20;
- skor 5 berada di bawah nilai pisah;
- skor 6 memenuhi nilai pisah;
- jawaban kurang atau berlebih ditolak;
- jawaban kosong tidak menghasilkan skor final;
- pertanyaan nomor 17 disimpan dengan benar;
- kategori ditentukan backend;
- hasil tidak tampil pada halaman konfirmasi responden.

## 12.3. Tes M-CHAT-R/F

Uji:

- 20 jawaban;
- pemetaan jawaban berisiko untuk setiap item;
- skor batas 2, 3, 7, dan 8;
- kategori risiko rendah, sedang, dan tinggi sesuai versi aturan yang aktif;
- skor follow-up 1 dan 2;
- follow-up wajib untuk kategori yang memerlukannya;
- versi SDIDTK tidak tercampur dengan versi workbook 2025;
- pertanyaan follow-up tidak dibuat sendiri.

Jangan menetapkan hasil klinis final menggunakan algoritma yang belum disetujui.

## 12.4. Tes GPPH/ACTRS

Uji:

- tepat 10 jawaban;
- setiap jawaban berada pada rentang 0–3;
- skor minimum 0 dan maksimum 30;
- total 12 tanpa keraguan pemeriksa menghasilkan kategori normal;
- total 12 dengan keraguan pemeriksa menghasilkan kategori meragukan;
- total 13 menghasilkan kemungkinan GPPH;
- rekomendasi sesuai kategori;
- usia di luar rentang yang disetujui ditolak.

## 12.5. Tes integrasi

Uji:

- login dari sumber layanan;
- autentikasi untuk dokter dan perawat;
- akun orang tua ditolak;
- dokter dapat membuat sesi dan menetapkan perawat;
- perawat dapat mengerjakan sesi yang ditugaskan;
- hasil interpretasi dokter tidak dapat diubah oleh perawat;
- draf dapat dipulihkan;
- pengiriman ganda tidak membuat hasil duplikat;
- query sumber menggunakan skema yang tepat;
- `public.sdq_screenings` tidak tertimpa;
- seluruh hasil SPK ditulis pada `spk`;
- transaksi rollback saat penyimpanan gagal.

Jalankan tes yang relevan setelah tiap tahap, kemudian seluruh test suite dan build frontend.

---

# 13. Kriteria penerimaan

Implementasi tahap ini dianggap memenuhi kebutuhan apabila:

1. Data pasien, akun pengguna, dan dokter berasal dari database layanan.
2. Tabel operasional SPK berada di skema `spk`.
3. Tidak ada tabel `public` yang terhapus atau tertimpa.
4. Dokter dan perawat memiliki hak akses berbeda sesuai tugas.
5. Dokter dapat memulai sesi dan memilih perawat penanggung jawab.
6. Orang tua dapat mengisi instrumen tanpa akun login.
7. SDQ menghitung lima subskala, total kesulitan, dan Pro secara tepat.
8. SRQ menilai kondisi responden sendiri dan memakai nilai pisah yang benar.
9. M-CHAT-R/F menggunakan versi algoritma yang terdokumentasi.
10. GPPH mempertimbangkan penilaian keraguan pemeriksa.
11. Jawaban draf tidak dianggap hasil final.
12. Interpretasi dokter dicatat terpisah per instrumen.
13. Catatan sementara tidak memaksa seluruh instrumen selesai.
14. KPSP belum dibuat sebagai modul lengkap dan tidak diisi dengan pertanyaan generik.
15. Data historis dapat direkonsiliasi tanpa kehilangan catatan.
16. Unit test, feature test, dan build berhasil.
17. Konflik aturan instrumen didokumentasikan sebelum penggunaan klinis.

---

# 14. Metode kerja coding agent

Kerjakan dalam tahapan yang dapat diperiksa dan diuji.

### Tahap A — Audit repositori dan sumber

Sebelum mengubah kode, laporkan:

- kondisi Git;
- status migrasi;
- struktur tabel yang relevan;
- hubungan model;
- aturan skoring yang sekarang aktif;
- tes yang sudah tersedia;
- konflik di dokumen instrumen;
- risiko integrasi database.

### Tahap B — Rancang dan validasi database

Siapkan skema SPK, model, foreign key, jalur migrasi, serta pemetaan data historis. Uji seluruhnya di staging.

### Tahap C — Integrasi pengguna, pasien, dan sesi

Pastikan autentikasi sumber, hak akses dokter/perawat, pembuat sesi, dan penanggung jawab perawat bekerja dengan benar.

### Tahap D — Instrumen dan skoring

Audit SDQ dan SRQ yang sudah berjalan sebelum mengubah kode. Kemudian kembangkan atau perbaiki M-CHAT-R/F serta GPPH berdasarkan aturan yang telah diverifikasi. Jangan mengembangkan KPSP pada tahap ini.

### Tahap E — Antarmuka dan interpretasi

Implementasikan direktori pasien, konfigurasi sesi, pengisian instrumen, ringkasan klinis, interpretasi dokter, penyimpanan draf, dan laporan.

### Tahap F — Validasi keseluruhan

Jalankan test suite, audit rute, verifikasi skema, build frontend, dan pemeriksaan Git. Dokumentasikan fitur selesai, yang tertunda, konflik klinis, serta risiko yang masih ada.

Setelah setiap tahap, laporkan perubahan file, alasan teknis, hasil tes, status migrasi, dan pekerjaan selanjutnya.

Jangan melakukan `git commit` atau `git push` tanpa instruksi eksplisit.

**Target akhir:** aplikasi SPK Skrining Anak yang terintegrasi secara aman dengan `ta_bismillah`, menghitung skor dari aturan instrumen yang terverifikasi, mendukung perawat dan dokter, mempertahankan riwayat pemeriksaan, serta tidak merusak database layanan maupun menghasilkan kategori klinis berdasarkan asumsi.