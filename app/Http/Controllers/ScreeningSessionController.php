<?php

namespace App\Http\Controllers;

use App\Models\Patient;
use App\Models\ScreeningSession;
use App\Services\KpspAgeCalculator;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;
use InvalidArgumentException;

class ScreeningSessionController extends Controller
{
    /**
     * Display screening sessions created by the authenticated nurse.
     */
    public function index(Request $request)
    {
        $nurse = $request->user()->nurse;

        abort_unless(
            $nurse,
            403,
            'Akun perawat belum memiliki profil perawat.'
        );

        $sessions = ScreeningSession::query()
            ->where('nurse_id', $nurse->id)
            ->with([
                'patient:id,medical_record_number,name',
                'screeningSessionInstruments:id,screening_session_id,instrument_code,status',
            ])
            ->orderByDesc('screening_date')
            ->paginate(15);

        return Inertia::render('ScreeningSessions/Index', [
            'sessions' => $sessions,
        ]);
    }

    /**
     * Store a new screening session and its selected instruments.
     */

    /**
     * Display the screening session creation form.
     */
    public function create(): Response
    {
        $patients = Patient::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get([
                'id',
                'medical_record_number',
                'name',
                'birth_date',
                'is_premature',
                'gestational_age_weeks',
            ]);

        return Inertia::render('ScreeningSessions/Create', [
            'patients' => $patients,
        ]);
    }


    /**
     * Display a screening session owned by the authenticated nurse.
     */
    public function show(
        Request $request,
        ScreeningSession $screeningSession
    ): Response {
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

        $screeningSession->load([
            'patient:id,medical_record_number,name,birth_date,gender',
            'screeningSessionInstruments:id,screening_session_id,instrument_code,status,started_at,completed_at',
            'sdqScreening',
        ]);

        return Inertia::render('ScreeningSessions/Show', [
            'session' => $screeningSession,
        ]);
    }


    public function store(
        Request $request,
        KpspAgeCalculator $ageCalculator
    ): RedirectResponse {
        $validated = $request->validate([
            'patient_id' => [
                'required',
                'integer',
                Rule::exists('patients', 'id')
                    ->where('is_active', true),
            ],
            'screening_date' => [
                'required',
                'date',
                'before_or_equal:today',
            ],
            'instruments' => [
                'required',
                'array',
                'min:1',
            ],
            'instruments.*' => [
                'required',
                'string',
                'distinct',
                Rule::in([
                    'KPSP',
                    'MCHAT',
                    'GPPH',
                    'SDQ',
                    'SRQ',
                ]),
            ],
        ]);

        $nurse = $request->user()->nurse;

        abort_unless(
            $nurse,
            403,
            'Akun perawat belum memiliki profil perawat.'
        );

        $patient = Patient::findOrFail($validated['patient_id']);

        if (
            $validated['screening_date']
            < $patient->birth_date->toDateString()
        ) {
            return back()
                ->withErrors([
                    'screening_date' =>
                        'Tanggal pemeriksaan tidak boleh sebelum tanggal lahir pasien.',
                ])
                ->withInput();
        }

        try {
            $ageResult = $ageCalculator->calculate(
                $patient->birth_date->toDateString(),
                $validated['screening_date'],
                $patient->is_premature,
                $patient->gestational_age_weeks,
            );
        } catch (InvalidArgumentException $exception) {
            return back()
                ->withErrors([
                    'patient_id' =>
                        'Umur pasien tidak dapat dihitung: '
                        . $exception->getMessage(),
                ])
                ->withInput();
        }


        if (
            in_array('SDQ', $validated['instruments'], true)
            && (
                $ageResult['age_months'] < 48
                || $ageResult['age_months'] >= 132
            )
        ) {
            return back()
                ->withErrors([
                    'instruments' =>
                        'SDQ hanya dapat digunakan untuk anak berusia 4 tahun sampai sebelum 11 tahun.',
                ])
                ->withInput();
        }


        if (
            in_array('KPSP', $validated['instruments'], true)
            && $ageResult['form_age_months'] === null
        ) {
            return back()
                ->withErrors([
                    'instruments' =>
                        'KPSP tidak dapat dipilih karena tidak tersedia formulir untuk umur terkoreksi pasien.',
                ])
                ->withInput();
        }

        DB::transaction(function () use (
            $validated,
            $nurse,
            $ageResult
        ): void {
            $session = new ScreeningSession([
                'patient_id' => $validated['patient_id'],
                'nurse_id' => $nurse->id,
                'screening_date' => $validated['screening_date'],
                'status' => 'draft',
            ]);

            // The session age is generated by the application,
            // not accepted from the incoming request.
            $session->age_months = $ageResult['age_months'];
            $session->save();

            $instruments = array_map(
                fn (string $code): array => [
                    'instrument_code' => $code,
                    'status' => 'pending',
                ],
                $validated['instruments'],
            );

            $session->screeningSessionInstruments()
                ->createMany($instruments);
        });

        return redirect()
            ->route('screening-sessions.index')
            ->with('success', 'Sesi skrining berhasil dibuat.');
    }
}