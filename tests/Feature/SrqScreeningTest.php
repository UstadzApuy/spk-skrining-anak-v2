<?php

namespace Tests\Feature;

use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningSession;
use App\Models\SrqScreening;
use App\Models\User;
use Inertia\Testing\AssertableInertia as Assert;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SrqScreeningTest extends TestCase
{
    use RefreshDatabase;

    public function test_perawat_can_open_srq_form(): void
    {
        [$nurseUser, $session] = $this->createNurseWithSrqSession();

        $this->actingAs($nurseUser)
            ->get(route('screening-sessions.srq.create', $session))
            ->assertOk();
    }

    public function test_score_of_five_is_saved_below_cutoff(): void
    {
        [$nurseUser, $session] = $this->createNurseWithSrqSession();

        $answers = array_merge(
            array_fill(0, 5, true),
            array_fill(0, 15, false),
        );

        $response = $this->actingAs($nurseUser)
            ->post(
                route('screening-sessions.srq.store', $session),
                ['answers' => $answers],
            );

        $response->assertRedirect(
            route('screening-sessions.srq.complete', $session)
        );

        $this->assertDatabaseHas('srq_screenings', [
            'screening_session_id' => $session->id,
            'score' => 5,
            'category' => 'di_bawah_nilai_pisah',
        ]);

        $result = SrqScreening::query()
            ->where('screening_session_id', $session->id)
            ->firstOrFail();

        $this->assertSame($answers, $result->answers);
        $this->assertNull($result->recommendation);

        $session->refresh();

        $this->assertSame(
            'pending_doctor_review',
            $session->status
        );

        $this->assertDatabaseHas('screening_session_instruments', [
            'screening_session_id' => $session->id,
            'instrument_code' => 'SRQ',
            'status' => 'completed',
        ]);
    }

    public function test_score_of_six_is_saved_at_screening_cutoff(): void
    {
        [$nurseUser, $session] = $this->createNurseWithSrqSession();

        $answers = array_merge(
            array_fill(0, 6, true),
            array_fill(0, 14, false),
        );

        $this->actingAs($nurseUser)
            ->post(
                route('screening-sessions.srq.store', $session),
                ['answers' => $answers],
            )
            ->assertRedirect(
                route('screening-sessions.srq.complete', $session)
            );

        $this->assertDatabaseHas('srq_screenings', [
            'screening_session_id' => $session->id,
            'score' => 6,
            'category' => 'gangguan_mental_emosional_distres',
        ]);
    }

    public function test_incomplete_srq_answers_are_rejected(): void
    {
        [$nurseUser, $session] = $this->createNurseWithSrqSession();

        $response = $this->actingAs($nurseUser)
            ->from(route('screening-sessions.srq.create', $session))
            ->post(
                route('screening-sessions.srq.store', $session),
                ['answers' => array_fill(0, 19, false)],
            );

        $response->assertRedirect(
            route('screening-sessions.srq.create', $session)
        );
        $response->assertSessionHasErrors('answers');

        $this->assertDatabaseCount('srq_screenings', 0);
    }

    public function test_guest_cannot_open_srq_form(): void
    {
        [, $session] = $this->createNurseWithSrqSession();

        $this->get(route('screening-sessions.srq.create', $session))
            ->assertRedirect(route('login'));
    }

    public function test_perawat_cannot_access_another_nurses_srq_session(): void
    {
        [$ownerUser, $session] = $this->createNurseWithSrqSession();

        $otherUser = User::create([
            'name' => 'Perawat Lain SRQ',
            'email' => 'perawat-lain-srq@test.local',
            'password' => 'password',
            'role_id' => $ownerUser->role_id,
        ]);

        Nurse::create([
            'user_id' => $otherUser->id,
            'registration_number' => 'NRS-SRQ-002',
        ]);

        $this->actingAs($otherUser)
            ->get(route('screening-sessions.srq.create', $session))
            ->assertForbidden();

        $this->actingAs($otherUser)
            ->post(
                route('screening-sessions.srq.store', $session),
                ['answers' => array_fill(0, 20, false)],
            )
            ->assertForbidden();
    }

    public function test_completion_page_does_not_expose_srq_score(): void
    {
        [$nurseUser, $session] = $this->createNurseWithSrqSession();

        $this->actingAs($nurseUser)
            ->post(
                route('screening-sessions.srq.store', $session),
                ['answers' => array_fill(0, 20, false)],
            )
            ->assertRedirect(
                route('screening-sessions.srq.complete', $session)
            );

        $this->actingAs($nurseUser)
            ->get(route('screening-sessions.srq.complete', $session))
            ->assertOk()
            ->assertInertia(
                fn (Assert $page) => $page
                    ->component('ScreeningSessions/SrqCompleted')
                    ->where('session.id', $session->id)
                    ->missing('session.score')
                    ->missing('score')
            );
    }

    public function test_doctor_can_view_screening_sessions_list(): void
    {
        [, $session] = $this->createNurseWithSrqSession();

        $doctorRole = Role::create([
            'name' => 'dokter',
        ]);

        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter-list-srq@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $this->actingAs($doctor)
            ->get(route('screening-sessions.index'))
            ->assertOk()
            ->assertInertia(
                fn (Assert $page) => $page
                    ->component('ScreeningSessions/Index')
                    ->where('sessions.data.0.id', $session->id)
            );
    }

    public function test_doctor_can_view_screening_session_detail(): void
    {
        [, $session] = $this->createNurseWithSrqSession();

        $doctorRole = Role::create([
            'name' => 'dokter',
        ]);

        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter-detail-srq@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $this->actingAs($doctor)
            ->get(route('screening-sessions.show', $session))
            ->assertOk()
            ->assertInertia(
                fn (Assert $page) => $page
                    ->component('ScreeningSessions/Show')
                    ->where('session.id', $session->id)
                    ->where('session.srq_screening', null)
            );
    }

    public function test_doctor_cannot_create_sessions_or_fill_srq(): void
    {
        [, $session] = $this->createNurseWithSrqSession();

        $doctorRole = Role::create([
            'name' => 'dokter',
        ]);

        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter-restriction-srq@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $this->actingAs($doctor)
            ->get(route('screening-sessions.create'))
            ->assertForbidden();

        $this->actingAs($doctor)
            ->post(route('screening-sessions.store'), [])
            ->assertForbidden();

        $this->actingAs($doctor)
            ->get(route('screening-sessions.srq.create', $session))
            ->assertForbidden();

        $this->actingAs($doctor)
            ->post(
                route('screening-sessions.srq.store', $session),
                ['answers' => array_fill(0, 20, false)],
            )
            ->assertForbidden();
    }

    /**
     * Create a nurse, patient, session, and pending SRQ instrument.
     *
     * @return array{0: User, 1: ScreeningSession}
     */
    private function createNurseWithSrqSession(): array
    {
        $nurseRole = Role::create([
            'name' => 'perawat',
        ]);

        $parentRole = Role::create([
            'name' => 'orang_tua',
        ]);

        $nurseUser = User::create([
            'name' => 'Perawat SRQ Test',
            'email' => 'perawat-srq@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NRS-SRQ-001',
        ]);

        $parentUser = User::create([
            'name' => 'Orang Tua SRQ Test',
            'email' => 'orangtua-srq@test.local',
            'password' => 'password',
            'role_id' => $parentRole->id,
        ]);

        $parentGuardian = ParentGuardian::create([
            'user_id' => $parentUser->id,
        ]);

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-SRQ-001',
            'name' => 'Anak SRQ Test',
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
            'status' => 'draft',
        ]);

        $session->age_months = 48;
        $session->save();

        $session->screeningSessionInstruments()->create([
            'instrument_code' => 'SRQ',
            'status' => 'pending',
        ]);

        return [$nurseUser, $session];
    }
}
