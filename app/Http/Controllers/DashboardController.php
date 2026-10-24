<?php

namespace App\Http\Controllers;

use App\Models\Patient;
use App\Models\ScreeningSession;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    /**
     * Display the dashboard according to the authenticated user's role.
     */
    public function index(Request $request): Response
    {
        $role = $request->user()->role?->name;

        $page = match ($role) {
            'administrator' => 'Dashboard/Administrator',
            'perawat' => 'Dashboard/Perawat',
            'dokter' => 'Dashboard/Dokter',
            'orang_tua' => 'Dashboard/OrangTua',
            default => abort(403),
        };

        if (in_array($role, ['perawat', 'dokter'], true)) {
            $today = CarbonImmutable::today();

            $patients = Patient::query()
                ->where('is_active', true)
                ->with([
                    'parentGuardian.user:id,name',
                    'screeningSessions' => function ($query) {
                        $query->orderByDesc('screening_date')
                            ->orderByDesc('id')
                            ->with('screeningSessionInstruments:id,screening_session_id,instrument_code,status');
                    },
                ])
                ->withCount('screeningSessions')
                ->orderBy('name')
                ->get()
                ->map(function ($patient) use ($today) {
                    $latestSession = $patient->screeningSessions->first();

                    // Hitung usia dalam bulan dan tahun
                    $birth = $patient->birth_date;
                    $ageMonths = $birth ? (int) $birth->diffInMonths($today) : 0;
                    $years = intdiv($ageMonths, 12);
                    $remMonths = $ageMonths % 12;

                    return [
                        'id' => $patient->id,
                        'medical_record_number' => $patient->medical_record_number,
                        'name' => $patient->name,
                        'birth_date' => $patient->birth_date?->toDateString(),
                        'gender' => $patient->gender,
                        'is_premature' => (bool) $patient->is_premature,
                        'gestational_age_weeks' => $patient->gestational_age_weeks,
                        'is_active' => (bool) $patient->is_active,
                        'age_months' => $ageMonths,
                        'age_display' => $years > 0 ? "{$years}y {$remMonths}m" : "{$remMonths}m",
                        'age_display_id' => $years > 0 ? "{$years} th {$remMonths} bln" : "{$remMonths} bln",
                        'guardian_name' => $patient->parentGuardian?->user?->name,
                        'guardian_relationship' => $patient->guardian_relationship,
                        'sessions_count' => (int) $patient->screening_sessions_count,
                        'latest_session' => $latestSession ? [
                            'id' => $latestSession->id,
                            'screening_date' => $latestSession->screening_date?->toDateString(),
                            'status' => $latestSession->status,
                            'instruments' => $latestSession->screeningSessionInstruments->pluck('instrument_code'),
                        ] : null,
                    ];
                });

            $stats = [
                'active_profiles' => Patient::where('is_active', true)->count(),
                'today_screenings' => ScreeningSession::whereDate('screening_date', $today->toDateString())->count(),
                'pending_reports' => ScreeningSession::whereIn('status', ['in_progress', 'pending_doctor_review'])->count(),
            ];

            return Inertia::render($page, [
                'patients' => $patients,
                'stats' => $stats,
            ]);
        }

        return Inertia::render($page);
    }
}