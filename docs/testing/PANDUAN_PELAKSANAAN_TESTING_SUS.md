# PANDUAN LENGKAP PELAKSANAAN SYSTEM USABILITY SCALE (SUS) & USABILITY TESTING
**Sistem Pendukung Keputusan Deteksi Dini Tumbuh Kembang Anak (SDIDTK)**  
**UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus (BLK-ABK) Kota Balikpapan**

---

## 1. Landasan Teori & Rujukan Metodologi
Panduan ini disusun secara sistematis berdasarkan metodologi yang tervalidasi dari 3 jurnal rujukan:
1. **Dyayu, Beny, & Yani (2023)** — *Evaluasi Usability Aplikasi Menggunakan Metode Usability Testing dan System Usability Scale (SUS)*, Jurnal Manajemen Teknologi dan Sistem Informasi (JMS), Vol. 3, No. 1.
2. **Ramadan, Ramadhani, Handayani, Sulistiyani, & Budiarti (2024)** — *Implementation of Black Box Testing and System Usability Scale on Information System*, Applied Technology and Computing Science Journal (ATCSJ), Vol. 7, No. 2.
3. **Nugroho, Julianto, & Nur MS (2022)** — *Usability Testing pada Sistem Informasi Manajemen Menggunakan Metode System Usability Scale*, Jurnal Nasional Pendidikan Teknik Informatika (JANAPATI), Vol. 11, No. 1.

Mengacu pada teori dasar oleh **John Brooke (1996)**, **Bangor, Kortum, & Miller (2009)**, dan **Sauro & Lewis (2018)**.

---

## 2. Kerangka Kerja Pengujian (Research & Testing Workflow)

Berdasarkan kerangka kerja Dyayu (2023) dan Nugroho (2022), alur pengujian terdiri dari 4 tahapan utama:

```
┌────────────────────────────────────────────────────────────────────────┐
│ 1. TAHAP PERSIAPAN (PRE-TEST)                                          │
│    • Reset database ke titik checkpoint bersih (./reset-test.sh)       │
│    • Menyiapkan lembar task scenario & kuesioner SUS                   │
│    • Menentukan responden representatif (Purposive Sampling)           │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 2. TAHAP PELAKSANAAN (TESTING SESSION)                                 │
│    • Briefing singkat tujuan pengujian & skenario                      │
│    • Responden mengerjakan Task Scenario secara mandiri (interaksi riil│
│    • Fasilitator melakukan observasi tingkah laku & kendala fungsional │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 3. TAHAP PENGISIAN SUS & WAWANCARA (POST-TEST)                         │
│    • Responden mengisi 10 butir instrumen SUS (Skala Likert 1–5)       │
│    • Wawancara kualitatif tidak terstruktur untuk menggali temuan      │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 4. TAHAP ANALISIS DATA (DATA ANALYSIS)                                 │
│    • Perhitungan skor SUS per responden & skor rata-rata               │
│    • Interpretasi 4 Dimensi: Grade, Adjective, Acceptability, & NPS    │
│    • Tabulasi temuan masalah & rekomendasi perbaikan sistem            │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Tahap Persiapan Pengujian (Pre-Test)

### 3.1 Penentuan Responden (Purposive Sampling)
Berdasarkan Nugroho (2022) dan Ramadan (2024), pengujian usability efektif menggunakan teknik *Purposive Sampling*, yaitu memilih responden yang memiliki keterkaitan langsung dengan proses bisnis sistem:
- **Kelompok 1: Perawat (Screening Nurse)** &rarr; Staf tenaga kesehatan yang bertugas melakukan deteksi dini antropometri, KPSP, dan GPPH.
- **Kelompok 2: Orang Tua / Wali Pasien** &rarr; Pengguna awam yang mendampingi anak dan mengisi instrumen mandiri SDQ & SRQ-20.
- **Kelompok 3: Dokter (Reviewing Doctor / Sp.A)** &rarr; Tenaga medis peninjau yang memvalidasi sintesis SPK, menentukan intervensi, dan mencetak dokumen resmi SDIDTK.

> *Catatan Ukuran Sampel*: Menurut Nielsen (2012) dan Brooke (2013), pengujian usability kualitatif dengan 5 responden per kelompok pengguna telah mampu mengungkap lebih dari 80% masalah usability antarmuka.

### 3.2 Penyiapan Lingkungan Sistem (Checkpoint Reset)
Sebelum sesi pengujian dimulai untuk responden baru, fasilitator **wajib mereset database** agar data kembali ke titik awal yang bersih:
```bash
./reset-test.sh
```
*Hasil reset*: 5 data pasien terfokus (`RM-001` s.d. `RM-005`) dan akun uji masing-masing peran siap digunakan tanpa residu pengujian sebelumnya.

---

## 4. Tahap Pelaksanaan Pengujian (Running the Test)

### 4.1 Prinsip Skenario Tugas (Task Scenario Guidelines)
Sesuai prinsip Carol (2020) dan McCloskey (2014) dalam Dyayu (2023):
1. **Gunakan bahasa pengguna**, bukan istilah teknis pemrograman.
2. **Berikan tujuan (*Goal*) dan konteks**, bukan instruksi klik per klik:
   - *Salah*: "Klik tombol login, lalu klik tombol biru di kanan atas."
   - *Benar*: "Anda ingin memeriksa tumbuh kembang anak Anda yang berusia 5 tahun, silakan isi kuesioner perilaku yang tersedia untuk anak Anda."
3. **Biarkan pengguna berinteraksi secara mandiri**. Fasilitator dilarang membantu kecuali terjadi kendala teknis fatal.

### 4.2 Pelaksanaan per Kelompok Pengguna
Gunakan lembar panduan operasional masing-masing yang telah tersedia di direktori `docs/testing/`:
- **Perawat**: Panduan tugas di [`GUIDE_TESTING_PERAWAT.md`](./GUIDE_TESTING_PERAWAT.md)
  - Tugas 1: Membuat sesi skrining baru untuk Muhammad Zain Ageng Pangestu (`RM-001`) sesuai rekam medis hardcopy.
  - Tugas 2: Menjalankan sesi evaluasi ulang KPSP 14 hari untuk Adelio Vember (`RM-005`) dan memverifikasi rujukan otomatis.
- **Orang Tua**: Panduan tugas di [`GUIDE_TESTING_ORANG_TUA.md`](./GUIDE_TESTING_ORANG_TUA.md)
  - Tugas 1: Login ke portal orang tua.
  - Tugas 2: Mengisi kuesioner mandiri SDQ (25 butir) dan SRQ-20 (20 butir) untuk Chairil Rafqi Nababan (`RM-002`).
- **Dokter**: Panduan tugas di [`GUIDE_TESTING_DOKTER.md`](./GUIDE_TESTING_DOKTER.md)
  - Tugas 1: Menelaah antrean telaah `pending_doctor_review` untuk Rychi Yislam Gaza (`RM-003`).
  - Tugas 2: Menginput catatan medis, memfinalisasi sesi, dan menguji cetak formulir SDIDTK Kemenkes RI.

---

## 5. Instrumen Kuesioner System Usability Scale (SUS)

Setelah responden selesai mengerjakan task scenario dan sebelum berdiskusi panjang, berikan 10 butir instrumen SUS resmi bahasa Indonesia berikut (Skala Likert 1–5):

| No | Pernyataan Instrumen SUS | Indikator Usability | 1 (STS) | 2 (TS) | 3 (N) | 4 (S) | 5 (SS) |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Q1** | Saya berpikir akan sering menggunakan sistem ini dalam kegiatan skrining / pemantauan tumbuh kembang anak. | *Satisfaction* (Kepuasan) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q2** | Saya merasa sistem ini terlalu rumit untuk digunakan. | *Complexity* (Kerumitan) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q3** | Saya merasa sistem ini mudah untuk digunakan. | *Ease of Use* (Kemudahan) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q4** | Saya membutuhkan bantuan dari orang teknis atau orang lain untuk dapat menggunakan sistem ini. | *Learnability* (Dukungan) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q5** | Saya merasa fitur-fitur dan fungsi dalam sistem ini berjalan dengan semestinya. | *Efficiency* (Kelancaran Fitur) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q6** | Saya merasa ada banyak hal yang tidak konsisten (tidak serasi) pada sistem ini. | *Consistency* (Konsistensi) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q7** | Saya merasa orang lain akan dapat memahami dan mempelajari sistem ini dengan cepat. | *Learnability* (Kemudahan Belajar) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q8** | Saya merasa sistem ini membingungkan saat dioperasikan. | *Ease of Use* (Kebingungan) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q9** | Saya merasa tidak ada hambatan yang berarti dalam menggunakan sistem ini. | *Ease of Use* (Kelancaran) | [ ] | [ ] | [ ] | [ ] | [ ] |
| **Q10** | Saya perlu membiasakan diri terlebih dahulu sebelum saya dapat menggunakan sistem ini dengan lancar. | *Learnability* (Adaptasi) | [ ] | [ ] | [ ] | [ ] | [ ] |

*Keterangan Skala Likert*:  
`1` = Sangat Tidak Setuju (STS) &bull; `2` = Tidak Setuju (TS) &bull; `3` = Netral / Ragu-ragu (N) &bull; `4` = Setuju (S) &bull; `5` = Sangat Setuju (SS).

---

## 6. Formula & Cara Perhitungan Skor SUS

Berdasarkan rumus standar John Brooke (1996) yang dikutip dalam ketiga jurnal:

### 6.1 Aturan Konversi Skor Tiap Pertanyaan (Skala 0–4)
- **Untuk Pertanyaan Bernomor GANJIL (Q1, Q3, Q5, Q7, Q9)**:  
  Pernyataan bernada positif. Respon dihitung dengan rumus:
  $$\text{Skor Kontribusi } R_i = X_i - 1$$
  *(Contoh: Jika responden menjawab 5, skor kontribusi = 5 - 1 = 4)*
- **Untuk Pertanyaan Bernomor GENAP (Q2, Q4, Q6, Q8, Q10)**:  
  Pernyataan bernada negatif. Respon dihitung dengan rumus:
  $$\text{Skor Kontribusi } R_i = 5 - X_i$$
  *(Contoh: Jika responden menjawab 1, skor kontribusi = 5 - 1 = 4)*

### 6.2 Perhitungan Skor Akhir Responden (Skala 0–100)
Jumlahkan seluruh skor kontribusi dari Q1 hingga Q10, kemudian kalikan dengan faktor koreksi **2.5**:
$$\text{Skor SUS Individu} = \left( \sum_{i=1}^{10} R_i \right) \times 2.5$$

### 6.3 Perhitungan Rata-Rata SUS Keseluruhan
$$\bar{X} = \frac{\sum_{k=1}^{n} \text{Skor SUS}_k}{n}$$
*(di mana $n$ adalah jumlah responden).*

---

## 7. Model Interpretasi Skor SUS (Bangor et al., 2009 & Sauro, 2018)

Berdasarkan sintesis dari Ramadan et al. (2024), Dyayu et al. (2023), dan Nugroho et al. (2022), skor rata-rata SUS dievaluasi menggunakan **4 Kuadran Interpretasi**:

```
Skor SUS : 0      10     20     30     40     50     60    68    70     80     90    100
           |------|------|------|------|------|------|-----|-----|------|------|------|
NPS      : [──────────────── Detractor ───────────────] [─ Passive ─] [─── Promoter ───]
Accept.  : [──────── Not Acceptable ─────────] [── Marginal ──] [───── Acceptable ─────]
Adjective: [ Worst ] [   Poor   ] [     OK     ] [    Good    ] [ Excellent ] [ Best ]
Grade    : [──────────── F ───────────] [  D   ] [ C ] [  B   ] [       A        ]
```

### Tabel Matriks Interpretasi Komprehensif:

| Rentang Skor SUS | Grade Scale | Adjective Rating | Acceptability Range | Net Promoter Score (NPS) | Makna Klinis & Operasional |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **84.1 – 100** | **A+** | **Best Imaginable** | **Acceptable** | **Promoter** | Sistem sangat luar biasa, sangat intuitif, tidak memerlukan pelatihan tambahan. |
| **80.8 – 84.0** | **A** | **Excellent** | **Acceptable** | **Promoter** | Kualitas antarmuka sangat baik, alur kerja efisien, sangat direkomendasikan. |
| **78.9 – 80.7** | **A-** | **Good to Excellent**| **Acceptable** | **Promoter** | Pengguna sangat puas, tingkat kegagalan interaksi sangat rendah. |
| **74.1 – 78.8** | **B+ / B** | **Good** | **Acceptable** | **Passive** | Sistem diterima dengan baik dan siap digunakan di fasilitas kesehatan. |
| **71.1 – 74.0** | **B-** | **Good** | **Acceptable** | **Passive** | Di atas rata-rata industri (68.0), namun terdapat catatan kecil pada konsistensi. |
| **65.0 – 71.0** | **C** | **OK** | **Marginal** | **Passive** | Memenuhi syarat batas bawah operasional; memerlukan sedikit perbaikan UX. |
| **51.7 – 64.9** | **D** | **Poor** | **Not Acceptable** | **Detractor** | Sistem membingungkan; pengguna berisiko melakukan salah input data medis. |
| **0 – 51.6** | **F** | **Worst Imaginable** | **Not Acceptable** | **Detractor** | Sistem ditolak pengguna; alur kerja harus dirancang ulang secara mendasar. |

> **Benchmark Standar**: Skor rata-rata industri menurut Sauro (2018) adalah **68.0**. Sistem SPK SDIDTK ditargetkan mencapai minimal **&ge; 70.0 (Grade B / Acceptable)** agar layak dan aman digunakan dalam operasional UPTD BLK-ABK.

---

## 8. Template Tabulasi Data Pengujian (Siap Pakai untuk Excel / Spreadsheet)

Gunakan format tabel berikut untuk merekap hasil kuisioner 10 butir SUS:

```
+------------+---------------------+----+----+----+----+----+----+----+----+----+-----+-------+------------+-------+-----------+---------------+
| Responden  | Role Pengguna       | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | Q8 | Q9 | Q10 | Total | Skor Akhir | Grade | Adjective | Acceptability |
+------------+---------------------+----+----+----+----+----+----+----+----+----+-----+-------+------------+-------+-----------+---------------+
| R01        | Perawat             | 5  | 1  | 5  | 1  | 5  | 2  | 4  | 1  | 5  |  2  |  37   |   92.50    |  A+   | Excellent |  Acceptable   |
| R02        | Perawat             | 4  | 2  | 4  | 2  | 4  | 2  | 4  | 2  | 4  |  2  |  30   |   75.00    |  B    |   Good    |  Acceptable   |
| R03        | Orang Tua           | 5  | 2  | 5  | 1  | 5  | 1  | 5  | 2  | 4  |  2  |  36   |   90.00    |  A+   | Excellent |  Acceptable   |
| R04        | Orang Tua           | 4  | 2  | 4  | 2  | 4  | 3  | 4  | 2  | 4  |  3  |  28   |   70.00    |  C    |    OK     |  Acceptable   |
| R05        | Dokter              | 5  | 1  | 5  | 1  | 5  | 1  | 5  | 1  | 5  |  1  |  40   |  100.00    |  A+   |   Best    |  Acceptable   |
+------------+---------------------+----+----+----+----+----+----+----+----+----+-----+-------+------------+-------+-----------+---------------+
| RATA-RATA KESELURUHAN (SUS MEAN)                                                       |  34.2 |   85.50    |   A   | Excellent |  Acceptable   |
+----------------------------------------------------------------------------------------+-------+------------+-------+-----------+---------------+
```

---

## 9. Format Pelaporan Temuan Masalah Kualitatif

Sesuai metodologi Dyayu (2023), catat setiap kendala atau komentar responden selama pengerjaan tugas menggunakan format kode masalah berikut:

| Kode Masalah | Deskripsi Kendala yang Ditemukan | Peran yang Mengalami | Dampak pada Usability | Rekomendasi Solusi Perbaikan |
| :---: | :--- | :---: | :---: | :--- |
| **M1** | Responden sempat mencari letak tombol cetak laporan SDIDTK. | Dokter | Efisiensi waktu | Mempertahankan tombol hijau kontras di bagian atas detail sesi. |
| **M2** | Orang tua ragu apakah kuesioner SDQ yang telah diisi sudah tersimpan. | Orang Tua | Kepuasan (*Satisfaction*) | Memberikan banner alert hijau yang menegaskan kuesioner selesai. |
| **M3** | Perawat memerlukan konfirmasi saat input antropometri desimal. | Perawat | Error rate | Menambahkan validasi input dan satuan `kg` / `cm` yang tegas. |

