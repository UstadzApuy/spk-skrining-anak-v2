<?php

namespace Database\Factories;

use App\Models\Doctor;
use App\Models\Nurse;
use App\Models\Patient;
use App\Models\ScreeningSession;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ScreeningSession>
 */
class ScreeningSessionFactory extends Factory
{
    
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $patient = Patient::query()->inRandomOrder()->first();
        $nurse = Nurse::query()->first();

        if ($patient === null) {
            throw new \RuntimeException(
                'Patient belum tersedia. Jalankan PatientSeeder terlebih dahulu.'
            );
        }

        if ($nurse === null) {
            throw new \RuntimeException(
                'Nurse belum tersedia. Jalankan UserSeeder terlebih dahulu.'
            );
        }

        $screeningDate = now()->toDateString();
        $ageMonths = $patient->birth_date->diffInMonths($screeningDate);

        return [
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'doctor_id' => Doctor::query()->first()?->id,
            'screening_date' => $screeningDate,
            'age_months' => $ageMonths,
            'status' => 'draft',
            'notes' => null,
            'doctor_notes' => null,
            'reviewed_at' => null,
        ];
    }
}