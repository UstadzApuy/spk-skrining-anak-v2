<?php

namespace Tests\Feature;

use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningSession;
use App\Models\User;
use App\Models\SdqScreening;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScreeningSessionTest extends TestCase
{
    use RefreshDatabase;


    public function test_sdq_cannot_be_selected_for_patient_under_four(): void
    {
        [$nurseUser, , $patient] = $this->createNurseAndPatient();

        $response = $this->actingAs($nurseUser)
            ->from(route('screening-sessions.create'))
            ->post(route('screening-sessions.store'), [
                'patient_id' => $patient->id,
                'screening_date' => '2026-10-11',
                'instruments' => ['SDQ'],
            ]);

        $response->assertRedirect(route('screening-sessions.create'));
        $response->assertSessionHasErrors('instruments');

        $this->assertDatabaseCount('screening_sessions', 0);
    }

    public function test_sdq_cannot_be_selected_for_patient_aged_eleven_or_older(): void
    {
        [$nurseUser, , $patient] = $this->createNurseAndPatient();

        $patient->update([
            'birth_date' => '2015-10-11',
        ]);

        $response = $this->actingAs($nurseUser)
            ->from(route('screening-sessions.create'))
            ->post(route('screening-sessions.store'), [
                'patient_id' => $patient->id,
                'screening_date' => '2026-10-11',
                'instruments' => ['SDQ'],
            ]);

        $response->assertRedirect(route('screening-sessions.create'));
        $response->assertSessionHasErrors('instruments');

        $this->assertDatabaseCount('screening_sessions', 0);
    }


    public function test_perawat_can_create_screening_session(): void
    {
        [$nurseUser, $nurse, $patient] = $this->createNurseAndPatient();

        $patient->update([
            'birth_date' => '2022-10-11',
        ]);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.store'), [
                'patient_id' => $patient->id,
                'screening_date' => '2026-10-11',
                'instruments' => ['KPSP', 'SDQ'],

                // Values below must not override system-generated data.
                'nurse_id' => 999999,
                'age_months' => 99,
                'status' => 'reviewed',
            ]);

        $response->assertRedirect(route('screening-sessions.index'));

        $response->assertSessionHas(
            'success',
            'Sesi skrining berhasil dibuat.'
        );

        $session = ScreeningSession::query()->firstOrFail();

        $this->assertSame($nurse->id, $session->nurse_id);
        $this->assertSame(48, $session->age_months);
        $this->assertSame('draft', $session->status);

        $this->assertDatabaseHas('screening_sessions', [
            'id' => $session->id,
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'age_months' => 48,
            'status' => 'draft',
        ]);

        $this->assertDatabaseHas('screening_session_instruments', [
            'screening_session_id' => $session->id,
            'instrument_code' => 'KPSP',
            'status' => 'pending',
        ]);

        $this->assertDatabaseHas('screening_session_instruments', [
            'screening_session_id' => $session->id,
            'instrument_code' => 'SDQ',
            'status' => 'pending',
        ]);

        $this->assertDatabaseCount('screening_sessions', 1);
        $this->assertDatabaseCount('screening_session_instruments', 2);
    }

    public function test_non_nurse_cannot_create_screening_session(): void
    {
        $doctorRole = Role::create([
            'name' => 'dokter',
        ]);

        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter-session@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $this->actingAs($doctor)
            ->post(route('screening-sessions.store'), [])
            ->assertForbidden();

        $this->assertDatabaseCount('screening_sessions', 0);
    }

    public function test_guest_cannot_create_screening_session(): void
    {
        $this->post(route('screening-sessions.store'), [])
            ->assertRedirect(route('login'));

        $this->assertDatabaseCount('screening_sessions', 0);
    }


    public function test_perawat_can_open_sdq_form_for_eligible_session(): void
    {
        [$nurseUser, $nurse, $patient] = $this->createNurseAndPatient();

        $patient->update([
            'birth_date' => '2021-09-11',
        ]);

        $session = new ScreeningSession([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'status' => 'draft',
        ]);

        $session->age_months = 61;
        $session->save();

        $session->screeningSessionInstruments()->create([
            'instrument_code' => 'SDQ',
            'status' => 'pending',
        ]);

        $this->actingAs($nurseUser)
            ->get(route('screening-sessions.sdq.create', $session))
            ->assertOk();
    }

    public function test_perawat_cannot_open_sdq_for_ineligible_age(): void
    {
        [$nurseUser, $nurse, $patient] = $this->createNurseAndPatient();

        $session = new ScreeningSession([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'status' => 'draft',
        ]);

        $session->age_months = 47;
        $session->save();

        $session->screeningSessionInstruments()->create([
            'instrument_code' => 'SDQ',
            'status' => 'pending',
        ]);

        $this->actingAs($nurseUser)
            ->get(route('screening-sessions.sdq.create', $session))
            ->assertStatus(422);
    }

    public function test_perawat_cannot_open_another_nurses_sdq_form(): void
    {
        [$ownerUser, $nurse, $patient] = $this->createNurseAndPatient();

        $otherUser = User::create([
            'name' => 'Perawat Lain',
            'email' => 'perawat-lain-sdq@test.local',
            'password' => 'password',
            'role_id' => $ownerUser->role_id,
        ]);

        Nurse::create([
            'user_id' => $otherUser->id,
            'registration_number' => 'NRS-SDQ-002',
        ]);

        $session = new ScreeningSession([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'status' => 'draft',
        ]);

        $session->age_months = 61;
        $session->save();

        $session->screeningSessionInstruments()->create([
            'instrument_code' => 'SDQ',
            'status' => 'pending',
        ]);

        $this->actingAs($otherUser)
            ->get(route('screening-sessions.sdq.create', $session))
            ->assertForbidden();
    }


    /**
     * Create a nurse account, nurse profile, and patient for testing.
     *
     * @return array{0: User, 1: Nurse, 2: Patient}
     */
    private function createNurseAndPatient(): array
    {
        $nurseRole = Role::create([
            'name' => 'perawat',
        ]);

        $parentRole = Role::create([
            'name' => 'orang_tua',
        ]);

        $nurseUser = User::create([
            'name' => 'Perawat Test',
            'email' => 'perawat-session@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NRS-SESSION-001',
        ]);

        $parentUser = User::create([
            'name' => 'Orang Tua Test',
            'email' => 'orangtua-session@test.local',
            'password' => 'password',
            'role_id' => $parentRole->id,
        ]);

        $parentGuardian = ParentGuardian::create([
            'user_id' => $parentUser->id,
        ]);

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-SESSION-001',
            'name' => 'Anak Test',
            'birth_date' => '2026-04-25',
            'gender' => 'L',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        return [$nurseUser, $nurse, $patient];
    }


    public function test_perawat_can_view_own_screening_session(): void
    {
        [$nurseUser, $nurse, $patient] = $this->createNurseAndPatient();

        $session = new ScreeningSession([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'status' => 'draft',
        ]);

        $session->age_months = 5;
        $session->save();

        $this->actingAs($nurseUser)
            ->get(route('screening-sessions.show', $session))
            ->assertOk()
            ->assertInertia(fn ($page) => $page
                ->component('ScreeningSessions/Show')
                ->where('session.id', $session->id)
                ->where('session.patient.name', $patient->name)
            );
    }

    public function test_perawat_cannot_view_another_nurses_screening_session(): void
    {
        [$ownerUser, $nurse, $patient] = $this->createNurseAndPatient();

        $otherUser = User::create([
            'name' => 'Perawat Lain',
            'email' => 'perawat-lain@test.local',
            'password' => 'password',
            'role_id' => $ownerUser->role_id,
        ]);

        Nurse::create([
            'user_id' => $otherUser->id,
            'registration_number' => 'NRS-SESSION-002',
        ]);

        $session = new ScreeningSession([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'status' => 'draft',
        ]);

        $session->age_months = 5;
        $session->save();

        $this->actingAs($otherUser)
            ->get(route('screening-sessions.show', $session))
            ->assertForbidden();
    }



    public function test_perawat_can_open_create_form_with_only_active_patients(): void
    {
        [$nurseUser, , $patient] = $this->createNurseAndPatient();

        Patient::create([
            'parent_guardian_id' => $patient->parent_guardian_id,
            'medical_record_number' => 'RM-SESSION-INACTIVE',
            'name' => 'Anak Tidak Aktif',
            'birth_date' => '2024-01-01',
            'gender' => 'P',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => false,
        ]);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.create'));

        $response->assertOk();

        $response->assertInertia(fn ($page) => $page
            ->component('ScreeningSessions/Create')
            ->has('patients', 1)
            ->where('patients.0.id', $patient->id)
        );
    }


public function test_perawat_can_submit_25_sdq_answers_and_save_scoring_result(): void
{
    [$nurseUser, $session] = $this->createEligibleSdqSession();

    $answers = array_fill(0, 25, 0);

    $response = $this->actingAs($nurseUser)
        ->post(route('screening-sessions.sdq.store', $session), [
            'answers' => $answers,
        ]);

    $response
        ->assertRedirect(route('screening-sessions.show', $session))
        ->assertSessionHas(
            'success',
            'Hasil SDQ berhasil disimpan.'
        );

    $result = SdqScreening::query()
        ->where('screening_session_id', $session->id)
        ->firstOrFail();

    $this->assertSame($answers, $result->answers);

    // Expected scores account for the five reverse-scored items.
    $this->assertSame(0, $result->emotional_score);
    $this->assertSame(2, $result->conduct_score);
    $this->assertSame(4, $result->hyperactivity_score);
    $this->assertSame(4, $result->peer_score);
    $this->assertSame(10, $result->total_difficulties_score);
    $this->assertSame(0, $result->prosocial_score);
    $this->assertSame('normal', $result->emotional_category);
    $this->assertSame('normal', $result->conduct_category);
    $this->assertSame('normal', $result->hyperactivity_category);
    $this->assertSame('abnormal', $result->peer_category);

    $this->assertSame(
        'normal',
        $result->total_difficulties_category
    );

    $this->assertSame(
        'abnormal',
        $result->prosocial_category
    );

    $this->assertDatabaseHas('screening_session_instruments', [
        'screening_session_id' => $session->id,
        'instrument_code' => 'SDQ',
        'status' => 'completed',
    ]);

    $this->assertDatabaseHas('screening_sessions', [
        'id' => $session->id,
        'status' => 'pending_doctor_review',
    ]);
}

public function test_sdq_rejects_incomplete_answers(): void
{
    [$nurseUser, $session] = $this->createEligibleSdqSession();

    $response = $this->actingAs($nurseUser)
        ->from(route('screening-sessions.sdq.create', $session))
        ->post(route('screening-sessions.sdq.store', $session), [
            'answers' => array_fill(0, 24, 0),
        ]);

    $response
        ->assertRedirect(route('screening-sessions.sdq.create', $session))
        ->assertSessionHasErrors('answers');

    $this->assertDatabaseCount('sdq_screenings', 0);

    $this->assertDatabaseHas('screening_session_instruments', [
        'screening_session_id' => $session->id,
        'instrument_code' => 'SDQ',
        'status' => 'pending',
    ]);
}

/**
 * Create an eligible screening session with a pending SDQ instrument.
 *
 * @return array{0: User, 1: ScreeningSession}
 */
private function createEligibleSdqSession(): array
{
    [$nurseUser, $nurse, $patient] = $this->createNurseAndPatient();

    $patient->update([
        'birth_date' => '2021-09-11',
    ]);

    $session = new ScreeningSession([
        'patient_id' => $patient->id,
        'nurse_id' => $nurse->id,
        'screening_date' => '2026-10-11',
        'status' => 'draft',
    ]);

    $session->age_months = 61;
    $session->save();

    $session->screeningSessionInstruments()->create([
        'instrument_code' => 'SDQ',
        'status' => 'pending',
    ]);

    return [$nurseUser, $session];
}
}