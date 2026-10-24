<?php

namespace Tests\Feature;

use App\Models\Doctor;
use App\Models\Nurse;
use App\Models\Patient;
use App\Models\ScreeningSession;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScreeningTestCasesSpectrumTest extends TestCase
{
    use RefreshDatabase;

    private User $nurseUser;
    private Nurse $nurse;
    private User $doctorUser;
    private Doctor $doctor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();

        $this->nurseUser = User::where('email', 'perawat@spk.test')->firstOrFail();
        $this->nurse = $this->nurseUser->nurse;

        $this->doctorUser = User::where('email', 'dokter@spk.test')->firstOrFail();
        $this->doctor = $this->doctorUser->doctor;
    }

    public function test_all_rentang_umur_patients_exist_and_each_has_three_sessions(): void
    {
        $expectedPatients = [
            'RM-RU-001' => 3,   // 3 Bulan
            'RM-RU-002' => 6,   // 6 Bulan (Baris 1 Rentang Umur.pdf)
            'RM-RU-003' => 9,   // 9 Bulan (Baris 2 Rentang Umur.pdf)
            'RM-RU-004' => 12,  // 12 Bulan
            'RM-RU-005' => 18,  // 18 Bulan (Baris 3 Rentang Umur.pdf)
            'RM-RU-006' => 24,  // 24 Bulan (Baris 4 Rentang Umur.pdf)
            'RM-RU-007' => 30,  // 30 Bulan
            'RM-RU-008' => 36,  // 36 Bulan (Baris 5 Rentang Umur.pdf)
            'RM-RU-009' => 48,  // 48 Bulan (Baris 6 Rentang Umur.pdf)
            'RM-RU-010' => 60,  // 60 Bulan (Baris 7 Rentang Umur.pdf)
            'RM-RU-011' => 72,  // 72 Bulan (Baris 8 Rentang Umur.pdf)
            'RM-RU-012' => 84,  // 84 Bulan / 7 Tahun
            'RM-RU-013' => 120, // 120 Bulan / 10 Tahun
        ];

        $this->assertSame(13, Patient::count());
        $this->assertSame(39, ScreeningSession::count());

        foreach ($expectedPatients as $mrn => $approxAgeMonths) {
            $patient = Patient::where('medical_record_number', $mrn)->first();
            $this->assertNotNull($patient, "Pasien {$mrn} harus ada dalam database.");

            // Setiap pasien wajib memiliki tepat 3 sesi skrining
            $sessions = $patient->screeningSessions()->get();
            $this->assertCount(3, $sessions, "Pasien {$mrn} harus memiliki tepat 3 sesi skrining.");

            // Setiap sesi hanya mengambil instrumen yang eligible untuk usianya
            foreach ($sessions as $session) {
                $instruments = $session->screeningSessionInstruments()->pluck('instrument_code')->all();

                if ($approxAgeMonths < 16) {
                    $this->assertNotContains('MCHAT', $instruments);
                }
                if ($approxAgeMonths < 36) {
                    $this->assertNotContains('GPPH', $instruments);
                }
                if ($approxAgeMonths < 48) {
                    $this->assertNotContains('SDQ', $instruments);
                }
                if ($approxAgeMonths > 30) {
                    $this->assertNotContains('MCHAT', $instruments);
                }
                if ($approxAgeMonths > 72) {
                    $this->assertNotContains('KPSP', $instruments);
                    $this->assertNotContains('GPPH', $instruments);
                }
            }
        }
    }

    public function test_age_eligibility_blocks_ineligible_instruments_on_session_creation(): void
    {
        $today = CarbonImmutable::today()->toDateString();

        // 1. Bayi 3 Bulan (RM-RU-001) mencoba SDQ -> ditolak (< 48 bulan)
        $p1 = Patient::where('medical_record_number', 'RM-RU-001')->firstOrFail();
        $resp = $this->actingAs($this->nurseUser)->post('/screening-sessions', [
            'patient_id' => $p1->id,
            'screening_date' => $today,
            'instruments' => ['SDQ'],
        ]);
        $resp->assertSessionHasErrors('instruments');

        // 2. Batita 18 Bulan (RM-RU-005) mencoba GPPH -> ditolak (< 36 bulan)
        $p5 = Patient::where('medical_record_number', 'RM-RU-005')->firstOrFail();
        $resp = $this->actingAs($this->nurseUser)->post('/screening-sessions', [
            'patient_id' => $p5->id,
            'screening_date' => $today,
            'instruments' => ['GPPH'],
        ]);
        $resp->assertSessionHasErrors('instruments');

        // 3. Anak 36 Bulan (RM-RU-008) mencoba M-CHAT-R -> ditolak (> 30 bulan)
        $p8 = Patient::where('medical_record_number', 'RM-RU-008')->firstOrFail();
        $resp = $this->actingAs($this->nurseUser)->post('/screening-sessions', [
            'patient_id' => $p8->id,
            'screening_date' => $today,
            'instruments' => ['MCHAT'],
        ]);
        $resp->assertSessionHasErrors('instruments');

        // 4. Anak 7 Tahun / 84 Bulan (RM-RU-012) mencoba KPSP -> ditolak (> 72 bulan)
        $p12 = Patient::where('medical_record_number', 'RM-RU-012')->firstOrFail();
        $resp = $this->actingAs($this->nurseUser)->post('/screening-sessions', [
            'patient_id' => $p12->id,
            'screening_date' => $today,
            'instruments' => ['KPSP'],
        ]);
        $resp->assertSessionHasErrors('instruments');
    }

    public function test_all_screening_categories_and_results_are_present_in_dataset(): void
    {
        // 1. KPSP: sesuai_umur, meragukan, kemungkinan_penyimpangan
        $p2 = Patient::where('medical_record_number', 'RM-RU-002')->firstOrFail();
        $p2Sessions = $p2->screeningSessions()->orderBy('id')->get();
        $this->assertSame('sesuai_umur', $p2Sessions[0]->kpspScreening->category);
        $this->assertSame('meragukan', $p2Sessions[1]->kpspScreening->category);
        $this->assertSame('kemungkinan_penyimpangan', $p2Sessions[2]->kpspScreening->category);

        // 2. M-CHAT-R: risiko_rendah, risiko_sedang_tinggi
        $p5 = Patient::where('medical_record_number', 'RM-RU-005')->firstOrFail();
        $p5Sessions = $p5->screeningSessions()->orderBy('id')->get();
        $this->assertSame('risiko_rendah', $p5Sessions[0]->mchatScreening->category);
        $this->assertSame('risiko_sedang_tinggi', $p5Sessions[1]->mchatScreening->category);
        $this->assertSame('risiko_sedang_tinggi', $p5Sessions[2]->mchatScreening->category);

        // 3. GPPH: normal, meragukan, kemungkinan_gpph
        $p8 = Patient::where('medical_record_number', 'RM-RU-008')->firstOrFail();
        $p8Sessions = $p8->screeningSessions()->orderBy('id')->get();
        $this->assertSame('normal', $p8Sessions[0]->gpphScreening->category);
        $this->assertSame('meragukan', $p8Sessions[1]->gpphScreening->category);
        $this->assertTrue($p8Sessions[1]->gpphScreening->examiner_doubtful);
        $this->assertSame('kemungkinan_gpph', $p8Sessions[2]->gpphScreening->category);

        // 4. SDQ: normal, ambang_borderline, abnormal
        $p9 = Patient::where('medical_record_number', 'RM-RU-009')->firstOrFail();
        $p9Sessions = $p9->screeningSessions()->orderBy('id')->get();
        $this->assertSame('normal', $p9Sessions[0]->sdqScreening->total_difficulties_category);
        $this->assertSame('ambang_borderline', $p9Sessions[1]->sdqScreening->total_difficulties_category);
        $this->assertSame('abnormal', $p9Sessions[2]->sdqScreening->total_difficulties_category);

        // 5. SRQ-20: di_bawah_nilai_pisah, gangguan_mental_emosional_distres
        $this->assertSame('di_bawah_nilai_pisah', $p2Sessions[0]->srqScreening->category);
        $this->assertSame('gangguan_mental_emosional_distres', $p2Sessions[2]->srqScreening->category);
    }

    public function test_workflow_statuses_and_doctor_interpretations_are_accessible(): void
    {
        // Dokter dapat mengakses sesi reviewed dengan catatan klinis lengkap
        $sReview = ScreeningSession::where('status', 'reviewed')->firstOrFail();
        $resp = $this->actingAs($this->doctorUser)->get("/screening-sessions/{$sReview->id}");
        $resp->assertOk();
        $this->assertNotEmpty($sReview->screeningInterpretations);

        // Dokter dapat mengakses sesi pending_doctor_review
        $sPending = ScreeningSession::where('status', 'pending_doctor_review')->firstOrFail();
        $resp = $this->actingAs($this->doctorUser)->get("/screening-sessions/{$sPending->id}");
        $resp->assertOk();

        // Perawat dapat melihat sesi milik pasien
        $respNurse = $this->actingAs($this->nurseUser)->get("/screening-sessions/{$sReview->id}");
        $respNurse->assertOk();
    }
}
