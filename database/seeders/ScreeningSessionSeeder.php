<?php

namespace Database\Seeders;

use App\Models\Doctor;
use App\Models\GpphScreening;
use App\Models\KpspScreening;
use App\Models\MchatScreening;
use App\Models\Nurse;
use App\Models\Patient;
use App\Models\ScreeningInterpretation;
use App\Models\ScreeningSession;
use App\Models\ScreeningSessionInstrument;
use App\Models\SdqScreening;
use App\Models\SrqScreening;
use Carbon\CarbonImmutable;
use Illuminate\Database\Seeder;

class ScreeningSessionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Membuat 3 sesi skrining untuk setiap pasien pada daftar pasien rentang umur.
     * Setiap sesi hanya mengambil instrumen yang ELIGIBLE untuk umur anak tersebut.
     * Sesi 1: Kunjungan Awal (Normal / Sesuai Umur) — Status: reviewed
     * Sesi 2: Kunjungan Evaluasi (Meragukan / Borderline) — Status: pending_doctor_review
     * Sesi 3: Kunjungan Komprehensif (Penyimpangan / Abnormal) — Status: reviewed
     */
    public function run(): void
    {
        $nurse = Nurse::whereHas('user', function ($query) {
            $query->where('email', 'perawat@spk.test');
        })->firstOrFail();

        $doctor = Doctor::whereHas('user', function ($query) {
            $query->where('email', 'dokter@spk.test');
        })->firstOrFail();

        $today = CarbonImmutable::today();

        // 1. Seed seluruh 176 sesi register bulan Oktober 2026 dari register resmi UPTD BLK-ABK
        $this->seedUptdOctoberSessions($nurse, $doctor);

        // 2. Siapkan sesi uji aktif untuk skenario testing peran (Perawat, Orang Tua, Dokter)
        //    menggunakan pasien anak asli UPTD (RM-002, RM-003, RM-005)
        $this->seedActiveTestingSessions($nurse, $doctor, $today);
    }

    /**
     * Muat dan generate 176 sesi register bulan Oktober 2026 dari data UPTD BLK-ABK
     * lengkap dengan instrumen KPSP 4 domain, M-CHAT-R, GPPH, serta dummy SDQ dan SRQ-20.
     */
    private function seedUptdOctoberSessions(Nurse $nurse, Doctor $doctor): void
    {
        $jsonPath = database_path('seeders/uptd_october_data.json');
        if (! file_exists($jsonPath)) {
            return;
        }

        $uptdRecords = json_decode(file_get_contents($jsonPath), true);
        if (! is_array($uptdRecords)) {
            return;
        }

        foreach ($uptdRecords as $idx => $rec) {
            $mrn = sprintf('RM-%03d', $idx + 1);
            $patient = Patient::where('medical_record_number', $mrn)->first();
            if (! $patient) {
                continue;
            }

            // Sebarkan tanggal pemeriksaan secara berurutan sesuai nomor urut register Excel (1 s/d 30 Oktober 2026)
            $day = min(30, 1 + (int) floor(($idx * 29) / count($uptdRecords)));
            $dateStr = sprintf('2026-10-%02d', $day);
            $screeningDate = CarbonImmutable::parse($dateStr);

            $session = ScreeningSession::create([
                'patient_id' => $patient->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $screeningDate->toDateString(),
                'age_months' => $rec['age_months'] ?? 36,
                'case_type' => $rec['case_type'] ?? 'lama',
                'referral_source' => $rec['referral_from'],
                'referral_target' => $rec['rujukan_ke'],
                'interventions' => $rec['interventions'] ?? [],
                'recap_notes' => $rec['school_name'],
                'status' => 'reviewed',
                'notes' => 'Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.',
                'doctor_notes' => 'Hasil evaluasi klinis dan program intervensi disetujui dokter.',
                'reviewed_at' => $screeningDate->addHours(3),
            ]);

            // KPSP (4 Domain Perkembangan)
            $hasKpspDeficit = $rec['kpsp_kasar'] || $rec['kpsp_halus'] || $rec['kpsp_bicara'] || $rec['kpsp_sosialisasi'];
            $kpspCategory = $hasKpspDeficit ? 'meragukan' : 'sesuai_umur';
            $kpspScore = $hasKpspDeficit ? 8 : 10;

            $lackingDomains = [];
            if ($rec['kpsp_kasar']) $lackingDomains[] = 'Gerak Kasar';
            if ($rec['kpsp_halus']) $lackingDomains[] = 'Gerak Halus';
            if ($rec['kpsp_bicara']) $lackingDomains[] = 'Bicara dan Bahasa';
            if ($rec['kpsp_sosialisasi']) $lackingDomains[] = 'Sosialisasi dan Kemandirian';

            ScreeningSessionInstrument::create([
                'screening_session_id' => $session->id,
                'instrument_code' => 'KPSP',
                'status' => 'completed',
                'started_at' => $screeningDate->subHour(),
                'completed_at' => $screeningDate->subMinutes(30),
            ]);

            KpspScreening::create([
                'screening_session_id' => $session->id,
                'form_age_months' => $this->getKpspFormAge((int) ($rec['age_months'] ?? 36)) ?? 72,
                'answers' => array_fill(0, 10, true),
                'score' => $kpspScore,
                'category' => $kpspCategory,
                'recommendation' => $hasKpspDeficit ? 'Lakukan stimulasi terarah pada domain yang mengalami hambatan.' : 'Perkembangan sesuai umur.',
                'domain_scores' => [
                    'domains' => [
                        'gerak_kasar' => ['key' => 'gerak_kasar', 'name' => 'Gerak Kasar', 'score' => $rec['kpsp_kasar'] ? 1 : 3, 'total' => 3, 'percentage' => $rec['kpsp_kasar'] ? 33 : 100, 'status' => $rec['kpsp_kasar'] ? 'meragukan' : 'sesuai'],
                        'gerak_halus' => ['key' => 'gerak_halus', 'name' => 'Gerak Halus', 'score' => $rec['kpsp_halus'] ? 1 : 2, 'total' => 2, 'percentage' => $rec['kpsp_halus'] ? 50 : 100, 'status' => $rec['kpsp_halus'] ? 'meragukan' : 'sesuai'],
                        'bicara_bahasa' => ['key' => 'bicara_bahasa', 'name' => 'Bicara dan Bahasa', 'score' => $rec['kpsp_bicara'] ? 1 : 2, 'total' => 2, 'percentage' => $rec['kpsp_bicara'] ? 50 : 100, 'status' => $rec['kpsp_bicara'] ? 'meragukan' : 'sesuai'],
                        'sosialisasi_kemandirian' => ['key' => 'sosialisasi_kemandirian', 'name' => 'Sosialisasi dan Kemandirian', 'score' => $rec['kpsp_sosialisasi'] ? 1 : 3, 'total' => 3, 'percentage' => $rec['kpsp_sosialisasi'] ? 33 : 100, 'status' => $rec['kpsp_sosialisasi'] ? 'meragukan' : 'sesuai'],
                    ],
                    'lacking_domains' => $lackingDomains,
                    'optimal_domains' => array_values(array_diff(['Gerak Kasar', 'Gerak Halus', 'Bicara dan Bahasa', 'Sosialisasi dan Kemandirian'], $lackingDomains)),
                    'all_optimal' => empty($lackingDomains),
                ],
            ]);

            // M-CHAT-R (Autis)
            $mchatCategory = $rec['mchat'] ? 'risiko_sedang_tinggi' : 'risiko_rendah';
            $mchatScore = $rec['mchat'] ? 5 : 1;
            ScreeningSessionInstrument::create([
                'screening_session_id' => $session->id,
                'instrument_code' => 'MCHAT',
                'status' => 'completed',
                'started_at' => $screeningDate->subHour(),
                'completed_at' => $screeningDate->subMinutes(30),
            ]);
            MchatScreening::create([
                'screening_session_id' => $session->id,
                'answers' => array_fill(0, 20, false),
                'score' => $mchatScore,
                'category' => $mchatCategory,
                'recommendation' => $rec['mchat'] ? 'Rujuk untuk evaluasi komprehensif spektrum autisme.' : 'Risiko rendah autisme.',
            ]);

            // GPPH (Hiperaktivitas)
            $gpphCategory = $rec['gpph'] ? 'kemungkinan_gpph' : 'normal';
            $gpphScore = $rec['gpph'] ? 14 : 4;
            ScreeningSessionInstrument::create([
                'screening_session_id' => $session->id,
                'instrument_code' => 'GPPH',
                'status' => 'completed',
                'started_at' => $screeningDate->subHour(),
                'completed_at' => $screeningDate->subMinutes(30),
            ]);
            GpphScreening::create([
                'screening_session_id' => $session->id,
                'answers' => array_fill(0, 10, $rec['gpph'] ? 2 : 0),
                'score' => $gpphScore,
                'examiner_doubtful' => false,
                'category' => $gpphCategory,
                'recommendation' => $rec['gpph'] ? 'Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.' : 'Tidak menunjukkan GPPH.',
            ]);

            // SDQ (Dummy Data Sesuai Permintaan User)
            $isSdqAbnormal = (bool) ($rec['kmpe'] || $rec['mchat'] || $rec['gpph']);
            $sdqTotalScore = $isSdqAbnormal ? 18 : 6;
            $sdqCategory = $isSdqAbnormal ? 'abnormal' : 'normal';

            ScreeningSessionInstrument::create([
                'screening_session_id' => $session->id,
                'instrument_code' => 'SDQ',
                'status' => 'completed',
                'started_at' => $screeningDate->subHour(),
                'completed_at' => $screeningDate->subMinutes(30),
            ]);
            SdqScreening::create([
                'screening_session_id' => $session->id,
                'answers' => array_fill(0, 25, $isSdqAbnormal ? 1 : 0),
                'total_difficulties_score' => $sdqTotalScore,
                'emotional_score' => $isSdqAbnormal ? 5 : 1,
                'conduct_score' => $isSdqAbnormal ? 4 : 1,
                'hyperactivity_score' => $isSdqAbnormal ? 5 : 2,
                'peer_score' => $isSdqAbnormal ? 4 : 2,
                'prosocial_score' => $isSdqAbnormal ? 6 : 9,
                'total_difficulties_category' => $sdqCategory,
                'emotional_category' => $isSdqAbnormal ? 'abnormal' : 'normal',
                'conduct_category' => $isSdqAbnormal ? 'abnormal' : 'normal',
                'hyperactivity_category' => $isSdqAbnormal ? 'abnormal' : 'normal',
                'peer_category' => $isSdqAbnormal ? 'abnormal' : 'normal',
                'prosocial_category' => 'normal',
                'recommendation' => $isSdqAbnormal ? 'Perlu pendampingan psikologis terarah.' : 'Perkembangan perilaku emosional baik.',
            ]);

            // SRQ-20 (Dummy Data Kesehatan Mental Pengasuh Sesuai Permintaan User)
            $isSrqDistres = ($idx % 4 === 0) || ($isSdqAbnormal && $idx % 2 === 0);
            $srqScore = $isSrqDistres ? 7 : 2;
            $srqCategory = $isSrqDistres ? 'gangguan_mental_emosional_distres' : 'di_bawah_nilai_pisah';
            $srqAnswers = array_fill(0, 20, false);
            for ($i = 0; $i < $srqScore; $i++) {
                $srqAnswers[$i] = true;
            }
            if ($idx % 20 === 0 && $isSrqDistres) {
                $srqAnswers[16] = true;
            }

            ScreeningSessionInstrument::create([
                'screening_session_id' => $session->id,
                'instrument_code' => 'SRQ',
                'status' => 'completed',
                'started_at' => $screeningDate->subHour(),
                'completed_at' => $screeningDate->subMinutes(30),
            ]);
            SrqScreening::create([
                'screening_session_id' => $session->id,
                'answers' => $srqAnswers,
                'score' => $srqScore,
                'category' => $srqCategory,
                'depression_score' => $isSrqDistres ? 3 : 1,
                'anxiety_score' => $isSrqDistres ? 2 : 1,
                'somatic_score' => $isSrqDistres ? 1 : 0,
                'cognitive_score' => $isSrqDistres ? 1 : 0,
                'energy_score' => 0,
                'recommendation' => $isSrqDistres ? 'Disarankan konseling suportif bagi orang tua.' : 'Kondisi kesehatan mental emosional baik.',
            ]);

            // Rekomendasi / Interpretasi Klinis Dokter
            ScreeningInterpretation::create([
                'screening_session_id' => $session->id,
                'instrument_code' => 'KPSP',
                'doctor_id' => $doctor->id,
                'clinical_notes' => 'Tinjauan klinis selesai. Program intervensi disetujui.',
                'follow_up_decision' => !empty($rec['rujukan_ke']) ? 'rujuk_rs' : 'konseling_stimulasi',
                'follow_up_notes' => 'Jadwalkan pemantauan berkala di UPTD BLK-ABK.',
                'status' => 'completed',
                'completed_at' => $screeningDate->addHours(2),
            ]);
        }
    }

    /**
     * Tentukan daftar kode instrumen yang eligible berdasarkan umur anak dalam bulan.
     *
     * @return list<string>
     */
    private function getEligibleInstruments(int $ageMonths): array
    {
        $instruments = [];

        // KPSP: 3 - 72 bulan
        if ($ageMonths >= 3 && $ageMonths <= 72) {
            $instruments[] = 'KPSP';
        }

        // M-CHAT-R: 16 - 30 bulan
        if ($ageMonths >= 16 && $ageMonths <= 30) {
            $instruments[] = 'MCHAT';
        }

        // GPPH: 36 - 72 bulan (3 - 6 tahun)
        if ($ageMonths >= 36 && $ageMonths <= 72) {
            $instruments[] = 'GPPH';
        }

        // SDQ: 48 - 131 bulan (4 - 10 tahun / sebelum 11 tahun)
        if ($ageMonths >= 48 && $ageMonths <= 131) {
            $instruments[] = 'SDQ';
        }

        // SRQ-20: Kesehatan mental orang tua/pengasuh (seluruh usia anak)
        $instruments[] = 'SRQ';

        return $instruments;
    }

    /**
     * Tentukan formulir umur KPSP yang sesuai (pembulatan ke bawah sesuai milestone SDIDTK).
     */
    private function getKpspFormAge(int $ageMonths): ?int
    {
        if ($ageMonths < 3 || $ageMonths > 72) {
            return null;
        }

        $kpspAges = [3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60, 66, 72];
        $selected = 3;

        foreach ($kpspAges as $fa) {
            if ($fa <= $ageMonths) {
                $selected = $fa;
            } else {
                break;
            }
        }

        return $selected;
    }

    /**
     * Simpan jawaban dan hasil skoring instrumen berdasarkan varian (normal | borderline | abnormal).
     */
    private function seedInstrumentResult(
        int $sessionId,
        string $code,
        string $variant,
        ?int $kpspFormAge,
        string $patientName
    ): void {
        switch ($code) {
            case 'KPSP':
                if ($kpspFormAge === null) {
                    return;
                }
                $kpspCatalog = new \App\Services\KpspCatalogService();
                if ($variant === 'normal') {
                    $ans = array_fill(0, 10, true);
                    KpspScreening::create([
                        'screening_session_id' => $sessionId,
                        'form_age_months' => $kpspFormAge,
                        'answers' => $ans,
                        'score' => 10,
                        'category' => 'sesuai_umur',
                        'recommendation' => "Perkembangan {$patientName} sesuai usia {$kpspFormAge} bulan. Lanjutkan stimulasi rutin di rumah.",
                        'domain_scores' => $kpspCatalog->calculateDomainScores($kpspFormAge, $ans),
                    ]);
                } elseif ($variant === 'borderline') {
                    $ans = array_fill(0, 10, true);
                    $ans[4] = false;
                    $ans[7] = false;
                    KpspScreening::create([
                        'screening_session_id' => $sessionId,
                        'form_age_months' => $kpspFormAge,
                        'answers' => $ans,
                        'score' => 8,
                        'category' => 'meragukan',
                        'recommendation' => 'Hasil perkembangan meragukan. Lakukan stimulasi intensif selama 2 minggu dan jadwalkan evaluasi ulang.',
                        'domain_scores' => $kpspCatalog->calculateDomainScores($kpspFormAge, $ans),
                    ]);
                } else {
                    $ans = [true, false, true, false, false, true, false, true, false, true];
                    KpspScreening::create([
                        'screening_session_id' => $sessionId,
                        'form_age_months' => $kpspFormAge,
                        'answers' => $ans,
                        'score' => 5,
                        'category' => 'kemungkinan_penyimpangan',
                        'recommendation' => 'Kemungkinan penyimpangan perkembangan terindikasi. Perlu pemeriksaan komprehensif oleh dokter spesialis anak.',
                        'domain_scores' => $kpspCatalog->calculateDomainScores($kpspFormAge, $ans),
                    ]);
                }
                break;

            case 'MCHAT':
                if ($variant === 'normal') {
                    // M-CHAT-R: item 2, 5, 12 false is normal; others true is normal
                    $ans = array_fill(0, 20, true);
                    $ans[1] = false;
                    $ans[4] = false;
                    $ans[11] = false;
                    MchatScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => 0,
                        'category' => 'risiko_rendah',
                        'recommendation' => 'Risiko autisme rendah. Lanjutkan pemantauan tumbuh kembang rutin.',
                    ]);
                } elseif ($variant === 'borderline') {
                    $ans = array_fill(0, 20, true);
                    $ans[1] = false;
                    $ans[4] = false;
                    $ans[11] = false;
                    // Tambah 4 jawaban berisiko
                    $ans[0] = false;
                    $ans[2] = false;
                    $ans[5] = false;
                    $ans[6] = false;
                    MchatScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => 4,
                        'category' => 'risiko_sedang_tinggi',
                        'recommendation' => 'Risiko autisme sedang. Diperlukan evaluasi tindak lanjut (Follow-Up Interview) oleh tenaga medis.',
                    ]);
                } else {
                    $ans = array_fill(0, 20, true);
                    // Items 2, 5, 12 true -> 3 risk points
                    $ans[1] = true;
                    $ans[4] = true;
                    $ans[11] = true;
                    // Items 0, 2, 5, 6, 7 false -> 5 risk points
                    $ans[0] = false;
                    $ans[2] = false;
                    $ans[5] = false;
                    $ans[6] = false;
                    $ans[7] = false;
                    MchatScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => 8,
                        'category' => 'risiko_sedang_tinggi',
                        'recommendation' => 'Risiko tinggi gangguan spektrum autisme. Rujuk segera ke dokter spesialis anak / psikiater anak.',
                    ]);
                }
                break;

            case 'GPPH':
                if ($variant === 'normal') {
                    $ans = [0, 1, 0, 0, 1, 0, 0, 0, 1, 0];
                    GpphScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => 3,
                        'examiner_doubtful' => false,
                        'category' => 'normal',
                        'recommendation' => 'Pemusatan perhatian dan aktivitas motorik dalam batas wajar.',
                    ]);
                } elseif ($variant === 'borderline') {
                    $ans = [1, 1, 1, 1, 1, 1, 1, 1, 1, 0];
                    GpphScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => 9,
                        'examiner_doubtful' => true,
                        'category' => 'meragukan',
                        'recommendation' => 'Pemeriksa ragu-ragu. Terdapat indikasi meragukan masalah konsentrasi dan perilaku. Evaluasi ulang 1 bulan.',
                    ]);
                } else {
                    $ans = [2, 2, 2, 1, 2, 2, 1, 2, 1, 1];
                    GpphScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => 16,
                        'examiner_doubtful' => false,
                        'category' => 'kemungkinan_gpph',
                        'recommendation' => 'Skor melampaui ambang batas 13. Konsultasi dokter spesialis anak untuk evaluasi GPPH/ADHD komprehensif.',
                    ]);
                }
                break;

            case 'SDQ':
                if ($variant === 'normal') {
                    $ans = array_fill(0, 25, 0);
                    // Prosocial items (0, 3, 8, 16, 19) set to 2 -> prosocial score = 10
                    $ans[0] = 2; $ans[3] = 2; $ans[8] = 2; $ans[16] = 2; $ans[19] = 2;
                    // Sedikit skor kesulitan
                    $ans[2] = 1; // emosional = 1
                    $ans[4] = 1; // conduct = 1
                    $ans[1] = 1; // hiperaktivitas = 2 (items 1 & 9)
                    $ans[9] = 1;
                    $ans[5] = 1; // peer = 1
                    SdqScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'emotional_score' => 1,
                        'conduct_score' => 1,
                        'hyperactivity_score' => 2,
                        'peer_score' => 1,
                        'total_difficulties_score' => 5,
                        'prosocial_score' => 10,
                        'total_difficulties_category' => 'normal',
                        'prosocial_category' => 'normal',
                        'emotional_category' => 'normal',
                        'conduct_category' => 'normal',
                        'hyperactivity_category' => 'normal',
                        'peer_category' => 'normal',
                        'recommendation' => 'Kekuatan dan kesulitan dalam batas normal.',
                    ]);
                } elseif ($variant === 'borderline') {
                    $ans = array_fill(0, 25, 1);
                    SdqScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'emotional_score' => 4,
                        'conduct_score' => 3,
                        'hyperactivity_score' => 5,
                        'peer_score' => 3,
                        'total_difficulties_score' => 15,
                        'prosocial_score' => 7,
                        'total_difficulties_category' => 'ambang_borderline',
                        'prosocial_category' => 'normal',
                        'emotional_category' => 'ambang_borderline',
                        'conduct_category' => 'ambang_borderline',
                        'hyperactivity_category' => 'ambang_borderline',
                        'peer_category' => 'normal',
                        'recommendation' => 'Total kesulitan berada pada rentang ambang/borderline.',
                    ]);
                } else {
                    $ans = array_fill(0, 25, 1);
                    $ans[2] = 2; $ans[7] = 2; // emotional
                    $ans[4] = 2; $ans[6] = 2; // conduct
                    $ans[1] = 2; $ans[9] = 2; // hyperactivity
                    SdqScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'emotional_score' => 6,
                        'conduct_score' => 5,
                        'hyperactivity_score' => 6,
                        'peer_score' => 4,
                        'total_difficulties_score' => 21,
                        'prosocial_score' => 5,
                        'total_difficulties_category' => 'abnormal',
                        'prosocial_category' => 'ambang_borderline',
                        'emotional_category' => 'abnormal',
                        'conduct_category' => 'abnormal',
                        'hyperactivity_category' => 'abnormal',
                        'peer_category' => 'abnormal',
                        'recommendation' => 'Total kesulitan abnormal dengan masalah signifikan pada aspek emosi, perilaku, dan hiperaktivitas.',
                    ]);
                }
                break;

            case 'SRQ':
                $srqScorer = new \App\Services\Scoring\SrqScorer();
                if ($variant === 'normal') {
                    $ans = array_fill(0, 20, false);
                    $ans[0] = true;
                    $res = $srqScorer->score($ans);
                    SrqScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => $res->scores['total'],
                        'depression_score' => $res->scores['depression'],
                        'anxiety_score' => $res->scores['anxiety'],
                        'somatic_score' => $res->scores['somatic'],
                        'cognitive_score' => $res->scores['cognitive'],
                        'energy_score' => $res->scores['energy'],
                        'category' => 'di_bawah_nilai_pisah',
                        'recommendation' => 'Skor SRQ-20 berada di bawah batas nilai pisah. Kondisi kesehatan mental pengasuh dalam batas normal.',
                    ]);
                } elseif ($variant === 'borderline') {
                    $ans = array_fill(0, 20, false);
                    $ans[0] = true; $ans[5] = true; $ans[7] = true; $ans[10] = true;
                    $res = $srqScorer->score($ans);
                    SrqScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => $res->scores['total'],
                        'depression_score' => $res->scores['depression'],
                        'anxiety_score' => $res->scores['anxiety'],
                        'somatic_score' => $res->scores['somatic'],
                        'cognitive_score' => $res->scores['cognitive'],
                        'energy_score' => $res->scores['energy'],
                        'category' => 'di_bawah_nilai_pisah',
                        'recommendation' => 'Skor SRQ-20 masih di bawah nilai pisah 6. Pengasuh disarankan menjaga waktu istirahat yang cukup.',
                    ]);
                } else {
                    $ans = array_fill(0, 20, false);
                    for ($i = 0; $i < 8; $i++) {
                        $ans[$i] = true;
                    }
                    $res = $srqScorer->score($ans);
                    SrqScreening::create([
                        'screening_session_id' => $sessionId,
                        'answers' => $ans,
                        'score' => $res->scores['total'],
                        'depression_score' => $res->scores['depression'],
                        'anxiety_score' => $res->scores['anxiety'],
                        'somatic_score' => $res->scores['somatic'],
                        'cognitive_score' => $res->scores['cognitive'],
                        'energy_score' => $res->scores['energy'],
                        'category' => 'gangguan_mental_emosional_distres',
                        'recommendation' => 'Skor SRQ-20 memenuhi batas nilai pisah (≥ 6). Mengindikasikan distres emosional/psikologis pengasuh.',
                    ]);
                }
                break;
        }
    }

    /**
     * Catat interpretasi dokter klinis resmi untuk instrumen pada Sesi 3.
     */
    private function seedDoctorInterpretation(
        int $sessionId,
        string $code,
        int $doctorId,
        CarbonImmutable $date,
        string $patientName
    ): void {
        $notesMap = [
            'KPSP' => [
                'clinical' => "KPSP menunjukkan keterlambatan pada sektor motorik dan bahasa untuk {$patientName}. Perlu asesmen habilitasi fisioterapi dan terapi wicara.",
                'decision' => 'rujuk_rs',
                'follow_up' => 'Rujuk ke Poli Tumbuh Kembang RSUD dan layanan terapi di UPTD BLK-ABK.',
            ],
            'MCHAT' => [
                'clinical' => "Hasil M-CHAT-R mengindikasikan defisit atensi bersama, respon nama, dan kontak mata pada {$patientName}. Gejala mengarah pada spektrum autisme.",
                'decision' => 'rujuk_rs',
                'follow_up' => 'Rujukan diagnostik formal ke Dokter Spesialis Anak Konsultan Tumbuh Kembang / Psikiater Anak.',
            ],
            'GPPH' => [
                'clinical' => "Skor ACTRS melebihi ambang batas. Ditemukan pola perilaku hiperaktif dan impulsif yang mempengaruhi interaksi harian {$patientName}.",
                'decision' => 'rujuk_rs',
                'follow_up' => 'Rujuk ke Poli Tumbuh Kembang untuk evaluasi psikologis dan modifikasi perilaku terarah.',
            ],
            'SDQ' => [
                'clinical' => "Skor kesulitan total SDQ berada pada rentang abnormal. Masalah perilaku dan hiperaktivitas memerlukan pendampingan khusus.",
                'decision' => 'konseling_stimulasi',
                'follow_up' => 'Edukasi pengasuhan positif bagi orang tua dan koordinasi dengan lingkungan sekolah/PAUD.',
            ],
            'SRQ' => [
                'clinical' => "Skor SRQ-20 memenuhi indikasi distres emosional pengasuh. Diperlukan konseling psikososial keluarga untuk menjaga kesejahteraan mental ibu/pengasuh.",
                'decision' => 'konseling_stimulasi',
                'follow_up' => 'Jadwalkan konseling psikososial keluarga dan program dukungan pengasuh anak di UPTD BLK-ABK.',
            ],
        ];

        $info = $notesMap[$code] ?? [
            'clinical' => "Catatan evaluasi klinis untuk instrumen {$code}.",
            'decision' => 'konseling_stimulasi',
            'follow_up' => 'Lanjutkan pemantauan rutin.',
        ];

        ScreeningInterpretation::create([
            'screening_session_id' => $sessionId,
            'instrument_code' => $code,
            'doctor_id' => $doctorId,
            'clinical_notes' => $info['clinical'],
            'follow_up_decision' => $info['decision'],
            'follow_up_notes' => $info['follow_up'],
            'status' => 'completed',
            'completed_at' => $date->subHours(1),
        ]);
    }

    /**
     * Skenario pengujian aktif menggunakan anak asli UPTD:
     * - RM-002 (Chairil Rafqi Nababan, 61 bln): Sesi aktif hari ini untuk Orang Tua mengisi SDQ & SRQ
     * - RM-003 (Rychi Yislam Gaza, 25 bln): Sesi kemarin menunggu telaah dokter (pending_doctor_review)
     * - RM-005 (Adelio Vember, 37 bln): Sesi evaluasi ulang KPSP 14 hari untuk Perawat
     */
    private function seedActiveTestingSessions(Nurse $nurse, Doctor $doctor, CarbonImmutable $today): void
    {
        // 1. SKENARIO ORANG TUA: RM-002 (Chairil Rafqi Nababan, 61 bln / 5 th)
        $p2 = Patient::where('medical_record_number', 'RM-002')->first();
        if ($p2) {
            $s2 = ScreeningSession::create([
                'patient_id' => $p2->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => null,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $today->toDateString(),
                'age_months' => 61,
                'case_type' => 'lama',
                'referral_source' => 'Puskesmas Karang Rejo',
                'interventions' => ['konseling'],
                'status' => 'in_progress',
                'notes' => 'Pemeriksaan berkala usia 5 tahun. Menunggu pengisian kuesioner SDQ dan SRQ-20 oleh Orang Tua.',
                'doctor_notes' => null,
                'reviewed_at' => null,
            ]);

            ScreeningSessionInstrument::create([
                'screening_session_id' => $s2->id,
                'instrument_code' => 'KPSP',
                'status' => 'completed',
                'started_at' => $today->subHours(2),
                'completed_at' => $today->subHour(),
            ]);
            $this->seedInstrumentResult($s2->id, 'KPSP', 'normal', 60, $p2->name);

            ScreeningSessionInstrument::create([
                'screening_session_id' => $s2->id,
                'instrument_code' => 'GPPH',
                'status' => 'completed',
                'started_at' => $today->subHour(),
                'completed_at' => $today->subMinutes(30),
            ]);
            $this->seedInstrumentResult($s2->id, 'GPPH', 'normal', 60, $p2->name);

            // SDQ: status pending (siap diisi orang tua)
            ScreeningSessionInstrument::create([
                'screening_session_id' => $s2->id,
                'instrument_code' => 'SDQ',
                'status' => 'pending',
                'started_at' => null,
                'completed_at' => null,
            ]);

            // SRQ: status pending (siap diisi orang tua)
            ScreeningSessionInstrument::create([
                'screening_session_id' => $s2->id,
                'instrument_code' => 'SRQ',
                'status' => 'pending',
                'started_at' => null,
                'completed_at' => null,
            ]);
        }

        // 2. SKENARIO DOKTER: RM-003 (Rychi Yislam Gaza, 25 bln)
        $p3 = Patient::where('medical_record_number', 'RM-003')->first();
        if ($p3) {
            $date3 = $today->subDays(1);
            $s3 = ScreeningSession::create([
                'patient_id' => $p3->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $date3->toDateString(),
                'age_months' => 25,
                'case_type' => 'lama',
                'referral_source' => 'Puskesmas Damai',
                'interventions' => ['ot', 'tw', 'konseling'],
                'status' => 'pending_doctor_review',
                'notes' => 'Pemeriksaan evaluasi 25 bulan - Hasil KPSP meragukan (8/10). Menunggu tinjauan dokter.',
                'doctor_notes' => null,
                'reviewed_at' => null,
            ]);

            ScreeningSessionInstrument::create([
                'screening_session_id' => $s3->id,
                'instrument_code' => 'KPSP',
                'status' => 'completed',
                'started_at' => $date3->subHours(2),
                'completed_at' => $date3->subHours(1),
            ]);
            $this->seedInstrumentResult($s3->id, 'KPSP', 'borderline', 24, $p3->name);

            ScreeningSessionInstrument::create([
                'screening_session_id' => $s3->id,
                'instrument_code' => 'MCHAT',
                'status' => 'completed',
                'started_at' => $date3->subHours(1),
                'completed_at' => $date3->subMinutes(30),
            ]);
            $this->seedInstrumentResult($s3->id, 'MCHAT', 'normal', 24, $p3->name);
        }

        // 3. SKENARIO EVALUASI ULANG KPSP 14 HARI: RM-005 (Adelio Vember, 37 bln)
        $p5 = Patient::where('medical_record_number', 'RM-005')->first();
        if ($p5) {
            $date1 = $today->subDays(14);
            $s1 = ScreeningSession::create([
                'patient_id' => $p5->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $date1->toDateString(),
                'age_months' => 37,
                'case_type' => 'baru',
                'referral_source' => 'Puskesmas Manggar',
                'referral_target' => null,
                'interventions' => ['konseling'],
                'status' => 'reviewed',
                'notes' => 'Pemeriksaan skrining berkala 36 bulan - Hasil KPSP Meragukan (Dm: Skor 8/10). Diberikan instruksi intervensi stimulasi intensif 2 minggu di rumah.',
                'doctor_notes' => 'KPSP Meragukan (Dm) pada domain motorik kasar dan bicara. Lakukan stimulasi terarah selama 14 hari sesuai buku KIA, lalu lakukan evaluasi ulang KPSP.',
                'reviewed_at' => $date1->addHours(2),
            ]);

            ScreeningSessionInstrument::create([
                'screening_session_id' => $s1->id,
                'instrument_code' => 'KPSP',
                'status' => 'completed',
                'started_at' => $date1->subHours(2),
                'completed_at' => $date1->subHours(1),
            ]);
            $this->seedInstrumentResult($s1->id, 'KPSP', 'borderline', 36, $p5->name);

            ScreeningInterpretation::create([
                'screening_session_id' => $s1->id,
                'instrument_code' => 'KPSP',
                'doctor_id' => $doctor->id,
                'clinical_notes' => 'Hasil KPSP Meragukan (Dm: 8/10). Disarankan intervensi stimulasi dini intensif di rumah selama 2 minggu.',
                'follow_up_decision' => 'konseling_stimulasi',
                'follow_up_notes' => 'Jadwalkan evaluasi ulang KPSP 14 hari kemudian.',
                'status' => 'completed',
                'completed_at' => $date1->addHours(2),
            ]);

            // Sesi 2 (Hari Ini): Menunggu input evaluasi ulang KPSP oleh Perawat
            $sReeval = ScreeningSession::create([
                'patient_id' => $p5->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $today->toDateString(),
                'age_months' => 37,
                'case_type' => 'lama',
                'referral_source' => 'Puskesmas Manggar',
                'referral_target' => 'RSUD Kanujoso Djatiwibowo',
                'interventions' => ['ot', 'tw', 'rujukan'],
                'status' => 'draft',
                'evaluation_type' => 'kpsp_re_evaluation_2_weeks',
                'parent_session_id' => $s1->id,
                'notes' => "Evaluasi ulang KPSP 2 minggu pasca intervensi dini perkembangan dari Sesi #{$s1->id} (Hasil sebelumnya: Meragukan / Dm: 8/10).",
                'doctor_notes' => null,
                'reviewed_at' => null,
            ]);

            ScreeningSessionInstrument::create([
                'screening_session_id' => $sReeval->id,
                'instrument_code' => 'KPSP',
                'status' => 'pending',
                'started_at' => null,
                'completed_at' => null,
            ]);
        }
    }
}
