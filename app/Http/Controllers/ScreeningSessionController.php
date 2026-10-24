<?php

namespace App\Http\Controllers;

use App\Models\Nurse;
use App\Models\Patient;
use App\Models\ScreeningSession;
use App\Services\KpspAgeCalculator;
use App\Services\KpspCatalogService;
use Carbon\CarbonImmutable;
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
     * Display screening sessions accessible to the authenticated user.
     */
    public function index(Request $request): Response
    {
        $user = $request->user();

        $query = ScreeningSession::query()
            ->with([
                'patient:id,medical_record_number,name,birth_date,gender,is_premature,gestational_age_weeks',
                'nurse.user:id,name',
                'doctor.user:id,name',
                'screeningSessionInstruments:id,screening_session_id,instrument_code,status',
                'kpspScreening:id,screening_session_id,category,score',
                'mchatScreening:id,screening_session_id,category,score',
                'gpphScreening:id,screening_session_id,category,score,examiner_doubtful',
                'sdqScreening:id,screening_session_id,total_difficulties_category,total_difficulties_score',
                'srqScreening:id,screening_session_id,category,score,answers',
            ]);

        $nurse = null;
        if ($user->hasRole('perawat')) {
            $nurse = $user->nurse;

            abort_unless(
                $nurse,
                403,
                'Akun perawat belum memiliki profil perawat.'
            );

            $query->where('nurse_id', $nurse->id);
        }

        $patientId = $request->query('patient_id');
        $selectedPatient = null;

        if ($patientId) {
            $query->where('patient_id', (int) $patientId);
            $selectedPatient = Patient::with('parentGuardian.user:id,name')->find((int) $patientId);
        }

        // 1. Pencarian Teks (Nama Anak, No. RM, Perawat, Dokter)
        $search = trim((string) $request->query('search', ''));
        if ($search !== '') {
            $lower = strtolower($search);
            $query->where(function ($q) use ($lower) {
                $q->whereHas('patient', function ($pq) use ($lower) {
                    $pq->whereRaw('LOWER(name) LIKE ?', ["%{$lower}%"])
                       ->orWhereRaw('LOWER(medical_record_number) LIKE ?', ["%{$lower}%"]);
                })->orWhereHas('nurse.user', function ($nq) use ($lower) {
                    $nq->whereRaw('LOWER(name) LIKE ?', ["%{$lower}%"]);
                })->orWhereHas('doctor.user', function ($dq) use ($lower) {
                    $dq->whereRaw('LOWER(name) LIKE ?', ["%{$lower}%"]);
                });
            });
        }

        // 2. Filter Status Sesi
        $status = $request->query('status');
        if ($status && in_array($status, ['draft', 'in_progress', 'pending_parent', 'pending_doctor_review', 'reviewed', 'cancelled'], true)) {
            $query->where('status', $status);
        }

        // 3. Filter Instrumen
        $instrument = $request->query('instrument');
        if ($instrument && in_array($instrument, ['KPSP', 'M-CHAT', 'GPPH', 'SDQ', 'SRQ'], true)) {
            $query->whereHas('screeningSessionInstruments', function ($iq) use ($instrument) {
                $iq->where('instrument_code', $instrument);
            });
        }

        // 4. Filter Rentang Tanggal
        $startDate = $request->query('start_date');
        $endDate = $request->query('end_date');
        if ($startDate) {
            $query->whereDate('screening_date', '>=', $startDate);
        }
        if ($endDate) {
            $query->whereDate('screening_date', '<=', $endDate);
        }

        // Hitung status counts untuk pill tabs
        $baseCountQuery = ScreeningSession::query();
        if ($nurse) {
            $baseCountQuery->where('nurse_id', $nurse->id);
        }
        if ($patientId) {
            $baseCountQuery->where('patient_id', (int) $patientId);
        }

        $statusCounts = [
            'all' => (clone $baseCountQuery)->count(),
            'reviewed' => (clone $baseCountQuery)->where('status', 'reviewed')->count(),
            'pending_doctor_review' => (clone $baseCountQuery)->where('status', 'pending_doctor_review')->count(),
            'in_progress' => (clone $baseCountQuery)->where('status', 'in_progress')->count(),
            'draft' => (clone $baseCountQuery)->where('status', 'draft')->count(),
        ];

        $sessions = $query
            ->orderByDesc('screening_date')
            ->orderByDesc('id')
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('ScreeningSessions/Index', [
            'sessions' => $sessions,
            'selectedPatient' => $selectedPatient,
            'filters' => [
                'search' => $search,
                'status' => $status,
                'instrument' => $instrument,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'patient_id' => $patientId,
            ],
            'statusCounts' => $statusCounts,
        ]);
    }

    /**
     * Display the screening session creation form.
     */
    public function create(Request $request): Response
    {
        $patients = Patient::query()
            ->where('is_active', true)
            ->with('parentGuardian.user:id,name')
            ->orderBy('name')
            ->get([
                'id',
                'medical_record_number',
                'name',
                'birth_date',
                'gender',
                'parent_guardian_id',
                'is_premature',
                'gestational_age_weeks',
            ]);

        $nurses = Nurse::query()
            ->with('user:id,name')
            ->get(['id', 'user_id', 'registration_number']);

        $preselectedPatientId = $request->query('patient_id')
            ? (int) $request->query('patient_id')
            : null;

        return Inertia::render('ScreeningSessions/Create', [
            'patients' => $patients,
            'nurses' => $nurses,
            'preselectedPatientId' => $preselectedPatientId,
        ]);
    }

    /**
     * Display a screening session accessible to the authenticated user.
     */
    public function show(
        Request $request,
        ScreeningSession $screeningSession,
        KpspCatalogService $kpspCatalog
    ): Response {
        $user = $request->user();

        if ($user->hasRole('perawat')) {
            $nurse = $user->nurse;

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

        $screeningSession->load([
            'patient:id,medical_record_number,name,birth_date,gender,is_premature,gestational_age_weeks,guardian_relationship,parent_guardian_id',
            'patient.parentGuardian:id,user_id,phone',
            'patient.parentGuardian.user:id,name',
            'nurse.user:id,name',
            'doctor.user:id,name',
            'createdByUser:id,name',
            'screeningSessionInstruments:id,screening_session_id,instrument_code,status,started_at,completed_at',
            'sdqScreening',
            'srqScreening',
            'kpspScreening',
            'mchatScreening',
            'gpphScreening',
            'screeningInterpretations.doctor.user:id,name',
            'parentSession:id,screening_date,status,age_months,evaluation_type',
            'parentSession.kpspScreening:id,screening_session_id,score,category,sdidtk_code,clinical_action,domain_scores',
            'reEvaluations:id,parent_session_id,screening_date,status,evaluation_type',
            'reEvaluations.kpspScreening:id,screening_session_id,score,category,sdidtk_code,clinical_action,domain_scores',
        ]);

        $milestones = $kpspCatalog->getDevelopmentalGuidance((int) $screeningSession->age_months);

        return Inertia::render('ScreeningSessions/Show', [
            'session' => $screeningSession,
            'milestones' => $milestones,
        ]);
    }

    /**
     * Store a new screening session and its selected instruments.
     */
    public function store(
        Request $request,
        KpspAgeCalculator $ageCalculator
    ): RedirectResponse {
        $isDoctor = $request->user()->hasRole('dokter');

        $rules = [
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
            'notes' => [
                'nullable',
                'string',
                'max:1000',
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
        ];

        if ($isDoctor) {
            $rules['nurse_id'] = [
                'required',
                'integer',
                Rule::exists('nurses', 'id'),
            ];
        }

        $validated = $request->validate($rules);

        if ($isDoctor) {
            $nurseId = (int) $validated['nurse_id'];
        } else {
            $nurse = $request->user()->nurse;

            abort_unless(
                $nurse,
                403,
                'Akun perawat belum memiliki profil perawat.'
            );

            $nurseId = (int) $nurse->id;
        }

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

        $ageMonths = $ageResult['age_months'];

        if (
            in_array('SDQ', $validated['instruments'], true)
            && (
                $ageMonths < 48
                || $ageMonths >= 132
            )
        ) {
            return back()
                ->withErrors([
                    'instruments' =>
                        'SDQ hanya dapat digunakan untuk anak berusia 4 tahun sampai sebelum 11 tahun (48 - 131 bulan).',
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
                        'KPSP tidak dapat dipilih karena tidak tersedia formulir untuk umur terkoreksi pasien (3 - 72 bulan).',
                ])
                ->withInput();
        }

        if (
            in_array('MCHAT', $validated['instruments'], true)
            && (
                $ageMonths < 16
                || $ageMonths > 30
            )
        ) {
            return back()
                ->withErrors([
                    'instruments' =>
                        'M-CHAT-R hanya dapat digunakan untuk anak berusia 16 sampai 30 bulan.',
                ])
                ->withInput();
        }

        if (
            in_array('GPPH', $validated['instruments'], true)
            && (
                $ageMonths < 36
                || $ageMonths > 72
            )
        ) {
            return back()
                ->withErrors([
                    'instruments' =>
                        'GPPH/ACTRS hanya dapat digunakan untuk anak berusia 36 sampai 72 bulan (3 - 6 tahun).',
                ])
                ->withInput();
        }

        $creatorId = (int) $request->user()->id;
        $doctorId = $isDoctor ? $request->user()->doctor?->id : null;

        $session = DB::transaction(function () use (
            $validated,
            $nurseId,
            $doctorId,
            $ageResult,
            $creatorId
        ): ScreeningSession {
            $session = new ScreeningSession([
                'patient_id' => $validated['patient_id'],
                'nurse_id' => $nurseId,
                'doctor_id' => $doctorId,
                'screening_date' => $validated['screening_date'],
                'status' => 'draft',
                'notes' => $validated['notes'] ?? null,
            ]);

            $session->created_by_user_id = $creatorId;
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

            return $session;
        });

        return redirect()
            ->route('screening-sessions.index', [
                'patient_id' => (int) $validated['patient_id'],
            ])
            ->with('success', 'Sesi skrining berhasil dibuat.');
    }

    /**
     * Remove the specified screening session and its associated records.
     * Hanya dokter yang berwenang menghapus sesi skrining.
     */
    public function destroy(
        Request $request,
        ScreeningSession $screeningSession
    ): RedirectResponse {
        $user = $request->user();

        abort_unless(
            $user->hasRole('dokter'),
            403,
            'Hanya dokter yang berwenang menghapus sesi skrining.'
        );

        $patientId = $screeningSession->patient_id;

        DB::transaction(function () use ($screeningSession) {
            $screeningSession->screeningInterpretations()->delete();
            $screeningSession->kpspScreening()->delete();
            $screeningSession->mchatScreening()->delete();
            $screeningSession->gpphScreening()->delete();
            $screeningSession->sdqScreening()->delete();
            $screeningSession->srqScreening()->delete();
            $screeningSession->screeningSessionInstruments()->delete();
            $screeningSession->delete();
        });

        return redirect()
            ->route('screening-sessions.index', [
                'patient_id' => $patientId,
            ])
            ->with('success', 'Sesi skrining berhasil dihapus.');
    }

    /**
     * Create a 2-week KPSP re-evaluation screening session linked to the current session (SDIDTK Flow).
     */
    public function scheduleKpspReEvaluation(
        Request $request,
        ScreeningSession $screeningSession
    ): RedirectResponse {
        $user = $request->user();
        abort_unless(
            $user->hasRole(['perawat', 'dokter']),
            403,
            'Hanya perawat atau dokter yang berwenang menjadwalkan evaluasi ulang.'
        );

        abort_unless(
            $screeningSession->kpspScreening !== null,
            422,
            'Sesi ini belum memiliki hasil pemeriksaan KPSP.'
        );

        $patient = $screeningSession->patient;
        $nurseId = $user->hasRole('perawat') && $user->nurse
            ? $user->nurse->id
            : $screeningSession->nurse_id;

        $targetDate = CarbonImmutable::parse($screeningSession->screening_date)->addDays(14);
        if ($targetDate->isPast()) {
            $targetDate = CarbonImmutable::now()->addDays(14);
        }

        // Prevent duplicate re-evaluation sessions for the same session
        $existing = ScreeningSession::where('parent_session_id', $screeningSession->id)
            ->where('evaluation_type', 'kpsp_re_evaluation_2_weeks')
            ->first();

        if ($existing) {
            return redirect()
                ->route('screening-sessions.show', $existing)
                ->with('info', "Sesi evaluasi ulang 2 minggu sudah terdaftar (Sesi #{$existing->id}).");
        }

        $newSession = DB::transaction(function () use (
            $screeningSession,
            $patient,
            $nurseId,
            $targetDate,
            $user
        ): ScreeningSession {
            $session = new ScreeningSession([
                'patient_id' => $patient->id,
                'nurse_id' => $nurseId,
                'doctor_id' => $screeningSession->doctor_id,
                'screening_date' => $targetDate->toDateString(),
                'status' => 'draft',
                'evaluation_type' => 'kpsp_re_evaluation_2_weeks',
                'parent_session_id' => $screeningSession->id,
                'notes' => "Evaluasi ulang KPSP 2 minggu pasca intervensi dini perkembangan dari Sesi #{$screeningSession->id}.",
            ]);
            $session->created_by_user_id = $user->id;
            $session->age_months = $screeningSession->age_months;
            $session->save();

            $session->screeningSessionInstruments()->create([
                'instrument_code' => 'KPSP',
                'status' => 'pending',
            ]);

            return $session;
        });

        return redirect()
            ->route('screening-sessions.show', $newSession)
            ->with('success', "Sesi evaluasi ulang KPSP 2 minggu berhasil dijadwalkan (Target: {$targetDate->format('d/m/Y')}).");
    }
}