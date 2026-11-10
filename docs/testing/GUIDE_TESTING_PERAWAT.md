# PANDUAN PENGUJIAN SISTEM (USER TESTING GUIDE) — PERAWAT

**Sistem Pendukung Keputusan Deteksi Dini Tumbuh Kembang Anak (SDIDTK)**  
**UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus (BLK-ABK) Kota Balikpapan**

---

## 1. Identitas Pengujian

- **Peran Penguji (*Role*)**: Perawat Skrining Tumbuh Kembang (*Screening Nurse*)
- **Tujuan Pengujian**:
  1. *Blackbox Testing*: Memastikan seluruh fitur entri data antropometri, pengisian instrumen skrining (KPSP & GPPH), evaluasi ulang 14 hari, dan pendelegasian kuesioner orang tua berjalan akurat sesuai standar operasional rekam medis.
  2. *System Usability Scale (SUS)*: Mengukur kemudahan penggunaan, efisiensi alur kerja, dan kenyamanan antarmuka perawat.
- **Akun Login Pengujian**:
  - **URL Sistem**: `http://localhost:8001/login`
  - **Email**: `perawat@spk.test`
  - **Kata Sandi**: `password`

---

## 2. Petunjuk untuk Fasilitator / Peneliti
1. Pastikan lingkungan pengujian berada pada kondisi checkpoint bersih dengan menjalankan:
   ```bash
   ./reset-test.sh
   ```
2. Berikan lembar panduan ini kepada perawat responden.
3. Dampingi responden dan amati apakah responden dapat menyelesaikan tugas tanpa instruksi lisan berlebih.
4. Setelah seluruh skenario selesai, mintalah responden mengisi **Lembar Evaluasi SUS** di bagian akhir dokumen ini.

---

## 3. Skenario Pengujian Langkah demi Langkah

### Skenario 1: Entri Sesi Skrining Baru Berdasarkan Hardcopy Rekam Medis Pasien
*Target Pasien*: **Muhammad Zain Ageng Pangestu** (`RM-001`), Usia 48 Bulan (4 Tahun), Laki-laki.

1. **Login ke Sistem**:
   - Buka `http://localhost:8001/login`.
   - Masukkan email `perawat@spk.test` dan password `password`, lalu klik **Masuk ke Sistem**.
   - Pastikan Anda diarahkan ke halaman **Dashboard Perawat / Patient Selection Hub**.
2. **Pilih Pasien**:
   - Temukan kartu pasien **Muhammad Zain Ageng Pangestu** (`RM-001`).
   - Perhatikan statusnya: *Belum Ada Sesi Hari Ini*.
   - Klik tombol **Lihat Sesi Skrining &rarr;**, lalu klik **+ Mulai Sesi Baru** (atau klik tombol mulai sesi di kartu pasien).
3. **Isi Formulir Sesi Baru**:
   - **Tanggal Pemeriksaan**: Pilih hari ini.
   - **Tipe Kunjungan**: Pilih *Kunjungan Awal / Berkala*.
   - **Anamnesis & Keluhan**: Masukkan keluhan: *"Pemeriksaan berkala 4 tahun, orang tua mengeluhkan anak sulit fokus dan emosional"*.
   - **Pemeriksaan Fisik**:
     - Berat Badan (BB): `15.0` kg
     - Tinggi Badan (TB): `100.0` cm
     - Lingkar Kepala (LK): `50.0` cm
   - **Instrumen yang Dipilih**:
     - Centang **KPSP** (Formulir 48 Bulan otomatis terpilih).
     - Centang **GPPH** (Eligible untuk 36–72 Bulan).
     - Centang **SDQ** dan **SRQ-20** (Ditujukan untuk diisi orang tua / pendamping).
   - Klik tombol **Simpan & Mulai Sesi Skrining**.
4. **Pengisian KPSP 48 Bulan**:
   - Buka instrumen **KPSP**.
   - Terdapat 10 butir pertanyaan perkembangan motorik, bicara-bahasa, dan kemandirian.
   - Masukkan hasil pemeriksaan sesuai lembar rekam medis:
     - Pertanyaan 1 s.d. 5: Jawab **Ya**.
     - Pertanyaan 6 s.d. 10: Jawab **Tidak**.
   - Klik **Simpan & Selesai KPSP**.
   - *Verifikasi*: Skor KPSP terhitung **5/10** dengan kategori **Ada Kemungkinan Penyimpangan (Dp)**.
5. **Pengisian GPPH (Abbreviated Conners Rating Scale)**:
   - Buka instrumen **GPPH**.
   - Jawab 10 butir pertanyaan perilaku dengan nilai skor:
     - 4 pertanyaan diberi nilai `2` (Sering).
     - 4 pertanyaan diberi nilai `1` (Kadang-kadang).
     - 2 pertanyaan diberi nilai `0` (Tidak pernah).
   - Klik **Simpan & Hitung Skor GPPH**.
   - *Verifikasi*: Total skor adalah `16/30` (&ge; 13) dengan kesimpulan **Kemungkinan GPPH**.
6. **Delegasi Instrumen Orang Tua**:
   - Periksa bahwa instrumen **SDQ** dan **SRQ-20** berstatus *Pending / Menunggu Pengisian Orang Tua*.
7. **Kirim Sesi ke Antrean Dokter**:
   - Jika pemeriksaan perawat selesai, klik tombol **Kirim untuk Tinjauan Dokter**.
   - Status sesi berpindah ke `pending_doctor_review`.

---

### Skenario 2: Evaluasi Ulang KPSP 14 Hari Pasca Hasil Meragukan (SDIDTK Loop)
*Target Pasien*: **Adelio Vember** (`RM-005`), Usia 24 Bulan (2 Tahun), Laki-laki.

1. **Buka Riwayat Pasien**:
   - Kembali ke Dashboard / Daftar Pasien.
   - Temukan pasien **Adelio Vember** (`RM-005`).
   - Klik **Lihat Sesi Skrining &rarr;**.
   - Perhatikan riwayat:
     - *Sesi 14 hari lalu*: Status selesai dengan hasil KPSP Meragukan (Dm: 8/10) dan tindakan intervensi stimulasi 2 minggu.
     - *Sesi Hari Ini*: Terjadwal dengan label **`🔄 Evaluasi Ulang KPSP 2 Minggu`** (Status: *Draft*).
2. **Buka Sesi Evaluasi Ulang**:
   - Klik **Buka Sesi** pada sesi hari ini.
   - Perhatikan banner peringatan:
     > *🔄 Sesi Re-evaluasi 2 Minggu: Evaluasi Ulang KPSP Pasca Intervensi Stimulasi Dini (SDIDTK Loop)... Bila hasil tetap Meragukan (Dm: 7–8), sistem akan merekomendasikan rujukan langsung ke Rumah Sakit.*
   - Klik tombol **Mulai Pengisian KPSP**.
3. **Simulasi Hasil KPSP Tetap Meragukan**:
   - Jawab **8 pertanyaan dengan "Ya"** dan **2 pertanyaan dengan "Tidak"** (misal nomor 5 dan 8 dijawab "Tidak").
   - Klik tombol **Simpan & Selesai KPSP**.
4. **Verifikasi Output Keputusan Klinis**:
   - Skor terhitung: `8/10` (Kategori: **Meragukan / Dm**).
   - Karena merupakan sesi evaluasi ulang 14 hari, sistem otomatis memunculkan peringatan rujukan:
     - **Tindakan Klinis**: `rujuk_rs_spesialistik`.
     - **Peringatan**: *"🚨 Re-evaluasi Belum Optimal: Segera rujuk ke Rumah Sakit (Poli Tumbuh Kembang / Sp.A)"*.

---

## 4. Lembar Checklist Pengujian Blackbox (Perawat)

Beri tanda centang (&check;) pada kolom hasil pengujian:

| No | Komponen / Fitur yang Diuji | Hasil yang Diharapkan | Hasil Pengamatan | Status (Lolos / Gagal) |
| :---: | :--- | :--- | :--- | :---: |
| 1 | **Login Manual Perawat** | Berhasil login dengan email & password tanpa error, langsung menuju Dashboard. | | |
| 2 | **Tampilan Kartu Pasien** | Informasi nama anak, No RM, umur hitungan bulan, dan tanggal lahir tampil akurat. | | |
| 3 | **Pembuatan Sesi Baru** | Formulir anamnesis, input BB/TB/LK, dan pilihan instrumen tersimpan tanpa bug. | | |
| 4 | **Skoring Otomatis KPSP** | Skor 5/10 menghasilkan kategori "Ada Kemungkinan Penyimpangan (Dp)". | | |
| 5 | **Skoring Otomatis GPPH** | Skor 16/30 menghasilkan kesimpulan "Kemungkinan GPPH". | | |
| 6 | **Pembedaan Sesi Evaluasi Ulang** | Sesi 14 hari Batita Gilang menampilkan label dan banner khusus *Re-evaluasi 2 Minggu*. | | |
| 7 | **Golden Rule SDIDTK (Re-evaluasi Dm)** | KPSP evaluasi ulang dengan skor 8/10 otomatis menetapkan tindakan *Rujuk ke Rumah Sakit*. | | |
| 8 | **Pengiriman ke Dokter** | Sesi berhasil dikirim dan status berubah menjadi `pending_doctor_review`. | | |

---

## 5. Lembar Kuesioner System Usability Scale (SUS) — Perawat

*Petunjuk*: Berikan penilaian subjektif Anda terhadap sistem ini dengan memberi tanda silang (X) atau lingkaran pada skala **1 (Sangat Tidak Setuju)** sampai **5 (Sangat Setuju)**.

| No | Pernyataan Evaluasi Usability | 1 (STS) | 2 (TS) | 3 (N) | 4 (S) | 5 (SS) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| 1 | Saya merasa ingin sering menggunakan sistem SPK skrining anak ini dalam pekerjaan harian. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 2 | Saya merasa sistem ini terlalu rumit dan membingungkan untuk digunakan. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 3 | Saya merasa sistem ini sangat mudah untuk digunakan dalam menginput data pemeriksaan. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 4 | Saya merasa membutuhkan bantuan dari orang teknis atau panduan terus-menerus untuk menjalankan sistem ini. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 5 | Saya merasa berbagai fitur dan fungsi dalam sistem ini terintegrasi dengan sangat baik. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 6 | Saya merasa ada terlalu banyak hal yang tidak konsisten pada sistem ini. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 7 | Saya merasa orang lain (rekan perawat) dapat belajar menggunakan sistem ini dengan sangat cepat. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 8 | Saya merasa sistem ini sangat janggal atau membingungkan saat digunakan. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 9 | Saya merasa sangat percaya diri dan yakin ketika mengoperasikan sistem ini. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 10 | Saya harus belajar banyak hal terlebih dahulu sebelum saya dapat menguasai sistem ini. | [ ] | [ ] | [ ] | [ ] | [ ] |

**Komentar / Masukan Tambahan dari Perawat**:
```text
....................................................................................................
....................................................................................................
```

