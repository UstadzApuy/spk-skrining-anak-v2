# PANDUAN PENGUJIAN SISTEM (USER TESTING GUIDE) — DOKTER

**Sistem Pendukung Keputusan Deteksi Dini Tumbuh Kembang Anak (SDIDTK)**  
**UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus (BLK-ABK) Kota Balikpapan**

---

## 1. Identitas Pengujian

- **Peran Penguji (*Role*)**: Dokter Peninjau / Dokter Spesialis Anak (*Reviewing Doctor / Pediatrician*)
- **Tujuan Pengujian**:
  1. *Blackbox Testing*: Menguji validitas alur telaah klinis (*clinical review*), pemeriksaan sintesis SPK berbasis aturan (*rule-based reasoning*), pemberian rekomendasi intervensi medis, finalisasi status sesi, dan verifikasi cetak Formulir Deteksi Dini Tumbuh Kembang Anak (Standar SDIDTK Kemenkes RI).
  2. *System Usability Scale (SUS)*: Menilai kegunaan sistem, kejelasan penyajian sintesis instrumen, dan efisiensi waktu pengambilan keputusan medis.
- **Akun Login Pengujian**:
  - **URL Sistem**: `http://localhost:8001/login`
  - **Email**: `dokter@spk.test`
  - **Kata Sandi**: `password`

---

## 2. Hak Akses & Batas Kuasa Fitur Dokter
- **Kewenangan Utama**:
  - Mengakses seluruh sesi skrining yang telah diselesaikan perawat dengan status `pending_doctor_review`.
  - Memeriksa lembar kerja kuesioner rinci dan sintesis aturan Kemenkes RI.
  - Memasukkan *Clinical Notes*, keputusan tindak lanjut intervensi dini, dan rujukan ke fasilitas kesehatan lanjutan / RS.
  - Melakukan **Finalisasi Sesi** (mengubah status menjadi `reviewed`).
  - Mengakses dan mencetak dokumen resmi **Formulir Deteksi Dini Tumbuh Kembang Anak (SDIDTK)**.
  - Mengakses modul Rekapitulasi Skrining dan statistik agregasi kasus.

---

## 3. Skenario Pengujian Langkah demi Langkah

### Target Pengujian: Tinjauan Klinis, Finalisasi, & Cetak Formulir SDIDTK
*Target Pasien*: **Rychi Yislam Gaza** (`RM-003`), Usia 36 Bulan (3 Tahun), Perempuan.

#### Langkah 1: Masuk ke Sistem (Login)
1. Buka browser dan akses alamat: `http://localhost:8001/login`.
2. Masukkan email: `dokter@spk.test` dan password: `password`.
3. Klik **Masuk ke Sistem**.
4. Anda akan diarahkan ke Dashboard Dokter (*Clinical Insight Hub*).

#### Langkah 2: Membuka Antrean Tinjauan Dokter
1. Pada menu samping (*sidebar*), klik menu **Sesi Skrining**.
2. Perhatikan filter status: cari sesi dengan status **Menunggu Dokter (*pending_doctor_review*)**.
3. Temukan sesi pemeriksaan untuk pasien **Rychi Yislam Gaza** (`RM-003`).
4. Klik tombol **Lihat Detail / Tinjau Sesi**.

#### Langkah 3: Menelaah Hasil Skrining & Sintesis SPK
1. Di halaman **Detail & Hasil Sesi Skrining**, perhatikan 2 tab tampilan:
   - **Formulir Deteksi Dini (Standar SDIDTK)**: Tampilan visual formal berbasis format Kemenkes RI.
   - **Detail Lembar Kerja & Kuesioner**: Rincian butir per butir jawaban instrumen.
2. Periksa hasil evaluasi instrumen:
   - **KPSP (36 Bulan)**: Skor `8/10` &rarr; Kategori: **Meragukan (Dm)**. Domain motorik/bicara terindikasi perlu stimulasi.
   - **GPPH**: Skor normal (di bawah ambang batas).
3. Periksa panel sintesis SPK: sistem merekomendasikan intervensi stimulasi intensif selama 2 minggu di rumah dan penjadwalan evaluasi ulang KPSP 14 hari.

#### Langkah 4: Memasukkan Evaluasi Dokter & Rencana Tindak Lanjut
1. Gulir ke bagian **Tinjauan & Keputusan Dokter**:
2. Isi formulir tinjauan klinis:
   - **Catatan Klinis Dokter (*Clinical Notes*)**:  
     *"Perkembangan anak menunjukkan hasil meragukan pada 2 butir KPSP 36 bulan. Disarankan konseling stimulasi keluarga terfokus pada kemandirian dan motorik halus selama 14 hari."*
   - **Keputusan Tindak Lanjut**:  
     Pilih opsi **Konseling Stimulasi Perkembangan**.
   - **Catatan Intervensi / Rujukan**:  
     *"Lakukan evaluasi ulang KPSP 2 minggu setelah intervensi rumah. Apabila hasil tetap meragukan, jadwalkan rujukan poli tumbuh kembang."*
3. Klik tombol **Simpan Catatan & Finalisasi Sesi**.
4. Status sesi akan otomatis berubah menjadi **Selesai Ditinjau (*Reviewed*)**.

#### Langkah 5: Menguji Cetak Formulir SDIDTK Kemenkes RI
1. Di bagian atas halaman detail sesi yang telah selesai ditinjau, klik tombol hijau: **Cetak Formulir SDIDTK**.
2. Dialog pratinjau cetak (*Print Preview*) peramban akan muncul.
3. Lakukan verifikasi visual pada tampilan cetak:
   - **Kop Surat**: Menampilkan identitas resmi *"UPTD BLK-ABK Dinas Kesehatan Kota Balikpapan"*.
   - **Identitas & No. RM**: Nomor rekam medis `RM-003` dan umur `3 tahun 0 bulan (36 bulan)` tercetak rapi di bagian identitas.
   - **Garis Pembatas (Outline Framing)**: Terdapat garis batas tepi luar utuh dan presisi pada kertas A4 (margin 10 mm).
   - **Kerapian Spasi**: Jarak antar-bagian (I, II, III, IV, V, VI) berjarak proporsional dan teks tidak terpotong.
   - **Warna Latar**: Latar belakang formulir berwarna putih solid (`#ffffff`), bersih dan hemat tinta, tidak terpengaruh oleh *Dark Mode* browser.
4. Anda dapat mencoba menyimpan sebagai PDF (*Save as PDF*) atau menutup dialog cetak.

#### Langkah 6: Memeriksa Modul Rekapitulasi Skrining
1. Pada menu samping, klik menu **Rekapitulasi Skrining**.
2. Periksa tabel agregasi data skrining:
   - Filter berdasarkan periode harian, mingguan, bulanan, atau tahunan.
   - Filter berdasarkan status (*Reviewed*, *Pending*, *In Progress*).
3. Pastikan grafik dan angka statistik bertambah sesuai sesi yang baru saja difinalisasi.

---

## 4. Lembar Checklist Pengujian Blackbox (Dokter)

Beri tanda centang (&check;) pada kolom hasil pengujian:

| No | Komponen / Fitur yang Diuji | Hasil yang Diharapkan | Hasil Pengamatan | Status (Lolos / Gagal) |
| :---: | :--- | :--- | :--- | :---: |
| 1 | **Login Dokter** | Berhasil login dan langsung diarahkan ke Dashboard Dokter (*Clinical Insight*). | | |
| 2 | **Daftar Antrean Review** | Sesi `pending_doctor_review` Rychi Yislam Gaza tampil jelas dan dapat dibuka. | | |
| 3 | **Sintesis Keputusan SPK** | Algoritma menampilkan kesimpulan KPSP Meragukan (Dm) dan rekomendasi tindakan secara tepat. | | |
| 4 | **Pemberian Catatan Medis** | Dokter dapat menginput *clinical notes* dan keputusan intervensi tanpa kendala. | | |
| 5 | **Finalisasi Sesi** | Sesi berhasil dikunci menjadi status `reviewed` dan riwayat tanggal review tercatat. | | |
| 6 | **Tata Letak Cetak SDIDTK** | Tampilan cetak A4 memiliki outline margin utuh, kop faskes lengkap, dan layout terstruktur. | | |
| 7 | **Proteksi Tema Gelap pada Cetak** | Dokumen cetak tetap berlatar putih bersih walau sistem sedang dalam *Dark Mode*. | | |
| 8 | **Modul Rekapitulasi** | Data sesi yang difinalisasi otomatis masuk ke laporan rekapitulasi klinis. | | |

---

## 5. Lembar Kuesioner System Usability Scale (SUS) — Dokter

*Petunjuk*: Berikan penilaian profesional Anda terhadap sistem SPK ini dengan memberi tanda silang (X) pada skala **1 (Sangat Tidak Setuju)** sampai **5 (Sangat Setuju)**.

| No | Pernyataan Evaluasi Usability | 1 (STS) | 2 (TS) | 3 (N) | 4 (S) | 5 (SS) |
| :---: | :--- | :--- :---: | :--- :---: | :--- :---: | :---: | :---: |
| 1 | Saya merasa ingin rutin menggunakan sistem ini untuk meninjau dan memvalidasi hasil skrining anak. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 2 | Saya merasa sistem ini terlalu rumit untuk alur kerja klinis seorang dokter. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 3 | Saya merasa sistem ini sangat mudah digunakan dalam menelaah sintesis instrumen dan memberi keputusan. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 4 | Saya merasa membutuhkan pendampingan teknis khusus untuk dapat memvalidasi dan memfinalisasi laporan. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 5 | Saya merasa integrasi antara data pemeriksaan perawat, sintesis SPK, dan cetak SDIDTK bekerja sangat baik. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 6 | Saya merasa ada ketidakkonsistenan pada penyajian data medis atau navigasi sistem ini. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 7 | Saya merasa rekan sejawat dokter anak lainnya dapat mempelajari sistem ini dalam waktu singkat. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 8 | Saya merasa antarmuka telaah rekam medis pada sistem ini janggal atau kurang praktis. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 9 | Saya merasa sangat yakin dan percaya diri dengan keakuratan data dan dokumen cetak yang dihasilkan sistem. | [ ] | [ ] | [ ] | [ ] | [ ] |
| 10 | Saya harus meluangkan banyak waktu untuk mempelajari sistem ini sebelum dapat menggunakannya secara mandiri. | [ ] | [ ] | [ ] | [ ] | [ ] |

**Catatan / Rekomendasi Klinis Tambahan dari Dokter**:
```text
....................................................................................................
....................................................................................................
```

