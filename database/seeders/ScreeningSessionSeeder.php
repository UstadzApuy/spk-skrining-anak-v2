<?php

namespace Database\Seeders;

use App\Models\Doctor;
use App\Models\Nurse;
use App\Models\Patient;
use App\Models\ScreeningSession;
use Carbon\CarbonImmutable;
use Illuminate\Database\Seeder;

class ScreeningSessionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $nurse = Nurse::whereHas('user', function ($query) {
            $query->where('email', 'perawat@spk.test');
        })->firstOrFail();

        $doctor = Doctor::whereHas('user', function ($query) {
            $query->where('email', 'dokter@spk.test');
        })->firstOrFail();

        $patientOne = Patient::where(
            'medical_record_number',
            'RM-TEST-001'
        )->firstOrFail();

        $patientTwo = Patient::where(
            'medical_record_number',
            'RM-TEST-002'
        )->firstOrFail();

        $screeningDate = CarbonImmutable::create(2026, 9, 25);

        ScreeningSession::updateOrCreate(
            [
                'patient_id' => $patientOne->id,
                'screening_date' => $screeningDate->toDateString(),
            ],
            [
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'age_months' => $patientOne->birth_date->diffInMonths($screeningDate),
                'status' => 'in_progress',
                'notes' => 'Data development untuk pengujian alur pemeriksaan.',
                'doctor_notes' => null,
                'reviewed_at' => null,
            ]
        );

        ScreeningSession::updateOrCreate(
            [
                'patient_id' => $patientTwo->id,
                'screening_date' => $screeningDate->toDateString(),
            ],
            [
                'nurse_id' => $nurse->id,
                'doctor_id' => null,
                'age_months' => $patientTwo->birth_date->diffInMonths($screeningDate),
                'status' => 'draft',
                'notes' => 'Data development untuk pengujian sesi pemeriksaan.',
                'doctor_notes' => null,
                'reviewed_at' => null,
            ]
        );
    }
}