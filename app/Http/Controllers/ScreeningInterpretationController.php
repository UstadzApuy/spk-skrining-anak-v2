<?php

namespace App\Http\Controllers;

use App\Models\ScreeningInterpretation;
use App\Models\ScreeningSession;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ScreeningInterpretationController extends Controller
{
    /**
     * Store or update a doctor's clinical interpretation for a specific instrument.
     */
    public function store(
        Request $request,
        ScreeningSession $screeningSession
    ): RedirectResponse {
        $doctor = $request->user()->doctor;

        abort_unless(
            $doctor,
            403,
            'Akun dokter belum memiliki profil dokter.'
        );

        $validated = $request->validate([
            'instrument_code' => [
                'required',
                'string',
                Rule::in(['KPSP', 'MCHAT', 'GPPH', 'SDQ', 'SRQ']),
            ],
            'clinical_notes' => [
                'nullable',
                'string',
                'max:5000',
            ],
            'follow_up_decision' => [
                'nullable',
                'string',
                'max:100',
            ],
            'follow_up_notes' => [
                'nullable',
                'string',
                'max:5000',
            ],
            'status' => [
                'required',
                Rule::in(['draft', 'completed']),
            ],
        ]);

        $instrument = $screeningSession
            ->screeningSessionInstruments()
            ->where('instrument_code', $validated['instrument_code'])
            ->first();

        abort_unless(
            $instrument && $instrument->status === 'completed',
            422,
            'Interpretasi klinis hanya dapat dicatat untuk instrumen yang sudah selesai dikerjakan.'
        );

        $completedAt = $validated['status'] === 'completed'
            ? now()
            : null;

        ScreeningInterpretation::updateOrCreate(
            [
                'screening_session_id' => $screeningSession->id,
                'instrument_code' => $validated['instrument_code'],
            ],
            [
                'doctor_id' => $doctor->id,
                'clinical_notes' => $validated['clinical_notes'] ?? null,
                'follow_up_decision' => $validated['follow_up_decision'] ?? null,
                'follow_up_notes' => $validated['follow_up_notes'] ?? null,
                'status' => $validated['status'],
                'completed_at' => $completedAt,
            ]
        );

        // Record the reviewing doctor on the session
        if ($screeningSession->doctor_id === null) {
            $screeningSession->doctor_id = $doctor->id;
            $screeningSession->save();
        }

        return back()->with(
            'success',
            $validated['status'] === 'completed'
                ? "Interpretasi dokter untuk {$validated['instrument_code']} berhasil disimpan dan diselesaikan."
                : "Draf interpretasi dokter untuk {$validated['instrument_code']} berhasil disimpan."
        );
    }

    /**
     * Finalize the overall review of the screening session.
     */
    public function finalize(
        Request $request,
        ScreeningSession $screeningSession
    ): RedirectResponse {
        $doctor = $request->user()->doctor;

        abort_unless(
            $doctor,
            403,
            'Akun dokter belum memiliki profil dokter.'
        );

        abort_unless(
            ! in_array($screeningSession->status, ['reviewed', 'cancelled'], true),
            422,
            'Sesi skrining ini sudah selesai ditinjau atau dibatalkan.'
        );

        $validated = $request->validate([
            'doctor_notes' => [
                'nullable',
                'string',
                'max:5000',
            ],
        ]);

        $screeningSession->update([
            'doctor_id' => $doctor->id,
            'doctor_notes' => $validated['doctor_notes'] ?? $screeningSession->doctor_notes,
            'status' => 'reviewed',
            'reviewed_at' => now(),
        ]);

        return back()->with(
            'success',
            'Tinjauan sesi skrining berhasil difinalisasi.'
        );
    }
}
