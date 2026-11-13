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

        if ($role === 'orang_tua') {
            $today = CarbonImmutable::today();
            $parent = $request->user()->parentGuardian;

            $patients = $parent ? Patient::query()
                ->where('parent_guardian_id', $parent->id)
                ->where('is_active', true)
                ->with([
                    'screeningSessions' => function ($query) {
                        $query->orderByDesc('screening_date')
                            ->orderByDesc('id')
                            ->with('screeningSessionInstruments');
                    },
                ])
                ->get()
                ->map(function ($patient) use ($today) {
                    $birth = $patient->birth_date;
                    $ageMonths = $birth ? (int) $birth->diffInMonths($today) : 0;
                    $years = intdiv($ageMonths, 12);
                    $remMonths = $ageMonths % 12;

                    $latestSession = $patient->screeningSessions->first();
                    $pendingInstruments = [];

                    if ($latestSession && in_array($latestSession->status, ['draft', 'in_progress', 'pending_parent'], true)) {
                        foreach ($latestSession->screeningSessionInstruments as $instrument) {
                            if (in_array($instrument->instrument_code, ['SDQ', 'SRQ'], true) && $instrument->status !== 'completed') {
                                $pendingInstruments[] = [
                                    'code' => $instrument->instrument_code,
                                    'title' => $instrument->instrument_code === 'SDQ'
                                        ? 'Kuesioner Masalah Perilaku & Emosional (SDQ)'
                                        : 'Kuesioner Kesehatan Jiwa Orang Tua / Pengasuh (SRQ-20)',
                                    'description' => $instrument->instrument_code === 'SDQ'
                                        ? 'Evaluasi kekuatan dan kesulitan perilaku anak (25 pertanyaan).'
                                        : 'Evaluasi faktor stres dan kesehatan emosional pengasuh (20 pertanyaan).',
                                    'url' => $instrument->instrument_code === 'SDQ'
                                        ? route('screening-sessions.sdq.create', $latestSession->id)
                                        : route('screening-sessions.srq.create', $latestSession->id),
                                ];
                            }
                        }
                    }

                    return [
                        'id' => $patient->id,
                        'name' => $patient->name,
                        'medical_record_number' => $patient->medical_record_number,
                        'birth_date' => $patient->birth_date?->toDateString(),
                        'gender' => $patient->gender,
                        'age_months' => $ageMonths,
                        'age_display_id' => $years > 0 ? "{$years} th {$remMonths} bln" : "{$remMonths} bln",
                        'latest_session' => $latestSession ? [
                            'id' => $latestSession->id,
                            'screening_date' => $latestSession->screening_date?->toDateString(),
                            'status' => $latestSession->status,
                        ] : null,
                        'pending_instruments' => $pendingInstruments,
                    ];
                }) : collect();

            return Inertia::render($page, [
                'patients' => $patients,
            ]);
        }

        return Inertia::render($page);
    }
}