<?php

namespace App\Http\Controllers;

use App\Models\Nurse;
use App\Models\ScreeningSession;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ScreeningRecapController extends Controller
{
    private const MONTH_NAMES = [
        1 => 'Januari',
        2 => 'Februari',
        3 => 'Maret',
        4 => 'April',
        5 => 'Mei',
        6 => 'Juni',
        7 => 'Juli',
        8 => 'Agustus',
        9 => 'September',
        10 => 'Oktober',
        11 => 'November',
        12 => 'Desember',
    ];

    private const SHORT_MONTH_NAMES = [
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'Mei',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Agu',
        9 => 'Sep',
        10 => 'Okt',
        11 => 'Nov',
        12 => 'Des',
    ];

    private const DAY_NAMES = [
        0 => 'Minggu',
        1 => 'Senin',
        2 => 'Selasa',
        3 => 'Rabu',
        4 => 'Kamis',
        5 => 'Jumat',
        6 => 'Sabtu',
    ];

    /**
     * Tampilkan rekapitulasi sesi skrining anak.
     * Granularitas mandiri: bulanan (default), harian, mingguan, tahunan.
     */
    public function index(Request $request): Response
    {
        $granularity = in_array($request->query('granularity'), ['bulanan', 'harian', 'mingguan', 'tahunan'], true)
            ? $request->query('granularity')
            : 'bulanan';

        $nurseId = $request->query('nurse_id') ? (int) $request->query('nurse_id') : null;
        $status = $request->query('status');

        // Daftar tahun yang ada sesi di database
        $availableYears = ScreeningSession::query()
            ->selectRaw('EXTRACT(YEAR FROM screening_date)::integer as year')
            ->distinct()
            ->orderByDesc('year')
            ->pluck('year')
            ->all();

        if (empty($availableYears)) {
            $availableYears = [(int) date('Y')];
        }

        // Tanggal sesi paling mutakhir di sistem untuk default yang kontekstual
        $latestSession = ScreeningSession::query()
            ->orderByDesc('screening_date')
            ->first();

        $latestDateObj = $latestSession && $latestSession->screening_date
            ? CarbonImmutable::parse($latestSession->screening_date)
            : CarbonImmutable::today();

        $relations = [
            'patient:id,medical_record_number,name,birth_date,gender,is_premature',
            'nurse.user:id,name',
            'doctor.user:id,name',
            'screeningSessionInstruments:id,screening_session_id,instrument_code,status',
            'kpspScreening:id,screening_session_id,category,score',
            'mchatScreening:id,screening_session_id,category,score',
            'gpphScreening:id,screening_session_id,category,score,examiner_doubtful',
            'sdqScreening:id,screening_session_id,total_difficulties_category,total_difficulties_score,prosocial_category,prosocial_score',
            'srqScreening:id,screening_session_id,category,score,depression_score,anxiety_score,somatic_score,cognitive_score,energy_score,answers',
        ];

        // Inisialisasi variabel konteks
        $selectedYear = (int) ($request->query('year') ?? $latestDateObj->year);
        if (!in_array($selectedYear, $availableYears, true) && !empty($availableYears)) {
            $selectedYear = $availableYears[0];
        }

        $selectedMonth = (int) ($request->query('month') ?? $latestDateObj->month);
        if ($selectedMonth < 1 || $selectedMonth > 12) {
            $selectedMonth = 10;
        }

        $selectedDate = $latestDateObj->toDateString();
        $selectedWeek = (int) $latestDateObj->isoWeek();

        $prevDate = null;
        $nextDate = null;
        $prevWeek = null;
        $nextWeek = null;
        $weekStartDate = null;
        $weekEndDate = null;
        $periodLabel = '';

        // Tentukan periode aktif dan query sesi sesuai granularitas
        if ($granularity === 'harian') {
            // Tentukan tanggal terpilih
            if ($request->query('date')) {
                try {
                    $dateObj = CarbonImmutable::parse($request->query('date'));
                } catch (\Throwable) {
                    $dateObj = $latestDateObj;
                }
            } elseif ($request->query('year') && $request->query('month')) {
                $y = (int) $request->query('year');
                $m = (int) $request->query('month');
                $sessionInMonth = ScreeningSession::query()
                    ->whereYear('screening_date', $y)
                    ->whereMonth('screening_date', $m)
                    ->orderByDesc('screening_date')
                    ->first();
                $dateObj = $sessionInMonth && $sessionInMonth->screening_date
                    ? CarbonImmutable::parse($sessionInMonth->screening_date)
                    : CarbonImmutable::createFromDate($y, $m, 1);
            } else {
                $dateObj = $latestDateObj;
            }

            $selectedDate = $dateObj->toDateString();
            $selectedYear = $dateObj->year;
            $selectedMonth = $dateObj->month;
            $selectedWeek = (int) $dateObj->isoWeek();

            $prevDate = $dateObj->subDay()->toDateString();
            $nextDate = $dateObj->addDay()->toDateString();

            // Sesi hanya pada tanggal tersebut
            $activeQuery = ScreeningSession::query()
                ->whereDate('screening_date', $selectedDate)
                ->with($relations);

            if ($nurseId) $activeQuery->where('nurse_id', $nurseId);
            if ($status) $activeQuery->where('status', $status);
            $activeSessions = $activeQuery->orderByDesc('id')->get();

            $dayName = self::DAY_NAMES[$dateObj->dayOfWeek] ?? '';
            $monthName = self::MONTH_NAMES[$dateObj->month] ?? '';
            $periodLabel = "Harian: {$dayName}, {$dateObj->format('d')} {$monthName} {$dateObj->year}";

        } elseif ($granularity === 'mingguan') {
            $maxWeeksInYear = CarbonImmutable::createFromDate($selectedYear, 1, 1)->isoWeeksInYear();

            if ($request->query('week')) {
                $selectedWeek = (int) $request->query('week');
            } elseif ($request->query('month')) {
                $m = (int) $request->query('month');
                $sessionInMonth = ScreeningSession::query()
                    ->whereYear('screening_date', $selectedYear)
                    ->whereMonth('screening_date', $m)
                    ->orderBy('screening_date')
                    ->first();
                $selectedWeek = $sessionInMonth && $sessionInMonth->screening_date
                    ? (int) CarbonImmutable::parse($sessionInMonth->screening_date)->isoWeek()
                    : (int) CarbonImmutable::createFromDate($selectedYear, $m, 1)->isoWeek();
            } else {
                $selectedWeek = (int) $latestDateObj->isoWeek();
            }

            if ($selectedWeek < 1) $selectedWeek = 1;
            if ($selectedWeek > $maxWeeksInYear) $selectedWeek = $maxWeeksInYear;

            $weekStart = CarbonImmutable::now()->setISODate($selectedYear, $selectedWeek)->startOfWeek();
            $weekEnd = $weekStart->endOfWeek();
            $weekStartDate = $weekStart->toDateString();
            $weekEndDate = $weekEnd->toDateString();

            $selectedDate = $weekStartDate;
            $selectedMonth = $weekStart->month;

            $prevWeek = $selectedWeek > 1 ? $selectedWeek - 1 : $maxWeeksInYear;
            $nextWeek = $selectedWeek < $maxWeeksInYear ? $selectedWeek + 1 : 1;

            // Sesi dalam 7 hari minggu tersebut (Senin - Minggu)
            $activeQuery = ScreeningSession::query()
                ->whereBetween('screening_date', [$weekStartDate, $weekEndDate])
                ->with($relations);

            if ($nurseId) $activeQuery->where('nurse_id', $nurseId);
            if ($status) $activeQuery->where('status', $status);
            $activeSessions = $activeQuery->orderBy('screening_date')->orderByDesc('id')->get();

            $startMonthName = self::SHORT_MONTH_NAMES[$weekStart->month] ?? '';
            $endMonthName = self::SHORT_MONTH_NAMES[$weekEnd->month] ?? '';
            $periodLabel = "Mingguan: Minggu ke-{$selectedWeek} ({$weekStart->format('d')} {$startMonthName} – {$weekEnd->format('d')} {$endMonthName} {$weekEnd->year})";

        } elseif ($granularity === 'tahunan') {
            $selectedMonth = 1;
            $selectedDate = sprintf('%04d-01-01', $selectedYear);
            $selectedWeek = 1;

            // Sesi sepanjang tahun terpilih
            $activeQuery = ScreeningSession::query()
                ->whereYear('screening_date', $selectedYear)
                ->with($relations);

            if ($nurseId) $activeQuery->where('nurse_id', $nurseId);
            if ($status) $activeQuery->where('status', $status);
            $activeSessions = $activeQuery->orderByDesc('screening_date')->orderByDesc('id')->get();

            $periodLabel = "Tahunan: Tahun {$selectedYear}";

        } else {
            // Default: Bulanan
            $granularity = 'bulanan';
            $selectedDate = sprintf('%04d-%02d-01', $selectedYear, $selectedMonth);
            $selectedWeek = (int) CarbonImmutable::createFromDate($selectedYear, $selectedMonth, 1)->isoWeek();

            // Sesi sepanjang 1 bulan terpilih
            $activeQuery = ScreeningSession::query()
                ->whereYear('screening_date', $selectedYear)
                ->whereMonth('screening_date', $selectedMonth)
                ->with($relations);

            if ($nurseId) $activeQuery->where('nurse_id', $nurseId);
            if ($status) $activeQuery->where('status', $status);
            $activeSessions = $activeQuery->orderByDesc('screening_date')->orderByDesc('id')->get();

            $monthName = self::MONTH_NAMES[$selectedMonth] ?? '';
            $periodLabel = "Bulanan: {$monthName} {$selectedYear}";
        }

        // Hitung metrik ringkasan untuk periode aktif
        $summary = $this->calculateSummary($activeSessions);
        $instrumentBreakdown = $this->calculateInstrumentBreakdown($activeSessions);
        $statusBreakdown = $this->calculateStatusBreakdown($activeSessions);
        $demographics = $this->calculateDemographics($activeSessions);

        // Ambil sesi tahunan untuk konteks data tren jika diperlukan
        $allYearSessions = ScreeningSession::query()
            ->whereYear('screening_date', $selectedYear)
            ->when($nurseId, fn ($q) => $q->where('nurse_id', $nurseId))
            ->when($status, fn ($q) => $q->where('status', $status))
            ->with($relations)
            ->get();

        // 1. Data harian
        // Jika bulanan: hari-hari di bulan terpilih.
        // Jika harian: 30 hari aktif di sekitar tanggal terpilih (atau bulan yang bersangkutan).
        // Jika mingguan: 7 hari dalam minggu tersebut.
        if ($granularity === 'mingguan') {
            $weekStart = CarbonImmutable::now()->setISODate($selectedYear, $selectedWeek)->startOfWeek();
            $dailyData = $this->calculateDaysInWeekBreakdown($weekStart, $activeSessions);
            $weeklyDaysData = $dailyData;
        } elseif ($granularity === 'harian') {
            // Berikan hari-hari dalam bulan tanggal terpilih agar pengguna tetap dapat melihat perbandingan harian
            $monthSessionsForDaily = $allYearSessions->filter(fn ($s) => $s->screening_date && (int) $s->screening_date->format('n') === $selectedMonth);
            $dailyData = $this->calculateDailyBreakdown($selectedYear, $selectedMonth, $monthSessionsForDaily);
            $weeklyDaysData = [];
        } else {
            $monthSessionsForDaily = ($granularity === 'bulanan') ? $activeSessions : $allYearSessions->filter(fn ($s) => $s->screening_date && (int) $s->screening_date->format('n') === $selectedMonth);
            $dailyData = $this->calculateDailyBreakdown($selectedYear, $selectedMonth, $monthSessionsForDaily);
            $weeklyDaysData = [];
        }

        // 2. Data mingguan
        // Sediakan daftar minggu-minggu dalam bulan (untuk tab bulanan) dan seluruh minggu dalam tahun (untuk tab mingguan)
        $monthSessionsForWeekly = ($granularity === 'bulanan') ? $activeSessions : $allYearSessions->filter(fn ($s) => $s->screening_date && (int) $s->screening_date->format('n') === $selectedMonth);
        $weeklyData = $this->calculateWeeklyBreakdown($selectedYear, $selectedMonth, $monthSessionsForWeekly);

        // Daftar minggu yang tersedia di tahun terpilih (1 s/d maxWeeks)
        $availableWeeks = $this->generateAvailableWeeks($selectedYear, $allYearSessions);

        // 3. Data bulanan (12 bulan)
        $monthlyData = $this->calculateMonthlyBreakdown($selectedYear, $allYearSessions);

        // 4. Data tren tahunan
        $yearlyData = $this->calculateYearlyBreakdown($availableYears, $nurseId, $status);

        // 5. Daftar tanggal aktif yang memiliki sesi untuk navigasi cepat
        $activeDates = ScreeningSession::query()
            ->selectRaw('screening_date, count(*) as session_count')
            ->groupBy('screening_date')
            ->orderByDesc('screening_date')
            ->limit(20)
            ->get()
            ->map(function ($row) {
                $d = $row->screening_date instanceof \DateTimeInterface
                    ? $row->screening_date->format('Y-m-d')
                    : substr((string) $row->screening_date, 0, 10);
                return [
                    'date' => $d,
                    'count' => (int) $row->session_count,
                ];
            })
            ->all();

        // 6. Daftar bulan untuk dropdown
        $availableMonths = [];
        foreach (self::MONTH_NAMES as $num => $name) {
            $availableMonths[] = [
                'value' => $num,
                'label' => $name,
                'short' => self::SHORT_MONTH_NAMES[$num],
            ];
        }

        // 7. Daftar perawat untuk dropdown
        $nurses = Nurse::with('user:id,name')->get()->map(function ($nurse) {
            return [
                'id' => $nurse->id,
                'name' => $nurse->user?->name ?? "Perawat #{$nurse->id}",
            ];
        });

        // 8. Format sesi untuk tabel eksplorasi
        $formattedSessions = $activeSessions->map(function ($s) {
            $attentionReasons = $this->getAttentionReasons($s);
            $instruments = $s->screeningSessionInstruments->map(function ($inst) use ($s) {
                $category = null;
                $hasAlert = false;
                if ($inst->status === 'completed') {
                    if ($inst->instrument_code === 'KPSP') {
                        $category = $s->kpspScreening?->category;
                    } elseif ($inst->instrument_code === 'M-CHAT') {
                        $category = $s->mchatScreening?->category;
                    } elseif ($inst->instrument_code === 'GPPH') {
                        $category = $s->gpphScreening?->category;
                        if ($s->gpphScreening?->examiner_doubtful) {
                            $hasAlert = true;
                        }
                    } elseif ($inst->instrument_code === 'SDQ') {
                        $category = $s->sdqScreening?->total_difficulties_category;
                    } elseif ($inst->instrument_code === 'SRQ') {
                        $category = $s->srqScreening?->category;
                        $answers = $s->srqScreening?->answers;
                        if (is_array($answers) && isset($answers[16]) && in_array($answers[16], [true, 1, '1'], true)) {
                            $hasAlert = true;
                        }
                    }
                }

                return [
                    'code' => $inst->instrument_code,
                    'status' => $inst->status,
                    'category' => $category,
                    'has_alert' => $hasAlert,
                ];
            });

            return [
                'id' => $s->id,
                'screening_date' => $s->screening_date?->toDateString(),
                'status' => $s->status,
                'age_months' => $s->age_months,
                'patient' => [
                    'id' => $s->patient?->id,
                    'name' => $s->patient?->name ?? '-',
                    'medical_record_number' => $s->patient?->medical_record_number ?? '-',
                    'gender' => $s->patient?->gender,
                    'is_premature' => (bool) $s->patient?->is_premature,
                ],
                'nurse_name' => $s->nurse?->user?->name ?? '-',
                'doctor_name' => $s->doctor?->user?->name ?? '-',
                'instruments' => $instruments,
                'has_attention' => count($attentionReasons) > 0,
                'attention_reasons' => $attentionReasons,
            ];
        });

        return Inertia::render('ScreeningSessions/Recap', [
            'filters' => [
                'granularity' => $granularity,
                'year' => $selectedYear,
                'month' => $selectedMonth,
                'date' => $selectedDate,
                'week' => $selectedWeek,
                'nurse_id' => $nurseId,
                'status' => $status,
            ],
            'availableYears' => $availableYears,
            'availableMonths' => $availableMonths,
            'availableWeeks' => $availableWeeks,
            'activeDates' => $activeDates,
            'prevDate' => $prevDate,
            'nextDate' => $nextDate,
            'prevWeek' => $prevWeek,
            'nextWeek' => $nextWeek,
            'weekStartDate' => $weekStartDate,
            'weekEndDate' => $weekEndDate,
            'nurses' => $nurses,
            'summary' => $summary,
            'instrumentBreakdown' => $instrumentBreakdown,
            'statusBreakdown' => $statusBreakdown,
            'demographics' => $demographics,
            'dailyData' => $dailyData,
            'weeklyData' => $weeklyData,
            'weeklyDaysData' => $weeklyDaysData,
            'monthlyData' => $monthlyData,
            'yearlyData' => $yearlyData,
            'sessions' => $formattedSessions,
            'periodLabel' => $periodLabel,
        ]);
    }

    /**
     * Hitung rincian 7 hari (Senin - Minggu) di dalam minggu yang dipilih.
     */
    private function calculateDaysInWeekBreakdown(CarbonImmutable $weekStart, $sessions): array
    {
        $days = [];
        for ($i = 0; $i < 7; $i++) {
            $cur = $weekStart->addDays($i);
            $dateStr = $cur->toDateString();
            $dayOfWeek = $cur->dayOfWeek;

            $sessionsOnDay = $sessions->filter(fn ($s) => $s->screening_date && $s->screening_date->toDateString() === $dateStr);
            $total = $sessionsOnDay->count();
            $reviewed = $sessionsOnDay->where('status', 'reviewed')->count();
            $pending = $sessionsOnDay->whereIn('status', ['pending_doctor_review', 'in_progress'])->count();
            $uniquePatients = $sessionsOnDay->pluck('patient_id')->unique()->count();

            $attention = 0;
            $kpsp = 0; $mchat = 0; $gpph = 0; $sdq = 0; $srq = 0;
            foreach ($sessionsOnDay as $s) {
                if ($this->isAttentionCase($s)) $attention++;
                if ($s->kpspScreening) $kpsp++;
                if ($s->mchatScreening) $mchat++;
                if ($s->gpphScreening) $gpph++;
                if ($s->sdqScreening) $sdq++;
                if ($s->srqScreening) $srq++;
            }

            $days[] = [
                'day' => $cur->day,
                'date' => $dateStr,
                'day_name' => self::DAY_NAMES[$dayOfWeek],
                'is_weekend' => $dayOfWeek === 0 || $dayOfWeek === 6,
                'total_sessions' => $total,
                'unique_patients' => $uniquePatients,
                'reviewed_count' => $reviewed,
                'pending_count' => $pending,
                'attention_count' => $attention,
                'instruments' => [
                    'kpsp' => $kpsp,
                    'mchat' => $mchat,
                    'gpph' => $gpph,
                    'sdq' => $sdq,
                    'srq' => $srq,
                ],
            ];
        }

        return $days;
    }

    /**
     * Buat daftar minggu di tahun terpilih dengan rentang tanggal dan jumlah sesi.
     */
    private function generateAvailableWeeks(int $year, $yearSessions): array
    {
        $maxWeeks = CarbonImmutable::createFromDate($year, 1, 1)->isoWeeksInYear();
        $weeks = [];

        for ($w = 1; $w <= $maxWeeks; $w++) {
            $wStart = CarbonImmutable::now()->setISODate($year, $w)->startOfWeek();
            $wEnd = $wStart->endOfWeek();
            $startStr = $wStart->toDateString();
            $endStr = $wEnd->toDateString();

            $count = $yearSessions->filter(function ($s) use ($startStr, $endStr) {
                $d = $s->screening_date ? $s->screening_date->toDateString() : null;
                return $d >= $startStr && $d <= $endStr;
            })->count();

            $startM = self::SHORT_MONTH_NAMES[$wStart->month] ?? '';
            $endM = self::SHORT_MONTH_NAMES[$wEnd->month] ?? '';

            $weeks[] = [
                'week_number' => $w,
                'label' => "Minggu {$w} ({$wStart->format('d')} {$startM} – {$wEnd->format('d')} {$endM})",
                'start_date' => $startStr,
                'end_date' => $endStr,
                'total_sessions' => $count,
            ];
        }

        return $weeks;
    }

    /**
     * Hitung ringkasan utama KPI.
     */
    private function calculateSummary($sessions): array
    {
        $totalSessions = $sessions->count();
        $uniquePatients = $sessions->pluck('patient_id')->unique()->count();
        $reviewedCount = $sessions->where('status', 'reviewed')->count();
        $pendingDoctorCount = $sessions->where('status', 'pending_doctor_review')->count();
        $inProgressCount = $sessions->where('status', 'in_progress')->count();
        $draftCount = $sessions->where('status', 'draft')->count();

        $attentionCount = 0;
        foreach ($sessions as $session) {
            if ($this->isAttentionCase($session)) {
                $attentionCount++;
            }
        }

        $completionRate = $totalSessions > 0
            ? round(($reviewedCount / $totalSessions) * 100, 1)
            : 0;

        return [
            'total_sessions' => $totalSessions,
            'unique_patients' => $uniquePatients,
            'reviewed_sessions' => $reviewedCount,
            'pending_doctor_sessions' => $pendingDoctorCount,
            'in_progress_sessions' => $inProgressCount,
            'draft_sessions' => $draftCount,
            'attention_cases' => $attentionCount,
            'completion_rate' => $completionRate,
        ];
    }

    /**
     * Hitung rincian hasil untuk masing-masing instrumen klinis.
     */
    private function calculateInstrumentBreakdown($sessions): array
    {
        $kpspTotal = 0; $kpspSesuai = 0; $kpspMeragukan = 0; $kpspPenyimpangan = 0;
        $mchatTotal = 0; $mchatRendah = 0; $mchatTinggi = 0;
        $gpphTotal = 0; $gpphNormal = 0; $gpphKemungkinan = 0;
        $sdqTotal = 0; $sdqNormal = 0; $sdqAmbang = 0; $sdqAbnormal = 0;
        $srqTotal = 0; $srqNormal = 0; $srqDistres = 0; $srqSuicideAlert = 0;

        foreach ($sessions as $s) {
            if ($s->kpspScreening) {
                $kpspTotal++;
                match ($s->kpspScreening->category) {
                    'sesuai', 'sesuai_umur' => $kpspSesuai++,
                    'meragukan' => $kpspMeragukan++,
                    'penyimpangan', 'kemungkinan_penyimpangan' => $kpspPenyimpangan++,
                    default => null,
                };
            }

            if ($s->mchatScreening) {
                $mchatTotal++;
                match ($s->mchatScreening->category) {
                    'risiko_rendah' => $mchatRendah++,
                    'risiko_sedang_tinggi' => $mchatTinggi++,
                    default => null,
                };
            }

            if ($s->gpphScreening) {
                $gpphTotal++;
                match ($s->gpphScreening->category) {
                    'tidak_menunjukkan_gpph' => $gpphNormal++,
                    'kemungkinan_gpph' => $gpphKemungkinan++,
                    default => null,
                };
            }

            if ($s->sdqScreening) {
                $sdqTotal++;
                match ($s->sdqScreening->total_difficulties_category) {
                    'normal' => $sdqNormal++,
                    'ambang_borderline' => $sdqAmbang++,
                    'abnormal' => $sdqAbnormal++,
                    default => null,
                };
            }

            if ($s->srqScreening) {
                $srqTotal++;
                match ($s->srqScreening->category) {
                    'di_bawah_nilai_pisah' => $srqNormal++,
                    'gangguan_mental_emosional_distres' => $srqDistres++,
                    default => null,
                };

                $answers = $s->srqScreening->answers;
                if (is_array($answers) && isset($answers[16]) && in_array($answers[16], [true, 1, '1'], true)) {
                    $srqSuicideAlert++;
                }
            }
        }

        return [
            'kpsp' => [
                'total' => $kpspTotal,
                'sesuai' => $kpspSesuai,
                'meragukan' => $kpspMeragukan,
                'penyimpangan' => $kpspPenyimpangan,
            ],
            'mchat' => [
                'total' => $mchatTotal,
                'risiko_rendah' => $mchatRendah,
                'risiko_sedang_tinggi' => $mchatTinggi,
            ],
            'gpph' => [
                'total' => $gpphTotal,
                'tidak_menunjukkan_gpph' => $gpphNormal,
                'kemungkinan_gpph' => $gpphKemungkinan,
            ],
            'sdq' => [
                'total' => $sdqTotal,
                'normal' => $sdqNormal,
                'ambang_borderline' => $sdqAmbang,
                'abnormal' => $sdqAbnormal,
            ],
            'srq' => [
                'total' => $srqTotal,
                'di_bawah_nilai_pisah' => $srqNormal,
                'gangguan_mental_emosional_distres' => $srqDistres,
                'suicide_alert' => $srqSuicideAlert,
            ],
        ];
    }

    /**
     * Hitung rincian status sesi.
     */
    private function calculateStatusBreakdown($sessions): array
    {
        return [
            'reviewed' => $sessions->where('status', 'reviewed')->count(),
            'pending_doctor_review' => $sessions->where('status', 'pending_doctor_review')->count(),
            'in_progress' => $sessions->where('status', 'in_progress')->count(),
            'draft' => $sessions->where('status', 'draft')->count(),
            'cancelled' => $sessions->where('status', 'cancelled')->count(),
        ];
    }

    /**
     * Hitung distribusi demografi pasien yang diskrining.
     */
    private function calculateDemographics($sessions): array
    {
        $uniquePatients = $sessions->pluck('patient')->filter()->unique('id');

        $maleCount = $uniquePatients->where('gender', 'L')->count();
        $femaleCount = $uniquePatients->where('gender', 'P')->count();
        $prematureCount = $uniquePatients->where('is_premature', true)->count();
        $fullTermCount = $uniquePatients->where('is_premature', false)->count();

        // Kelompok umur berdasarkan age_months saat skrining
        $infantCount = 0;       // < 12 bulan
        $toddlerCount = 0;      // 12 - 35 bulan (1 - 3 th)
        $preschoolCount = 0;    // 36 - 59 bulan (3 - 5 th)
        $schoolAgeCount = 0;    // >= 60 bulan (5 - 11 th)

        foreach ($sessions as $s) {
            $m = (int) $s->age_months;
            if ($m < 12) {
                $infantCount++;
            } elseif ($m < 36) {
                $toddlerCount++;
            } elseif ($m < 60) {
                $preschoolCount++;
            } else {
                $schoolAgeCount++;
            }
        }

        return [
            'gender' => [
                'laki_laki' => $maleCount,
                'perempuan' => $femaleCount,
            ],
            'prematurity' => [
                'prematur' => $prematureCount,
                'cukup_bulan' => $fullTermCount,
            ],
            'age_groups' => [
                'bayi' => $infantCount,             // < 12 bln
                'batita' => $toddlerCount,          // 1-3 th
                'prasekolah' => $preschoolCount,    // 3-5 th
                'sekolah' => $schoolAgeCount,       // 5-11 th
            ],
        ];
    }

    /**
     * Hitung rincian per hari untuk bulan yang dipilih.
     */
    private function calculateDailyBreakdown(int $year, int $month, $monthSessions): array
    {
        $dateObj = CarbonImmutable::createFromDate($year, $month, 1);
        $daysInMonth = $dateObj->daysInMonth;

        $groupedByDate = $monthSessions->groupBy(function ($session) {
            return $session->screening_date ? $session->screening_date->toDateString() : null;
        });

        $dailyList = [];

        for ($day = 1; $day <= $daysInMonth; $day++) {
            $currentDate = CarbonImmutable::createFromDate($year, $month, $day);
            $dateString = $currentDate->toDateString();
            $dayOfWeek = $currentDate->dayOfWeek; // 0 = Minggu, 6 = Sabtu

            $sessionsOnDay = $groupedByDate->get($dateString, collect());
            $totalSessions = $sessionsOnDay->count();

            $reviewedCount = $sessionsOnDay->where('status', 'reviewed')->count();
            $pendingCount = $sessionsOnDay->whereIn('status', ['pending_doctor_review', 'in_progress'])->count();
            $uniquePatients = $sessionsOnDay->pluck('patient_id')->unique()->count();

            $attentionCount = 0;
            $kpspCount = 0; $mchatCount = 0; $gpphCount = 0; $sdqCount = 0; $srqCount = 0;

            foreach ($sessionsOnDay as $s) {
                if ($this->isAttentionCase($s)) {
                    $attentionCount++;
                }
                if ($s->kpspScreening) $kpspCount++;
                if ($s->mchatScreening) $mchatCount++;
                if ($s->gpphScreening) $gpphCount++;
                if ($s->sdqScreening) $sdqCount++;
                if ($s->srqScreening) $srqCount++;
            }

            $dailyList[] = [
                'day' => $day,
                'date' => $dateString,
                'day_name' => self::DAY_NAMES[$dayOfWeek],
                'is_weekend' => $dayOfWeek === 0 || $dayOfWeek === 6,
                'total_sessions' => $totalSessions,
                'unique_patients' => $uniquePatients,
                'reviewed_count' => $reviewedCount,
                'pending_count' => $pendingCount,
                'attention_count' => $attentionCount,
                'instruments' => [
                    'kpsp' => $kpspCount,
                    'mchat' => $mchatCount,
                    'gpph' => $gpphCount,
                    'sdq' => $sdqCount,
                    'srq' => $srqCount,
                ],
            ];
        }

        return $dailyList;
    }

    /**
     * Hitung rincian per minggu dalam bulan yang dipilih (Minggu 1 sd 5).
     */
    private function calculateWeeklyBreakdown(int $year, int $month, $monthSessions): array
    {
        $dateObj = CarbonImmutable::createFromDate($year, $month, 1);
        $daysInMonth = $dateObj->daysInMonth;
        $monthName = self::SHORT_MONTH_NAMES[$month] ?? '';

        $weekRanges = [
            1 => ['start' => 1, 'end' => 7],
            2 => ['start' => 8, 'end' => 14],
            3 => ['start' => 15, 'end' => 21],
            4 => ['start' => 22, 'end' => 28],
            5 => ['start' => 29, 'end' => $daysInMonth],
        ];

        $weeklyList = [];

        foreach ($weekRanges as $weekNum => $range) {
            if ($range['start'] > $daysInMonth) {
                continue;
            }

            $startDay = $range['start'];
            $endDay = min($range['end'], $daysInMonth);

            $startDateStr = sprintf('%04d-%02d-%02d', $year, $month, $startDay);
            $endDateStr = sprintf('%04d-%02d-%02d', $year, $month, $endDay);

            $sessionsInWeek = $monthSessions->filter(function ($s) use ($startDateStr, $endDateStr) {
                $d = $s->screening_date ? $s->screening_date->toDateString() : null;
                return $d >= $startDateStr && $d <= $endDateStr;
            });

            $total = $sessionsInWeek->count();
            $uniquePatients = $sessionsInWeek->pluck('patient_id')->unique()->count();
            $reviewed = $sessionsInWeek->where('status', 'reviewed')->count();
            $pending = $sessionsInWeek->whereIn('status', ['pending_doctor_review', 'in_progress'])->count();

            $attention = 0;
            $kpsp = 0; $mchat = 0; $gpph = 0; $sdq = 0; $srq = 0;

            foreach ($sessionsInWeek as $s) {
                if ($this->isAttentionCase($s)) $attention++;
                if ($s->kpspScreening) $kpsp++;
                if ($s->mchatScreening) $mchat++;
                if ($s->gpphScreening) $gpph++;
                if ($s->sdqScreening) $sdq++;
                if ($s->srqScreening) $srq++;
            }

            $weeklyList[] = [
                'week_number' => $weekNum,
                'week_label' => "Minggu {$weekNum}",
                'date_range' => sprintf('%02d %s – %02d %s %d', $startDay, $monthName, $endDay, $monthName, $year),
                'total_sessions' => $total,
                'unique_patients' => $uniquePatients,
                'reviewed_count' => $reviewed,
                'pending_count' => $pending,
                'attention_count' => $attention,
                'instruments' => [
                    'kpsp' => $kpsp,
                    'mchat' => $mchat,
                    'gpph' => $gpph,
                    'sdq' => $sdq,
                    'srq' => $srq,
                ],
            ];
        }

        return $weeklyList;
    }

    /**
     * Hitung rincian 12 bulan dalam tahun terpilih.
     */
    private function calculateMonthlyBreakdown(int $year, $yearSessions): array
    {
        $monthlyList = [];

        for ($m = 1; $m <= 12; $m++) {
            $sessionsInMonth = $yearSessions->filter(function ($s) use ($m) {
                return $s->screening_date && (int) $s->screening_date->format('n') === $m;
            });

            $total = $sessionsInMonth->count();
            $uniquePatients = $sessionsInMonth->pluck('patient_id')->unique()->count();
            $reviewed = $sessionsInMonth->where('status', 'reviewed')->count();
            $pending = $sessionsInMonth->whereIn('status', ['pending_doctor_review', 'in_progress'])->count();

            $attention = 0;
            $kpsp = 0; $mchat = 0; $gpph = 0; $sdq = 0; $srq = 0;

            foreach ($sessionsInMonth as $s) {
                if ($this->isAttentionCase($s)) $attention++;
                if ($s->kpspScreening) $kpsp++;
                if ($s->mchatScreening) $mchat++;
                if ($s->gpphScreening) $gpph++;
                if ($s->sdqScreening) $sdq++;
                if ($s->srqScreening) $srq++;
            }

            $monthlyList[] = [
                'month' => $m,
                'month_name' => self::MONTH_NAMES[$m] ?? '',
                'short_name' => self::SHORT_MONTH_NAMES[$m] ?? '',
                'total_sessions' => $total,
                'unique_patients' => $uniquePatients,
                'reviewed_count' => $reviewed,
                'pending_count' => $pending,
                'attention_count' => $attention,
                'completion_rate' => $total > 0 ? round(($reviewed / $total) * 100, 1) : 0,
                'instruments' => [
                    'kpsp' => $kpsp,
                    'mchat' => $mchat,
                    'gpph' => $gpph,
                    'sdq' => $sdq,
                    'srq' => $srq,
                ],
            ];
        }

        return $monthlyList;
    }

    /**
     * Hitung rincian tahunan dari tahun-tahun yang tersedia.
     */
    private function calculateYearlyBreakdown(array $availableYears, ?int $nurseId, ?string $status): array
    {
        $yearlyList = [];

        foreach ($availableYears as $y) {
            $query = ScreeningSession::query()->whereYear('screening_date', $y);

            if ($nurseId) {
                $query->where('nurse_id', $nurseId);
            }

            if ($status) {
                $query->where('status', $status);
            }

            $sessions = $query->with([
                'kpspScreening:id,screening_session_id,category',
                'mchatScreening:id,screening_session_id,category',
                'gpphScreening:id,screening_session_id,category,examiner_doubtful',
                'sdqScreening:id,screening_session_id,total_difficulties_category',
                'srqScreening:id,screening_session_id,category,answers',
            ])->get();

            $total = $sessions->count();
            $uniquePatients = $sessions->pluck('patient_id')->unique()->count();
            $reviewed = $sessions->where('status', 'reviewed')->count();

            $attention = 0;
            foreach ($sessions as $s) {
                if ($this->isAttentionCase($s)) $attention++;
            }

            $yearlyList[] = [
                'year' => $y,
                'total_sessions' => $total,
                'unique_patients' => $uniquePatients,
                'reviewed_count' => $reviewed,
                'attention_count' => $attention,
                'completion_rate' => $total > 0 ? round(($reviewed / $total) * 100, 1) : 0,
            ];
        }

        return $yearlyList;
    }

    /**
     * Tentukan apakah sesi memiliki catatan klinis yang perlu perhatian / rujukan.
     */
    private function isAttentionCase(ScreeningSession $session): bool
    {
        if ($session->kpspScreening && in_array($session->kpspScreening->category, ['meragukan', 'penyimpangan', 'kemungkinan_penyimpangan'], true)) {
            return true;
        }

        if ($session->mchatScreening && $session->mchatScreening->category === 'risiko_sedang_tinggi') {
            return true;
        }

        if ($session->gpphScreening && ($session->gpphScreening->category === 'kemungkinan_gpph' || $session->gpphScreening->examiner_doubtful)) {
            return true;
        }

        if ($session->sdqScreening && in_array($session->sdqScreening->total_difficulties_category, ['abnormal', 'ambang_borderline'], true)) {
            return true;
        }

        if ($session->srqScreening) {
            if ($session->srqScreening->category === 'gangguan_mental_emosional_distres') {
                return true;
            }
            $answers = $session->srqScreening->answers;
            if (is_array($answers) && isset($answers[16]) && in_array($answers[16], [true, 1, '1'], true)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Dapatkan daftar alasan mengapa sesi membutuhkan perhatian klinis.
     */
    private function getAttentionReasons(ScreeningSession $session): array
    {
        $reasons = [];

        if ($session->kpspScreening) {
            if (in_array($session->kpspScreening->category, ['penyimpangan', 'kemungkinan_penyimpangan'], true)) {
                $reasons[] = 'KPSP: Penyimpangan';
            } elseif ($session->kpspScreening->category === 'meragukan') {
                $reasons[] = 'KPSP: Meragukan';
            }
        }

        if ($session->mchatScreening && $session->mchatScreening->category === 'risiko_sedang_tinggi') {
            $reasons[] = 'M-CHAT-R: Risiko Autisme';
        }

        if ($session->gpphScreening) {
            if ($session->gpphScreening->category === 'kemungkinan_gpph') {
                $reasons[] = 'GPPH: Kemungkinan GPPH';
            } elseif ($session->gpphScreening->examiner_doubtful) {
                $reasons[] = 'GPPH: Pemeriksa Ragu';
            }
        }

        if ($session->sdqScreening) {
            if ($session->sdqScreening->total_difficulties_category === 'abnormal') {
                $reasons[] = 'SDQ: Kesulitan Abnormal';
            } elseif ($session->sdqScreening->total_difficulties_category === 'ambang_borderline') {
                $reasons[] = 'SDQ: Kesulitan Ambang';
            }
        }

        if ($session->srqScreening) {
            if ($session->srqScreening->category === 'gangguan_mental_emosional_distres') {
                $reasons[] = 'SRQ-20: Distres Pengasuh';
            }
            $answers = $session->srqScreening->answers;
            if (is_array($answers) && isset($answers[16]) && in_array($answers[16], [true, 1, '1'], true)) {
                $reasons[] = 'SRQ-20: Peringatan Butir 17';
            }
        }

        return $reasons;
    }
}
