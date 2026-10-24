<?php

namespace Tests\Feature;

use App\Models\Doctor;
use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningInterpretation;
use App\Models\ScreeningSession;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScreeningInterpretationTest extends TestCase
{
    use RefreshDatabase;

    public function test_doctor_can_record_clinical_interpretation_for_completed_instrument(): void
    {
        [$doctorUser, $doctor] = $this->createDoctor();
        $session = $this->createSessionWithCompletedInstrument('KPSP');

        $response = $this->actingAs($doctorUser)
            ->post(route('screening-sessions.interpretations.store', $session), [
                'instrument_code' => 'KPSP',
                'clinical_notes' => 'Perkembangan motorik kasar anak sesuai usia, stimulasi bahasa perlu ditingkatkan.',
                'follow_up_decision' => 'stimulasi_2_minggu',
                'follow_up_notes' => 'Ibu diedukasi cara stimulasi berbicara di rumah selama 2 minggu.',
                'status' => 'completed',
            ]);

        $response->assertRedirect();
        $response->assertSessionHas('success');

        $this->assertDatabaseHas('screening_interpretations', [
            'screening_session_id' => $session->id,
            'doctor_id' => $doctor->id,
            'instrument_code' => 'KPSP',
            'follow_up_decision' => 'stimulasi_2_minggu',
            'status' => 'completed',
        ]);

        $this->assertDatabaseHas('screening_sessions', [
            'id' => $session->id,
            'doctor_id' => $doctor->id,
        ]);
    }

    public function test_doctor_cannot_record_interpretation_for_incomplete_instrument(): void
    {
        [$doctorUser] = $this->createDoctor();
        $session = $this->createSessionWithPendingInstrument('SDQ');

        $response = $this->actingAs($doctorUser)
            ->post(route('screening-sessions.interpretations.store', $session), [
                'instrument_code' => 'SDQ',
                'clinical_notes' => 'Catatan prematur.',
                'status' => 'completed',
            ]);

        $response->assertStatus(422);
        $this->assertDatabaseCount('screening_interpretations', 0);
    }

    public function test_doctor_can_finalize_session_review(): void
    {
        [$doctorUser, $doctor] = $this->createDoctor();
        $session = $this->createSessionWithCompletedInstrument('KPSP');

        $response = $this->actingAs($doctorUser)
            ->post(route('screening-sessions.finalize', $session), [
                'doctor_notes' => 'Sesi skrining lengkap. Anak dalam batas perkembangan normal. Jadwalkan kontrol 3 bulan lagi.',
            ]);

        $response->assertRedirect();
        $response->assertSessionHas('success', 'Tinjauan sesi skrining berhasil difinalisasi.');

        $session->refresh();
        $this->assertSame('reviewed', $session->status);
        $this->assertSame($doctor->id, $session->doctor_id);
        $this->assertNotNull($session->reviewed_at);
        $this->assertStringContainsString('Sesi skrining lengkap', $session->doctor_notes);
    }

    public function test_cannot_finalize_already_reviewed_session(): void
    {
        [$doctorUser] = $this->createDoctor();
        $session = $this->createSessionWithCompletedInstrument('KPSP');
        $session->update(['status' => 'reviewed']);

        $response = $this->actingAs($doctorUser)
            ->post(route('screening-sessions.finalize', $session), [
                'doctor_notes' => 'Catatan tambahan.',
            ]);

        $response->assertStatus(422);
    }

    public function test_nurse_cannot_record_clinical_interpretations_or_finalize(): void
    {
        $nurseRole = Role::firstOrCreate(['name' => 'perawat']);
        $nurseUser = User::create([
            'name' => 'Perawat Test',
            'email' => 'nurse-interp@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);
        Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NRS-INTERP-001',
        ]);

        $session = $this->createSessionWithCompletedInstrument('KPSP');

        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.interpretations.store', $session), [
                'instrument_code' => 'KPSP',
                'clinical_notes' => 'Catatan ilegal.',
                'status' => 'completed',
            ])
            ->assertForbidden();

        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.finalize', $session), [
                'doctor_notes' => 'Catatan ilegal.',
            ])
            ->assertForbidden();
    }

    /**
     * @return array{0: User, 1: Doctor}
     */
    private function createDoctor(): array
    {
        $doctorRole = Role::firstOrCreate(['name' => 'dokter']);

        $doctorUser = User::create([
            'name' => 'dr. Budi Santoso, Sp.A',
            'email' => 'dr.budi-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $doctor = Doctor::create([
            'user_id' => $doctorUser->id,
            'specialization' => 'Spesialis Anak',
        ]);

        return [$doctorUser, $doctor];
    }

    private function createSessionWithCompletedInstrument(string $instrumentCode): ScreeningSession
    {
        $nurseRole = Role::firstOrCreate(['name' => 'perawat']);
        $parentRole = Role::firstOrCreate(['name' => 'orang_tua']);

        $nurseUser = User::create([
            'name' => 'Perawat Pendamping',
            'email' => 'nurse-sess-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NRS-SESS-' . uniqid(),
        ]);

        $parentUser = User::create([
            'name' => 'Ibu Pasien',
            'email' => 'ibu-sess-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $parentRole->id,
        ]);

        $parentGuardian = ParentGuardian::create(['user_id' => $parentUser->id]);

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-INTERP-' . uniqid(),
            'name' => 'Anak Pasien Interp',
            'birth_date' => '2022-10-11',
            'gender' => 'L',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        $session = new ScreeningSession([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'status' => 'pending_doctor_review',
        ]);

        $session->created_by_user_id = $nurseUser->id;
        $session->age_months = 48;
        $session->save();

        $session->screeningSessionInstruments()->create([
            'instrument_code' => $instrumentCode,
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        return $session;
    }

    private function createSessionWithPendingInstrument(string $instrumentCode): ScreeningSession
    {
        $session = $this->createSessionWithCompletedInstrument($instrumentCode);
        $session->screeningSessionInstruments()->update(['status' => 'pending', 'completed_at' => null]);
        $session->update(['status' => 'draft']);

        return $session;
    }
}
