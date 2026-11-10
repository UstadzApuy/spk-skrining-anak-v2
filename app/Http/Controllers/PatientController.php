<?php

namespace App\Http\Controllers;

use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;

class PatientController extends Controller
{
    /**
     * Display the patient & guardian management list.
     */
    public function index(Request $request): Response
    {
        $patients = Patient::query()
            ->with(['parentGuardian.user:id,name,email'])
            ->withCount('screeningSessions')
            ->orderByDesc('is_active')
            ->orderBy('name')
            ->get([
                'id',
                'parent_guardian_id',
                'medical_record_number',
                'name',
                'birth_date',
                'gender',
                'address',
                'education',
                'school_name',
                'guardian_relationship',
                'is_premature',
                'gestational_age_weeks',
                'is_active',
            ]);

        $parentGuardians = ParentGuardian::query()
            ->with(['user:id,name,email', 'patients:id,parent_guardian_id,name'])
            ->get()
            ->map(function ($pg) {
                return [
                    'id' => $pg->id,
                    'user_id' => $pg->user_id,
                    'name' => $pg->user?->name ?? 'Tanpa Nama',
                    'email' => $pg->user?->email ?? '-',
                    'phone' => $pg->phone ?? '-',
                    'address' => $pg->address ?? '-',
                    'children_count' => $pg->patients->count(),
                    'children_names' => $pg->patients->pluck('name')->join(', '),
                ];
            })
            ->sortBy('name')
            ->values();

        return Inertia::render('Patients/Index', [
            'patients' => $patients,
            'parentGuardians' => $parentGuardians,
            'canDeletePatient' => $request->user()->hasRole('dokter'),
        ]);
    }

    /**
     * Display the patient creation form.
     */
    public function create(): Response
    {
        $parentGuardians = ParentGuardian::query()
            ->with('user:id,name,email')
            ->whereHas('user', function ($query) {
                $query->whereHas('role', function ($roleQuery) {
                    $roleQuery->where('name', 'orang_tua');
                });
            })
            ->get([
                'id',
                'user_id',
                'phone',
                'address',
            ])
            ->sortBy(fn ($parentGuardian) => $parentGuardian->user?->name)
            ->values();

        return Inertia::render('Patients/Create', [
            'parentGuardians' => $parentGuardians,
        ]);
    }

    /**
     * Display the patient editing form.
     */
    public function edit(Patient $patient): Response
    {
        $parentGuardians = ParentGuardian::query()
            ->with('user:id,name,email')
            ->whereHas('user', function ($query) {
                $query->whereHas('role', function ($roleQuery) {
                    $roleQuery->where('name', 'orang_tua');
                });
            })
            ->get([
                'id',
                'user_id',
                'phone',
                'address',
            ])
            ->sortBy(fn ($parentGuardian) => $parentGuardian->user?->name)
            ->values();

        return Inertia::render('Patients/Edit', [
            'patient' => [
                'id' => $patient->id,
                'parent_guardian_id' => $patient->parent_guardian_id,
                'medical_record_number' => $patient->medical_record_number,
                'name' => $patient->name,
                'birth_date' => $patient->birth_date?->format('Y-m-d'),
                'gender' => $patient->gender,
                'address' => $patient->address ?? '',
                'education' => $patient->education ?? 'tidak_sekolah',
                'school_name' => $patient->school_name ?? '',
                'guardian_relationship' => $patient->guardian_relationship ?? '',
                'is_premature' => $patient->is_premature,
                'gestational_age_weeks' => $patient->gestational_age_weeks,
                'is_active' => $patient->is_active,
            ],
            'parentGuardians' => $parentGuardians,
        ]);
    }

    /**
     * Update an existing patient.
     */
    public function update(Request $request, Patient $patient): RedirectResponse
    {
        $validated = $request->validate([
            'parent_guardian_id' => [
                'required',
                'integer',
                Rule::exists('parent_guardians', 'id')
                    ->where(function ($query) {
                        $query->whereIn(
                            'user_id',
                            User::query()
                                ->whereHas('role', function ($roleQuery) {
                                    $roleQuery->where('name', 'orang_tua');
                                })
                                ->select('id')
                        );
                    }),
            ],
            'medical_record_number' => [
                'required',
                'string',
                'max:100',
                Rule::unique('patients', 'medical_record_number')
                    ->ignore($patient->id),
            ],
            'name' => [
                'required',
                'string',
                'max:150',
            ],
            'birth_date' => [
                'required',
                'date',
            ],
            'gender' => [
                'required',
                Rule::in(['L', 'P']),
            ],
            'address' => [
                'nullable',
                'string',
                'max:500',
            ],
            'education' => [
                'nullable',
                'string',
                Rule::in(['tidak_sekolah', 'reguler', 'inklusi', 'slb', 'panti']),
            ],
            'school_name' => [
                'nullable',
                'string',
                'max:200',
            ],
            'guardian_relationship' => [
                'nullable',
                'string',
                'max:50',
            ],
            'is_premature' => [
                'required',
                'boolean',
            ],
            'gestational_age_weeks' => [
                'nullable',
                'integer',
                'min:20',
                'max:45',
                Rule::requiredIf($request->boolean('is_premature')),
            ],
            'is_active' => [
                'sometimes',
                'boolean',
            ],
        ]);

        if (! $validated['is_premature']) {
            $validated['gestational_age_weeks'] = null;
        }

        $validated['education'] = $validated['education'] ?? 'tidak_sekolah';

        if ($validated['education'] === 'tidak_sekolah') {
            $validated['school_name'] = null;
        }

        $patient->update($validated);

        return redirect()
            ->route('patients.index')
            ->with('success', 'Data pasien berhasil diperbarui.');
    }

    /**
     * Store a newly created patient.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'parent_guardian_id' => [
                'required',
                'integer',
                Rule::exists('parent_guardians', 'id')
                    ->where(function ($query) {
                        $query->whereIn(
                            'user_id',
                            User::query()
                                ->whereHas('role', function ($roleQuery) {
                                    $roleQuery->where('name', 'orang_tua');
                                })
                                ->select('id')
                        );
                    }),
            ],
            'medical_record_number' => [
                'required',
                'string',
                'max:100',
                'unique:patients,medical_record_number',
            ],
            'name' => [
                'required',
                'string',
                'max:150',
            ],
            'birth_date' => [
                'required',
                'date',
            ],
            'gender' => [
                'required',
                Rule::in(['L', 'P']),
            ],
            'address' => [
                'nullable',
                'string',
                'max:500',
            ],
            'education' => [
                'nullable',
                'string',
                Rule::in(['tidak_sekolah', 'reguler', 'inklusi', 'slb', 'panti']),
            ],
            'school_name' => [
                'nullable',
                'string',
                'max:200',
            ],
            'guardian_relationship' => [
                'nullable',
                'string',
                'max:50',
            ],
            'is_premature' => [
                'required',
                'boolean',
            ],
            'gestational_age_weeks' => [
                'nullable',
                'integer',
                'min:20',
                'max:45',
                Rule::requiredIf($request->boolean('is_premature')),
            ],
        ]);

        if (! $validated['is_premature']) {
            $validated['gestational_age_weeks'] = null;
        }

        $validated['education'] = $validated['education'] ?? 'tidak_sekolah';

        if ($validated['education'] === 'tidak_sekolah') {
            $validated['school_name'] = null;
        }

        Patient::create([
            ...$validated,
            'is_active' => true,
        ]);

        return redirect()
            ->route('patients.index')
            ->with('success', 'Data pasien berhasil ditambahkan.');
    }

    /**
     * Remove the specified patient and their screening records.
     * Hanya dokter yang berwenang menghapus data pasien.
     */
    public function destroy(Request $request, Patient $patient): RedirectResponse
    {
        abort_unless(
            $request->user()->hasRole('dokter'),
            403,
            'Hanya dokter yang berwenang menghapus data pasien.'
        );

        DB::transaction(function () use ($patient) {
            // Hapus sesi skrining terkait beserta instrumen dan interpretasinya
            foreach ($patient->screeningSessions as $session) {
                $session->kpspScreening()?->delete();
                $session->mchatScreening()?->delete();
                $session->gpphScreening()?->delete();
                $session->sdqScreening()?->delete();
                $session->srqScreening()?->delete();
                $session->screeningInterpretations()->delete();
                $session->screeningSessionInstruments()->delete();
                $session->delete();
            }

            $patient->delete();
        });

        return redirect()
            ->route('patients.index')
            ->with('success', "Data pasien {$patient->name} berhasil dihapus.");
    }

    /**
     * Store a newly created parent / guardian account.
     */
    public function storeParentGuardian(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:150', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:30'],
            'address' => ['nullable', 'string', 'max:500'],
            'password' => ['nullable', 'string', 'min:6'],
        ]);

        $parentRole = Role::firstOrCreate(['name' => 'orang_tua']);

        DB::transaction(function () use ($validated, $parentRole) {
            $user = User::create([
                'name' => $validated['name'],
                'email' => strtolower($validated['email']),
                'password' => Hash::make($validated['password'] ?: 'password'),
                'role_id' => $parentRole->id,
            ]);

            ParentGuardian::create([
                'user_id' => $user->id,
                'phone' => $validated['phone'] ?? null,
                'address' => $validated['address'] ?? null,
            ]);
        });

        return back()->with('success', "Akun orang tua/wali {$validated['name']} berhasil didaftarkan.");
    }
}
