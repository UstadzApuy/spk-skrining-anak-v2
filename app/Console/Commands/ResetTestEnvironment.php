<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;

class ResetTestEnvironment extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'test:reset';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Reset database and application state to pristine checkpoint for user testing simulation';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $this->newLine();
        $this->line('<fg=cyan;options=bold>======================================================================</>');
        $this->line('<fg=cyan;options=bold>   CHECKPOINT RESET - SPK SKRINING TUMBUH KEMBANG ANAK (SDIDTK)      </>');
        $this->line('<fg=cyan;options=bold>   UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus (BLK-ABK)   </>');
        $this->line('<fg=cyan;options=bold>======================================================================</>');
        $this->newLine();

        $this->info('1/3 Menjalankan migrasi ulang dan database seeder bersih...');
        $exitCode = Artisan::call('migrate:fresh', [
            '--seed' => true,
            '--force' => true,
        ]);

        if ($exitCode !== 0) {
            $this->error('Gagal menjalankan migrasi & seeder.');
            $this->line(Artisan::output());
            return 1;
        }
        $this->line('    <fg=green>✓</> Database berhasil di-reset dan data uji bersih telah dimuat.');

        $this->info('2/3 Membersihkan cache aplikasi...');
        Artisan::call('cache:clear');
        Artisan::call('config:clear');
        Artisan::call('route:clear');
        Artisan::call('view:clear');
        $this->line('    <fg=green>✓</> Cache aplikasi, konfigurasi, dan rute berhasil dibersihkan.');

        $this->newLine();
        $this->info('3/3 Lingkungan pengujian siap! Berikut akun & skenario untuk peserta uji:');
        $this->newLine();

        $this->table(
            ['Role Pengguna', 'Email Akun', 'Password', 'Skenario Uji Blackbox & SUS'],
            [
                [
                    'Perawat (Screening)',
                    'perawat@spk.test',
                    'password',
                    'Input sesi skrining baru untuk Muhammad Zain Ageng Pangestu (RM-001) atau Adelio Vember (RM-005) evaluasi ulang KPSP 14 hari.',
                ],
                [
                    'Orang Tua (Parent)',
                    'orangtua@spk.test',
                    'password',
                    'Login mandiri, buka kuesioner SDQ & SRQ-20 untuk Chairil Rafqi Nababan (RM-002, 61 Bulan), isi seluruh pertanyaan, dan kirimkan.',
                ],
                [
                    'Dokter (Reviewer)',
                    'dokter@spk.test',
                    'password',
                    'Buka antrean review Rychi Yislam Gaza (RM-003, 25 Bulan), tinjau sintesis SPK, isi kesimpulan klinis & intervensi, finalisasi, dan cetak SDIDTK.',
                ],
            ]
        );

        $this->newLine();
        $this->line('<fg=cyan;options=bold>Daftar Pasien Target Pengujian (100% Data Asli UPTD BLK-ABK):</>');
        $this->table(
            ['No. Rekam Medis', 'Nama Anak', 'Usia', 'Jenis Kelamin', 'Kondisi Awal untuk Testing'],
            [
                ['RM-001', 'Muhammad Zain Ageng Pangestu', '86 Bulan (7.2 Th)', 'Laki-laki', 'Belum Ada Sesi Hari Ini (Siap dibuat Perawat)'],
                ['RM-002', 'Chairil Rafqi Nababan', '61 Bulan (5.1 Th)', 'Laki-laki', 'Sesi Aktif - SDQ & SRQ Menunggu Orang Tua'],
                ['RM-003', 'Rychi Yislam Gaza', '25 Bulan (2.1 Th)', 'Laki-laki', 'Sesi Menunggu Tinjauan Dokter (pending review)'],
                ['RM-004', 'Nausyad Ezzar A.', '81 Bulan (6.8 Th)', 'Laki-laki', 'Selesai Ditinjau Dokter (Histori & Rekapitulasi)'],
                ['RM-005', 'Adelio Vember', '37 Bulan (3.1 Th)', 'Laki-laki', 'Sesi Evaluasi Ulang KPSP 14 Hari (Tes Re-skrining Dm -> Rujuk RS)'],
            ]
        );

        $this->newLine();
        $this->line('<fg=yellow;options=bold>Petunjuk Penguji / Fasilitator:</>');
        $this->line('  • Setelah seorang responden/user selesai melakukan pengujian, jalankan perintah ini kembali:');
        $this->line('    <fg=white;options=bold>./reset-test.sh</>  atau  <fg=white;options=bold>docker exec -e HOME=/tmp spk-skrining-anak-v3-app php artisan test:reset</>');
        $this->line('  • Seluruh data sesi dan kuesioner baru akan kembali ke kondisi awal yang bersih untuk responden berikutnya.');
        $this->newLine();

        return 0;
    }
}

