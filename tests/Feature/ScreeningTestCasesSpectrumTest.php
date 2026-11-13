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

    public function test_all_testing_patients_exist_and_have_valid_sessions(): void
    {
        $this->assertSame(176, Patient::count());

        $firstFewPatients = [
            'RM-001' => 86, // Muhammad Zain Ageng Pangestu (86 Bulan / 7.2 Th)
            'RM-002' => 61, // Chairil Rafqi Nababan (61 Bulan / 5.1 Th)
            'RM-003' => 25, // Rychi Yislam Gaza (25 Bulan / 2.1 Th)
            'RM-004' => 81, // Nausyad Ezzar A. (81 Bulan / 6.8 Th)
            'RM-005' => 37, // Adelio Vember (37 Bulan / 3.1 Th)
        ];

        foreach ($firstFewPatients as $mrn => $approxAgeMonths) {
            $patient = Patient::where('medical_record_number', $mrn)->first();
            $this->assertNotNull($patient, "Pasien {$mrn} harus ada dalam database.");

            $sessions = $patient->screeningSessions()->get();
            $this->assertNotEmpty($sessions, "Pasien {$mrn} harus memiliki sesi skrining.");
        }
    }

    public function test_age_eligibility_blocks_ineligible_instruments_on_session_creation(): void
    {
        $today = CarbonImmutable::today()->toDateString();

        // 1. Batita 25 Bulan (RM-003: Rychi Yislam Gaza) mencoba SDQ -> ditolak (< 48 bulan)
        $p3 = Patient::where('medical_record_number', 'RM-003')->firstOrFail();
        $resp = $this->actingAs($this->nurseUser)->post(route('screening-sessions.store'), [
            'patient_id' => $p3->id,
            'screening_date' => $today,
            'instruments' => ['SDQ'],
        ]);
        $resp->assertSessionHasErrors('instruments');

        // 2. Batita 25 Bulan (RM-003) mencoba GPPH -> ditolak (< 36 bulan)
        $resp2 = $this->actingAs($this->nurseUser)->post(route('screening-sessions.store'), [
            'patient_id' => $p3->id,
            'screening_date' => $today,
            'instruments' => ['GPPH'],
        ]);
        $resp2->assertSessionHasErrors('instruments');

        // 3. Balita 37 Bulan (RM-005: Adelio Vember) mencoba M-CHAT-R -> ditolak (> 30 bulan)
        $p5 = Patient::where('medical_record_number', 'RM-005')->firstOrFail();
        $resp3 = $this->actingAs($this->nurseUser)->post(route('screening-sessions.store'), [
            'patient_id' => $p5->id,
            'screening_date' => $today,
            'instruments' => ['MCHAT'],
        ]);
        $resp3->assertSessionHasErrors('instruments');

        // 4. Anak 61 Bulan (RM-002: Chairil Rafqi Nababan) mencoba M-CHAT-R -> ditolak (> 30 bulan)
        $p2 = Patient::where('medical_record_number', 'RM-002')->firstOrFail();
        $resp4 = $this->actingAs($this->nurseUser)->post(route('screening-sessions.store'), [
            'patient_id' => $p2->id,
            'screening_date' => $today,
            'instruments' => ['MCHAT'],
        ]);
        $resp4->assertSessionHasErrors('instruments');
    }

    public function test_all_screening_categories_and_results_are_present_in_dataset(): void
    {
        // 1. KPSP: meragukan pada sesi pending review (RM-003)
        $p3 = Patient::where('medical_record_number', 'RM-003')->firstOrFail();
        $p3Pending = $p3->screeningSessions()->where('status', 'pending_doctor_review')->firstOrFail();
        $this->assertSame('meragukan', $p3Pending->kpspScreening->category);

        // 2. M-CHAT-R: risiko_rendah pada sesi RM-003
        $this->assertSame('risiko_rendah', $p3Pending->mchatScreening->category);

        // 3. GPPH pada sesi RM-002 (sesuai register riil UPTD)
        $p2 = Patient::where('medical_record_number', 'RM-002')->firstOrFail();
        $p2Session = $p2->screeningSessions()->where('status', 'reviewed')->firstOrFail();
        $this->assertContains($p2Session->gpphScreening->category, ['normal', 'kemungkinan_gpph']);

        // 4. SDQ & SRQ-20 pada sesi RM-002
        $this->assertNotNull($p2Session->sdqScreening);
        $this->assertNotNull($p2Session->srqScreening);
    }

    public function test_workflow_statuses_and_doctor_interpretations_are_accessible(): void
    {
        // Dokter dapat mengakses sesi reviewed dengan catatan klinis lengkap
        $sReview = ScreeningSession::where('status', 'reviewed')->firstOrFail();
        $resp = $this->actingAs($this->doctorUser)->get(route('screening-sessions.show', $sReview));
        $resp->assertOk();
        $this->assertNotEmpty($sReview->screeningInterpretations);

        // Dokter dapat mengakses sesi pending_doctor_review
        $sPending = ScreeningSession::where('status', 'pending_doctor_review')->firstOrFail();
        $resp = $this->actingAs($this->doctorUser)->get(route('screening-sessions.show', $sPending));
        $resp->assertOk();

        // Perawat dapat melihat sesi milik pasien
        $respNurse = $this->actingAs($this->nurseUser)->get(route('screening-sessions.show', $sReview));
        $respNurse->assertOk();
    }
}
