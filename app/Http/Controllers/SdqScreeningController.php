<?php

namespace App\Http\Controllers;

use App\Models\ScreeningSession;
use App\Models\SdqScreening;
use App\Services\Scoring\RuleBasedScoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class SdqScreeningController extends Controller
{
    /**
     * Display the SDQ questionnaire for an eligible screening session.
     */
    public function create(
        Request $request,
        ScreeningSession $screeningSession
    ): Response {
        $this->ensureAuthorizedToAccessSdq($request, $screeningSession);
        $this->ensureSdqIsAvailable($screeningSession);

        $screeningSession->load([
            'patient:id,medical_record_number,name,birth_date,gender',
            'sdqScreening',
        ]);

        $instrumentStatus = $screeningSession
            ->screeningSessionInstruments()
            ->where('instrument_code', 'SDQ')
            ->value('status');

        return Inertia::render('ScreeningSessions/Sdq', [
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
                ->sdqScreening?->answers ?? [],
        ]);
    }

    /**
     * Validate answers, calculate the SDQ result, and save it.
     */
    public function store(
        Request $request,
        ScreeningSession $screeningSession,
        RuleBasedScoringService $scoringService
    ): RedirectResponse {
        $this->ensureAuthorizedToAccessSdq($request, $screeningSession);
        $this->ensureSdqIsAvailable($screeningSession);

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
                'size:25',
            ],
            'answers.*' => [
                'required',
                'integer',
                'between:0,2',
            ],
        ], [
            'answers.required' => 'Seluruh pertanyaan SDQ wajib dijawab.',
            'answers.size' => 'SDQ harus memiliki tepat 25 jawaban.',
            'answers.*.required' => 'Seluruh pertanyaan SDQ wajib dijawab.',
            'answers.*.integer' => 'Jawaban SDQ tidak valid.',
            'answers.*.between' => 'Nilai jawaban SDQ harus 0, 1, atau 2.',
        ]);

        $answers = array_values($validated['answers']);

        // Use the registered rule-based scoring service.
        $result = $scoringService->score('SDQ', $answers);

        DB::transaction(function () use (
            $screeningSession,
            $answers,
            $result
        ): void {
            SdqScreening::updateOrCreate(
                [
                    'screening_session_id' => $screeningSession->id,
                ],
                [
                    'answers' => $answers,
                    'emotional_score' =>
                        $result->scores['emotional'],
                    'conduct_score' =>
                        $result->scores['conduct'],
                    'hyperactivity_score' =>
                        $result->scores['hyperactivity'],
                    'peer_score' =>
                        $result->scores['peer'],
                    'emotional_category' =>
                        $result->categories['emotional'],
                    'conduct_category' =>
                        $result->categories['conduct'],
                    'hyperactivity_category' =>
                        $result->categories['hyperactivity'],
                    'peer_category' =>
                        $result->categories['peer'],
                    'total_difficulties_score' =>
                        $result->scores['total_difficulties'],
                    'prosocial_score' =>
                        $result->scores['prosocial'],
                    'total_difficulties_category' =>
                        $result->categories['total_difficulties'],
                    'prosocial_category' =>
                        $result->categories['prosocial'],
                    'recommendation' => $result->recommendation,
                ]
            );

            $instrument = $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'SDQ')
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

        if ($request->user()->role?->name === 'orang_tua') {
            return redirect()
                ->route('dashboard')
                ->with('success', 'Kuesioner SDQ berhasil disimpan.');
        }

        return redirect()
            ->route('screening-sessions.show', $screeningSession)
            ->with('success', 'Hasil SDQ berhasil disimpan.');
    }

    /**
     * Restrict access to the nurse who owns the session or the patient's parent guardian.
     */
    private function ensureAuthorizedToAccessSdq(
        Request $request,
        ScreeningSession $screeningSession
    ): void {
        $user = $request->user();

        if ($user->role?->name === 'perawat') {
            $nurse = $user->nurse;

            abort_unless(
                $nurse,
                403,
                'Akun perawat belum memiliki profil perawat.'
            );

            abort_unless(
                (int) $screeningSession->nurse_id === (int) $nurse->id,
                403,
                'Akun perawat tidak memiliki akses ke sesi skrining ini.'
            );
        } elseif ($user->role?->name === 'orang_tua') {
            $parent = $user->parentGuardian;

            abort_unless(
                $parent,
                403,
                'Akun orang tua belum memiliki profil wali.'
            );

            abort_unless(
                (int) $screeningSession->patient->parent_guardian_id === (int) $parent->id,
                403,
                'Anda hanya dapat mengisi kuesioner untuk anak Anda sendiri.'
            );
        } else {
            abort(403, 'Akses tidak diizinkan.');
        }
    }

    /**
     * Ensure SDQ belongs to this session and the age is eligible.
     */
    private function ensureSdqIsAvailable(
        ScreeningSession $screeningSession
    ): void {
        abort_unless(
            $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'SDQ')
                ->exists(),
            404,
            'Instrumen SDQ tidak ditemukan pada sesi ini.'
        );

        abort_unless(
            $screeningSession->age_months >= 48
            && $screeningSession->age_months < 132,
            422,
            'SDQ hanya dapat digunakan untuk anak berusia 4 tahun sampai sebelum 11 tahun.'
        );
    }
}
