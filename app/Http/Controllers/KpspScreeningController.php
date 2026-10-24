<?php

namespace App\Http\Controllers;

use App\Models\KpspScreening;
use App\Models\ScreeningSession;
use App\Services\KpspAgeCalculator;
use App\Services\KpspCatalogService;
use App\Services\Scoring\RuleBasedScoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class KpspScreeningController extends Controller
{
    /**
     * Display the KPSP form for an eligible screening session.
     */
    public function create(
        Request $request,
        ScreeningSession $screeningSession,
        KpspCatalogService $catalogService,
        KpspAgeCalculator $ageCalculator
    ): Response {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureKpspIsAvailable($screeningSession);

        $screeningSession->load([
            'patient:id,medical_record_number,name,birth_date,gender,is_premature,gestational_age_weeks',
            'kpspScreening',
        ]);

        $patient = $screeningSession->patient;
        $ageCalc = $ageCalculator->calculate(
            $patient->birth_date->toDateString(),
            $screeningSession->screening_date->toDateString(),
            (bool) $patient->is_premature,
            $patient->gestational_age_weeks
        );

        $formAgeMonths = $screeningSession->kpspScreening?->form_age_months
            ?? $ageCalc['form_age_months'];

        abort_unless(
            $formAgeMonths !== null,
            422,
            'Tidak tersedia formulir KPSP untuk umur pasien pada tanggal pemeriksaan ini.'
        );

        $questions = $catalogService->getFormQuestions($formAgeMonths) ?? [];
        $guidance = $catalogService->getDevelopmentalGuidance($screeningSession->age_months);

        $instrumentStatus = $screeningSession
            ->screeningSessionInstruments()
            ->where('instrument_code', 'KPSP')
            ->value('status');

        return Inertia::render('ScreeningSessions/Kpsp', [
            'session' => [
                'id' => $screeningSession->id,
                'screening_date' => $screeningSession->screening_date->toDateString(),
                'age_months' => $screeningSession->age_months,
                'form_age_months' => $formAgeMonths,
                'status' => $screeningSession->status,
                'instrument_status' => $instrumentStatus,
                'patient' => $screeningSession->patient,
                'is_re_evaluation' => $screeningSession->isReEvaluation(),
                'evaluation_type' => $screeningSession->evaluation_type,
                'parent_session_id' => $screeningSession->parent_session_id,
            ],
            'questions' => $questions,
            'guidance' => $guidance,
            'existingAnswers' => $screeningSession->kpspScreening?->answers ?? [],
        ]);
    }

    /**
     * Validate answers, calculate the KPSP score, and save the result.
     */
    public function store(
        Request $request,
        ScreeningSession $screeningSession,
        RuleBasedScoringService $scoringService,
        KpspAgeCalculator $ageCalculator,
        KpspCatalogService $catalogService
    ): RedirectResponse {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureKpspIsAvailable($screeningSession);

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
                'size:10',
            ],
            'answers.*' => [
                'required',
                'boolean',
            ],
        ], [
            'answers.required' => 'Seluruh pertanyaan KPSP wajib dijawab.',
            'answers.size' => 'KPSP harus memiliki tepat 10 jawaban.',
            'answers.*.required' => 'Seluruh pertanyaan KPSP wajib dijawab.',
            'answers.*.boolean' => 'Setiap jawaban KPSP harus berupa Ya atau Tidak.',
        ]);

        $patient = $screeningSession->patient;
        $ageCalc = $ageCalculator->calculate(
            $patient->birth_date->toDateString(),
            $screeningSession->screening_date->toDateString(),
            (bool) $patient->is_premature,
            $patient->gestational_age_weeks
        );

        $formAgeMonths = $ageCalc['form_age_months'];

        abort_unless(
            $formAgeMonths !== null,
            422,
            'Tidak tersedia formulir KPSP untuk umur pasien.'
        );

        $answers = array_map(
            static fn ($answer): bool => in_array($answer, [true, 1, '1'], true),
            array_values($validated['answers'])
        );

        $isReEvaluation = $screeningSession->isReEvaluation();

        $result = $scoringService->score('KPSP', $answers, [
            'form_age_months' => $formAgeMonths,
            'is_re_evaluation' => $isReEvaluation,
        ]);

        $domainScores = $catalogService->calculateDomainScores($formAgeMonths, $answers);

        DB::transaction(function () use (
            $screeningSession,
            $formAgeMonths,
            $answers,
            $result,
            $domainScores,
            $isReEvaluation
        ): void {
            KpspScreening::updateOrCreate(
                [
                    'screening_session_id' => $screeningSession->id,
                ],
                [
                    'form_age_months' => $formAgeMonths,
                    'answers' => $answers,
                    'score' => $result->scores['total'],
                    'category' => $result->categories['overall'],
                    'sdidtk_code' => $result->scores['sdidtk_code'] ?? null,
                    'clinical_action' => $result->scores['clinical_action'] ?? null,
                    'is_re_evaluation' => $isReEvaluation,
                    'recommendation' => $result->recommendation,
                    'domain_scores' => $domainScores,
                ]
            );

            $instrument = $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'KPSP')
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

        return redirect()
            ->route('screening-sessions.show', $screeningSession)
            ->with('success', 'Hasil KPSP berhasil disimpan.');
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
     * Ensure KPSP belongs to this session.
     */
    private function ensureKpspIsAvailable(
        ScreeningSession $screeningSession
    ): void {
        abort_unless(
            $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'KPSP')
                ->exists(),
            404,
            'Instrumen KPSP tidak ditemukan pada sesi ini.'
        );
    }
}
