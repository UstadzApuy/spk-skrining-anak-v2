<?php

namespace App\Http\Controllers;

use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;

class PatientController extends Controller
{
    /**
     * Display the patient list.
     */
    public function index(): Response
    {
        $patients = Patient::query()
            ->with('parentGuardian.user')
            ->orderByDesc('is_active')
            ->orderBy('name')
            ->get([
                'id',
                'parent_guardian_id',
                'medical_record_number',
                'name',
                'birth_date',
                'gender',
                'guardian_relationship',
                'is_premature',
                'gestational_age_weeks',
                'is_active',
            ]);

        return Inertia::render('Patients/Index', [
            'patients' => $patients,
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
            ])
            ->sortBy(fn ($parentGuardian) => $parentGuardian->user?->name)
            ->values();

        return Inertia::render('Patients/Create', [
            'parentGuardians' => $parentGuardians,
        ]);
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

        Patient::create([
            ...$validated,
            'is_active' => true,
        ]);

        return redirect()
            ->route('patients.index')
            ->with('success', 'Data pasien berhasil ditambahkan.');
    }
}