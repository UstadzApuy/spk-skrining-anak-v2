<?php

namespace Tests\Feature;

use App\Models\GpphScreening;
use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningSession;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GpphScreeningTest extends TestCase
{
    use RefreshDatabase;

    public function test_perawat_can_open_gpph_form_for_eligible_session(): void
    {
        [$nurseUser, $session] = $this->createEligibleGpphSession(48);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.gpph.create', $session));

        $response->assertOk();
        $response->assertInertia(
            fn ($page) => $page
                ->component('ScreeningSessions/Gpph')
                ->where('session.id', $session->id)
                ->has('questions', 10)
        );
    }

    public function test_gpph_cannot_be_opened_for_ineligible_age(): void
    {
        // Child age 24 months is below 36 months minimum
        [$nurseUser, $session] = $this->createEligibleGpphSession(24);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.gpph.create', $session));

        $response->assertStatus(422);
    }

    public function test_perawat_can_submit_gpph_answers_with_normal_result(): void
    {
        [$nurseUser, $session] = $this->createEligibleGpphSession(48);

        $answers = array_fill(0, 10, 0);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.gpph.store', $session), [
                'answers' => $answers,
                'examiner_doubtful' => false,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));
        $response->assertSessionHas('success', 'Hasil GPPH berhasil disimpan.');

        $result = GpphScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(0, $result->score);
        $this->assertSame('normal', $result->category);
        $this->assertFalse($result->examiner_doubtful);

        $this->assertDatabaseHas('screening_session_instruments', [
            'screening_session_id' => $session->id,
            'instrument_code' => 'GPPH',
            'status' => 'completed',
        ]);
    }

    public function test_perawat_can_submit_gpph_answers_with_kemungkinan_gpph(): void
    {
        [$nurseUser, $session] = $this->createEligibleGpphSession(48);

        // 10 answers with value 2 -> score = 20 (>= 13)
        $answers = array_fill(0, 10, 2);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.gpph.store', $session), [
                'answers' => $answers,
                'examiner_doubtful' => false,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));

        $result = GpphScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(20, $result->score);
        $this->assertSame('kemungkinan_gpph', $result->category);
        $this->assertStringContainsString('rujuk', strtolower($result->recommendation));
    }

    public function test_gpph_handles_examiner_doubtful_flag(): void
    {
        [$nurseUser, $session] = $this->createEligibleGpphSession(48);

        // Score 5 is technically below 13, but examiner is doubtful
        $answers = [1, 1, 1, 1, 1, 0, 0, 0, 0, 0];

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.gpph.store', $session), [
                'answers' => $answers,
                'examiner_doubtful' => true,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));

        $result = GpphScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(5, $result->score);
        $this->assertTrue($result->examiner_doubtful);
        $this->assertSame('meragukan', $result->category);
        $this->assertStringContainsString('intervensi dini', strtolower($result->recommendation));
    }

    public function test_gpph_rejects_incomplete_answers(): void
    {
        [$nurseUser, $session] = $this->createEligibleGpphSession(48);

        $answers = array_fill(0, 9, 0);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.gpph.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertSessionHasErrors('answers');
        $this->assertDatabaseCount('gpph_screenings', 0);
    }

    public function test_non_nurse_cannot_access_gpph_form(): void
    {
        [, $session] = $this->createEligibleGpphSession(48);

        $doctorRole = Role::firstOrCreate(['name' => 'dokter']);
        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter-gpph@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $this->actingAs($doctor)
            ->get(route('screening-sessions.gpph.create', $session))
            ->assertForbidden();

        $this->actingAs($doctor)
            ->post(route('screening-sessions.gpph.store', $session), [
                'answers' => array_fill(0, 10, 0),
            ])
            ->assertForbidden();
    }

    /**
     * @return array{0: User, 1: ScreeningSession}
     */
    private function createEligibleGpphSession(int $ageMonths): array
    {
        $nurseRole = Role::firstOrCreate(['name' => 'perawat']);
        $parentRole = Role::firstOrCreate(['name' => 'orang_tua']);

        $nurseUser = User::create([
            'name' => 'Perawat Test',
            'email' => 'perawat-gpph-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NRS-GPPH-' . uniqid(),
        ]);

        $parentUser = User::create([
            'name' => 'Orang Tua Test',
            'email' => 'orangtua-gpph-' . uniqid() . '@test.local',
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
            'medical_record_number' => 'RM-GPPH-' . uniqid(),
            'name' => 'Anak GPPH',
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
            'instrument_code' => 'GPPH',
            'status' => 'pending',
        ]);

        return [$nurseUser, $session];
    }
}
