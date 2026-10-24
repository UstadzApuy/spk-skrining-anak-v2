# SPESIFIKASI LANJUTAN — MODUL KPSP, TAHAPAN PERKEMBANGAN, STIMULASI, DAN RED FLAGS

## 1. Tujuan implementasi

Kembangkan modul Kuesioner Pra Skrining Perkembangan (KPSP) pada aplikasi SPK Skrining Anak UPTD BLK-ABK Kota Balikpapan.

Modul harus lebih dari sekadar menampilkan 10 pertanyaan dan menghitung jawaban Ya. Sistem harus memiliki data formulir yang berbeda menurut umur, instruksi pelaksanaan untuk setiap butir, penilaian otomatis, kategori hasil, referensi tahapan perkembangan, stimulasi sesuai umur, red flags perkembangan, serta rekomendasi tindak lanjut sesuai hasil pemeriksaan.

Sumber utama:

1. `KPSP(3).pdf` — Buku Bagan Stimulasi, Deteksi, dan Intervensi Dini Tumbuh Kembang Anak di Tingkat Pelayanan Kesehatan Dasar.
2. `Rentang Umur(3).pdf` — tabel jadwal dan jenis deteksi dini tumbuh kembang.
3. Kode dan tes yang telah tersedia pada proyek, terutama `KpspAgeCalculator`, `KpspScorer`, `RuleBasedScoringService`, `ScreeningSessionController`, dan `KpspAgeCalculatorTest`.

Semua teks butir, instruksi pemeriksaan, kriteria jawaban, stimulasi, dan red flags harus diekstrak dari PDF sumber. Jangan mengganti materi tersebut dengan milestone atau rekomendasi buatan sendiri.

**Cakupan modul:** KPSP, tahapan perkembangan, stimulasi, red flags, dan alur tindak lanjut.

**Di luar cakupan:** Tes Daya Dengar (TDD), formulir TDD, pertanyaan TDD, skor TDD, serta halaman atau hasil pemeriksaan TDD. Jangan membangun modul TDD atau memasukkannya ke ringkasan hasil sebagai instrumen yang dikerjakan. Item KPSP asli tetap harus dipertahankan meskipun pada instruksi tertentu terdapat pengamatan terhadap respons anak terhadap suara.

---

## 2. Dua jenis data umur yang tidak boleh dicampur

Sistem harus membedakan:

### A. Umur formulir KPSP

Umur formulir KPSP adalah umur acuan yang digunakan untuk menentukan 10 butir pemeriksaan yang perlu dilaksanakan.

Formulir tersedia pada 16 titik umur:

| No. | Umur formulir |
|---:|---:|
| 1 | 3 bulan |
| 2 | 6 bulan |
| 3 | 9 bulan |
| 4 | 12 bulan |
| 5 | 15 bulan |
| 6 | 18 bulan |
| 7 | 21 bulan |
| 8 | 24 bulan |
| 9 | 30 bulan |
| 10 | 36 bulan |
| 11 | 42 bulan |
| 12 | 48 bulan |
| 13 | 54 bulan |
| 14 | 60 bulan |
| 15 | 66 bulan |
| 16 | 72 bulan |

Referensi PDF pada `KPSP(3).pdf`:

| Umur | Halaman PDF | Nomor halaman pada Buku Bagan |
|---:|---:|---:|
| 3 bulan | 7 | 27 |
| 6 bulan | 8 | 28 |
| 9 bulan | 14 | 34 |
| 12 bulan | 15 | 35 |
| 15 bulan | 20 | 40 |
| 18 bulan | 21 | 41 |
| 21 bulan | 26 | 46 |
| 24 bulan | 27 | 47 |
| 30 bulan | 32 | 52 |
| 36 bulan | 33 | 53 |
| 42 bulan | 40 | 60 |
| 48 bulan | 42 | 62 |
| 54 bulan | 48 | 68 |
| 60 bulan | 50 | 70 |
| 66 bulan | 56 | 76 |
| 72 bulan | 58 | 78 |

Nomor halaman PDF dan nomor halaman tercetak berbeda. Gunakan nomor halaman PDF untuk menemukan isi berkas, lalu cocokkan dengan halaman tercetak sebelum mengimpor pertanyaan.

Setiap formulir terdiri atas tepat 10 item. Jangan mengganti formulir dengan kelompok umur yang hanya memiliki susunan pertanyaan serupa.

### B. Kelompok tahapan perkembangan

Tabel tahapan perkembangan, stimulasi, dan red flags menggunakan kelompok umur yang berbeda dari umur formulir KPSP.

Kelompok umur dalam Buku Bagan:

- 0–2 bulan;
- 3–5 bulan;
- 6–8 bulan;
- 9–11 bulan;
- 12–17 bulan;
- 18–23 bulan;
- 24–35 bulan;
- 36–47 bulan;
- 48–59 bulan;
- 60–72 bulan.

Kelompok tersebut harus dipertahankan sebagai referensi perkembangan sesuai sumber. Jangan memaksakan satu tabel stimulasi untuk semua umur hanya karena beberapa umur menggunakan formulir KPSP yang sama.

Kelompok umur 0–2 bulan tetap dapat memiliki referensi perkembangan dan red flags, tetapi sumber ini tidak menyediakan formulir KPSP untuk kelompok umur tersebut. Karena itu, jangan membuat formulir KPSP 0–2 bulan sendiri.

---

## 3. Penghitungan umur dan pemilihan formulir

Gunakan `KpspAgeCalculator` yang telah ada sebagai dasar. Audit implementasi dan tesnya sebelum mengubah kode.

### A. Menghitung umur

Penghitungan umur dilakukan dari tanggal lahir dan tanggal pemeriksaan.

Ikuti metode penghitungan pada halaman 1 PDF KPSP:

- Hitung tahun, bulan, dan hari.
- Jika perlu meminjam satu bulan dalam penghitungan, satu bulan dianggap 30 hari.
- Satu tahun setara dengan 12 bulan.
- Jangan menerima `age_months` atau `form_age_months` dari frontend sebagai nilai otoritatif.

### B. Koreksi prematuritas

Menurut sumber pada halaman 1 Buku Bagan, apabila pada penghitungan awal umur anak belum mencapai 2 tahun, tanyakan apakah anak lahir saat usia gestasi kurang dari 38 minggu.

Jika koreksi prematuritas memang berlaku, koreksi dilakukan terhadap umur dengan 40 minggu sebagai usia gestasi cukup bulan.

Rumus durasi koreksi:

`Durasi koreksi = 40 minggu - usia gestasi saat lahir`

Umur yang telah dikoreksi menjadi masukan untuk pemilihan formulir KPSP sesuai aturan yang berlaku pada sistem.

Pertahankan aturan yang sudah diuji pada proyek dan periksa bahwa koreksi tidak diterapkan dua kali. Jika ada perbedaan antara implementasi sekarang dan sumber, dokumentasikan perbedaannya sebelum mengubah hasil.

### C. Pembulatan umur

Algoritme pada halaman 2 Buku Bagan menyebut umur dengan sisa hari lebih dari 16 hari dibulatkan menjadi satu bulan berikutnya.

Jadi:

- sisa hari 16 hari tidak dibulatkan ke atas;
- sisa hari 17 hari atau lebih dibulatkan satu bulan ke atas.

Pertahankan hasil tes proyek yang sudah menguji kedua batas tersebut.

Urutan penghitungan, koreksi prematuritas, pembulatan, dan pemilihan formulir harus terpusat dalam service, bukan ditulis ulang secara terpisah di controller dan Vue.

### D. Pemilihan formulir yang tersedia

Setelah umur dihitung, dibulatkan, dan dikoreksi sesuai ketentuan:

1. Jika tersedia formulir tepat pada umur tersebut, gunakan formulir yang sesuai.
2. Jika tidak tersedia formulir tepat pada umur tersebut, gunakan formulir untuk kelompok umur yang lebih muda sebagaimana algoritme pada halaman 2 Buku Bagan.
3. Jangan memilih formulir umur yang lebih tua hanya karena jaraknya lebih dekat.
4. Jika umur di luar rentang formulir KPSP yang tersedia, jangan membuat formulir baru atau memperkirakan hasil dari formulir lain.
5. Tampilkan kepada petugas umur hasil perhitungan, umur formulir yang dipakai, dan alasan pemilihannya.

Contoh yang perlu diuji:

| Umur hasil akhir | Formulir yang digunakan |
|---:|---:|
| 3 bulan | 3 bulan |
| 5 bulan | 3 bulan |
| 6 bulan | 6 bulan |
| 10 bulan | 9 bulan |
| 15 bulan | 15 bulan |
| 23 bulan | 21 bulan |
| 24 bulan | 24 bulan |
| 29 bulan | 24 bulan |
| 30 bulan | 30 bulan |
| 33 bulan | 30 bulan |
| 42 bulan | 42 bulan |
| 69 bulan | 66 bulan |
| 72 bulan | 72 bulan |

Contoh tersebut mengasumsikan umur yang ditampilkan sudah melewati semua tahap koreksi dan pembulatan. Umur yang belum melalui perhitungan tersebut tidak boleh langsung dipakai untuk memilih formulir.

Periksa apakah controller saat ini menolak KPSP ketika `form_age_months` bernilai `null`. Bila iya, audit apakah kondisi itu menyebabkan anak dengan umur valid kehilangan akses ke formulir umur lebih muda. Sesuaikan secara teruji dengan ketentuan sumber, tanpa membuat formulir untuk umur di luar cakupan.

---

## 4. Instrumen per formulir umur

### A. Prinsip pengelolaan formulir

Semua 16 formulir pada Bagian 2 harus tersedia sebagai data terstruktur.

Setiap butir harus memuat setidaknya:

- umur formulir;
- nomor butir;
- teks pertanyaan asli;
- instruksi pelaksanaan;
- alat atau bahan yang diperlukan;
- cara memeriksa atau meminta responden menjawab;
- kriteria yang membuat jawaban dinilai Ya;
- domain perkembangan sebagaimana tertulis di sumber;
- urutan tampilan.

Gunakan teks dan instruksi langsung dari PDF. Pertahankan gambar contoh, diagram, atau stimulus visual yang memang dibutuhkan untuk melaksanakan butir. Jika asset tersebut tidak dapat diekstrak secara andal, tandai sebagai kebutuhan asset, bukan menggantinya dengan gambar ilustratif yang tidak setara.

### B. Domain perkembangan setiap butir

Gunakan label asli:

1. Gerak kasar.
2. Gerak halus.
3. Bicara dan bahasa.
4. Sosialisasi dan kemandirian.

Jangan mengubah domain menjadi subskala yang menghasilkan skor klinis baru. Domain digunakan untuk menjelaskan kemampuan yang diperiksa serta membantu petugas mengidentifikasi aspek perkembangan yang belum tercapai.

### C. Fokus pemeriksaan masing-masing umur

Tabel ini merupakan ringkasan fokus, bukan pengganti isi 10 pertanyaan asli. Coding agent wajib memeriksa seluruh butir dalam halaman sumber.

| Umur formulir | Fokus kemampuan yang terlihat pada formulir sumber |
|---:|---|
| 3 bulan | Gerakan anggota tubuh, kontrol dan pengangkatan kepala, pelacakan visual, tatapan wajah, senyum timbal balik, serta vokalisasi. |
| 6 bulan | Pelacakan visual, kontrol kepala, penyanggaan tubuh, genggaman, kemampuan meraih benda, berguling, vokalisasi, dan respons sosial. |
| 9 bulan | Memungut benda kecil, memegang dua benda, mencari benda yang jatuh atau disembunyikan, meraih benda di luar jangkauan, suku kata berulang, makan sendiri, memindahkan benda, duduk, dan menyangga berat badan. |
| 12 bulan | Menggenggam alat, mengambil benda kecil, mempertemukan dua kubus, meniru kata, berdiri, duduk tanpa bantuan, memahami kata larangan, mencari pengasuh yang bersembunyi, membedakan pengasuh, dan berdiri sambil berpegangan. |
| 15 bulan | Manipulasi kubus dan wadah, berjalan dengan berpegangan, penggunaan kata bermakna, tepuk tangan atau lambaian, menyampaikan keinginan, serta berdiri tanpa bantuan. |
| 18 bulan | Periksa seluruh butir asli untuk kemampuan gerak, manipulasi benda, penggunaan kata, mengikuti instruksi, dan kemandirian. |
| 21 bulan | Periksa seluruh butir asli dan pertahankan urutan serta kriteria penilaiannya dari formulir umur 21 bulan. |
| 24 bulan | Periksa seluruh butir asli untuk gerak, manipulasi benda, bahasa, pemahaman, serta sosialisasi dan kemandirian. |
| 30 bulan | Periksa seluruh butir asli untuk keterampilan motorik, tugas visual-motor, pemahaman bahasa, perintah, dan kemampuan sosial. |
| 36 bulan | Periksa seluruh butir asli untuk menyusun kubus, bahasa, pengenalan benda, kemampuan mengikuti instruksi, serta kemandirian. |
| 42 bulan | Periksa seluruh butir asli dan gunakan kriteria serta stimulus spesifik dalam formulir umur 42 bulan. |
| 48 bulan | Periksa seluruh butir asli, termasuk tugas menggambar, bahasa, dan kemandirian yang terdapat pada formulir tersebut. |
| 54 bulan | Periksa seluruh butir asli, termasuk gambar, pengenalan warna/bahasa, konsep kata sifat, dan kemandirian sesuai sumber. |
| 60 bulan | Garis yang lebih panjang, menggambar orang, mengenali warna, menjawab pertanyaan sederhana, serta kemampuan lain dalam sepuluh butir formulir. |
| 66 bulan | Menggambar tanda tambah dan kotak, menggambar orang, konsep angka, bahasa, kemandirian, keseimbangan, serta menangkap bola. |
| 72 bulan | Menggambar kotak, menggambar orang, analogi berlawanan, pemahaman kata dan benda, tugas motorik, serta kemandirian. |

Jangan mengisi baris yang diringkas di atas dengan pertanyaan generik. Butir formulir harus diekstrak langsung dari halaman sumber yang bersangkutan.

### D. Cara penyajian kepada petugas

Halaman pengisian menampilkan:

- nama dan nomor rekam medis pasien;
- tanggal pemeriksaan;
- umur aktual atau terkoreksi sesuai aturan;
- umur formulir KPSP yang digunakan;
- instruksi setiap butir;
- stimulus yang diperlukan;
- pilihan Ya atau Tidak;
- progres, misalnya butir 4 dari 10;
- ringkasan jawaban sebelum penyimpanan hasil final.

Butir yang meminta pemeriksa melakukan tugas secara langsung harus menampilkan instruksi lengkap. Butir yang harus dijawab orang tua atau pengasuh harus mempertahankan sumber responden tersebut.

Jangan mengubah seluruh butir menjadi pertanyaan orang tua. Jangan pula mengasumsikan bahwa semua jawaban diperoleh dari observasi langsung.

---

## 5. Rule-based scoring KPSP

### A. Bentuk jawaban dan skor

Setiap formulir berisi tepat 10 butir, dengan jawaban:

- Ya = 1.
- Tidak = 0.

Skor KPSP dihitung dengan menjumlahkan seluruh jawaban Ya.

`Skor KPSP = Jumlah jawaban Ya dari 10 butir`

Rentang skor adalah 0–10.

KPSP tidak menggunakan pembalikan skor seperti pada beberapa butir SDQ. Jangan memberi bobot lebih tinggi kepada item tertentu tanpa dasar sumber.

Jawaban yang tidak diberikan tidak boleh dianggap Tidak. Backend harus menolak penghitungan final apabila belum seluruh butir dijawab secara valid.

### B. Kategori hasil

Gunakan algoritme pada halaman 2 Buku Bagan.

| Skor Ya | Kategori internal | Label tampilan |
|---:|---|---|
| 9–10 | `sesuai_umur` | Sesuai umur |
| 7–8 | `meragukan` | Meragukan |
| 0–6 | `kemungkinan_penyimpangan` | Ada kemungkinan penyimpangan |

Simpan skor final, kategori, umur formulir, jawaban, versi instrumen, serta versi aturan scoring.

Jangan menetapkan kategori berdasarkan jumlah jawaban Tidak secara terpisah. Kategori selalu dihitung dari jumlah jawaban Ya yang valid.

### C. Tindak lanjut menurut kategori

**Sesuai umur — 9–10 jawaban Ya**

- Berikan pujian kepada orang tua/pengasuh dan anak.
- Lanjutkan stimulasi sesuai tahapan umur.
- Jadwalkan kunjungan berikutnya.

**Meragukan — 7–8 jawaban Ya**

- Anjurkan stimulasi yang lebih sering dengan penuh kasih sayang.
- Ajarkan intervensi dini pada aspek perkembangan yang tertinggal.
- Jadwalkan pemeriksaan ulang 2 minggu kemudian.
- Jika pemeriksaan ulang juga meragukan atau menunjukkan kemungkinan penyimpangan, rujuk ke rumah sakit rujukan tumbuh kembang level 1.

**Ada kemungkinan penyimpangan — 0–6 jawaban Ya**

- Arahkan petugas untuk merujuk anak ke layanan atau rumah sakit rujukan tumbuh kembang level 1 sesuai alur yang ditetapkan UPTD.

Simpan hasil perhitungan dan rekomendasi yang menyertainya. Dokter tetap bertanggung jawab atas interpretasi serta penetapan tindak lanjut klinis.

---

## 6. Tahapan perkembangan, stimulasi, dan red flags menurut kelompok umur

Semua referensi berikut harus disusun berdasarkan tabel asli pada `KPSP(3).pdf`. Konten tidak berasal dari hasil skor KPSP saja. Milestone, stimulasi, dan red flags merupakan data referensi perkembangan yang terpisah.

Gunakan empat domain perkembangan untuk pengelompokan milestone dan stimulasi:

- Gerak kasar.
- Gerak halus dan adaptif.
- Bicara dan bahasa.
- Sosialisasi dan kemandirian.

Apabila red flags pada sumber tidak dikelompokkan secara terpisah menurut domain, pertahankan sebagai daftar red flags kelompok umur tersebut. Jangan memaksakan klasifikasi yang tidak didukung sumber.

### 6.1. Umur 0–2 bulan

**Tahapan perkembangan**

Gerak kasar:
- Mengangkat kepala setinggi 45 derajat.
- Menahan kepala tetap tegak.

Gerak halus dan adaptif:
- Meraba dan memegang benda.
- Menggerakkan kepala dari kiri atau kanan ke tengah.
- Pandangan mengikuti benda dan mulai mengenali orang dari kejauhan.

Bicara dan bahasa:
- Membuat suara seperti berkumur atau cooing.
- Mengoceh spontan.
- Bereaksi terkejut terhadap suara keras.
- Menoleh ke arah sumber suara.

Sosialisasi dan kemandirian:
- Membalas senyum ketika diajak bicara atau tersenyum.
- Tertawa keras.
- Melihat dan menatap wajah.
- Mengenali ibu melalui penglihatan, penciuman, pendengaran, dan kontak.
- Menenangkan diri sendiri untuk beberapa saat.
- Menunjukkan rasa bosan saat aktivitas monoton.

**Stimulasi**

- Melatih bayi mengangkat kepala 45 derajat, menahan kepala, dan berguling.
- Melatih bayi meraba serta memegang benda.
- Menggantung benda berwarna dan berbunyi.
- Melatih bayi mengenali suara.
- Menirukan ocehan dan mimik bayi.
- Menunjukkan ketertarikan pada bayi.
- Memberikan rasa aman dan nyaman.
- Mengenali penyebab bayi rewel dan mengatasinya.
- Membentuk rutinitas.

**Red flags**

Periode neonatal:
- Tonus otot lemah.
- Tidak merespons suara keras.
- Pengasuh tampak tidak tertarik atau acuh tak acuh.

Umur 2 bulan:
- Tidak dapat mengangkat kepala ketika tengkurap.
- Tidak dapat membawa tangan ke mulut.
- Tidak merespons suara keras.
- Pandangan tidak mengikuti gerakan benda.
- Jarang menatap wajah atau kurangnya fiksasi mata.
- Tidak tersenyum kepada orang di sekitarnya.

Tidak ada formulir KPSP untuk umur 0–2 bulan dalam berkas sumber. Jangan membuat formulir untuk kelompok ini.

### 6.2. Umur 3–5 bulan

**Tahapan perkembangan**

Gerak kasar:
- Berbalik dari tengkurap ke terlentang.
- Mengangkat kepala 90 derajat ketika tengkurap dan menopang tubuh dengan kedua siku.
- Mempertahankan kepala stabil.
- Kaki menendang ketika bayi ditegakkan.

Gerak halus dan adaptif:
- Kepala menoleh ke berbagai arah.
- Memegang dan menggoyangkan mainan.
- Menggenggam mainan atau jari orang lain.
- Meraih benda dalam jangkauan.
- Menyatukan tangan di tengah dan mengamatinya.
- Mengikuti benda yang bergerak serta memperhatikan benda kecil.

Bicara dan bahasa:
- Mengeluarkan suara gembira bernada tinggi dan memekik.
- Mengoceh dengan ekspresi dan menirukan suara.
- Mencari sumber suara.

Sosialisasi dan kemandirian:
- Memasukkan tangan ke mulut.
- Memperhatikan wajah orang sekitar.
- Mengenali orang atau benda dari kejauhan.
- Tersenyum ketika melihat mainan atau gambar menarik.
- Menirukan gerakan dan ekspresi wajah.
- Menangis dengan pola berbeda sesuai kebutuhan.
- Menunjukkan rasa senang atau sedih.
- Merespons ungkapan kasih sayang.
- Menyukai permainan dengan orang lain.

**Stimulasi**

- Menggendong bayi tegak menghadap ke depan untuk melatih kontrol kepala.
- Membantu bayi belajar duduk dengan sandaran.
- Melatih menyangga berat badan dengan menyentuhkan kaki ke permukaan.
- Membantu bayi memegang benda pada kedua tangan.
- Melatih mengambil dan mengamati benda kecil.
- Meletakkan mainan sedikit di luar jangkauan dan membantu bayi meraihnya.
- Mengarahkan bayi ke sumber suara.
- Menirukan suara bayi dan mengulanginya.
- Memberi rasa aman melalui kontak mata, senyum, pelukan, dan percakapan.
- Menjaga rutinitas tidur dan makan.
- Memahami apa yang disukai atau tidak disukai bayi.
- Bermain cilukba dan mengajak bayi melihat dirinya di cermin.

**Red flags — umur 4 bulan**

- Tidak dapat menahan kepala dengan stabil.
- Tidak mampu menggerakkan tangan ke bagian tengah tubuh.
- Kaki tidak menendang ketika diletakkan pada permukaan keras.
- Tidak merespons suara keras.
- Pandangan tidak mengikuti arah gerak benda.
- Jarang menatap wajah atau kurangnya fiksasi mata.
- Tidak tersenyum kepada orang di sekitarnya.

### 6.3. Umur 6–8 bulan

**Tahapan perkembangan**

Gerak kasar:
- Duduk dengan kedua tangan menopang tubuh.
- Berguling ke dua arah.
- Merangkak meraih mainan atau mendekati seseorang.
- Belajar berdiri dengan kedua kaki menopang sebagian berat badan.

Gerak halus dan adaptif:
- Memindahkan benda dari satu tangan ke tangan lainnya.
- Memegang satu benda pada masing-masing tangan.
- Memungut benda sebesar kacang dengan gerakan meraup.
- Memasukkan makanan ke mulut.
- Mencari benda yang dijatuhkan.

Bicara dan bahasa:
- Mengoceh seperti “Mamama”, “Bababa”, atau “Dadada”.
- Menggabungkan vokal dan bergantian membuat suara dengan orang tua.
- Mengucapkan bunyi konsonan.
- Merespons ketika nama dipanggil.

Sosialisasi dan kemandirian:
- Makan kue sendiri.
- Bermain tepuk tangan atau cilukba.
- Menunjukkan rasa ingin tahu.
- Mengenali wajah yang familiar.
- Merespons emosi orang lain.
- Senang melihat diri sendiri di cermin.

**Stimulasi**

- Memberi pelukan, senyuman, mengajak bicara, dan memanggil nama.
- Meletakkan mainan di luar jangkauan untuk mendorong merangkak.
- Melatih bayi menuju posisi berdiri dan berjalan berpegangan.
- Melatih perpindahan benda antar tangan.
- Menyediakan alat tulis dan kertas untuk mencoret-coret.
- Mengajari memasukkan benda ke wadah.
- Menyembunyikan mainan dan menunjukkan cara menemukannya.
- Mengajari menghasilkan bunyi dari mainan.
- Mengulang suara bayi dan kata sederhana.
- Membacakan buku dengan gambar berwarna.
- Membaca suasana hati bayi.
- Mengajarkan sebab-akibat.
- Melatih permainan sosial, lambaian, tepuk tangan, dan perintah sederhana.

**Red flags — umur 6 bulan**

- Tidak dapat memindahkan benda dari satu tangan ke tangan lain.
- Kesulitan membawa benda ke arah mulut.
- Tampak sangat lemah seperti boneka kain.
- Tidak dapat berguling ke arah mana pun.
- Tampak sangat kaku atau otot tegang.
- Tidak merespons suara di sekitarnya.
- Tidak tertarik atau tidak mencoba meraih benda di sekitarnya.
- Tidak mengeluarkan suara vokal.
- Tidak tertawa atau memekik.
- Tidak tersenyum, tertawa, atau menunjukkan ekspresi wajah.
- Tidak menunjukkan ketertarikan atau rasa kasih sayang kepada pengasuh.

### 6.4. Umur 9–11 bulan

**Tahapan perkembangan**

Gerak kasar:
- Duduk sendiri dari posisi berbaring.
- Merangkak.
- Mengangkat badan untuk berdiri.
- Berdiri 30 detik atau berpegangan pada kursi.
- Berjalan dengan dituntun.

Gerak halus dan adaptif:
- Mengulurkan lengan atau badan untuk meraih mainan.
- Menggenggam pensil.
- Memindahkan benda antar tangan.
- Mengambil benda kecil dengan ibu jari dan telunjuk.
- Membenturkan dua benda.
- Mencari benda yang disembunyikan.

Bicara dan bahasa:
- Menirukan suara, kata, suku kata, atau gerak orang lain.
- Menyebut suku kata berulang tanpa arti.
- Menyebut satu kata bermakna.
- Bereaksi terhadap suara perlahan atau bisikan.
- Memberi respons anggukan atau gelengan kepala.

Sosialisasi dan kemandirian:
- Mengeksplorasi lingkungan.
- Mengenali keluarga dan takut pada orang asing.
- Memiliki mainan favorit.
- Memahami makna kata “tidak”.
- Menunjuk sesuatu.

**Stimulasi**

- Menyediakan tempat bermain yang cukup luas dan aman.
- Melatih duduk, merangkak, berdiri berpegangan, dan memegang mainan.
- Melatih memasukkan benda kecil ke wadah dan menyusun balok.
- Mengajak mencoret-coret.
- Melatih mencari dan mengambil mainan.
- Mendeskripsikan benda atau kegiatan yang dilihat anak.
- Mengajak bicara dan melatih peniruan kata.
- Membacakan buku, menunjukkan gambar, dan meminta anak menunjuk gambar.
- Bermain dengan boneka serta bernyanyi.
- Memberikan kesempatan bermain dengan teman.
- Mengajak bayi bergiliran, berlatih sebab-akibat, cilukba, dan petak umpet.
- Melatih salam dan lambaian ketika anggota keluarga pergi.

**Red flags — umur 9 bulan**

- Tidak mampu duduk dengan bantuan dan jarang berguling.
- Tidak dapat menyangga berat badan dengan kedua kaki.
- Tidak dapat melakukan permainan bolak-balik.
- Tidak dapat memindahkan mainan antar tangan.
- Jarang mengoceh dengan konsonan atau tidak mengoceh “Mama”, “Baba”, atau “Dada”.
- Tidak merespons ketika nama dipanggil dan tidak melihat ke arah yang ditunjuk.
- Tidak mengenali orang familiar.
- Tidak ada interaksi timbal balik saat diajak tersenyum atau bicara.

### 6.5. Umur 12–17 bulan

**Tahapan perkembangan**

Gerak kasar:
- Berdiri sendiri.
- Membungkuk mengambil mainan lalu berdiri.
- Berjalan dengan baik.

Gerak halus dan adaptif:
- Menumpuk dua kubus.
- Memasukkan benda ke wadah dan mengeluarkannya.
- Mengeksplorasi benda dengan menggoyang, membentur, atau melempar.
- Memegang krayon dan mencoret-coret.
- Menemukan benda tersembunyi.
- Menggunakan benda sesuai kegunaannya.

Bicara dan bahasa:
- Memanggil orang tua dengan “mama” atau “papa”.
- Menyebutkan 1–6 kata bermakna.
- Mencoba mengucapkan kata yang didengar.
- Merespons perintah lisan sederhana.
- Melakukan gerakan sederhana seperti menggeleng atau dadah.

Sosialisasi dan kemandirian:
- Menunjuk keinginan tanpa menangis atau merengek.
- Mengulang suara atau tindakan untuk menarik perhatian.
- Menunjukkan rasa takut, malu, atau gugup.
- Menangis ketika orang tua pergi.
- Memiliki mainan atau orang favorit.
- Menggunakan bahasa tubuh untuk menyampaikan keinginan.

**Stimulasi**

- Melatih berjalan mundur, membungkuk mengambil benda, naik dan turun tangga.
- Bermain puzzle, merangkai manik besar, menangkap dan melempar bola.
- Melatih menyusun balok dan memasukkan atau mengeluarkan benda.
- Memberi krayon dan kertas.
- Menyembunyikan mainan dan mendorong anak menemukannya.
- Mengajak bermain bunyi atau alat musik, mengenal bagian tubuh, dan menyanyikan lagu dengan gerakan.
- Memberi kesempatan bermain dengan teman.
- Menarasikan kegiatan, membacakan buku cerita, dan menanggapi perilaku anak.
- Melatih meniru pekerjaan rumah tangga, melepas pakaian, makan sendiri, dan merapikan mainan.
- Mengajarkan permainan pura-pura.
- Memberi waktu beradaptasi dengan pengasuh baru.
- Mendorong perilaku yang diinginkan lebih sering daripada menghukum perilaku yang tidak diinginkan.

**Red flags**

Umur 12 bulan:
- Tidak dapat berdiri atau menyangga berat badan dengan kedua kaki.
- Tidak merespons nama.
- Tidak memahami kata “tidak”.
- Tidak mencari benda yang diketahui disembunyikan.
- Tidak mengucapkan satu kata seperti “Mama” atau “Dada”.
- Tidak dapat menunjuk benda.
- Acuh tak acuh atau menolak kedekatan dengan pengasuh.

Umur 15 bulan:
- Tidak dapat memegang pensil.
- Tidak dapat menunjuk benda yang diinginkan.

### 6.6. Umur 18–23 bulan

**Tahapan perkembangan**

Gerak kasar:
- Berjalan mundur lima langkah.
- Naik tangga dengan pegangan.
- Berlari.

Gerak halus dan adaptif:
- Menumpuk empat kubus.
- Mencoret-coret.
- Menggelindingkan bola ke arah sasaran.

Bicara dan bahasa:
- Menyebut 7–20 kata bermakna.
- Menunjuk untuk menyampaikan keinginan.
- Mengatakan “tidak”.
- Menunjuk satu bagian tubuh.
- Mengikuti satu perintah lisan tanpa bantuan gerak.

Sosialisasi dan kemandirian:
- Melepas pakaian dengan bantuan.
- Meniru pekerjaan rumah tangga.
- Memegang cangkir, belajar makan dan minum sendiri.
- Mengajak orang lain bermain.
- Menunjukkan takut pada orang asing dan sayang pada orang dikenal.
- Bermain peran sederhana.
- Menunjuk hal menarik.
- Mengeksplorasi lingkungan dengan orang tua tetap dekat.
- Mengenali jenis kelamin diri sendiri.

**Stimulasi**

- Menyediakan ruang aman untuk berjalan dan bergerak.
- Memberikan mainan dorong-tarik yang aman.
- Menciptakan lingkungan penuh kasih sayang dan dapat diprediksi.
- Melatih keseimbangan, berjalan, berlari, melompat, naik-turun tangga, melempar, menangkap, dan menendang bola.
- Mengenalkan ukuran, bentuk, puzzle, gambar wajah, dan bentuk.
- Melatih berpakaian, makan, minum, dan merapikan mainan.
- Melatih mencari benda tersembunyi.
- Mengajak bernyanyi dan menirukan kata.
- Menggunakan frasa sederhana dan jelas untuk berbicara tentang emosi.
- Memberikan pertanyaan sederhana, latihan instruksi, serta permainan bergiliran.
- Mengajarkan konsep jenis kelamin dan mengenali emosi.
- Memuji perilaku baik serta mengajarkan empati melalui permainan dan cerita.

**Red flags — umur 18 bulan**

- Tidak dapat berjalan tanpa bantuan.
- Tidak mampu menyebut minimal enam kata.
- Tidak mampu meniru tindakan atau perkataan.
- Tidak peduli ketika pengasuh datang atau pergi.
- Tidak dapat menunjuk benda untuk menunjukkan sesuatu kepada orang lain.
- Tidak mengetahui fungsi benda familiar.

### 6.7. Umur 24–35 bulan

**Tahapan perkembangan**

Gerak kasar:
- Berjalan naik tangga sendiri dan berlari.
- Bermain dan menendang bola kecil.

Gerak halus dan adaptif:
- Membuat garis lurus dan menumpuk empat kubus atau lebih.
- Menemukan benda yang disembunyikan di antara dua atau tiga lapisan penutup.

Bicara dan bahasa:
- Membuat kalimat dua sampai empat kata.
- Mengulangi kata-kata yang didengar.
- Mengetahui nama orang yang dikenal.
- Menunjuk 3–6 bagian tubuh atau lebih.
- Menunjuk empat gambar atau benda yang namanya disebut.
- Menyebut benda dalam gambar.
- Mulai mengenali bentuk dan warna.
- Mengikuti perintah dua langkah.
- Melengkapi kalimat dari cerita atau lagu yang familiar.

Sosialisasi dan kemandirian:
- Menunjukkan kemandirian lebih besar.
- Makan sendiri dengan sedikit tumpah.
- Menirukan orang lain.
- Bersemangat bermain bersama anak lain.
- Menunjukkan perilaku menentang.
- Bermain pura-pura sederhana.

**Stimulasi**

- Mendorong memanjat, berlari, melompat, merayap, latihan keseimbangan, bola, dan rintangan.
- Membuat gambar tempelan, proyek seni, dan mencocokkan gambar dengan benda asli.
- Mengelompokkan benda serta mengenal jumlah.
- Membantu membuka pintu atau laci, membalik halaman buku, dan membawa benda kecil.
- Mengajak bicara menggunakan dua kata yang jelas.
- Membacakan cerita dan menanyakan apa, di mana, mengapa, siapa, dan bagaimana.
- Mendorong anak bercerita tentang yang dilihat.
- Mendampingi ketika menonton TV atau bermain gawai.
- Mengajari menyebut nama lengkap, bagian tubuh, hewan, pakaian, serta sifat dan kegunaan benda.
- Menceritakan kembali kejadian yang menarik.
- Melatih buang air di kamar mandi, berpakaian, menjaga diri, mencuci tangan, makan, dan merapikan mainan.
- Memberikan perhatian dan pujian saat anak mengikuti instruksi.
- Menenangkan anak saat kecewa dengan memeluk dan berbicara.

**Red flags — umur 24 bulan**

- Tidak dapat berjalan stabil.
- Tidak mampu mengatakan kalimat dua kata.
- Tidak mampu mengikuti perintah sederhana.
- Tidak dapat meniru tindakan atau kata.
- Kontak mata minimal.

### 6.8. Umur 36–47 bulan

**Tahapan perkembangan**

Gerak kasar:
- Berdiri satu kaki selama dua detik.
- Melakukan lompatan lebar minimal 20 cm.
- Naik turun tangga dengan satu kaki pada setiap anak tangga tanpa berpegangan.

Gerak halus dan adaptif:
- Menumpuk delapan kubus.
- Menyusun puzzle 3–4 bagian.
- Menggambar lingkaran dengan contoh atau mandiri.
- Menggambar orang dengan tiga bagian.

Bicara dan bahasa:
- Pembicaraan dapat dimengerti orang lain.
- Melakukan percakapan dua hingga tiga kalimat.
- Menyebut nama, umur, tempat, nama teman, dan benda familiar.
- Mengenal 2–4 warna.
- Memahami kata depan sederhana dan konsep dua.
- Mendengarkan cerita serta mengikuti perintah tiga langkah atau lebih.

Sosialisasi dan kemandirian:
- Mencuci dan mengeringkan tangan.
- Memakai dan melepas pakaian sendiri.
- Bermain dengan teman dan mengikuti aturan.
- Bermain pura-pura.
- Memahami konsep milik sendiri dan milik orang lain.
- Menunjukkan berbagai emosi.
- Berpisah dengan mudah dari orang tua.
- Mengenal bagian tubuh pribadi yang tidak boleh disentuh orang lain.

**Stimulasi**

- Melatih melompat satu kaki bergantian dan berjalan di garis lurus.
- Melatih melempar dan menangkap bola.
- Menirukan gerak-gerik hewan.
- Melatih menggambar, menulis nama, menggunakan gunting, menempel, berhitung, mengenali huruf, dan mencampur warna.
- Membacakan cerita setiap hari dan meminta anak menunjuk gambar serta menirukan kata.
- Menjawab pertanyaan dengan kata sederhana dan mendorong anak bercerita tentang dirinya.
- Melatih mengikuti instruksi 2–3 langkah.
- Mengajarkan keselamatan tubuh serta area pribadi sesuai panduan sumber.
- Melatih mencuci tangan dan kaki, makan dengan peralatan, serta keterampilan mandiri.
- Mengajak anak berada di lingkungan sosial dengan anak lain.
- Membantu anak menyelesaikan masalah dan mengenali emosi.

**Red flags — umur 36 bulan**

- Sering jatuh atau kesulitan menaiki tangga.
- Tidak mampu mengucapkan kalimat tiga kata.
- Sering berliur atau ucapannya sangat tidak jelas.
- Jarang bermain peran atau pura-pura.
- Tidak ingin bermain dengan mainan atau anak lain.
- Tidak memahami instruksi sederhana.
- Tidak dapat berbicara dalam kalimat.

### 6.9. Umur 48–59 bulan

**Tahapan perkembangan**

Gerak kasar:
- Berdiri satu kaki enam detik.
- Melompat dan berdiri satu kaki hingga dua detik.
- Menari dan menangkap bola yang dipantulkan.

Gerak halus dan adaptif:
- Menggambar tanda tambah dan lingkaran.
- Menggambar orang dengan 4–6 bagian tubuh.
- Mengancing baju.
- Membandingkan ukuran dan bentuk.
- Mengingat bagian cerita serta memahami konsep waktu.
- Menghitung jari dan memahami konsep berhitung.

Bicara dan bahasa:
- Berbicara dengan mudah dimengerti.
- Bernyanyi dan bercerita.
- Menyebut nama lengkap tanpa bantuan.
- Menyebut angka, warna, dan nama hari.
- Menyebut kata baru dan bertanya.
- Menjawab pertanyaan dengan kata yang benar.
- Memberi tahu apa yang diperkirakan terjadi berikutnya pada cerita.

Sosialisasi dan kemandirian:
- Berpakaian dan menggosok gigi tanpa bantuan.
- Bereaksi lebih tenang saat ditinggal orang tua.
- Bermain peran sebagai orang dewasa.
- Bermain lebih kooperatif bersama teman.
- Mengungkapkan kesukaan dan minat.

**Stimulasi**

- Bermain aktivitas motorik seperti balap karung, engklek, lompat tali, menari, dan puzzle.
- Melatih menggambar, menggunting, dan menempel.
- Mengenalkan angka, konsep berhitung, perbandingan ukuran, bentuk, dan warna.
- Berkebun dan berbicara tentang pertumbuhan tanaman, hewan, dan anak.
- Mengenalkan nama hari, huruf, dan simbol.
- Melatih melengkapi kalimat.
- Membacakan cerita dan menjawab pertanyaan “mengapa”.
- Menggunakan bahasa yang baik.
- Mendampingi anak ketika menggunakan TV atau gawai; batas waktu dalam sumber adalah maksimal satu jam per hari.
- Menggunakan mainan untuk merangsang imajinasi dan bermain peran.
- Melatih aktivitas rumah tangga serta pembicaraan tentang perasaan.
- Melatih kemandirian dan kepercayaan diri.
- Memberikan pilihan sederhana kepada anak.

**Red flags — umur 48 bulan**

- Tidak dapat melompat di tempat.
- Mengalami kesulitan menggambar orang.
- Bicara tidak jelas dan tidak mampu menjawab pertanyaan sederhana.
- Tidak menghiraukan anak lain atau tidak merespons orang selain keluarga.
- Tidak menunjukkan ketertarikan pada permainan interaktif atau pura-pura.

Catatan untuk penerapan: sumber memuat anjuran mengunjungi tetangga dekat tanpa ditemani orang tua sebagai latihan kemandirian. Jangan langsung menyajikannya sebagai instruksi praktik kepada keluarga tanpa pemeriksaan dan persetujuan UPTD.

### 6.10. Umur 60–72 bulan

**Tahapan perkembangan**

Gerak kasar:
- Berdiri satu kaki selama 11 detik atau lebih.
- Melompat jauh dan melompat dengan satu kaki.

Gerak halus dan adaptif:
- Menangkap bola kecil dengan kedua tangan.
- Menggambar orang dengan enam bagian tubuh.
- Menggambar bentuk geometris.
- Menulis beberapa angka dan huruf.
- Mengenal angka dan menghitung 5–10 benda.

Bicara dan bahasa:
- Berbicara dengan jelas.
- Menyebut nama lengkap dan alamat.
- Menjelaskan bahan dan kegunaan benda.
- Menceritakan cerita sederhana menggunakan kalimat lengkap.
- Memahami lawan kata dan semua warna.

Sosialisasi dan kemandirian:
- Mengungkapkan simpati dan lebih mandiri.
- Mengikuti aturan permainan.
- Memahami konsep jenis kelamin.
- Menyukai bernyanyi, menari, dan bermain peran.
- Kadang menuntut, tetapi juga mampu bekerja sama.

**Stimulasi**

- Lanjutkan stimulasi umur 48–59 bulan.
- Mengajak anak berjalan-jalan serta bermain berburu dan halang rintang.
- Mendorong menggambar dan proyek seni menggunakan berbagai bahan.
- Membacakan buku dan meminta anak menceritakan atau memprediksi kelanjutan cerita.
- Membahas perasaan anak dan melibatkan anak dalam kegiatan keluarga.
- Mendampingi penggunaan TV/gawai, dengan batas waktu dalam sumber maksimal satu jam per hari.
- Mengajarkan urutan kegiatan, konsep waktu, hari, minggu, bulan, dan uang.
- Mengobrol setiap hari.
- Melatih kepatuhan terhadap aturan keluarga dan penerimaan terhadap jawaban “tidak”.
- Mengajarkan sentuhan aman dan area pribadi.
- Mengajarkan alamat rumah dan nomor telepon.
- Mengeksplorasi minat anak.

**Red flags**

Umur 60 bulan:
- Tidak dapat membuat gambar, bentuk, atau garis.
- Keseimbangan tubuh buruk.
- Tidak mampu memahami bentuk, huruf, dan warna.
- Tidak dapat menyebutkan namanya sendiri.
- Tidak menunjukkan berbagai macam emosi.
- Tidak dapat membedakan kenyataan dan pura-pura.

Umur 72 bulan:
- Tidak dapat melompat dengan satu kaki.
- Tidak dapat menuliskan nama.
- Tidak dapat menceritakan kembali atau merangkum cerita secara runtut dari awal sampai akhir.
- Tidak mengetahui nama teman dan tidak mengenali perasaan orang lain.

---

## 7. Hubungan jawaban KPSP, domain perkembangan, stimulasi, dan red flags

Sistem harus membedakan empat objek berikut.

**A. Jawaban instrumen KPSP**

Merupakan jawaban Ya/Tidak pada 10 butir formulir yang dipilih.

**B. Hasil scoring KPSP**

Merupakan total jawaban Ya dan kategori keseluruhan KPSP.

**C. Tahapan perkembangan dan stimulasi**

Merupakan referensi perkembangan sesuai kelompok umur pada Buku Bagan. Informasi ini dipakai untuk edukasi, bukan skor tambahan.

**D. Red flags perkembangan**

Merupakan tanda perkembangan yang perlu diperhatikan pada kelompok umur tertentu. Red flags bukan daftar tambahan butir KPSP dan bukan penjumlahan skor.

Jangan menghitung nilai KPSP dari jumlah red flags. Jangan menetapkan diagnosis atau menyimpulkan gangguan berdasarkan satu red flag.

Jika hasil KPSP menunjukkan butir Tidak pada domain tertentu, sistem boleh membantu menyoroti domain tersebut untuk ditinjau petugas. Namun, jangan mengklaim bahwa sumber menyediakan pemetaan satu-ke-satu antara setiap pertanyaan KPSP dan semua stimulasi pada tabel umur jika pemetaan tersebut tidak tercantum.

Jika stimulasi dalam sumber tidak dapat dihubungkan secara spesifik dengan satu butir, tampilkan set stimulasi sesuai kelompok umur dan jelaskan bahwa itu referensi stimulasi umum.

Red flags harus ditampilkan sebagai referensi yang terpisah. Jika suatu red flag sesuai umur anak, tampilkan penanda perhatian kepada tenaga kesehatan. Jangan mengubah kategori KPSP secara otomatis hanya karena red flag ditandai.

---

## 8. Struktur data yang direkomendasikan

Audit skema proyek sebelum menetapkan nama tabel final.

### A. Katalog formulir KPSP

Pertimbangkan katalog versi formulir yang berisi:

- umur formulir;
- versi instrumen;
- status aktif;
- sumber dan halaman.

### B. Butir pertanyaan

Setiap item mencakup:

- identitas formulir;
- nomor pertanyaan;
- teks pertanyaan;
- instruksi pemeriksaan;
- alat/bahan yang diperlukan;
- kriteria Ya;
- domain perkembangan;
- rujukan halaman sumber.

### C. Referensi perkembangan

Simpan atau kelola sebagai konfigurasi berversi:

- kelompok umur minimum dan maksimum;
- domain;
- tahapan perkembangan;
- stimulasi;
- red flags;
- sumber dan halaman.

Pilih antara konfigurasi terstruktur dan tabel katalog berdasarkan pola proyek aktual. Jangan menduplikasi isi sumber di controller, scorer, dan Vue.

### D. Hasil KPSP

Pertahankan tabel `spk.kpsp_screenings` dalam rancangan integrasi.

Hasil minimal meliputi:

- `screening_session_id`;
- `form_age_months`;
- jawaban 10 item;
- skor total;
- kategori;
- rekomendasi;
- versi instrumen dan aturan skoring;
- waktu pencatatan.

Jika skema hasil yang tersedia sudah mendukung sebagian besar kebutuhan, buat perubahan minimal dan pertahankan histori yang sudah ada.

### E. Versi dan histori

Setiap hasil pemeriksaan harus mengacu pada versi form dan aturan yang digunakan. Perubahan teks atau algoritme di masa depan tidak boleh membuat hasil lama ditafsirkan ulang secara diam-diam.

---

## 9. Desain halaman KPSP

Halaman KPSP harus mengikuti desain referensi aplikasi: identitas pasien di bagian atas, formulir yang terstruktur, indikator progres, dan hasil pada ringkasan sesi.

### A. Sebelum pemeriksaan

Tampilkan:

- identitas pasien;
- tanggal pemeriksaan;
- umur hasil penghitungan;
- umur setelah koreksi jika berlaku;
- umur formulir yang dipilih;
- alasan memilih formulir tersebut;
- jumlah pertanyaan: 10;
- instruksi dan kebutuhan alat.

### B. Selama pemeriksaan

Untuk setiap item:

- tampilkan nomor dan teks asli;
- tampilkan instruksi lengkap;
- tampilkan stimulus visual atau daftar alat bila dibutuhkan;
- sediakan Ya dan Tidak;
- simpan progres secara aman;
- jangan menghitung kategori final sebelum seluruh item lengkap.

### C. Setelah pemeriksaan

Tampilkan:

- skor Ya dari 10;
- kategori KPSP;
- domain dengan butir yang dijawab Tidak;
- stimulasi sesuai umur;
- red flags perkembangan sesuai kelompok umur;
- tindak lanjut sumber sesuai kategori;
- penjelasan bahwa KPSP merupakan skrining, bukan diagnosis.

Tampilan hasil pada halaman internal hanya dapat diakses tenaga kesehatan yang berwenang.

---

## 10. Pengujian wajib KPSP

### A. Kalkulasi umur

Pertahankan atau lengkapi tes untuk:

- penghitungan hari, bulan, dan tahun;
- peminjaman 30 hari dan 12 bulan;
- prematuritas;
- koreksi hanya pada kondisi umur yang ditentukan sumber;
- batas sisa hari 16 dan 17;
- pemilihan formulir tepat;
- pemilihan formulir lebih muda ketika tidak ada umur yang tepat;
- umur di bawah 3 bulan dan di atas 72 bulan.

### B. Scorer

Uji:

- tepat 10 jawaban;
- jawaban harus boolean atau bentuk data yang secara eksplisit dikonversi oleh controller;
- seluruh jawaban wajib terisi;
- skor 0, 6, 7, 8, 9, dan 10;
- kategori yang sesuai pada setiap batas;
- tidak ada penghitungan ulang dari data frontend;
- jawaban mentah tersimpan persis sesuai pilihan pemeriksaan.

### C. Isi formulir

Pastikan:

- seluruh 16 formulir tersedia;
- setiap formulir memiliki tepat 10 butir;
- teks dan kriteria jawaban cocok dengan PDF;
- urutan pertanyaan dipertahankan;
- domain dan instruksi setiap pertanyaan benar;
- gambar yang diperlukan tersedia;
- tidak ada pertanyaan yang tertukar antar umur.

### D. Stimulasi dan red flags

Uji bahwa:

- kelompok umur dipilih dengan aturan yang terdefinisi;
- stimulasi sesuai kelompok umur;
- red flags sesuai kelompok umur;
- tidak ada instrumen TDD yang dibuat atau ditampilkan;
- red flags tidak otomatis mengubah skor KPSP;
- hasil KPSP dan referensi perkembangan tetap bisa ditinjau secara terpisah.

### E. Integrasi sesi

Uji bahwa:

- perawat dapat melakukan KPSP pada sesi yang menjadi tanggung jawabnya;
- dokter dapat melihat hasil sesuai kewenangan;
- hasil tersimpan pada skema `spk`;
- data KPSP atau data master dari skema `public` tidak diubah secara tidak sengaja;
- sesi tidak dinyatakan lengkap jika instrumen masih memiliki jawaban kosong;
- penyimpanan hasil menggunakan transaksi database.

---

## 11. Ketentuan implementasi

- Pertahankan `KpspAgeCalculator`, `KpspScorer`, dan `RuleBasedScoringService` jika secara teknis masih sesuai.
- Jangan memindahkan logika scoring ke Vue.
- Jangan membuat formulir dengan daftar pertanyaan generik berdasarkan umur.
- Jangan membuat threshold kategori baru.
- Jangan menghubungkan setiap red flag dengan satu pertanyaan secara otomatis tanpa dasar sumber.
- Jangan menghapus model atau tes KPSP yang sudah tersedia.
- Jangan membangun atau menyertakan TDD.
- Jangan memigrasikan data KPSP historis secara destruktif.
- Jangan menjalankan migrasi terhadap database layanan sebelum pengujian staging dan validasi skema selesai.

Mulai dengan audit seluruh 16 formulir, service umur, scorer, dan tes yang sudah tersedia. Setelah hasil audit disajikan, implementasikan katalog formulir, aturan umur, scoring, dan referensi perkembangan dalam tahap yang terpisah serta dapat diuji.