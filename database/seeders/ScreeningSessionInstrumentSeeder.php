<?php

namespace Database\Seeders;

use App\Models\ScreeningSession;
use App\Models\ScreeningSessionInstrument;
use Illuminate\Database\Seeder;

class ScreeningSessionInstrumentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $session = ScreeningSession::whereHas('patient', function ($query) {
            $query->where('medical_record_number', 'RM-TEST-001');
        })
            ->where('screening_date', '2026-09-25')
            ->firstOrFail();

        $instrumentCodes = [
            'KPSP',
            'MCHAT',
            'GPPH',
            'SDQ',
            'SRQ',
        ];

        foreach ($instrumentCodes as $instrumentCode) {
            ScreeningSessionInstrument::updateOrCreate(
                [
                    'screening_session_id' => $session->id,
                    'instrument_code' => $instrumentCode,
                ],
                [
                    'status' => 'pending',
                    'started_at' => null,
                    'completed_at' => null,
                ]
            );
        }
    }
}