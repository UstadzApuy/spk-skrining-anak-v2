<?php

namespace Database\Seeders;

use App\Models\GpphScreening;
use App\Models\KpspScreening;
use App\Models\MchatScreening;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningInterpretation;
use App\Models\ScreeningSession;
use App\Models\ScreeningSessionInstrument;
use App\Models\SdqScreening;
use App\Models\SrqScreening;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class PatientSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Membersihkan seluruh data sesi dan pasien lama, lalu menyiapkan:
     * 100% 176 anak riil UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus Balikpapan
     * dari register resmi bulan Oktober 2026 (tanpa data pasien dummy).
     */
    public function run(): void
    {
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

        // 2. Wali akun pengujian (orangtua@spk.test)
        $parentGuardian = ParentGuardian::whereHas('user', function ($query) {
            $query->where('email', 'orangtua@spk.test');
        })->firstOrFail();

        // 3. Wali umum untuk pasien UPTD lainnya agar dashboard orangtua@spk.test terfokus
        $parentRole = Role::where('name', 'orang_tua')->firstOrFail();
        $generalParentUser = User::firstOrCreate(
            ['email' => 'wali_uptd@spk.test'],
            [
                'name' => 'Wali Pasien UPTD',
                'role_id' => $parentRole->id,
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );

        $generalGuardian = ParentGuardian::firstOrCreate(
            ['user_id' => $generalParentUser->id],
            [
                'phone' => '081234567890',
                'address' => 'Balikpapan',
            ]
        );

        // 4. Muat dan masukkan 176 data anak riil dari file register UPTD BLK-ABK
        $jsonPath = database_path('seeders/uptd_october_data.json');
        if (file_exists($jsonPath)) {
            $uptdRecords = json_decode(file_get_contents($jsonPath), true);
            if (is_array($uptdRecords)) {
                foreach ($uptdRecords as $idx => $rec) {
                    $mrn = sprintf('RM-%03d', $idx + 1);
                    $birthDate = $rec['birth_date'] ?? $today->subMonths($rec['age_months'] ?? 36)->toDateString();

                    // Khusus RM-002 (Chairil Rafqi Nababan, 61 Bulan) dihubungkan ke orangtua@spk.test
                    // untuk alur pengujian kuesioner Orang Tua mandiri
                    $isTestParentChild = ($idx === 1);
                    $guardianId = $isTestParentChild ? $parentGuardian->id : $generalGuardian->id;

                    Patient::create([
                        'medical_record_number' => $mrn,
                        'name' => $rec['name'],
                        'birth_date' => $birthDate,
                        'gender' => $rec['gender'] ?? 'L',
                        'address' => $rec['address'] ?: 'Balikpapan',
                        'education' => $rec['education'] ?? 'tidak_sekolah',
                        'school_name' => $rec['school_name'] ?? null,
                        'guardian_relationship' => $isTestParentChild ? 'Ibu' : 'Orang Tua',
                        'is_premature' => false,
                        'gestational_age_weeks' => null,
                        'parent_guardian_id' => $guardianId,
                        'is_active' => true,
                    ]);
                }
            }
        }
    }
}
