<?php

namespace App\Http\Controllers;

use App\Models\GpphScreening;
use App\Models\ScreeningSession;
use App\Services\Scoring\RuleBasedScoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class GpphScreeningController extends Controller
{
    /**
     * Indonesian GPPH ACTRS items from GPPH_ACTRS.pdf.
     */
    public const QUESTIONS = [
        'Tidak kenal lelah atau aktivitas yang berlebihan.',
        'Mudah menjadi gembira, impulsif.',
        'Mengganggu anak–anak lain.',
        'Gagal menyelesaikan kegiatan yang telah dimulai; rentang perhatian pendek.',
        'Menggerak–gerakkan anggota badan atau kepala secara terus menerus.',
        'Kurang memperhatikan, mudah teralihkan.',
        'Permintaannya harus segera dipenuhi; mudah menjadi frustrasi.',
        'Sering dan mudah menangis.',
        'Suasana hatinya mudah berubah dengan cepat dan drastis.',
        'Ledakan kekesalan, tingkah laku eksplosif dan tak terduga.',
    ];

    /**
     * Display the GPPH form for an eligible screening session.
     */
    public function create(
        Request $request,
        ScreeningSession $screeningSession
    ): Response {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureGpphIsAvailable($screeningSession);

        $screeningSession->load([
            'patient:id,medical_record_number,name,birth_date,gender',
            'gpphScreening',
        ]);

        $instrumentStatus = $screeningSession
            ->screeningSessionInstruments()
            ->where('instrument_code', 'GPPH')
            ->value('status');

        return Inertia::render('ScreeningSessions/Gpph', [
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
            'questions' => self::QUESTIONS,
            'existingAnswers' => $screeningSession
                ->gpphScreening?->answers ?? [],
            'existingExaminerDoubtful' => (bool) (
                $screeningSession->gpphScreening?->examiner_doubtful ?? false
            ),
        ]);
    }

    /**
     * Validate answers, calculate the GPPH result, and save it.
     */
    public function store(
        Request $request,
        ScreeningSession $screeningSession,
        RuleBasedScoringService $scoringService
    ): RedirectResponse {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureGpphIsAvailable($screeningSession);

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
                'integer',
                'between:0,3',
            ],
            'examiner_doubtful' => [
                'nullable',
                'boolean',
            ],
        ], [
            'answers.required' => 'Seluruh pertanyaan GPPH wajib dijawab.',
            'answers.size' => 'GPPH harus memiliki tepat 10 jawaban.',
            'answers.*.required' => 'Seluruh pertanyaan GPPH wajib dijawab.',
            'answers.*.integer' => 'Nilai jawaban GPPH tidak valid.',
            'answers.*.between' => 'Nilai jawaban GPPH harus antara 0 sampai 3.',
        ]);

        $answers = array_values($validated['answers']);
        $examinerDoubtful = (bool) ($validated['examiner_doubtful'] ?? false);

        $result = $scoringService->score('GPPH', $answers, [
            'examiner_doubtful' => $examinerDoubtful,
        ]);

        DB::transaction(function () use (
            $screeningSession,
            $answers,
            $examinerDoubtful,
            $result
        ): void {
            GpphScreening::updateOrCreate(
                [
                    'screening_session_id' => $screeningSession->id,
                ],
                [
                    'answers' => $answers,
                    'score' => $result->scores['total'],
                    'examiner_doubtful' => $examinerDoubtful,
                    'category' => $result->categories['overall'],
                    'recommendation' => $result->recommendation,
                ]
            );

            $instrument = $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'GPPH')
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
            ->with('success', 'Hasil GPPH berhasil disimpan.');
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
     * Ensure GPPH belongs to this session and the age is eligible (36-72 months).
     */
    private function ensureGpphIsAvailable(
        ScreeningSession $screeningSession
    ): void {
        abort_unless(
            $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'GPPH')
                ->exists(),
            404,
            'Instrumen GPPH tidak ditemukan pada sesi ini.'
        );

        abort_unless(
            $screeningSession->age_months >= 36
            && $screeningSession->age_months <= 72,
            422,
            'GPPH hanya dapat digunakan untuk anak berusia 36 sampai 72 bulan.'
        );
    }
}
