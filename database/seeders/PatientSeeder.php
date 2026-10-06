<?php

namespace Database\Seeders;

use App\Models\ParentGuardian;
use App\Models\Patient;
use Illuminate\Database\Seeder;

class PatientSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $parentGuardian = ParentGuardian::whereHas('user', function ($query) {
            $query->where('email', 'orangtua@spk.test');
        })->firstOrFail();

        Patient::updateOrCreate(
            [
                'medical_record_number' => 'RM-TEST-001',
            ],
            [
                'parent_guardian_id' => $parentGuardian->id,
                'name' => 'Anak Uji Satu',
                'birth_date' => '2024-09-25',
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
                'is_active' => true,
            ]
        );

        Patient::updateOrCreate(
            [
                'medical_record_number' => 'RM-TEST-002',
            ],
            [
                'parent_guardian_id' => $parentGuardian->id,
                'name' => 'Anak Uji Dua',
                'birth_date' => '2025-01-25',
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => true,
                'gestational_age_weeks' => 32,
                'is_active' => true,
            ]
        );
    }
}