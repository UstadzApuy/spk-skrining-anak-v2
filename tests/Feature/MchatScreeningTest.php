<?php

namespace Tests\Feature;

use App\Models\MchatScreening;
use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningSession;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MchatScreeningTest extends TestCase
{
    use RefreshDatabase;

    public function test_perawat_can_open_mchat_form_for_eligible_session(): void
    {
        [$nurseUser, $session] = $this->createEligibleMchatSession(24);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.mchat.create', $session));

        $response->assertOk();
        $response->assertInertia(
            fn ($page) => $page
                ->component('ScreeningSessions/Mchat')
                ->where('session.id', $session->id)
                ->has('questions', 20)
        );
    }

    public function test_mchat_cannot_be_opened_for_ineligible_age(): void
    {
        // Child age 12 months is below 16 months minimum
        [$nurseUser, $session] = $this->createEligibleMchatSession(12);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.mchat.create', $session));

        $response->assertStatus(422);
    }

    public function test_perawat_can_submit_20_answers_with_risiko_rendah(): void
    {
        [$nurseUser, $session] = $this->createEligibleMchatSession(20);

        // Standard passing answers:
        // Items 2, 5, 12: 'Tidak' (false) is typical
        // Other items: 'Ya' (true) is typical
        // All non-risk responses:
        $answers = array_fill(0, 20, true);
        $answers[1] = false; // Item 2
        $answers[4] = false; // Item 5
        $answers[11] = false; // Item 12

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.mchat.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));
        $response->assertSessionHas('success', 'Hasil M-CHAT-R berhasil disimpan.');

        $result = MchatScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(0, $result->score);
        $this->assertSame('risiko_rendah', $result->category);
        $this->assertNotEmpty($result->recommendation);

        $this->assertDatabaseHas('screening_session_instruments', [
            'screening_session_id' => $session->id,
            'instrument_code' => 'MCHAT',
            'status' => 'completed',
        ]);
    }

    public function test_perawat_can_submit_answers_with_risiko_sedang_tinggi(): void
    {
        [$nurseUser, $session] = $this->createEligibleMchatSession(24);

        // All 'false' means items 1, 3, 4, 6..20 are risk (17 risk items)
        $answers = array_fill(0, 20, false);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.mchat.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));

        $result = MchatScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertGreaterThanOrEqual(3, $result->score);
        $this->assertSame('risiko_sedang_tinggi', $result->category);
    }

    public function test_mchat_rejects_incomplete_answers(): void
    {
        [$nurseUser, $session] = $this->createEligibleMchatSession(24);

        // Only 19 answers
        $answers = array_fill(0, 19, true);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.mchat.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertSessionHasErrors('answers');
        $this->assertDatabaseCount('mchat_screenings', 0);
    }

    public function test_non_nurse_cannot_access_mchat_form(): void
    {
        [, $session] = $this->createEligibleMchatSession(20);

        $doctorRole = Role::firstOrCreate(['name' => 'dokter']);
        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter-mchat@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $this->actingAs($doctor)
            ->get(route('screening-sessions.mchat.create', $session))
            ->assertForbidden();

        $this->actingAs($doctor)
            ->post(route('screening-sessions.mchat.store', $session), [
                'answers' => array_fill(0, 20, true),
            ])
            ->assertForbidden();
    }

    public function test_perawat_cannot_access_another_nurses_mchat_session(): void
    {
        [, $session] = $this->createEligibleMchatSession(20);

        $nurseRole = Role::where('name', 'perawat')->firstOrFail();
        $otherUser = User::create([
            'name' => 'Perawat Lain',
            'email' => 'perawat-lain-mchat@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        Nurse::create([
            'user_id' => $otherUser->id,
            'registration_number' => 'NRS-MCHAT-OTHER',
        ]);

        $this->actingAs($otherUser)
            ->get(route('screening-sessions.mchat.create', $session))
            ->assertForbidden();
    }

    /**
     * @return array{0: User, 1: ScreeningSession}
     */
    private function createEligibleMchatSession(int $ageMonths): array
    {
        $nurseRole = Role::firstOrCreate(['name' => 'perawat']);
        $parentRole = Role::firstOrCreate(['name' => 'orang_tua']);

        $nurseUser = User::create([
            'name' => 'Perawat Test',
            'email' => 'perawat-mchat-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NRS-MCHAT-' . uniqid(),
        ]);

        $parentUser = User::create([
            'name' => 'Orang Tua Test',
            'email' => 'orangtua-mchat-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $parentRole->id,
        ]);

        $parentGuardian = ParentGuardian::create([
            'user_id' => $parentUser->id,
        ]);

        $years = intdiv($ageMonths, 12);
        $remMonths = $ageMonths % 12;
        $birthDate = sprintf('%04d-%02d-11', 2026 - $years, max(1, 10 - $remMonths));

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-MCHAT-' . uniqid(),
            'name' => 'Anak MCHAT',
            'birth_date' => $birthDate,
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

        $session->created_by_user_id = $nurseUser->id;
        $session->age_months = $ageMonths;
        $session->save();

        $session->screeningSessionInstruments()->create([
            'instrument_code' => 'MCHAT',
            'status' => 'pending',
        ]);

        return [$nurseUser, $session];
    }
}
