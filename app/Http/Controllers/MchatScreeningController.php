<?php

namespace App\Http\Controllers;

use App\Models\MchatScreening;
use App\Models\ScreeningSession;
use App\Services\Scoring\RuleBasedScoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class MchatScreeningController extends Controller
{
    /**
     * Indonesian M-CHAT-R items from Autism_M-Chat-R.pdf.
     */
    public const QUESTIONS = [
        'Jika Anda menunjuk sesuatu di ruangan, apakah anak Anda melihatnya? (Misalnya, jika Anda menunjuk hewan atau mainan, apakah anak Anda melihat ke arah hewan atau mainan yang Anda tunjuk?)',
        'Pernahkah Anda berpikir bahwa anak Anda tuli?',
        'Apakah anak Anda pernah bermain pura-pura? (Misalnya, berpura-pura minum dari gelas kosong, berpura-pura berbicara menggunakan telepon, atau menyuapi boneka atau boneka binatang?)',
        'Apakah anak Anda suka memanjat benda-benda? (Misalnya, furnitur, alat-alat bermain, atau tangga)',
        'Apakah anak Anda menggerakkan jari-jari tangannya dengan cara yang tidak biasa di dekat matanya? (Misalnya, apakah anak Anda menggoyangkan jari dekat pada matanya?)',
        'Apakah anak Anda pernah menunjuk dengan satu jari untuk meminta sesuatu atau untuk meminta tolong? (Misalnya, menunjuk makanan atau mainan yang jauh dari jangkauannya)',
        'Apakah anak Anda pernah menunjuk dengan satu jari untuk menunjukkan sesuatu yang menarik pada Anda? (Misalnya, menunjuk pada pesawat di langit atau truk besar di jalan)',
        'Apakah anak Anda tertarik pada anak lain? (Misalnya, apakah anak Anda memperhatikan anak lain, tersenyum pada mereka atau pergi ke arah mereka)',
        'Apakah anak Anda pernah memperlihatkan suatu benda dengan membawa atau mengangkatnya kepada Anda – tidak untuk minta tolong, hanya untuk berbagi? (Misalnya, memperlihatkan Anda bunga, binatang atau truk mainan)',
        'Apakah anak Anda memberikan respon jika namanya dipanggil? (Misalnya, apakah anak Anda melihat, bicara atau bergumam, atau menghentikan apa yang sedang dilakukannya saat Anda memanggil namanya)',
        'Saat Anda tersenyum pada anak Anda, apakah anak Anda tersenyum balik?',
        'Apakah anak Anda pernah marah saat mendengar suara bising sehari-hari? (Misalnya, apakah anak Anda berteriak atau menangis saat mendengar suara bising seperti vacuum cleaner atau musik keras)',
        'Apakah anak Anda bisa berjalan?',
        'Apakah anak Anda menatap mata Anda saat Anda bicara padanya, bermain bersamanya, atau saat memakaikan pakaian?',
        'Apakah anak Anda mencoba meniru apa yang Anda lakukan? (Misalnya, melambaikan tangan, tepuk tangan atau meniru saat Anda membuat suara lucu)',
        'Jika Anda memutar kepala untuk melihat sesuatu, apakah anak Anda melihat sekeliling untuk melihat apa yang Anda lihat?',
        'Apakah anak Anda mencoba untuk membuat Anda melihat kepadanya? (Misalnya, apakah anak Anda melihat Anda untuk dipuji atau berkata “lihat” atau “lihat aku”)',
        'Apakah anak Anda mengerti saat Anda memintanya melakukan sesuatu? (Misalnya, jika Anda tidak menunjuk, apakah anak Anda mengerti kalimat “letakkan buku itu di atas kursi” atau “ambilkan saya selimut”)',
        'Jika sesuatu yang baru terjadi, apakah anak Anda menatap wajah Anda untuk melihat perasaan Anda tentang hal tersebut? (Misalnya, jika anak Anda mendengar bunyi aneh atau lucu, atau melihat mainan baru, akankah dia menatap wajah Anda?)',
        'Apakah anak Anda menyukai aktivitas yang bergerak? (Misalnya, diayun-ayun atau dihentak-hentakkan pada lutut Anda)',
    ];

    /**
     * Display the M-CHAT-R questionnaire for an eligible screening session.
     */
    public function create(
        Request $request,
        ScreeningSession $screeningSession
    ): Response {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureMchatIsAvailable($screeningSession);

        $screeningSession->load([
            'patient:id,medical_record_number,name,birth_date,gender',
            'mchatScreening',
        ]);

        $instrumentStatus = $screeningSession
            ->screeningSessionInstruments()
            ->where('instrument_code', 'MCHAT')
            ->value('status');

        return Inertia::render('ScreeningSessions/Mchat', [
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
                ->mchatScreening?->answers ?? [],
        ]);
    }

    /**
     * Validate answers, calculate the M-CHAT-R result, and save it.
     */
    public function store(
        Request $request,
        ScreeningSession $screeningSession,
        RuleBasedScoringService $scoringService
    ): RedirectResponse {
        $this->ensureNurseOwnsSession($request, $screeningSession);
        $this->ensureMchatIsAvailable($screeningSession);

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
            'answers.required' => 'Seluruh pertanyaan M-CHAT-R wajib dijawab.',
            'answers.size' => 'M-CHAT-R harus memiliki tepat 20 jawaban.',
            'answers.*.required' => 'Seluruh pertanyaan M-CHAT-R wajib dijawab.',
            'answers.*.boolean' => 'Setiap jawaban M-CHAT-R harus berupa Ya atau Tidak.',
        ]);

        $answers = array_map(
            static fn ($answer): bool => in_array($answer, [true, 1, '1'], true),
            array_values($validated['answers'])
        );

        $result = $scoringService->score('MCHAT', $answers);

        DB::transaction(function () use (
            $screeningSession,
            $answers,
            $result
        ): void {
            MchatScreening::updateOrCreate(
                [
                    'screening_session_id' => $screeningSession->id,
                ],
                [
                    'answers' => $answers,
                    'score' => $result->scores['total'],
                    'category' => $result->categories['overall'],
                    'recommendation' => $result->recommendation,
                ]
            );

            $instrument = $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'MCHAT')
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
            ->with('success', 'Hasil M-CHAT-R berhasil disimpan.');
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
     * Ensure M-CHAT-R belongs to this session and the age is eligible (16-30 months).
     */
    private function ensureMchatIsAvailable(
        ScreeningSession $screeningSession
    ): void {
        abort_unless(
            $screeningSession
                ->screeningSessionInstruments()
                ->where('instrument_code', 'MCHAT')
                ->exists(),
            404,
            'Instrumen M-CHAT-R tidak ditemukan pada sesi ini.'
        );

        abort_unless(
            $screeningSession->age_months >= 16
            && $screeningSession->age_months <= 30,
            422,
            'M-CHAT-R hanya dapat digunakan untuk anak berusia 16 sampai 30 bulan.'
        );
    }
}
