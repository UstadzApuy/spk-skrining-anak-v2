<?php

namespace Database\Seeders;

use App\Models\GpphScreening;
use App\Models\KpspScreening;
use App\Models\MchatScreening;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\ScreeningInterpretation;
use App\Models\ScreeningSession;
use App\Models\ScreeningSessionInstrument;
use App\Models\SdqScreening;
use App\Models\SrqScreening;
use Carbon\CarbonImmutable;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PatientSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Membersihkan seluruh data pasien dan sesi lama, lalu membuat list pasien
     * bertahap usia (pasien++) yang mencakup seluruh rentang usia Rentang Umur.pdf.
     */
    public function run(): void
    {
        $parentGuardian = ParentGuardian::whereHas('user', function ($query) {
            $query->where('email', 'orangtua@spk.test');
        })->firstOrFail();

        $today = CarbonImmutable::today();

        // 1. Bersihkan seluruh sesi skrining dan data pasien lama
        DB::transaction(function () {
            ScreeningInterpretation::query()->delete();
            KpspScreening::query()->delete();
            MchatScreening::query()->delete();
            GpphScreening::query()->delete();
            SdqScreening::query()->delete();
            SrqScreening::query()->delete();
            ScreeningSessionInstrument::query()->delete();
            ScreeningSession::query()->delete();
            Patient::query()->delete();
        });

        // 2. Daftar pasien bertahap usia (pasien++) mencakup seluruh rentang usia Rentang Umur.pdf
        //    (3 bln, 6 bln, 9 bln, 12 bln, 18 bln, 24 bln, 30 bln, 36 bln, 48 bln, 60 bln, 72 bln, 84 bln, 120 bln)
        $patientsData = [
            [
                'medical_record_number' => 'RM-RU-001',
                'name' => 'Bayi Arka Pratama (Usia 3 Bulan)',
                'birth_date' => $today->subMonths(3)->toDateString(),
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-002',
                'name' => 'Bayi Bianca Putri (Usia 6 Bulan)',
                'birth_date' => $today->subMonths(6)->toDateString(),
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-003',
                'name' => 'Bayi Cakra Baskara (Usia 9 Bulan)',
                'birth_date' => $today->subMonths(9)->toDateString(),
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-004',
                'name' => 'Bayi Dinda Kirana (Usia 12 Bulan / 1 Th)',
                'birth_date' => $today->subMonths(12)->toDateString(),
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-005',
                'name' => 'Batita Elang Mahendra (Usia 18 Bulan)',
                'birth_date' => $today->subMonths(18)->toDateString(),
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-006',
                'name' => 'Batita Farah Sabrina (Usia 24 Bulan / 2 Th)',
                'birth_date' => $today->subMonths(24)->toDateString(),
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-007',
                'name' => 'Batita Gilang Ramadhan (Usia 30 Bulan)',
                'birth_date' => $today->subMonths(30)->toDateString(),
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-008',
                'name' => 'Balita Hana Safira (Usia 36 Bulan / 3 Th)',
                'birth_date' => $today->subMonths(36)->toDateString(),
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-009',
                'name' => 'Anak Irfan Syahputra (Usia 48 Bulan / 4 Th)',
                'birth_date' => $today->subMonths(48)->toDateString(),
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-010',
                'name' => 'Anak Jessica Olivia (Usia 60 Bulan / 5 Th)',
                'birth_date' => $today->subMonths(60)->toDateString(),
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-011',
                'name' => 'Anak Kevin Sanjaya (Usia 72 Bulan / 6 Th)',
                'birth_date' => $today->subMonths(72)->toDateString(),
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-012',
                'name' => 'Anak Larasati Dewanti (Usia 7 Tahun / 84 Bln)',
                'birth_date' => $today->subMonths(84)->toDateString(),
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
            [
                'medical_record_number' => 'RM-RU-013',
                'name' => 'Anak Muhammad Rifqi (Usia 10 Tahun / 120 Bln)',
                'birth_date' => $today->subMonths(120)->toDateString(),
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ],
        ];

        foreach ($patientsData as $data) {
            Patient::create(array_merge($data, [
                'parent_guardian_id' => $parentGuardian->id,
                'is_active' => true,
            ]));
        }
    }
}