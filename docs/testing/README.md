# DOKUMENTASI PANDUAN PENGUJIAN SISTEM (TESTING GUIDES INDEX)

**Sistem Pendukung Keputusan Deteksi Dini Tumbuh Kembang Anak (SDIDTK)**  
**UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus (BLK-ABK) Kota Balikpapan**

Dokumentasi ini menyediakan panduan lengkap pelaksanaan pengujian sistem (*User Testing*) yang mencakup metode **Blackbox Testing** (pengujian fungsionalitas fitur) dan **System Usability Scale / SUS** (pengujian kegunaan antarmuka) untuk 3 kelompok pengguna utama sistem.

> **Dokumen Utama Peneliti / Fasilitator**:  
> Lihat [`PANDUAN_PELAKSANAAN_TESTING_SUS.md`](./PANDUAN_PELAKSANAAN_TESTING_SUS.md) untuk panduan komprehensif alur pengujian, formula perhitungan skor, dan 4 kuadran interpretasi SUS (Grade, Adjective, Acceptability, NPS) berbasis 3 jurnal rujukan.

---

## 1. Daftar Dokumen Panduan per Peran Pengguna

| No | Peran Pengguna | Dokumen Panduan | Fokus Pengujian Utama |
| :---: | :--- | :--- | :--- |
| 1 | **Perawat** | [`GUIDE_TESTING_PERAWAT.md`](./GUIDE_TESTING_PERAWAT.md) | Entri data fisik/antropometri, KPSP (skor & kategori Dp/Dm), GPPH, pendelegasian SDQ/SRQ, dan evaluasi ulang KPSP 14 hari. |
| 2 | **Orang Tua** | [`GUIDE_TESTING_ORANG_TUA.md`](./GUIDE_TESTING_ORANG_TUA.md) | Login mandiri, melihat notifikasi tugas kuesioner, pengisian mandiri 25 butir SDQ dan 20 butir SRQ-20, serta konfirmasi sukses. |
| 3 | **Dokter** | [`GUIDE_TESTING_DOKTER.md`](./GUIDE_TESTING_DOKTER.md) | Tinjauan klinis antrean review, validasi sintesis SPK, input keputusan intervensi rujukan, finalisasi status, dan uji cetak formulir SDIDTK A4. |

---

## 2. Kredensial Akun Pengujian

Seluruh akun telah disiapkan secara otomatis dalam database:

| Peran (*Role*) | Email Pengguna | Kata Sandi | Halaman Utama Setelah Login |
| :--- | :--- | :--- | :--- |
| **Perawat** | `perawat@spk.test` | `password` | `/dashboard` (Patient Selection Hub) |
| **Orang Tua** | `orangtua@spk.test` | `password` | `/dashboard` (Portal Kuesioner Anak) |
| **Dokter** | `dokter@spk.test` | `password` | `/dashboard` (Clinical Insight Hub) |

---

## 3. Daftar Pasien Pengujian (5 Pasien Terfokus)

Sistem menggunakan 5 profil pasien ringkas dan terarah agar responden tidak merasa kewalahan (*overwhelmed*):

1. **`RM-001` — Muhammad Zain Ageng Pangestu (48 Bulan / 4 Th, Laki-laki)**  
   *Target Uji*: **Perawat**  
   *Kondisi*: Belum ada sesi hari ini. Digunakan perawat untuk menguji pembuatan sesi skrining baru dari nol sesuai hardcopy rekam medis.
2. **`RM-002` — Chairil Rafqi Nababan (60 Bulan / 5 Th, Perempuan)**  
   *Target Uji*: **Orang Tua**  
   *Kondisi*: Sesi skrining aktif hari ini telah dimulai oleh perawat. Kuesioner **SDQ** & **SRQ-20** berstatus *pending* siap diisi oleh orang tua.
3. **`RM-003` — Rychi Yislam Gaza (36 Bulan / 3 Th, Perempuan)**  
   *Target Uji*: **Dokter**  
   *Kondisi*: Sesi skrining berkala berstatus `pending_doctor_review`. Siap ditinjau dokter, difinalisasi, dan diuji cetak Formulir SDIDTK.
4. **`RM-004` — Nausyad Ezzar A. (18 Bulan / 1.5 Th, Laki-laki)**  
   *Target Uji*: **Histori / Rekapitulasi**  
   *Kondisi*: Memiliki riwayat skrining lengkap selesai (*reviewed*) dengan hasil KPSP normal dan skrining autisme M-CHAT-R risiko rendah.
5. **`RM-005` — Adelio Vember (24 Bulan / 2 Th, Laki-laki)**  
   *Target Uji*: **Perawat (Re-evaluasi 14 Hari)**  
   *Kondisi*: Memiliki sesi awal 14 hari lalu dengan hasil KPSP Meragukan (Dm). Sesi evaluasi ulang terjadwal hari ini berstatus *draft/pending*. Menguji *Golden Rule SDIDTK*: jika hasil evaluasi ulang tetap meragukan, sistem otomatis menetapkan rujukan ke RS/Dokter Spesialis Anak.

---

## 4. Mekanisme Checkpoint & Reset untuk Fasilitator

Sebelum responden memulai pengujian, atau **setelah seorang responden selesai melakukan pengujian**, fasilitator wajib mereset sistem ke kondisi awal yang bersih.

Cukup jalankan perintah berikut di terminal:
```bash
./reset-test.sh
```

Perintah ini akan secara otomatis:
1. Membersihkan database dan menjalankan ulang migrasi.
2. Mengisi ulang (*seed*) 5 pasien uji dan akun pengujian di atas.
3. Membersihkan *application cache*, *config cache*, dan *route cache*.
4. Menampilkan tabel ringkasan kesiapan lingkungan pengujian.

---

## 5. Cara Perhitungan Skor System Usability Scale (SUS)

Kuesioner SUS menggunakan 10 butir pertanyaan dengan skala Likert 1 (Sangat Tidak Setuju) sampai 5 (Sangat Setuju).

Rumus Perhitungan Skor SUS (Brooke, 1996):
1. Untuk pertanyaan bernomor **ganjil** (1, 3, 5, 7, 9):  
   $$\text{Skor Kontribusi} = \text{Skala Jawaban} - 1$$
2. Untuk pertanyaan bernomor **genap** (2, 4, 6, 8, 10):  
   $$\text{Skor Kontribusi} = 5 - \text{Skala Jawaban}$$
3. Jumlahkan seluruh 10 skor kontribusi (rentang total 0 s.d. 40).
4. Kalikan jumlah total tersebut dengan **2.5** untuk mendapatkan **Skor Akhir SUS** (rentang 0 s.d. 100).
5. Interpretasi Skor Rata-rata SUS:
   - **> 80.3**: *Grade A (Excellent)*
   - **68.0 – 80.3**: *Grade B (Good / Di atas rata-rata industri)*
   - **< 68.0**: *Marginal / Butuh perbaikan*

