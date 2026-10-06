<?php

namespace Database\Factories;

use App\Models\ScreeningSession;
use App\Models\ScreeningSessionInstrument;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Carbon;

/**
 * @extends Factory<ScreeningSessionInstrument>
 */
class ScreeningSessionInstrumentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $screeningSession = ScreeningSession::query()->inRandomOrder()->first();

        if ($screeningSession === null) {
            throw new \RuntimeException(
                'ScreeningSession belum tersedia. Jalankan ScreeningSessionSeeder terlebih dahulu.'
            );
        }

        $instrumentCodes = [
            'KPSP',
            'MCHAT',
            'GPPH',
            'SDQ',
            'SRQ',
        ];

        $usedCodes = $screeningSession
            ->screeningSessionInstruments()
            ->pluck('instrument_code')
            ->all();

        $availableCodes = array_values(
            array_diff($instrumentCodes, $usedCodes)
        );

        if ($availableCodes === []) {
            throw new \RuntimeException(
                "Semua instrumen sudah terdaftar pada ScreeningSession ID {$screeningSession->id}."
            );
        }

        return [
            'screening_session_id' => $screeningSession->id,
            'instrument_code' => fake()->randomElement($availableCodes),
            'status' => 'pending',
            'started_at' => null,
            'completed_at' => null,
        ];
    }

    /**
     * Indicate that the instrument is in progress.
     */
    public function inProgress(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'in_progress',
            'started_at' => Carbon::now(),
            'completed_at' => null,
        ]);
    }

    /**
     * Indicate that the instrument has been completed.
     */
    public function completed(): static
    {
        return $this->state(function (array $attributes) {
            $startedAt = Carbon::now()->subMinutes(
                fake()->numberBetween(5, 30)
            );

            return [
                'status' => 'completed',
                'started_at' => $startedAt,
                'completed_at' => Carbon::now(),
            ];
        });
    }

    /**
     * Indicate that the instrument has been cancelled.
     */
    public function cancelled(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'cancelled',
            'started_at' => null,
            'completed_at' => null,
        ]);
    }
}