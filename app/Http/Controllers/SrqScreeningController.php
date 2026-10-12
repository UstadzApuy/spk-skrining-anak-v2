<?php

namespace App\Http\Controllers;

use App\Models\ScreeningSession;
use App\Models\SrqScreening;
use App\Services\Scoring\RuleBasedScoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class SrqScreeningController extends Controller
{
    /**
     * Display the SRQ-20 questionnaire.
     */
    public function create(
        Request $request,
        ScreeningSession $screeningSession
    ): Response {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureSrqIsAvailable($screeningSession);

        $screeningSession->load([
            'patient:id,medical_record_number,name,birth_date,gender',
            'srqScreening',
        ]);

        $instrumentStatus = $screeningSession
            ->screeningSessionInstruments()
            ->where('instrument_code', 'SRQ')
            ->value('status');

        return Inertia::render('ScreeningSessions/Srq', [
            'session' => [
                'id' => $screeningSession->id,
                'screening_date' => $screeningSession
                    ->screening_date
                    ->toDateString(),
                'age_months' => $screeningSession->age_months,
                'status' => $screeningSession->status,
                'instrument_status' => $instrumentStatus,
                'patient' => $screeningSession->patient,
            ],
            'existingAnswers' => $screeningSession
                ->srqScreening?->answers ?? [],
        ]);
    }

    /**
     * Validate answers, calculate the SRQ-20 score, and save it.
     */
    public function store(
        Request $request,
        ScreeningSession $screeningSession,
        RuleBasedScoringService $scoringService
    ): RedirectResponse {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureSrqIsAvailable($screeningSession);

        abort_unless(
            ! in_array($screeningSession->status, [
                'reviewed',
                'cancelled',
            ], true),
            403,
            'Sesi skrining ini tidak dapat diubah.'
        );

        $validated = $request->validate([
            'answers' => [
                'required',
                'array',
                'size:20',
            ],
            'answers.*' => [
                'required',
                'boolean',
            ],
        ], [
            'answers.required' =>
                'Seluruh pertanyaan SRQ-20 wajib dijawab.',
            'answers.size' =>
                'SRQ-20 harus memiliki tepat 20 jawaban.',
            'answers.*.required' =>
                'Seluruh pertanyaan SRQ-20 wajib dijawab.',
            'answers.*.boolean' =>
                'Setiap jawaban SRQ-20 harus berupa Ya atau Tidak.',
        ]);

        // Normalize accepted request values to strict booleans.
        $answers = array_map(
            static fn ($answer): bool =>
                in_array($answer, [true, 1, '1'], true),
            array_values($validated['answers'])
        );

        $result = $scoringService->score('SRQ', $answers);

        DB::transaction(function () use (
            $screeningSession,
            $answers,
            $result
        ): void {
            SrqScreening::updateOrCreate(
                [
                    'screening_session_id' => $screeningSession->id,
                ],
                [
                    'answers' => $answers,
                    'score' => $result->scores['total'],
                    'category' => $result->categories['overall'],
                    'recommendation' => null,
                ]
            );

            $instrument = $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'SRQ')
                ->firstOrFail();

            $instrument->started_at ??= now();
            $instrument->status = 'completed';
            $instrument->completed_at = now();
            $instrument->save();

            $hasUnfinishedInstruments = $screeningSession
                ->screeningSessionInstruments()
                ->whereNotIn('status', [
                    'completed',
                    'cancelled',
                ])
                ->exists();

            $screeningSession->status = $hasUnfinishedInstruments
                ? 'in_progress'
                : 'pending_doctor_review';

            $screeningSession->save();
        });

        return redirect()->route(
            'screening-sessions.srq.complete',
            $screeningSession
        );
    }

    /**
     * Display a completion confirmation without showing the score.
     */
    public function complete(
        Request $request,
        ScreeningSession $screeningSession
    ): Response {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureSrqIsAvailable($screeningSession);

        abort_unless(
            $screeningSession->srqScreening()->exists(),
            404,
            'Hasil SRQ-20 belum tersedia.'
        );

        $screeningSession->load([
            'patient:id,name,medical_record_number',
        ]);

        return Inertia::render('ScreeningSessions/SrqCompleted', [
            'session' => [
                'id' => $screeningSession->id,
                'patient' => $screeningSession->patient,
            ],
        ]);
    }

    /**
     * Restrict access to the nurse who owns the session.
     */
    private function ensureNurseOwnsSession(
        Request $request,
        ScreeningSession $screeningSession
    ): void {
        $nurse = $request->user()->nurse;

        abort_unless(
            $nurse,
            403,
            'Akun perawat belum memiliki profil perawat.'
        );

        abort_unless(
            (int) $screeningSession->nurse_id === (int) $nurse->id,
            403
        );
    }

    /**
     * Ensure SRQ belongs to this screening session.
     */
    private function ensureSrqIsAvailable(
        ScreeningSession $screeningSession
    ): void {
        abort_unless(
            $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'SRQ')
                ->exists(),
            404,
            'Instrumen SRQ-20 tidak ditemukan pada sesi ini.'
        );
    }
}
