<?php

namespace Database\Factories;

use App\Models\ParentGuardian;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Patient>
 */
class PatientFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $parentGuardianId = ParentGuardian::query()->value('id');

        if ($parentGuardianId === null) {
            throw new \RuntimeException(
                'ParentGuardian belum tersedia. Jalankan UserSeeder terlebih dahulu.'
            );
        }

        return [
            'parent_guardian_id' => $parentGuardianId,
            'medical_record_number' => fake()->unique()->numerify('RM-######'),
            'name' => fake()->name(),
            'birth_date' => fake()->dateTimeBetween('-10 years', '-1 month')->format('Y-m-d'),
            'gender' => fake()->randomElement(['L', 'P']),
            'guardian_relationship' => fake()->randomElement([
                'Ayah',
                'Ibu',
                'Wali',
            ]),
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ];
    }

    /**
     * Indicate that the patient was born prematurely.
     */
    public function premature(?int $gestationalAgeWeeks = null): static
    {
        return $this->state(function (array $attributes) use ($gestationalAgeWeeks) {
            return [
                'is_premature' => true,
                'gestational_age_weeks' => $gestationalAgeWeeks
                    ?? fake()->numberBetween(20, 45),
            ];
        });
    }

    /**
     * Indicate that the patient is inactive.
     */
    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }
}