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

        $patients = Patient::query()->orderBy('birth_date', 'desc')->get();

        foreach ($patients as $patient) {
            $ageMonths = (int) $patient->birth_date->diffInMonths($today);
            $eligibleInstruments = $this->getEligibleInstruments($ageMonths);
            $kpspFormAge = $this->getKpspFormAge($ageMonths);

            // ---------------------------------------------------------
            // SESI 1: Kunjungan Awal — Normal / Sesuai Umur
            // Status: reviewed (Selesai Ditinjau Dokter)
            // Tanggal: 14 hari yang lalu
            // ---------------------------------------------------------
            $date1 = $today->subDays(14);
            $s1 = ScreeningSession::create([
                'patient_id' => $patient->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $date1->toDateString(),
                'age_months' => $ageMonths,
                'status' => 'reviewed',
                'notes' => 'Pemeriksaan skrining awal berkala (Kunjungan 1) - Hasil Normal / Sesuai Umur.',
                'doctor_notes' => "Pemeriksaan skrining berkala ke-1 untuk {$patient->name}. Seluruh aspek tumbuh kembang anak dalam batas normal sesuai usia.",
                'reviewed_at' => $date1->addHours(2),
            ]);

            foreach ($eligibleInstruments as $code) {
                ScreeningSessionInstrument::create([
                    'screening_session_id' => $s1->id,
                    'instrument_code' => $code,
                    'status' => 'completed',
                    'started_at' => $date1->subHours(2),
                    'completed_at' => $date1->subHours(1),
                ]);

                $this->seedInstrumentResult($s1->id, $code, 'normal', $kpspFormAge, $patient->name);

                ScreeningInterpretation::create([
                    'screening_session_id' => $s1->id,
                    'instrument_code' => $code,
                    'doctor_id' => $doctor->id,
                    'clinical_notes' => "Hasil skrining {$code} berada dalam batas normal. Pertumbuhan dan perkembangan anak terpantau baik.",
                    'follow_up_decision' => 'konseling_stimulasi',
                    'follow_up_notes' => 'Lanjutkan stimulasi rutin di rumah dan jadwalkan skrining berkala berikutnya.',
                    'status' => 'completed',
                    'completed_at' => $date1->addHours(2),
                ]);
            }

            // ---------------------------------------------------------
            // SESI 2: Kunjungan Evaluasi — Meragukan / Borderline
            // Status: pending_doctor_review (Siap Ditinjau Dokter)
            // Tanggal: 7 hari yang lalu
            // ---------------------------------------------------------
            $date2 = $today->subDays(7);
            $s2 = ScreeningSession::create([
                'patient_id' => $patient->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $date2->toDateString(),
                'age_months' => $ageMonths,
                'status' => 'pending_doctor_review',
                'notes' => 'Pemeriksaan skrining evaluasi berkala (Kunjungan 2) - Ditemukan indikasi Meragukan / Borderline. Menunggu tinjauan dokter.',
                'doctor_notes' => null,
                'reviewed_at' => null,
            ]);

            foreach ($eligibleInstruments as $code) {
                ScreeningSessionInstrument::create([
                    'screening_session_id' => $s2->id,
                    'instrument_code' => $code,
                    'status' => 'completed',
                    'started_at' => $date2->subHours(2),
                    'completed_at' => $date2->subHours(1),
                ]);

                $this->seedInstrumentResult($s2->id, $code, 'borderline', $kpspFormAge, $patient->name);
            }

            // ---------------------------------------------------------
            // SESI 3: Kunjungan Komprehensif — Penyimpangan / Abnormal
            // Status: reviewed (Selesai Ditinjau Dokter dengan Rujukan)
            // Tanggal: Hari ini
            // ---------------------------------------------------------
            $date3 = $today;
            $s3 = ScreeningSession::create([
                'patient_id' => $patient->id,
                'nurse_id' => $nurse->id,
                'doctor_id' => $doctor->id,
                'created_by_user_id' => $nurse->user_id,
                'screening_date' => $date3->toDateString(),
                'age_months' => $ageMonths,
                'status' => 'reviewed',
                'notes' => 'Pemeriksaan komprehensif (Kunjungan 3) - Indikasi Penyimpangan / Risiko Tinggi / Perlu Intervensi Spesialis.',
                'doctor_notes' => "Tinjauan klinis selesai untuk {$patient->name}. Hasil skrining mengindikasikan perlunya pemantauan intensif, konseling keluarga, dan rujukan tumbuh kembang.",
                'reviewed_at' => $date3->subHours(1),
            ]);

            foreach ($eligibleInstruments as $code) {
                ScreeningSessionInstrument::create([
                    'screening_session_id' => $s3->id,
                    'instrument_code' => $code,
                    'status' => 'completed',
                    'started_at' => $date3->subHours(3),
                    'completed_at' => $date3->subHours(2),
                ]);

                $this->seedInstrumentResult($s3->id, $code, 'abnormal', $kpspFormAge, $patient->name);

                // Tambahkan interpretasi dokter resmi untuk setiap instrumen pada Sesi 3
                $this->seedDoctorInterpretation($s3->id, $code, $doctor->id, $date3, $patient->name);
            }
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
}