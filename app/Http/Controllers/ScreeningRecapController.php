<?php

namespace App\Http\Controllers;

use App\Models\Nurse;
use App\Models\ScreeningSession;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

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
     * Default dan fokus utama sistem adalah rekapitulasi bulanan register UPTD BLK-ABK.
     */
    public function index(Request $request): Response
    {
        $granularity = in_array($request->query('granularity'), ['bulanan', 'harian', 'mingguan', 'tahunan'], true)
            ? $request->query('granularity')
            : 'bulanan';

        $nurseId = $request->query('nurse_id') ? (int) $request->query('nurse_id') : null;
        $status = $request->query('status');
        $search = $request->query('search');

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
            'patient:id,medical_record_number,name,birth_date,gender,is_premature,address,education,school_name,parent_guardian_id',
            'patient.parentGuardian:id,user_id,address,phone',
            'nurse.user:id,name',
            'doctor.user:id,name',
            'screeningSessionInstruments:id,screening_session_id,instrument_code,status',
            'kpspScreening:id,screening_session_id,category,score,domain_scores',
            'mchatScreening:id,screening_session_id,category,score',
            'gpphScreening:id,screening_session_id,category,score,examiner_doubtful',
            'sdqScreening:id,screening_session_id,total_difficulties_category,total_difficulties_score,prosocial_category,prosocial_score',
            'srqScreening:id,screening_session_id,category,score,depression_score,anxiety_score,somatic_score,cognitive_score,energy_score,answers',
            'screeningInterpretations:id,screening_session_id,instrument_code,follow_up_decision,clinical_notes',
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

        // Tentukan periode aktif dan query sesi sesuai granularitas
        if ($granularity === 'harian') {
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

            $activeQuery = ScreeningSession::query()
                ->whereYear('screening_date', $selectedYear)
                ->whereMonth('screening_date', $selectedMonth)
                ->with($relations);

            if ($nurseId) $activeQuery->where('nurse_id', $nurseId);
            if ($status) $activeQuery->where('status', $status);
            $activeSessions = $activeQuery->orderBy('screening_date')->orderBy('id')->get();

            $monthName = self::MONTH_NAMES[$selectedMonth] ?? '';
            $periodLabel = "Bulanan: {$monthName} {$selectedYear}";
        }

        // Filter search lokal jika ada
        if ($search) {
            $searchLower = mb_strtolower($search);
            $activeSessions = $activeSessions->filter(function ($s) use ($searchLower) {
                $name = mb_strtolower($s->patient?->name ?? '');
                $mrn = mb_strtolower($s->patient?->medical_record_number ?? '');
                return str_contains($name, $searchLower) || str_contains($mrn, $searchLower);
            });
        }

        // Ambil hanya sesi skrining terakhir per anak untuk rekapitulasi pada periode ini
        $activeSessions = $activeSessions
            ->sortByDesc('screening_date')
            ->sortByDesc('id')
            ->unique('patient_id')
            ->sortBy('screening_date')
            ->sortBy('id')
            ->values();

        // Bangun data Register Bulanan UPTD BLK-ABK
        [$registerRows, $registerTotals] = $this->buildRegisterData($activeSessions);

        // Hitung metrik ringkasan untuk periode aktif
        $summary = $this->calculateSummary($activeSessions);
        $instrumentBreakdown = $this->calculateInstrumentBreakdown($activeSessions);
        $statusBreakdown = $this->calculateStatusBreakdown($activeSessions);
        $demographics = $this->calculateDemographics($activeSessions);

        // Ambil sesi tahunan untuk konteks tren
        $allYearSessions = ScreeningSession::query()
            ->whereYear('screening_date', $selectedYear)
            ->when($nurseId, fn ($q) => $q->where('nurse_id', $nurseId))
            ->when($status, fn ($q) => $q->where('status', $status))
            ->with($relations)
            ->get();

        if ($granularity === 'mingguan') {
            $weekStart = CarbonImmutable::now()->setISODate($selectedYear, $selectedWeek)->startOfWeek();
            $dailyData = $this->calculateDaysInWeekBreakdown($weekStart, $activeSessions);
            $weeklyDaysData = $dailyData;
        } elseif ($granularity === 'harian') {
            $monthSessionsForDaily = $allYearSessions->filter(fn ($s) => $s->screening_date && (int) $s->screening_date->format('n') === $selectedMonth);
            $dailyData = $this->calculateDailyBreakdown($selectedYear, $selectedMonth, $monthSessionsForDaily);
            $weeklyDaysData = [];
        } else {
            $monthSessionsForDaily = ($granularity === 'bulanan') ? $activeSessions : $allYearSessions->filter(fn ($s) => $s->screening_date && (int) $s->screening_date->format('n') === $selectedMonth);
            $dailyData = $this->calculateDailyBreakdown($selectedYear, $selectedMonth, $monthSessionsForDaily);
            $weeklyDaysData = [];
        }

        $monthSessionsForWeekly = ($granularity === 'bulanan') ? $activeSessions : $allYearSessions->filter(fn ($s) => $s->screening_date && (int) $s->screening_date->format('n') === $selectedMonth);
        $weeklyData = $this->calculateWeeklyBreakdown($selectedYear, $selectedMonth, $monthSessionsForWeekly);
        $availableWeeks = $this->generateAvailableWeeks($selectedYear, $allYearSessions);
        $monthlyData = $this->calculateMonthlyBreakdown($selectedYear, $allYearSessions);
        $yearlyData = $this->calculateYearlyBreakdown($availableYears, $nurseId, $status);
        $annualReports = $this->calculateAnnualComprehensiveReports($selectedYear, $allYearSessions);

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

        $availableMonths = [];
        foreach (self::MONTH_NAMES as $num => $name) {
            $availableMonths[] = [
                'value' => $num,
                'label' => $name,
                'short' => self::SHORT_MONTH_NAMES[$num],
            ];
        }

        $nurses = Nurse::with('user:id,name')->get()->map(function ($nurse) {
            return [
                'id' => $nurse->id,
                'name' => $nurse->user?->name ?? "Perawat #{$nurse->id}",
            ];
        });

        $formattedSessions = $activeSessions->map(function ($s) {
            $attentionReasons = $this->getAttentionReasons($s);
            $instruments = $s->screeningSessionInstruments->map(function ($inst) use ($s) {
                $category = null;
                $hasAlert = false;
                if ($inst->status === 'completed') {
                    if ($inst->instrument_code === 'KPSP') {
                        $category = $s->kpspScreening?->category;
                    } elseif (in_array($inst->instrument_code, ['MCHAT', 'M-CHAT'], true)) {
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

        // Bulan sebelumnya dan sesudahnya untuk navigasi bulanan yang mulus
        $currentMonthDate = CarbonImmutable::createFromDate($selectedYear, $selectedMonth, 1);
        $prevMonthObj = $currentMonthDate->subMonth();
        $nextMonthObj = $currentMonthDate->addMonth();

        return Inertia::render('ScreeningSessions/Recap', [
            'filters' => [
                'granularity' => $granularity,
                'year' => $selectedYear,
                'month' => $selectedMonth,
                'date' => $selectedDate,
                'week' => $selectedWeek,
                'nurse_id' => $nurseId,
                'status' => $status,
                'search' => $search,
            ],
            'institutionInfo' => [
                'name' => 'UPTD BALAI LAYANAN KESEHATAN ANAK BERKEBUTUHAN KHUSUS',
                'city' => 'BALIKPAPAN',
                'month_name' => self::MONTH_NAMES[$selectedMonth] ?? 'Oktober',
                'year' => $selectedYear,
            ],
            'availableYears' => $availableYears,
            'availableMonths' => $availableMonths,
            'availableWeeks' => $availableWeeks,
            'activeDates' => $activeDates,
            'prevDate' => $prevDate,
            'nextDate' => $nextDate,
            'prevWeek' => $prevWeek,
            'nextWeek' => $nextWeek,
            'prevMonth' => [
                'year' => $prevMonthObj->year,
                'month' => $prevMonthObj->month,
                'label' => self::MONTH_NAMES[$prevMonthObj->month] . ' ' . $prevMonthObj->year,
            ],
            'nextMonth' => [
                'year' => $nextMonthObj->year,
                'month' => $nextMonthObj->month,
                'label' => self::MONTH_NAMES[$nextMonthObj->month] . ' ' . $nextMonthObj->year,
            ],
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
            'annualReports' => $annualReports,
            'sessions' => $formattedSessions,
            'registerRows' => $registerRows,
            'registerTotals' => $registerTotals,
            'periodLabel' => $periodLabel,
        ]);
    }

    /**
     * Export register rekapitulasi bulanan ke format Excel (.xls) atau CSV.
     */
    public function export(Request $request): HttpResponse|StreamedResponse
    {
        $year = (int) ($request->query('year') ?? date('Y'));
        $month = (int) ($request->query('month') ?? date('n'));
        if ($month < 1 || $month > 12) $month = 10;

        $format = strtolower((string) ($request->query('format') ?? 'excel'));
        $nurseId = $request->query('nurse_id') ? (int) $request->query('nurse_id') : null;
        $status = $request->query('status');

        $monthName = self::MONTH_NAMES[$month] ?? 'Bulan';

        $relations = [
            'patient:id,medical_record_number,name,birth_date,gender,is_premature,address,education,school_name,parent_guardian_id',
            'patient.parentGuardian:id,user_id,address,phone',
            'nurse.user:id,name',
            'doctor.user:id,name',
            'kpspScreening:id,screening_session_id,category,score,domain_scores',
            'mchatScreening:id,screening_session_id,category,score',
            'gpphScreening:id,screening_session_id,category,score,examiner_doubtful',
            'sdqScreening:id,screening_session_id,total_difficulties_category,total_difficulties_score,prosocial_category,prosocial_score',
            'srqScreening:id,screening_session_id,category,score,depression_score,anxiety_score,somatic_score,cognitive_score,energy_score,answers',
            'screeningInterpretations:id,screening_session_id,instrument_code,follow_up_decision,clinical_notes',
        ];

        $sessions = ScreeningSession::query()
            ->whereYear('screening_date', $year)
            ->whereMonth('screening_date', $month)
            ->when($nurseId, fn ($q) => $q->where('nurse_id', $nurseId))
            ->when($status, fn ($q) => $q->where('status', $status))
            ->with($relations)
            ->orderBy('screening_date')
            ->orderBy('id')
            ->get();

        // Ambil hanya sesi skrining terakhir per anak di bulan tersebut untuk ekspor
        $sessions = $sessions
            ->sortByDesc('screening_date')
            ->sortByDesc('id')
            ->unique('patient_id')
            ->sortBy('screening_date')
            ->sortBy('id')
            ->values();

        [$registerRows, $registerTotals] = $this->buildRegisterData($sessions);

        if ($format === 'csv') {
            return $this->exportCsv($registerRows, $registerTotals, $monthName, $year);
        }

        return $this->exportXlsx($registerRows, $registerTotals, $monthName, $year);
    }

    /**
     * Bangun data baris register laporan bulanan UPTD BLK-ABK.
     * KMPE disesuaikan menjadi SDQ dan SRQ.
     */
    private function buildRegisterData($sessions): array
    {
        $rows = [];
        $totals = [
            'total' => 0,
            'male' => 0,
            'female' => 0,
            'case_new' => 0,
            'case_old' => 0,
            'kpsp_motorik_kasar' => 0,
            'kpsp_motorik_halus' => 0,
            'kpsp_bicara_bahasa' => 0,
            'kpsp_sosialisasi' => 0,
            'sdq' => 0,
            'mchat' => 0,
            'gpph' => 0,
            'srq' => 0,
            'psikolog' => 0,
            'aba' => 0,
            'ot' => 0,
            'tw' => 0,
            'si' => 0,
            'fisioterapi' => 0,
            'perawatan_medis' => 0,
            'konseling' => 0,
            'rehabilitasi' => 0,
            'rujukan_ke' => 0,
            'sekolah_reguler' => 0,
            'sekolah_inklusi' => 0,
            'slb' => 0,
            'panti' => 0,
            'tidak_sekolah' => 0,
        ];

        $index = 1;
        foreach ($sessions as $s) {
            $patient = $s->patient;
            if (! $patient) continue;

            $isMale = ($patient->gender === 'L');
            $isFemale = ($patient->gender === 'P');

            // Kasus Baru / Lama
            if ($s->case_type) {
                $isCaseNew = ($s->case_type === 'baru');
            } else {
                $hasPrior = ScreeningSession::where('patient_id', $s->patient_id)
                    ->where('screening_date', '<', $s->screening_date)
                    ->where('id', '!=', $s->id)
                    ->exists();
                $isCaseNew = ! $hasPrior;
            }
            $isCaseOld = ! $isCaseNew;

            // Umur (Tahun.Bulan desimal sesuai format register UPTD)
            $ageYears = floor($s->age_months / 12);
            $ageRemMonths = $s->age_months % 12;
            $ageDisplay = "{$ageYears}.{$ageRemMonths}";

            // KPSP 4 Domain
            $kpsp = $s->kpspScreening;
            $ggKasar = null; $ggHalus = null; $ggBicara = null; $ggSosialisasi = null;
            if ($kpsp) {
                $ds = $kpsp->domain_scores;
                if (is_array($ds) && isset($ds['domains'])) {
                    $doms = $ds['domains'];
                    $lacking = $ds['lacking_domains'] ?? [];
                    if (in_array('Gerak Kasar', $lacking, true) || ($doms['gerak_kasar']['percentage'] ?? 100) < 100 || ($doms['gerak_kasar']['status'] ?? '') !== 'sesuai') {
                        $ggKasar = 1;
                    }
                    if (in_array('Gerak Halus', $lacking, true) || ($doms['gerak_halus']['percentage'] ?? 100) < 100 || ($doms['gerak_halus']['status'] ?? '') !== 'sesuai') {
                        $ggHalus = 1;
                    }
                    if (in_array('Bicara dan Bahasa', $lacking, true) || ($doms['bicara_bahasa']['percentage'] ?? 100) < 100 || ($doms['bicara_bahasa']['status'] ?? '') !== 'sesuai') {
                        $ggBicara = 1;
                    }
                    if (in_array('Sosialisasi dan Kemandirian', $lacking, true) || ($doms['sosialisasi_kemandirian']['percentage'] ?? 100) < 100 || ($doms['sosialisasi_kemandirian']['status'] ?? '') !== 'sesuai') {
                        $ggSosialisasi = 1;
                    }
                } elseif (in_array($kpsp->category, ['meragukan', 'penyimpangan', 'kemungkinan_penyimpangan'], true)) {
                    $ggBicara = 1;
                }
            }

            // Perilaku Emosional (KMPE disesuaikan -> SDQ, M-CHAT-R, GPPH, SRQ-20)
            $hasSdq = null;
            if ($s->sdqScreening && in_array($s->sdqScreening->total_difficulties_category, ['abnormal', 'ambang_borderline'], true)) {
                $hasSdq = 1;
            }

            $hasMchat = null;
            if ($s->mchatScreening && in_array($s->mchatScreening->category, ['risiko_tinggi', 'risiko_sedang', 'risiko_sedang_tinggi'], true)) {
                $hasMchat = 1;
            }

            $hasGpph = null;
            if ($s->gpphScreening && ($s->gpphScreening->category === 'positif' || $s->gpphScreening->category === 'kemungkinan_gpph' || $s->gpphScreening->examiner_doubtful)) {
                $hasGpph = 1;
            }

            $hasSrq = null;
            if ($s->srqScreening) {
                $answers = $s->srqScreening->answers;
                $hasSuicide = is_array($answers) && isset($answers[16]) && in_array($answers[16], [true, 1, '1'], true);
                if ($s->srqScreening->category === 'gangguan_mental_emosional_distres' || $s->srqScreening->score >= 6 || $hasSuicide) {
                    $hasSrq = 1;
                }
            }

            // Layanan Kesehatan yang Diberikan (Intervensi)
            $interventions = is_array($s->interventions) ? $s->interventions : [];
            $doctorDecisions = $s->screeningInterpretations->pluck('follow_up_decision')->filter()->all();

            $hasPsikolog = in_array('psikolog', $interventions, true) ? 1 : null;
            $hasAba = in_array('aba', $interventions, true) ? 1 : null;
            $hasOt = in_array('ot', $interventions, true) ? 1 : null;
            $hasTw = in_array('tw', $interventions, true) ? 1 : null;
            $hasSi = in_array('si', $interventions, true) ? 1 : null;
            $hasFisioterapi = in_array('fisioterapi', $interventions, true) ? 1 : null;
            $hasMedis = (in_array('perawatan_medis', $interventions, true) || in_array('medis', $interventions, true)) ? 1 : null;
            $hasKonseling = (in_array('konseling', $interventions, true) || in_array('konseling_stimulasi', $doctorDecisions, true)) ? 1 : null;
            $hasRehab = in_array('rehabilitasi', $interventions, true) ? 1 : null;
            $hasRujukan = (in_array('rujukan', $interventions, true) || in_array('rujuk_rs', $doctorDecisions, true)) ? 1 : null;
            $rujukanTarget = $s->referral_target ?: ($hasRujukan ? 'RS Rujukan' : null);

            // Pendidikan
            $edu = $patient->education ?? 'tidak_sekolah';
            $isReguler = ($edu === 'sekolah_reguler') ? 1 : null;
            $isInklusi = ($edu === 'sekolah_inklusi') ? 1 : null;
            $isSlb = ($edu === 'slb') ? 1 : null;
            $isPanti = ($edu === 'panti') ? 1 : null;
            $isTidakSekolah = ($edu === 'tidak_sekolah' || empty($edu)) ? 1 : null;

            // Keterangan: Nama Sekolah anak (sesuai format register UPTD BLK-ABK)
            $schoolName = $patient->school_name ?: ($s->recap_notes ?: '-');

            $effectiveAddress = $patient->address ?: ($patient->parentGuardian?->address ?: '-');

            $row = [
                'no' => $index++,
                'session_id' => $s->id,
                'medical_record_number' => $patient->medical_record_number,
                'name' => $patient->name,
                'gender' => $patient->gender,
                'is_male' => $isMale ? 1 : null,
                'is_female' => $isFemale ? 1 : null,
                'is_case_new' => $isCaseNew ? 1 : null,
                'is_case_old' => $isCaseOld ? 1 : null,
                'referral_from' => $s->referral_source ?: '-',
                'address' => $effectiveAddress,
                'birth_date' => $patient->birth_date ? $patient->birth_date->format('d/m/Y') : '-',
                'age_display' => $ageDisplay,
                'age_months' => $s->age_months,
                'school_name' => $patient->school_name,
                // KPSP 4 Domain
                'gg_motorik_kasar' => $ggKasar,
                'gg_motorik_halus' => $ggHalus,
                'gg_bicara_bahasa' => $ggBicara,
                'gg_sosialisasi' => $ggSosialisasi,
                // Perilaku Emosional
                'sdq' => $hasSdq,
                'mchat' => $hasMchat,
                'gpph' => $hasGpph,
                'srq' => $hasSrq,
                // Layanan / Intervensi
                'psikolog' => $hasPsikolog,
                'aba' => $hasAba,
                'ot' => $hasOt,
                'tw' => $hasTw,
                'si' => $hasSi,
                'fisioterapi' => $hasFisioterapi,
                'perawatan_medis' => $hasMedis,
                'konseling' => $hasKonseling,
                'rehabilitasi' => $hasRehab,
                'rujukan_ke' => $rujukanTarget,
                // Pendidikan
                'sekolah_reguler' => $isReguler,
                'sekolah_inklusi' => $isInklusi,
                'slb' => $isSlb,
                'panti' => $isPanti,
                'tidak_sekolah' => $isTidakSekolah,
                'keterangan' => $schoolName,
                'status' => $s->status,
                'screening_date' => $s->screening_date ? $s->screening_date->toDateString() : null,
            ];

            // Akumulasi total
            $totals['total']++;
            if ($isMale) $totals['male']++;
            if ($isFemale) $totals['female']++;
            if ($isCaseNew) $totals['case_new']++;
            if ($isCaseOld) $totals['case_old']++;
            if ($ggKasar) $totals['kpsp_motorik_kasar']++;
            if ($ggHalus) $totals['kpsp_motorik_halus']++;
            if ($ggBicara) $totals['kpsp_bicara_bahasa']++;
            if ($ggSosialisasi) $totals['kpsp_sosialisasi']++;
            if ($hasSdq) $totals['sdq']++;
            if ($hasMchat) $totals['mchat']++;
            if ($hasGpph) $totals['gpph']++;
            if ($hasSrq) $totals['srq']++;
            if ($hasPsikolog) $totals['psikolog']++;
            if ($hasAba) $totals['aba']++;
            if ($hasOt) $totals['ot']++;
            if ($hasTw) $totals['tw']++;
            if ($hasSi) $totals['si']++;
            if ($hasFisioterapi) $totals['fisioterapi']++;
            if ($hasMedis) $totals['perawatan_medis']++;
            if ($hasKonseling) $totals['konseling']++;
            if ($hasRehab) $totals['rehabilitasi']++;
            if ($rujukanTarget) $totals['rujukan_ke']++;
            if ($isReguler) $totals['sekolah_reguler']++;
            if ($isInklusi) $totals['sekolah_inklusi']++;
            if ($isSlb) $totals['slb']++;
            if ($isPanti) $totals['panti']++;
            if ($isTidakSekolah) $totals['tidak_sekolah']++;

            $rows[] = $row;
        }

        return [$rows, $totals];
    }

    /**
     * Export register dalam format Excel (.xls) HTML-based.
     */
    /**
     * Export register bulanan SDIDTK UPTD BLK-ABK dalam format OpenXML Spreadsheet (.xlsx) asli.
     */
    /**
     * Export register bulanan SDIDTK UPTD BLK-ABK dalam format OpenXML Spreadsheet (.xlsx) asli.
     */
    private function exportXlsx(array $rows, array $totals, string $monthName, int $year): HttpResponse
    {
        $filename = "Rekapitulasi_SDIDTK_UPTD_BLK_ABK_{$monthName}_{$year}.xlsx";

        $cHeader = '#D9E1F2';
        $cPerkembangan = '#E2EFDA';
        $cEmosional = '#FCE4D6';
        $cLayanan = '#FFF2CC';
        $cPendidikan = '#EDEDED';
        $cNum = '#F2F2F2';
        $cTotal = '#D9D9D9';

        $hCell = function (string $text, string $bg, string $align = 'center', bool $bold = true): string {
            $content = $bold ? "<b>{$text}</b>" : $text;
            return "<style bgcolor=\"{$bg}\" border=\"thin\"><{$align}>{$content}</{$align}></style>";
        };

        $sheets = [];

        // Row 1 - 3: Informasi Lembaga (persis format register UPTD)
        $sheets[] = ['<b>RUMAH PUSKESMAS / LEMBAGA</b>', null, '<b>: UPTD BALAI LAYANAN KESEHATAN ANAK BERKEBUTUHAN KHUSUS</b>'];
        $sheets[] = ['<b>KAB/KOTA</b>', null, '<b>: BALIKPAPAN</b>'];
        $sheets[] = ['<b>BULAN</b>', null, '<b>: ' . htmlspecialchars($monthName) . '</b>', null, '<b>TAHUN ' . $year . '</b>'];
        $sheets[] = array_fill(0, 34, null); // Row 4: Spacer baris kosong

        // Row 5: Header Grup Tingkat 1 (Semua 34 kolom memiliki style border utuh)
        $r5 = [
            $hCell('NO', $cHeader),
            $hCell('NAMA PASIEN/ANAK', $cHeader),
            $hCell('JENIS KELAMIN', $cHeader),
            $hCell('', $cHeader),
            $hCell('KASUS', $cHeader),
            $hCell('', $cHeader),
            $hCell('RUJUKAN DARI', $cHeader),
            $hCell('ALAMAT', $cHeader),
            $hCell('USIA/TGL LAHIR', $cHeader),
            $hCell('USIA', $cHeader),
            $hCell('HASIL DETEKSI DINI PENYIMPANGAN PERKEMBANGAN', $cPerkembangan),
            $hCell('', $cPerkembangan),
            $hCell('', $cPerkembangan),
            $hCell('', $cPerkembangan),
            $hCell('DETEKSI DINI PENYIMPANGAN PERILAKU EMOSIONAL', $cEmosional),
            $hCell('', $cEmosional),
            $hCell('', $cEmosional),
            $hCell('', $cEmosional),
            $hCell('LAYANAN KESEHATAN / INTERVENSI YANG DIBERIKAN', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('PENDIDIKAN', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('KETERANGAN (NAMA SEKOLAH)', $cHeader),
        ];
        $sheets[] = $r5;

        // Row 6: Header Sub-kolom Tingkat 2
        $r6 = [
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('LAKI-LAKI', $cHeader),
            $hCell('PEREMPUAN', $cHeader),
            $hCell('BARU', $cHeader),
            $hCell('LAMA', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('KPSP 4 DOMAIN', $cPerkembangan),
            $hCell('', $cPerkembangan),
            $hCell('', $cPerkembangan),
            $hCell('', $cPerkembangan),
            $hCell('SDQ, M-CHAT, GPPH, SRQ', $cEmosional),
            $hCell('', $cEmosional),
            $hCell('', $cEmosional),
            $hCell('', $cEmosional),
            $hCell('PSIKOLOG', $cLayanan),
            $hCell('ABA', $cLayanan),
            $hCell('OT', $cLayanan),
            $hCell('TW', $cLayanan),
            $hCell('SI', $cLayanan),
            $hCell('FISIOTERAPI', $cLayanan),
            $hCell('MEDIS', $cLayanan),
            $hCell('KONSELING', $cLayanan),
            $hCell('REHABILITASI', $cLayanan),
            $hCell('RUJUKAN KE', $cLayanan),
            $hCell('Sekolah Reguler', $cPendidikan),
            $hCell('Sekolah Inklusi', $cPendidikan),
            $hCell('SLB', $cPendidikan),
            $hCell('PANTI', $cPendidikan),
            $hCell('TDK SEKOLAH', $cPendidikan),
            $hCell('', $cHeader),
        ];
        $sheets[] = $r6;

        // Row 7: Header Sub-kolom Tingkat 3 (Rincian Domain KPSP & Instrumen Emosional)
        $r7 = [
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('', $cHeader),
            $hCell('GG MOTORIK KASAR', $cPerkembangan),
            $hCell('GG MOTORIK HALUS', $cPerkembangan),
            $hCell('GG BICARA/BAHASA', $cPerkembangan),
            $hCell('GG SOSIALISASI', $cPerkembangan),
            $hCell('SDQ (Anak)', $cEmosional),
            $hCell('M-CHAT (Autis)', $cEmosional),
            $hCell('GPPH', $cEmosional),
            $hCell('SRQ-20 (Pengasuh)', $cEmosional),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cLayanan),
            $hCell('', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('', $cPendidikan),
            $hCell('', $cHeader),
        ];
        $sheets[] = $r7;

        // Row 8: Penomoran Kolom Standar Register UPTD (1 s/d 34)
        $r8 = [];
        for ($c = 1; $c <= 34; $c++) {
            $r8[] = $hCell((string) $c, $cNum, 'center', false);
        }
        $sheets[] = $r8;

        // Row 9+: Data Rows Pasien
        foreach ($rows as $r) {
            $sheets[] = [
                '<style border="thin"><center>' . $r['no'] . '</center></style>',
                '<style border="thin"><left>' . htmlspecialchars($r['name']) . '</left></style>',
                '<style border="thin"><center>' . ($r['is_male'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['is_female'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['is_case_new'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['is_case_old'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . htmlspecialchars($r['referral_from'] !== '-' ? $r['referral_from'] : '') . '</center></style>',
                '<style border="thin"><left>' . htmlspecialchars($r['address']) . '</left></style>',
                '<style border="thin"><center>' . htmlspecialchars($r['birth_date']) . '</center></style>',
                '<style border="thin"><center>' . htmlspecialchars($r['age_display']) . '</center></style>',
                '<style border="thin"><center>' . ($r['gg_motorik_kasar'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['gg_motorik_halus'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['gg_bicara_bahasa'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['gg_sosialisasi'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['sdq'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['mchat'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['gpph'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['srq'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['psikolog'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['aba'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['ot'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['tw'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['si'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['fisioterapi'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['perawatan_medis'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['konseling'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['rehabilitasi'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . htmlspecialchars($r['rujukan_ke'] ?? '') . '</center></style>',
                '<style border="thin"><center>' . ($r['sekolah_reguler'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['sekolah_inklusi'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['slb'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['panti'] ? '1' : '') . '</center></style>',
                '<style border="thin"><center>' . ($r['tidak_sekolah'] ? '1' : '') . '</center></style>',
                '<style border="thin"><left>' . htmlspecialchars($r['keterangan'] !== '-' ? $r['keterangan'] : '-') . '</left></style>',
            ];
        }

        // Summary Total Row
        $totCell = fn ($val) => '<style bgcolor="' . $cTotal . '" border="thin"><center><b>' . $val . '</b></center></style>';
        $sheets[] = [
            $totCell('TOTAL'),
            $totCell(''),
            $totCell($totals['male']),
            $totCell($totals['female']),
            $totCell($totals['case_new']),
            $totCell($totals['case_old']),
            $totCell('-'),
            $totCell('-'),
            $totCell('-'),
            $totCell('-'),
            $totCell($totals['kpsp_motorik_kasar']),
            $totCell($totals['kpsp_motorik_halus']),
            $totCell($totals['kpsp_bicara_bahasa']),
            $totCell($totals['kpsp_sosialisasi']),
            $totCell($totals['sdq']),
            $totCell($totals['mchat']),
            $totCell($totals['gpph']),
            $totCell($totals['srq']),
            $totCell($totals['psikolog']),
            $totCell($totals['aba']),
            $totCell($totals['ot']),
            $totCell($totals['tw']),
            $totCell($totals['si']),
            $totCell($totals['fisioterapi']),
            $totCell($totals['perawatan_medis']),
            $totCell($totals['konseling']),
            $totCell($totals['rehabilitasi']),
            $totCell($totals['rujukan_ke']),
            $totCell($totals['sekolah_reguler']),
            $totCell($totals['sekolah_inklusi']),
            $totCell($totals['slb']),
            $totCell($totals['panti']),
            $totCell($totals['tidak_sekolah']),
            $totCell('-'),
        ];

        $xlsx = \Shuchkin\SimpleXLSXGen::fromArray($sheets);
        $xlsx->setTitle("Register SDIDTK UPTD BLK-ABK {$monthName} {$year}")
            ->setSubject("Register Bulanan SDIDTK UPTD BLK-ABK {$monthName} {$year}")
            ->setAuthor('UPTD BLK-ABK Balikpapan')
            ->setCompany('UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus')
            ->setDefaultFont('Calibri')
            ->setDefaultFontSize(10);

        // Merge cells untuk header bertingkat 3 level
        $xlsx->mergeCells('A5:A7'); // NO
        $xlsx->mergeCells('B5:B7'); // NAMA PASIEN/ANAK
        $xlsx->mergeCells('C5:D5'); // JENIS KELAMIN
        $xlsx->mergeCells('C6:C7'); // LAKI-LAKI
        $xlsx->mergeCells('D6:D7'); // PEREMPUAN
        $xlsx->mergeCells('E5:F5'); // KASUS
        $xlsx->mergeCells('E6:E7'); // BARU
        $xlsx->mergeCells('F6:F7'); // LAMA
        $xlsx->mergeCells('G5:G7'); // RUJUKAN DARI
        $xlsx->mergeCells('H5:H7'); // ALAMAT
        $xlsx->mergeCells('I5:I7'); // USIA/TGL LAHIR
        $xlsx->mergeCells('J5:J7'); // USIA
        $xlsx->mergeCells('K5:N5'); // HASIL DETEKSI DINI PENYIMPANGAN PERKEMBANGAN
        $xlsx->mergeCells('K6:N6'); // KPSP 4 DOMAIN
        $xlsx->mergeCells('O5:R5'); // DETEKSI DINI PENYIMPANGAN PERILAKU EMOSIONAL
        $xlsx->mergeCells('O6:R6'); // SDQ, M-CHAT, GPPH, SRQ
        $xlsx->mergeCells('S5:AB5'); // LAYANAN KESEHATAN / INTERVENSI YANG DIBERIKAN
        $xlsx->mergeCells('S6:S7'); // PSIKOLOG
        $xlsx->mergeCells('T6:T7'); // ABA
        $xlsx->mergeCells('U6:U7'); // OT
        $xlsx->mergeCells('V6:V7'); // TW
        $xlsx->mergeCells('W6:W7'); // SI
        $xlsx->mergeCells('X6:X7'); // FISIOTERAPI
        $xlsx->mergeCells('Y6:Y7'); // MEDIS
        $xlsx->mergeCells('Z6:Z7'); // KONSELING
        $xlsx->mergeCells('AA6:AA7'); // REHABILITASI
        $xlsx->mergeCells('AB6:AB7'); // RUJUKAN KE
        $xlsx->mergeCells('AC5:AG5'); // PENDIDIKAN
        $xlsx->mergeCells('AC6:AC7'); // Sekolah Reguler
        $xlsx->mergeCells('AD6:AD7'); // Sekolah Inklusi
        $xlsx->mergeCells('AE6:AE7'); // SLB
        $xlsx->mergeCells('AF6:AF7'); // PANTI
        $xlsx->mergeCells('AG6:AG7'); // TDK SEKOLAH
        $xlsx->mergeCells('AH5:AH7'); // KETERANGAN (NAMA SEKOLAH)

        // Merge sel untuk TOTAL (A..B)
        $totalRowIndex = count($rows) + 9;
        $xlsx->mergeCells("A{$totalRowIndex}:B{$totalRowIndex}");

        // Lebar kolom presisi sesuai kustomisasi template pengguna
        $customColWidths = [
            1 => 6,
            2 => 34,
            3 => 11.85,
            4 => 11.85,
            5 => 7,
            6 => 7,
            7 => 14,
            8 => 30,
            9 => 14.42,
            10 => 8,
            11 => 18.28,
            12 => 17.71,
            13 => 17.57,
            14 => 16,
            15 => 10.57,
            16 => 13.57,
            17 => 10,
            18 => 16.71,
            19 => 9.71,
            20 => 9,
            21 => 9,
            22 => 9,
            23 => 9,
            24 => 11.14,
            25 => 6.71,
            26 => 11.28,
            27 => 12.28,
            28 => 14,
            29 => 14.14,
            30 => 12.85,
            31 => 12,
            32 => 12,
            33 => 12.28,
            34 => 33,
        ];
        foreach ($customColWidths as $colIdx => $width) {
            $xlsx->setColWidth($colIdx, $width);
        }

        // Kunci baris header (1 s/d 8) dan 2 kolom identitas pertama (A: NO & B: NAMA)
        $xlsx->freezePanes('C9');

        $rawXlsx = (string) $xlsx;
        $xlsxContent = $rawXlsx;

        // Post-processing OpenXML: Ubah invalid shared-string tag <c r="..." t="s" s="..."/>
        // menjadi standar resmi OpenXML <c r="..." s="..."/> agar 100% border ter-render sempurna
        // di ONLYOFFICE, Microsoft Excel, LibreOffice Calc, dan Google Sheets.
        if (class_exists(\ZipArchive::class)) {
            $tempFile = tempnam(sys_get_temp_dir(), 'xlsx_recap_');
            file_put_contents($tempFile, $rawXlsx);

            $zip = new \ZipArchive();
            if ($zip->open($tempFile) === true) {
                $sheetXml = $zip->getFromName('xl/worksheets/sheet1.xml');
                if ($sheetXml !== false) {
                    $sheetXml = preg_replace('/<c r="([A-Z0-9]+)" t="s" s="(\d+)"\/>/', '<c r="$1" s="$2"/>', $sheetXml);
                    $zip->addFromString('xl/worksheets/sheet1.xml', $sheetXml);
                }
                $zip->close();
                $xlsxContent = file_get_contents($tempFile);
            }
            @unlink($tempFile);
        }

        return response($xlsxContent, 200, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
            'Cache-Control' => 'max-age=0, no-cache, no-store, must-revalidate',
            'Pragma' => 'no-cache',
        ]);
    }

    /**
     * Export register dalam format CSV dengan UTF-8 BOM.
     */
    private function exportCsv(array $rows, array $totals, string $monthName, int $year): StreamedResponse
    {
        $filename = "Rekapitulasi_SDIDTK_UPTD_BLK_ABK_{$monthName}_{$year}.csv";

        return response()->streamDownload(function () use ($rows, $totals, $monthName, $year) {
            $handle = fopen('php://output', 'w');
            // Write UTF-8 BOM agar terbaca sempurna di Microsoft Excel
            fprintf($handle, chr(0xEF) . chr(0xBB) . chr(0xBF));

            // Header Instansi
            fputcsv($handle, ['RUMAH PUSKESMAS / LEMBAGA', ': UPTD BALAI LAYANAN KESEHATAN ANAK BERKEBUTUHAN KHUSUS']);
            fputcsv($handle, ['KAB/KOTA', ': BALIKPAPAN']);
            fputcsv($handle, ['BULAN', ': ' . $monthName, 'TAHUN', $year]);
            fputcsv($handle, []);

            // Kolom Header
            fputcsv($handle, [
                'No',
                'Nama Pasien/Anak',
                'Laki-laki',
                'Perempuan',
                'Kasus Baru',
                'Kasus Lama',
                'Rujukan Dari',
                'Alamat',
                'Tgl Lahir',
                'Usia',
                'KPSP GG Motorik Kasar',
                'KPSP GG Motorik Halus',
                'KPSP GG Bicara/Bahasa',
                'KPSP GG Sosialisasi/Kemandirian',
                'SDQ (Perilaku Emosional)',
                'M-CHAT-R (Autis)',
                'GPPH',
                'SRQ-20 (Kesehatan Mental Pengasuh)',
                'Psikolog',
                'ABA',
                'Terapi Okupasi (OT)',
                'Terapi Wicara (TW)',
                'Sensori Integrasi (SI)',
                'Fisioterapi',
                'Perawatan Medis',
                'Konseling',
                'Rehabilitasi',
                'Rujukan Ke',
                'Sekolah Reguler',
                'Sekolah Inklusi',
                'SLB',
                'Panti',
                'Tidak Sekolah',
                'Keterangan (Nama Sekolah)',
            ]);

            foreach ($rows as $r) {
                fputcsv($handle, [
                    $r['no'],
                    $r['name'],
                    $r['is_male'] ? '1' : '',
                    $r['is_female'] ? '1' : '',
                    $r['is_case_new'] ? '1' : '',
                    $r['is_case_old'] ? '1' : '',
                    $r['referral_from'] !== '-' ? $r['referral_from'] : '',
                    $r['address'],
                    $r['birth_date'],
                    $r['age_display'],
                    $r['gg_motorik_kasar'] ? '1' : '',
                    $r['gg_motorik_halus'] ? '1' : '',
                    $r['gg_bicara_bahasa'] ? '1' : '',
                    $r['gg_sosialisasi'] ? '1' : '',
                    $r['sdq'] ? '1' : '',
                    $r['mchat'] ? '1' : '',
                    $r['gpph'] ? '1' : '',
                    $r['srq'] ? '1' : '',
                    $r['psikolog'] ? '1' : '',
                    $r['aba'] ? '1' : '',
                    $r['ot'] ? '1' : '',
                    $r['tw'] ? '1' : '',
                    $r['si'] ? '1' : '',
                    $r['fisioterapi'] ? '1' : '',
                    $r['perawatan_medis'] ? '1' : '',
                    $r['konseling'] ? '1' : '',
                    $r['rehabilitasi'] ? '1' : '',
                    $r['rujukan_ke'] ?? '',
                    $r['sekolah_reguler'] ? '1' : '',
                    $r['sekolah_inklusi'] ? '1' : '',
                    $r['slb'] ? '1' : '',
                    $r['panti'] ? '1' : '',
                    $r['tidak_sekolah'] ? '1' : '',
                    $r['keterangan'] !== '-' ? $r['keterangan'] : '',
                ]);
            }

            // Total row
            fputcsv($handle, [
                'TOTAL',
                '',
                $totals['male'],
                $totals['female'],
                $totals['case_new'],
                $totals['case_old'],
                '',
                '',
                '',
                '',
                $totals['kpsp_motorik_kasar'],
                $totals['kpsp_motorik_halus'],
                $totals['kpsp_bicara_bahasa'],
                $totals['kpsp_sosialisasi'],
                $totals['sdq'],
                $totals['mchat'],
                $totals['gpph'],
                $totals['srq'],
                $totals['psikolog'],
                $totals['aba'],
                $totals['ot'],
                $totals['tw'],
                $totals['si'],
                $totals['fisioterapi'],
                $totals['perawatan_medis'],
                $totals['konseling'],
                $totals['rehabilitasi'],
                $totals['rujukan_ke'],
                $totals['sekolah_reguler'],
                $totals['sekolah_inklusi'],
                $totals['slb'],
                $totals['panti'],
                $totals['tidak_sekolah'],
                '',
            ]);

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
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
        $kpspDomainKasar = 0; $kpspDomainHalus = 0; $kpspDomainBicara = 0; $kpspDomainSosialisasi = 0;
        $mchatTotal = 0; $mchatRendah = 0; $mchatTinggi = 0;
        $gpphTotal = 0; $gpphNormal = 0; $gpphMeragukan = 0; $gpphKemungkinan = 0;
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

                $ds = $s->kpspScreening->domain_scores;
                if (is_array($ds) && isset($ds['domains'])) {
                    $doms = $ds['domains'];
                    $lacking = $ds['lacking_domains'] ?? [];
                    if (in_array('Gerak Kasar', $lacking, true) || ($doms['gerak_kasar']['percentage'] ?? 100) < 100 || ($doms['gerak_kasar']['status'] ?? '') !== 'sesuai') {
                        $kpspDomainKasar++;
                    }
                    if (in_array('Gerak Halus', $lacking, true) || ($doms['gerak_halus']['percentage'] ?? 100) < 100 || ($doms['gerak_halus']['status'] ?? '') !== 'sesuai') {
                        $kpspDomainHalus++;
                    }
                    if (in_array('Bicara dan Bahasa', $lacking, true) || ($doms['bicara_bahasa']['percentage'] ?? 100) < 100 || ($doms['bicara_bahasa']['status'] ?? '') !== 'sesuai') {
                        $kpspDomainBicara++;
                    }
                    if (in_array('Sosialisasi dan Kemandirian', $lacking, true) || ($doms['sosialisasi_kemandirian']['percentage'] ?? 100) < 100 || ($doms['sosialisasi_kemandirian']['status'] ?? '') !== 'sesuai') {
                        $kpspDomainSosialisasi++;
                    }
                } elseif (in_array($s->kpspScreening->category, ['meragukan', 'penyimpangan', 'kemungkinan_penyimpangan'], true)) {
                    $kpspDomainBicara++;
                }
            }

            if ($s->mchatScreening) {
                $mchatTotal++;
                match ($s->mchatScreening->category) {
                    'risiko_rendah' => $mchatRendah++,
                    'risiko_sedang', 'risiko_tinggi', 'risiko_sedang_tinggi' => $mchatTinggi++,
                    default => null,
                };
            }

            if ($s->gpphScreening) {
                $gpphTotal++;
                match ($s->gpphScreening->category) {
                    'normal', 'tidak_menunjukkan_gpph' => $gpphNormal++,
                    'meragukan' => $gpphMeragukan++,
                    'kemungkinan_gpph', 'positif' => $gpphKemungkinan++,
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
                    'gangguan_mental_emosional_distres', 'berisiko' => $srqDistres++,
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
                'domains' => [
                    'motorik_kasar' => $kpspDomainKasar,
                    'motorik_halus' => $kpspDomainHalus,
                    'bicara_bahasa' => $kpspDomainBicara,
                    'sosialisasi_kemandirian' => $kpspDomainSosialisasi,
                ],
            ],
            'mchat' => [
                'total' => $mchatTotal,
                'risiko_rendah' => $mchatRendah,
                'risiko_sedang_tinggi' => $mchatTinggi,
            ],
            'gpph' => [
                'total' => $gpphTotal,
                'normal' => $gpphNormal,
                'tidak_menunjukkan_gpph' => $gpphNormal,
                'meragukan' => $gpphMeragukan,
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
            $dayOfWeek = $currentDate->dayOfWeek;

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
            if ($nurseId) $query->where('nurse_id', $nurseId);
            if ($status) $query->where('status', $status);

            $yearSessions = $query->get();
            $total = $yearSessions->count();
            $reviewed = $yearSessions->where('status', 'reviewed')->count();

            $yearlyList[] = [
                'year' => $y,
                'total_sessions' => $total,
                'unique_patients' => $yearSessions->pluck('patient_id')->unique()->count(),
                'reviewed_count' => $reviewed,
                'completion_rate' => $total > 0 ? round(($reviewed / $total) * 100, 1) : 0,
            ];
        }

        return $yearlyList;
    }

    /**
     * Deteksi apakah sesi memiliki temuan yang memerlukan perhatian klinis.
     */
    private function isAttentionCase(ScreeningSession $session): bool
    {
        return count($this->getAttentionReasons($session)) > 0;
    }

    /**
     * Ambil daftar alasan mengapa sesi memerlukan perhatian klinis.
     */
    private function getAttentionReasons(ScreeningSession $session): array
    {
        $reasons = [];

        if ($session->kpspScreening) {
            if ($session->kpspScreening->category === 'meragukan') {
                $reasons[] = 'KPSP: Meragukan (perlu stimulasi 2 minggu & evaluasi ulang)';
            } elseif (in_array($session->kpspScreening->category, ['penyimpangan', 'kemungkinan_penyimpangan'], true)) {
                $reasons[] = 'KPSP: Penyimpangan Perkembangan (perlu rujukan)';
            }
        }

        if ($session->mchatScreening) {
            if (in_array($session->mchatScreening->category, ['risiko_tinggi', 'risiko_sedang', 'risiko_sedang_tinggi'], true)) {
                $reasons[] = 'M-CHAT-R: Risiko Spektrum Autisme';
            }
        }

        if ($session->gpphScreening) {
            if ($session->gpphScreening->category === 'kemungkinan_gpph' || $session->gpphScreening->category === 'positif') {
                $reasons[] = 'GPPH: Indikasi Hiperaktivitas / GPPH';
            }
            if ($session->gpphScreening->examiner_doubtful) {
                $reasons[] = 'GPPH: Pemeriksa Meragukan Kondisi Pasien';
            }
        }

        if ($session->sdqScreening) {
            if ($session->sdqScreening->total_difficulties_category === 'abnormal') {
                $reasons[] = 'SDQ: Kesulitan Perilaku & Emosional Abnormal';
            } elseif ($session->sdqScreening->total_difficulties_category === 'ambang_borderline') {
                $reasons[] = 'SDQ: Kesulitan Ambang (Borderline)';
            }
        }

        if ($session->srqScreening) {
            if ($session->srqScreening->category === 'gangguan_mental_emosional_distres' || $session->srqScreening->category === 'berisiko') {
                $reasons[] = 'SRQ-20: Pengasuh Mengalami Distres Mental Emosional';
            }
            $answers = $session->srqScreening->answers;
            if (is_array($answers) && isset($answers[16]) && in_array($answers[16], [true, 1, '1'], true)) {
                $reasons[] = 'SRQ-20 [ALERT KRITIS]: Pikiran Mengakhiri Hidup (Pertanyaan 17)';
            }
        }

        return $reasons;
    }

    /**
     * Hitung laporan tahunan komprehensif 12 bulan murni dari data sesi di database:
     * 1. Total Pasien Terlayani (Gender L/P)
     * 2. Deteksi Dini Perkembangan (KPSP 4 Domain)
     * 3. Deteksi Dini Lanjutan (KMPE/SDQ, Autis/M-CHAT, GPPH)
     * 4. Rekapitulasi Diagnosis Klinis (Gangguan Fisik vs Emosional/Perilaku/Belajar/Komunikasi)
     * 5. Layanan Kesehatan / Intervensi yang Diberikan (9 Layanan)
     */
    private function calculateAnnualComprehensiveReports(int $year, $yearSessions): array
    {
        $compiled = [];
        $diagKeys = [
            'tuna_netra', 'tuna_rungu', 'tuna_daksa', 'tuna_ganda', 'gdd_down', 'tuna_laras', 'tuna_wicara',
            'adhd_gpph', 'gangguan_perilaku', 'tuna_grahita', 'keterlambatan_belajar', 'kesulitan_belajar', 'anak_berbakat', 'autisme', 'gangguan_bahasa'
        ];

        for ($m = 1; $m <= 12; $m++) {
            $mName = self::MONTH_NAMES[$m] ?? "Bulan {$m}";
            $sessionsInMonth = $yearSessions->filter(function ($s) use ($m) {
                return $s->screening_date && (int) $s->screening_date->format('n') === $m;
            });

            // Ambil hanya sesi skrining terakhir per anak dalam bulan tersebut
            $sessionsInMonth = $sessionsInMonth
                ->sortByDesc('screening_date')
                ->sortByDesc('id')
                ->unique('patient_id')
                ->values();

            $countInMonth = $sessionsInMonth->count();

            // Pasien
            $male = $sessionsInMonth->filter(fn($s) => $s->patient?->gender === 'L')->count();
            $female = $sessionsInMonth->filter(fn($s) => $s->patient?->gender === 'P')->count();

            // KPSP 4 Domain
            $kpspKasar = 0; $kpspHalus = 0; $kpspBicara = 0; $kpspSosial = 0;
            foreach ($sessionsInMonth as $s) {
                $kpsp = $s->kpspScreening;
                if ($kpsp) {
                    $ds = $kpsp->domain_scores;
                    if (is_array($ds) && isset($ds['domains'])) {
                        $doms = $ds['domains'];
                        $lacking = $ds['lacking_domains'] ?? [];
                        if (in_array('Gerak Kasar', $lacking, true) || ($doms['gerak_kasar']['percentage'] ?? 100) < 100 || ($doms['gerak_kasar']['status'] ?? '') !== 'sesuai') {
                            $kpspKasar++;
                        }
                        if (in_array('Gerak Halus', $lacking, true) || ($doms['gerak_halus']['percentage'] ?? 100) < 100 || ($doms['gerak_halus']['status'] ?? '') !== 'sesuai') {
                            $kpspHalus++;
                        }
                        if (in_array('Bicara dan Bahasa', $lacking, true) || ($doms['bicara_bahasa']['percentage'] ?? 100) < 100 || ($doms['bicara_bahasa']['status'] ?? '') !== 'sesuai') {
                            $kpspBicara++;
                        }
                        if (in_array('Sosialisasi dan Kemandirian', $lacking, true) || ($doms['sosialisasi_kemandirian']['percentage'] ?? 100) < 100 || ($doms['sosialisasi_kemandirian']['status'] ?? '') !== 'sesuai') {
                            $kpspSosial++;
                        }
                    } elseif (in_array($kpsp->category, ['meragukan', 'penyimpangan', 'kemungkinan_penyimpangan'], true)) {
                        $kpspBicara++;
                    }
                }
            }

            // Skrining Lanjutan (SDQ Anak, SRQ Pengasuh, Autis/M-CHAT, GPPH)
            $sdqCount = 0; $srqCount = 0; $mchatCount = 0; $gpphCount = 0;
            foreach ($sessionsInMonth as $s) {
                if ($s->sdqScreening && in_array($s->sdqScreening->total_difficulties_category, ['abnormal', 'ambang_borderline'], true)) {
                    $sdqCount++;
                }
                if ($s->srqScreening && ($s->srqScreening->category === 'gangguan_mental_emosional_distres' || $s->srqScreening->category === 'berisiko' || $s->srqScreening->score >= 6)) {
                    $srqCount++;
                }
                if ($s->mchatScreening && in_array($s->mchatScreening->category, ['risiko_tinggi', 'risiko_sedang', 'risiko_sedang_tinggi'], true)) {
                    $mchatCount++;
                }
                if ($s->gpphScreening && ($s->gpphScreening->category === 'positif' || $s->gpphScreening->category === 'kemungkinan_gpph' || $s->gpphScreening->examiner_doubtful)) {
                    $gpphCount++;
                }
            }

            // Layanan Kesehatan (9 Layanan)
            $intervCounts = [
                'psikolog' => 0, 'aba' => 0, 'ot' => 0, 'tw' => 0, 'si' => 0,
                'fisioterapi' => 0, 'perawatan_medis' => 0, 'konseling' => 0, 'rehabilitasi' => 0,
            ];
            foreach ($sessionsInMonth as $s) {
                $raw = $s->interventions;
                $items = is_array($raw) ? $raw : (json_decode($raw ?? '[]', true) ?: []);
                foreach ($items as $item) {
                    $clean = strtolower(trim((string) $item));
                    if ($clean === 'psikolog') $intervCounts['psikolog']++;
                    elseif ($clean === 'aba') $intervCounts['aba']++;
                    elseif ($clean === 'ot') $intervCounts['ot']++;
                    elseif ($clean === 'tw') $intervCounts['tw']++;
                    elseif ($clean === 'si') $intervCounts['si']++;
                    elseif (in_array($clean, ['fisio', 'fisioterapi'], true)) $intervCounts['fisioterapi']++;
                    elseif (in_array($clean, ['medis', 'perawatan_medis'], true)) $intervCounts['perawatan_medis']++;
                    elseif ($clean === 'konseling') $intervCounts['konseling']++;
                    elseif (in_array($clean, ['rehab', 'rehabilitasi'], true)) $intervCounts['rehabilitasi']++;
                }
            }

            // Diagnosis Klinis dari riwayat pemeriksaan pasien di sesi tersebut
            $diagCounts = array_fill_keys($diagKeys, 0);
            foreach ($sessionsInMonth as $s) {
                $hasAutis = ($s->mchatScreening && in_array($s->mchatScreening->category, ['risiko_tinggi', 'risiko_sedang', 'risiko_sedang_tinggi'], true));
                $hasGpph = ($s->gpphScreening && ($s->gpphScreening->category === 'positif' || $s->gpphScreening->category === 'kemungkinan_gpph' || $s->gpphScreening->examiner_doubtful));
                $allNotes = strtolower(($s->notes ?? '') . ' ' . ($s->recap_notes ?? '') . ' ' . ($s->doctor_notes ?? ''));

                if ($hasAutis) $diagCounts['autisme']++;
                if ($hasGpph) $diagCounts['adhd_gpph']++;

                if (str_contains($allNotes, 'cp') || str_contains($allNotes, 'cerebral') || str_contains($allNotes, 'daksa')) {
                    $diagCounts['tuna_daksa']++;
                }
                if (str_contains($allNotes, 'down') || str_contains($allNotes, 'gdd')) {
                    $diagCounts['gdd_down']++;
                }
                if (str_contains($allNotes, 'rungu')) {
                    $diagCounts['tuna_rungu']++;
                }
                if (str_contains($allNotes, 'ganda')) {
                    $diagCounts['tuna_ganda']++;
                }

                // Gangguan bahasa/komunikasi terindikasi jika KPSP bicara bahasa bermasalah
                if ($s->kpspScreening) {
                    $ds = $s->kpspScreening->domain_scores;
                    $doms = is_array($ds) ? ($ds['domains'] ?? []) : [];
                    $lacking = is_array($ds) ? ($ds['lacking_domains'] ?? []) : [];
                    if (in_array('Bicara dan Bahasa', $lacking, true) || ($doms['bicara_bahasa']['percentage'] ?? 100) < 100) {
                        $diagCounts['gangguan_bahasa']++;
                    }
                }

                // Gangguan perilaku jika SDQ abnormal
                if ($s->sdqScreening && $s->sdqScreening->total_difficulties_category === 'abnormal') {
                    $diagCounts['gangguan_perilaku']++;
                }
            }

            $compiled[$m] = [
                'name' => $mName,
                'patients' => ['male' => $male, 'female' => $female, 'total' => $countInMonth],
                'kpsp' => ['motorik_kasar' => $kpspKasar, 'motorik_halus' => $kpspHalus, 'bicara_bahasa' => $kpspBicara, 'sosialisasi' => $kpspSosial],
                'advanced' => [
                    'sdq' => $sdqCount,
                    'srq' => $srqCount,
                    'kmpe' => $sdqCount,
                    'mchat' => $mchatCount,
                    'gpph' => $gpphCount,
                ],
                'diagnosis' => $diagCounts,
                'interventions' => $intervCounts,
                'is_in_progress' => ($countInMonth === 0),
            ];
        }

        // 1. Laporan Total Pasien Terlayani
        $patientRows = [];
        $totalMale = 0; $totalFemale = 0; $grandTotalPatients = 0;
        $activeMonths = [];

        foreach ($compiled as $m => $d) {
            $tot = $d['patients']['total'];
            $patientRows[] = [
                'no' => $m,
                'month' => $m,
                'name' => $d['name'],
                'male' => $d['patients']['male'],
                'female' => $d['patients']['female'],
                'total' => $tot,
                'is_in_progress' => $d['is_in_progress'] ?? false,
            ];
            $totalMale += $d['patients']['male'];
            $totalFemale += $d['patients']['female'];
            $grandTotalPatients += $tot;

            if ($tot > 0) {
                $activeMonths[$d['name']] = $tot;
            }
        }

        $pctMale = $grandTotalPatients > 0 ? round(($totalMale / $grandTotalPatients) * 100, 1) : 0;
        $pctFemale = $grandTotalPatients > 0 ? round(($totalFemale / $grandTotalPatients) * 100, 1) : 0;

        if ($grandTotalPatients > 0) {
            arsort($activeMonths);
            $topMonthsText = implode(', ', array_map(fn($k, $v) => "{$k} ({$v} pasien)", array_keys($activeMonths), array_values($activeMonths)));
            $patientNarrative = "Sepanjang tahun {$year}, total " . number_format($grandTotalPatients, 0, ',', '.') . " pasien telah terlayani dengan rincian {$totalMale} pasien laki-laki ({$pctMale}%) dan {$totalFemale} pasien perempuan ({$pctFemale}%). Berdasarkan data sesi aktif di database, pelayanan tercatat pada bulan {$topMonthsText}, sementara bulan lainnya masih dalam proses pengisian berjalan.";
        } else {
            $patientNarrative = "Belum ada sesi skrining pasien yang tercatat pada database untuk tahun {$year}.";
        }

        // 2. Laporan KPSP 4 Domain
        $kpspRows = [];
        $totKasar = 0; $totHalus = 0; $totBicara = 0; $totSosial = 0;
        foreach ($compiled as $m => $d) {
            $k = $d['kpsp'];
            $kpspRows[] = [
                'no' => $m,
                'month' => $m,
                'name' => $d['name'],
                'motorik_kasar' => $k['motorik_kasar'],
                'motorik_halus' => $k['motorik_halus'],
                'bicara_bahasa' => $k['bicara_bahasa'],
                'sosialisasi' => $k['sosialisasi'],
                'total' => $k['motorik_kasar'] + $k['motorik_halus'] + $k['bicara_bahasa'] + $k['sosialisasi'],
                'is_in_progress' => $d['is_in_progress'] ?? false,
            ];
            $totKasar += $k['motorik_kasar'];
            $totHalus += $k['motorik_halus'];
            $totBicara += $k['bicara_bahasa'];
            $totSosial += $k['sosialisasi'];
        }

        // 3. Laporan Skrining Lanjutan (SDQ, SRQ, Autis/M-CHAT, GPPH)
        $advancedRows = [];
        $totSdq = 0; $totSrq = 0; $totMchat = 0; $totGpph = 0;
        foreach ($compiled as $m => $d) {
            $adv = $d['advanced'];
            $advancedRows[] = [
                'no' => $m,
                'month' => $m,
                'name' => $d['name'],
                'sdq' => $adv['sdq'],
                'srq' => $adv['srq'],
                'kmpe' => $adv['sdq'], // backward compatibility
                'mchat' => $adv['mchat'],
                'gpph' => $adv['gpph'],
                'total' => $adv['sdq'] + $adv['srq'] + $adv['mchat'] + $adv['gpph'],
                'is_in_progress' => $d['is_in_progress'] ?? false,
            ];
            $totSdq += $adv['sdq'];
            $totSrq += $adv['srq'];
            $totMchat += $adv['mchat'];
            $totGpph += $adv['gpph'];
        }

        if ($grandTotalPatients > 0) {
            $deteksiDiniNarrative = "Berdasarkan hasil deteksi dini tahun {$year} dari data sesi di sistem, temuan pada perkembangan dasar KPSP mencatat hambatan pada Bicara & Bahasa (" . number_format($totBicara, 0, ',', '.') . " temuan), Motorik Halus (" . number_format($totHalus, 0, ',', '.') . " temuan), Gerak Kasar (" . number_format($totKasar, 0, ',', '.') . "), dan Sosialisasi & Kemandirian (" . number_format($totSosial, 0, ',', '.') . "). Pada instrumen lanjutan, tercatat indikasi masalah perilaku/emosional anak SDQ (" . number_format($totSdq, 0, ',', '.') . " anak), distres mental emosional pengasuh SRQ-20 (" . number_format($totSrq, 0, ',', '.') . " orang tua), deteksi GPPH (" . number_format($totGpph, 0, ',', '.') . " anak), dan deteksi dini autisme M-CHAT (" . number_format($totMchat, 0, ',', '.') . " anak).";
        } else {
            $deteksiDiniNarrative = "Belum ada hasil deteksi dini yang tersimpan di sistem untuk tahun {$year}.";
        }

        // 4. Laporan Diagnosis (15 Kategori UPTD)
        $diagColumnsFisik = [
            'tuna_netra' => 'Tuna Netra',
            'tuna_rungu' => 'Tuna Rungu',
            'tuna_daksa' => 'Tuna Daksa / Cerebral Palsy',
            'tuna_ganda' => 'Tuna Ganda',
            'gdd_down' => 'GDD / Sindrom Down',
            'tuna_laras' => 'Tuna Laras',
            'tuna_wicara' => 'Tuna Wicara',
        ];
        $diagColumnsEmosional = [
            'adhd_gpph' => 'ADHD / GPPH / Hiperaktif / Indigo',
            'gangguan_perilaku' => 'GG Perilaku',
            'tuna_grahita' => 'Tuna Grahita / Retardasi Mental',
            'keterlambatan_belajar' => 'Keterlambatan Belajar',
            'kesulitan_belajar' => 'Kesulitan Belajar / Disleksia / Speech Delay',
            'anak_berbakat' => 'Anak Berbakat',
            'autisme' => 'Autisme',
            'gangguan_bahasa' => 'Gangguan Bahasa / Komunikasi',
        ];

        $diagnosisRows = [];
        $diagTotals = array_fill_keys(array_keys($diagColumnsFisik + $diagColumnsEmosional), 0);
        foreach ($compiled as $m => $d) {
            $rowDiag = $d['diagnosis'];
            $rowSum = array_sum($rowDiag);
            $diagnosisRows[] = array_merge([
                'no' => $m,
                'month' => $m,
                'name' => $d['name'],
                'total' => $rowSum,
                'is_in_progress' => $d['is_in_progress'] ?? false,
            ], $rowDiag);

            foreach ($rowDiag as $key => $val) {
                $diagTotals[$key] = ($diagTotals[$key] ?? 0) + $val;
            }
        }

        $grandTotalDiag = array_sum($diagTotals);
        if ($grandTotalDiag > 0) {
            $diagnosisNarrative = "Berdasarkan rekapitulasi diagnosis klinis sesi aktif tahun {$year}, kasus perkembangan yang teridentifikasi mencakup Autisme ({$diagTotals['autisme']} anak), Gangguan Bahasa/Komunikasi ({$diagTotals['gangguan_bahasa']} anak), ADHD/GPPH ({$diagTotals['adhd_gpph']} anak), Gangguan Perilaku ({$diagTotals['gangguan_perilaku']} anak), Tuna Daksa/CP ({$diagTotals['tuna_daksa']} anak), serta GDD/Sindrom Down ({$diagTotals['gdd_down']} anak).";
        } else {
            $diagnosisNarrative = "Belum ada rekapitulasi diagnosis yang tercatat untuk tahun {$year}.";
        }

        // 5. Laporan Layanan Kesehatan / Intervensi yang Diberikan (9 Layanan)
        $intervColumns = [
            'psikolog' => 'Psikolog',
            'aba' => 'Applied Behavioral Analysis (ABA)',
            'ot' => 'Terapi Okupasi (OT)',
            'tw' => 'Terapi Wicara (TW)',
            'si' => 'Terapi Lain-lain (Sensori Integrasi)',
            'fisioterapi' => 'Fisioterapi',
            'perawatan_medis' => 'Perawatan Medis',
            'konseling' => 'Konseling',
            'rehabilitasi' => 'Rehabilitasi Medik',
        ];

        $intervRows = [];
        $intervTotals = array_fill_keys(array_keys($intervColumns), 0);
        foreach ($compiled as $m => $d) {
            $rowInterv = $d['interventions'];
            $rowSum = array_sum($rowInterv);
            $intervRows[] = array_merge([
                'no' => $m,
                'month' => $m,
                'name' => $d['name'],
                'total' => $rowSum,
                'is_in_progress' => $d['is_in_progress'] ?? false,
            ], $rowInterv);

            foreach ($rowInterv as $k => $val) {
                $intervTotals[$k] = ($intervTotals[$k] ?? 0) + $val;
            }
        }

        $grandTotalInterv = array_sum($intervTotals);
        if ($grandTotalInterv > 0) {
            $interventionsNarrative = "Berdasarkan layanan kesehatan yang diberikan tahun {$year}, tindakan terbanyak yang tercatat meliputi Terapi Sensori Integrasi (" . number_format($intervTotals['si'], 0, ',', '.') . " tindakan), Applied Behavioral Analysis/ABA (" . number_format($intervTotals['aba'], 0, ',', '.') . " tindakan), Konseling (" . number_format($intervTotals['konseling'], 0, ',', '.') . " tindakan), Layanan Psikolog (" . number_format($intervTotals['psikolog'], 0, ',', '.') . " tindakan), Terapi Okupasi/OT (" . number_format($intervTotals['ot'], 0, ',', '.') . " tindakan), dan Fisioterapi (" . number_format($intervTotals['fisioterapi'], 0, ',', '.') . " tindakan).";
        } else {
            $interventionsNarrative = "Belum ada catatan intervensi layanan kesehatan untuk tahun {$year}.";
        }

        return [
            'year' => $year,
            'patientsReport' => [
                'rows' => $patientRows,
                'totals' => [
                    'male' => $totalMale,
                    'female' => $totalFemale,
                    'total' => $grandTotalPatients,
                ],
                'narrative' => $patientNarrative,
            ],
            'kpspReport' => [
                'rows' => $kpspRows,
                'totals' => [
                    'motorik_kasar' => $totKasar,
                    'motorik_halus' => $totHalus,
                    'bicara_bahasa' => $totBicara,
                    'sosialisasi' => $totSosial,
                    'total' => $totKasar + $totHalus + $totBicara + $totSosial,
                ],
            ],
            'advancedReport' => [
                'rows' => $advancedRows,
                'totals' => [
                    'sdq' => $totSdq,
                    'srq' => $totSrq,
                    'kmpe' => $totSdq,
                    'mchat' => $totMchat,
                    'gpph' => $totGpph,
                    'total' => $totSdq + $totSrq + $totMchat + $totGpph,
                ],
                'narrative' => $deteksiDiniNarrative,
            ],
            'diagnosisReport' => [
                'columns_fisik' => $diagColumnsFisik,
                'columns_emosional' => $diagColumnsEmosional,
                'rows' => $diagnosisRows,
                'totals' => $diagTotals,
                'grand_total' => $grandTotalDiag,
                'narrative' => $diagnosisNarrative,
            ],
            'interventionsReport' => [
                'columns' => $intervColumns,
                'rows' => $intervRows,
                'totals' => $intervTotals,
                'grand_total' => $grandTotalInterv,
                'narrative' => $interventionsNarrative,
            ],
        ];
    }
}
