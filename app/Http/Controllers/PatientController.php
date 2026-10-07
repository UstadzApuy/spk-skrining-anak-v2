<?php

namespace App\Http\Controllers;

use App\Models\Patient;
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
}