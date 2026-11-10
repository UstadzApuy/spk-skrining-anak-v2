# PANDUAN PENGUJIAN SISTEM (USER TESTING GUIDE) — ORANG TUA / WALI

**Sistem Pendukung Keputusan Deteksi Dini Tumbuh Kembang Anak (SDIDTK)**  
**UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus (BLK-ABK) Kota Balikpapan**

---

## 1. Identitas Pengujian

- **Peran Penguji (*Role*)**: Orang Tua / Pengasuh / Wali Anak (*Parent / Guardian*)
- **Tujuan Pengujian**:
  1. *Blackbox Testing*: Menguji kemudahan orang tua dalam mengakses kuesioner mandiri yang dibuka oleh perawat di klinik, menjawab instrumen SDQ (perilaku anak) dan SRQ-20 (kesehatan jiwa pengasuh), serta memastikan data tersimpan ke rekam medis anak.
  2. *System Usability Scale (SUS)*: Menilai keterbacaan bahasa, kenyamanan navigasi, dan kejelasan antarmuka formulir digital bagi pengguna non-medis.
- **Akun Login Pengujian**:
  - **URL Sistem**: `http://localhost:8001/login`
  - **Email**: `orangtua@spk.test`
  - **Kata Sandi**: `password`

---

## 2. Hak Akses & Batas Kuasa Fitur Orang Tua
Sesuai standar operasional fasilitas kesehatan:
- **Yang Dapat Dilakukan**: Melihat profil anak yang terdaftar, melihat status sesi skrining, dan mengisi kuesioner mandiri **SDQ** serta **SRQ-20** yang instrumennya telah dibuka oleh perawat.
- **Yang Tidak Dapat Dilakukan**: Orang tua tidak dapat mengubah pemeriksaan fisik (BB/TB/LK), mengisi KPSP/GPPH tenaga medis, memfinalisasi sesi, atau mengubah diagnosa dokter.

---

## 3. Skenario Pengujian Langkah demi Langkah

### Target Pengujian: Pengisian Mandiri Kuesioner untuk Chairil Rafqi Nababan
*Profil Anak*: **Chairil Rafqi Nababan** (`RM-002`), Usia 60 Bulan (5 Tahun), Perempuan.

#### Langkah 1: Masuk ke Sistem (Login)
1. Buka browser dan akses alamat: `http://localhost:8001/login`.
2. Masukkan email: `orangtua@spk.test`.
3. Masukkan kata sandi: `password`.
4. Klik tombol **Masuk ke Sistem**.
5. Pastikan Anda berhasil masuk ke halaman **Portal Beranda Orang Tua**.

#### Langkah 2: Memeriksa Dashboard & Notifikasi Tugas Kuesioner
1. Perhatikan banner atas yang menyapa Anda (*"Selamat Datang, Orang Tua Uji"*).
2. Periksa bagian **Kuesioner Menunggu Pengisian**:
   - Terdapat 2 kartu tugas aktif untuk **Chairil Rafqi Nababan**:
     - *Kuesioner Masalah Perilaku & Emosional (SDQ)*.
     - *Kuesioner Kesehatan Jiwa Orang Tua / Pengasuh (SRQ-20)*.
3. Periksa daftar anak terdaftar di bagian bawah (menampilkan identitas Chairil Rafqi Nababan, usia 5 tahun).

#### Langkah 3: Mengisi Kuesioner SDQ (Kekuatan & Kesulitan Anak)
1. Pada kartu kuesioner SDQ, klik tombol **Isi Kuesioner Sekarang**.
2. Anda akan diarahkan ke formulir pengisian kuesioner SDQ.
3. Terdapat **25 butir pernyataan** tentang perilaku, emosi, konsentrasi, dan hubungan sosial anak dalam 6 bulan terakhir.
4. Setiap butir memiliki 3 pilihan jawaban:
   - `Tidak Benar`
   - `Agak Benar`
   - `Benar`
5. Isi seluruh 25 pertanyaan secara lengkap.
6. Klik tombol **Simpan & Selesai Pengisian SDQ** di bagian bawah halaman.
7. Anda akan otomatis dialihkan kembali ke Dashboard dengan notifikasi hijau: *"Kuesioner SDQ berhasil disimpan"*.
8. Perhatikan bahwa kartu tugas SDQ kini telah hilang dari antrean tugas menunggu.

#### Langkah 4: Mengisi Kuesioner SRQ-20 (Kesehatan Jiwa Pengasuh)
1. Pada kartu kuesioner SRQ-20 yang tersisa, klik tombol **Isi Kuesioner Sekarang**.
2. Anda akan diarahkan ke formulir SRQ-20.
3. Terdapat **20 butir pertanyaan** seputar kondisi fisik, kecemasan, kelelahan, dan suasana hati pengasuh dalam 30 hari terakhir.
4. Setiap pertanyaan memiliki 2 pilihan: **Ya** atau **Tidak**.
5. Jawab seluruh 20 pertanyaan secara jujur.
6. Klik tombol **Kirim Jawaban Kuesioner**.
7. Anda akan melihat halaman konfirmasi:
   - Ikon centang hijau: *"Pengisian Berhasil"*.
   - Pesan terima kasih bahwa jawaban telah tersimpan untuk ditinjau oleh tenaga medis.
8. Klik tombol **Kembali ke Dashboard**.

#### Langkah 5: Verifikasi Akhir di Dashboard
1. Periksa kembali halaman Dashboard Orang Tua.
2. Seluruh kuesioner yang sebelumnya menunggu kini telah selesai diisi.
3. Muncul kotak hijau bertuliskan:
   > *"Seluruh Kuesioner Orang Tua Telah Lengkap — Saat ini tidak ada instrumen skrining yang menunggu pengisian dari orang tua."*

---

## 4. Lembar Checklist Pengujian Blackbox (Orang Tua)

Beri tanda centang (&check;) pada kolom hasil pengujian:

| No | Komponen / Fitur yang Diuji | Hasil yang Diharapkan | Hasil Pengamatan | Status (Lolos / Gagal) |
| :---: | :--- | :--- | :--- | :---: |
| 1 | **Login Orang Tua** | Login berhasil dan diarahkan ke Dashboard Orang Tua, bukan dashboard nakes. | | |
| 2 | **Kejelasan Informasi Dashboard** | Menampilkan profil anak kandung (Chairil Rafqi Nababan) dan status kuesioner yang jelas. | | |
| 3 | **Navigasi ke Kuesioner SDQ** | Tombol klik langsung membuka formulir SDQ tanpa pesan error izin akses (403). | | |
| 4 | **Pengisian 25 Butir SDQ** | Pilihan radio button responsif, mudah diklik, dan sistem menolak jika ada butir terlewat. | | |
| 5 | **Penyimpanan SDQ** | Berhasil disimpan dan otomatis kembali ke dashboard dengan notifikasi sukses. | | |
| 6 | **Pengisian 20 Butir SRQ-20** | Pilihan "Ya" dan "Tidak" mudah dipahami dan berfungsi lancar di layar. | | |
| 7 | **Halaman Sukses SRQ-20** | Menampilkan konfirmasi terima kasih tanpa membocorkan skor medis rahasia. | | |
| 8 | **Pembaruan Status Tugas** | Kotak peringatan berubah hijau menandakan seluruh kuesioner anak telah selesai. | | |

---

## 5. Lembar Kuesioner System Usability Scale (SUS) — Orang Tua

*Petunjuk*: Berikan penilaian sejujur-jujurnya sesuai pengalaman Anda menggunakan sistem ini dengan memberi tanda silang (X) pada skala **1 (Sangat Tidak Setuju)** sampai **5 (Sangat Setuju)**.

| No | Pernyataan Evaluasi Usability | 1 (STS) | 2 (TS) | 3 (N) | 4 (S) | 5 (SS) |
| :---: | :--- | :--- :---: | :---: | :---: | :---: | :---: |
| 1 | Saya merasa senang dan bersedia menggunakan aplikasi ini jika anak saya dijadwalkan skrining rutin. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 2 | Saya merasa pengisian kuesioner pada aplikasi ini membingungkan dan berbelit-belit. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 3 | Saya merasa aplikasi ini sangat mudah dipahami dan digunakan oleh orang tua seperti saya. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 4 | Saya merasa membutuhkan bantuan orang lain untuk bisa mengisi kuesioner pada aplikasi ini. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 5 | Saya merasa tampilan dan petunjuk di dalam aplikasi ini tersusun dengan rapi dan terpadu. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 6 | Saya merasa ada bagian di aplikasi ini yang membuat bingung karena tampilannya tidak konsisten. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 7 | Saya yakin orang tua lain dapat dengan cepat mengerti cara menggunakan aplikasi ini. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 8 | Saya merasa aplikasi ini sulit dipahami dan canggung ketika digunakan. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 9 | Saya merasa yakin dan nyaman saat menjawab kuesioner anak saya di aplikasi ini. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 10 | Saya harus membaca banyak petunjuk sulit sebelum bisa mengerti cara menggunakan aplikasi ini. | [ ] | [ ] | [ ] | [ ] | [ ] |

**Komentar / Saran dari Orang Tua untuk Aplikasi Ini**:
```text
....................................................................................................
....................................................................................................
```

