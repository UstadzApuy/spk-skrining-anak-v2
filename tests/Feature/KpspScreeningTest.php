<?php

namespace Tests\Feature;

use App\Models\KpspScreening;
use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningSession;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class KpspScreeningTest extends TestCase
{
    use RefreshDatabase;

    public function test_perawat_can_open_kpsp_form_for_eligible_session(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(48);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.kpsp.create', $session));

        $response->assertOk();
        $response->assertInertia(
            fn ($page) => $page
                ->component('ScreeningSessions/Kpsp')
                ->where('session.id', $session->id)
                ->where('session.form_age_months', 48)
                ->has('questions', 10)
        );
    }

    public function test_kpsp_selects_correct_form_age_for_premature_child(): void
    {
        [$nurseUser, $nurse, $patient] = $this->createNurseAndPatient();

        // Born 2023-08-11, screening date 2026-10-11 -> Chronological age ~38 months
        // Gestational age 32 weeks (8 weeks premature) -> Corrected age ~36 months
        $patient->update([
            'birth_date' => '2023-08-11',
            'is_premature' => true,
            'gestational_age_weeks' => 32,
        ]);

        $session = new ScreeningSession([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-11',
            'status' => 'draft',
        ]);
        $session->created_by_user_id = $nurseUser->id;
        $session->age_months = 36;
        $session->save();

        $session->screeningSessionInstruments()->create([
            'instrument_code' => 'KPSP',
            'status' => 'pending',
        ]);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.kpsp.create', $session));

        $response->assertOk();
        $response->assertInertia(
            fn ($page) => $page
                ->component('ScreeningSessions/Kpsp')
                ->where('session.form_age_months', 36)
                ->has('questions', 10)
        );
    }

    public function test_perawat_can_submit_10_kpsp_answers_with_sesuai_result(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(48);

        $answers = array_fill(0, 10, true);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));
        $response->assertSessionHas('success', 'Hasil KPSP berhasil disimpan.');

        $result = KpspScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(10, $result->score);
        $this->assertSame('sesuai_umur', $result->category);
        $this->assertSame(48, $result->form_age_months);
        $this->assertNotEmpty($result->recommendation);

        $this->assertDatabaseHas('screening_session_instruments', [
            'screening_session_id' => $session->id,
            'instrument_code' => 'KPSP',
            'status' => 'completed',
        ]);
    }

    public function test_perawat_can_submit_kpsp_answers_with_meragukan_result(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(24);

        // 7 Ya and 3 Tidak -> Meragukan
        $answers = [true, true, true, true, true, true, true, false, false, false];

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));

        $result = KpspScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(7, $result->score);
        $this->assertSame('meragukan', $result->category);
    }

    public function test_perawat_can_submit_kpsp_answers_with_penyimpangan_result(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(12);

        // 5 Ya and 5 Tidak -> Penyimpangan (<= 6)
        $answers = [true, true, true, true, true, false, false, false, false, false];

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));

        $result = KpspScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(5, $result->score);
        $this->assertSame('kemungkinan_penyimpangan', $result->category);
    }

    public function test_kpsp_rejects_incomplete_answers(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(48);

        // Only 9 answers instead of 10
        $answers = array_fill(0, 9, true);

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertSessionHasErrors('answers');
        $this->assertDatabaseCount('kpsp_screenings', 0);
    }

    public function test_kpsp_calculates_and_stores_domain_breakdown_scores_accurately(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(24);

        // Form 24 months questions:
        // #1: Gerak halus, #2: Gerak halus, #3: Bicara dan bahasa, #4: Bicara dan bahasa,
        // #5: Sosialisasi dan kemandirian, #6: Sosialisasi dan kemandirian,
        // #7: Gerak kasar, #8: Gerak kasar, #9: Gerak kasar, #10: Bicara dan bahasa
        // Answer false on #8 (idx 7, Gerak kasar) and #10 (idx 9, Bicara dan bahasa)
        $answers = [true, true, true, true, true, true, true, false, true, false];

        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => $answers,
            ]);

        $response->assertRedirect(route('screening-sessions.show', $session));

        $result = KpspScreening::where('screening_session_id', $session->id)->firstOrFail();
        $this->assertSame(8, $result->score);
        $this->assertSame('meragukan', $result->category);

        $domainScores = $result->domain_scores;
        $this->assertIsArray($domainScores);
        $this->assertFalse($domainScores['all_optimal']);
        $this->assertContains('Gerak Kasar', $domainScores['lacking_domains']);
        $this->assertContains('Bicara dan Bahasa', $domainScores['lacking_domains']);

        $domains = $domainScores['domains'];
        $this->assertSame(2, $domains['gerak_kasar']['score']);
        $this->assertSame(3, $domains['gerak_kasar']['total']);
        $this->assertSame('perlu_stimulasi', $domains['gerak_kasar']['status']);
        $this->assertCount(1, $domains['gerak_kasar']['missed_questions']);
        $this->assertSame(8, $domains['gerak_kasar']['missed_questions'][0]['number']);

        $this->assertSame(2, $domains['bicara_bahasa']['score']);
        $this->assertSame(3, $domains['bicara_bahasa']['total']);
        $this->assertSame('perlu_stimulasi', $domains['bicara_bahasa']['status']);
        $this->assertCount(1, $domains['bicara_bahasa']['missed_questions']);
        $this->assertSame(10, $domains['bicara_bahasa']['missed_questions'][0]['number']);

        $this->assertSame(2, $domains['gerak_halus']['score']);
        $this->assertSame(2, $domains['gerak_halus']['total']);
        $this->assertSame('sesuai', $domains['gerak_halus']['status']);
        $this->assertEmpty($domains['gerak_halus']['missed_questions']);

        $this->assertSame(2, $domains['sosialisasi_kemandirian']['score']);
        $this->assertSame(2, $domains['sosialisasi_kemandirian']['total']);
        $this->assertSame('sesuai', $domains['sosialisasi_kemandirian']['status']);

        // Check show page delivers domain_scores to Inertia
        $showResponse = $this->actingAs($nurseUser)
            ->get(route('screening-sessions.show', $session));

        $showResponse->assertOk();
        $showResponse->assertInertia(
            fn ($page) => $page
                ->component('ScreeningSessions/Show')
                ->has('session.kpsp_screening.domain_scores.domains')
                ->where('session.kpsp_screening.domain_scores.all_optimal', false)
                ->where('session.kpsp_screening.domain_scores.lacking_domains', ['Gerak Kasar', 'Bicara dan Bahasa'])
        );
    }

    public function test_non_nurse_cannot_access_kpsp_form(): void
    {
        [, $session] = $this->createEligibleKpspSession(48);

        $doctorRole = Role::firstOrCreate(['name' => 'dokter']);
        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter-kpsp@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $this->actingAs($doctor)
            ->get(route('screening-sessions.kpsp.create', $session))
            ->assertForbidden();

        $this->actingAs($doctor)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => array_fill(0, 10, true),
            ])
            ->assertForbidden();
    }

    public function test_perawat_cannot_access_another_nurses_kpsp_session(): void
    {
        [, $session] = $this->createEligibleKpspSession(48);

        $nurseRole = Role::where('name', 'perawat')->firstOrFail();
        $otherUser = User::create([
            'name' => 'Perawat Lain',
            'email' => 'perawat-lain-kpsp@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        Nurse::create([
            'user_id' => $otherUser->id,
            'registration_number' => 'NRS-KPSP-OTHER',
        ]);

        $this->actingAs($otherUser)
            ->get(route('screening-sessions.kpsp.create', $session))
            ->assertForbidden();
    }

    public function test_kpsp_assigns_sdidtk_codes_and_clinical_actions_for_initial_session(): void
    {
        // 1. Initial Sesual -> Ds, stimulasi_rutin_kia
        [$nurseUser, $sessionDs] = $this->createEligibleKpspSession(24);
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $sessionDs), [
                'answers' => array_fill(0, 10, true),
            ]);
        $kpspDs = KpspScreening::where('screening_session_id', $sessionDs->id)->firstOrFail();
        $this->assertSame('Ds', $kpspDs->sdidtk_code);
        $this->assertSame('stimulasi_rutin_kia', $kpspDs->clinical_action);
        $this->assertFalse($kpspDs->is_re_evaluation);

        // 2. Initial Meragukan -> Dm, intervensi_2_minggu
        [$nurseUser, $sessionDm] = $this->createEligibleKpspSession(24);
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $sessionDm), [
                'answers' => [true, true, true, true, true, true, true, false, false, false],
            ]);
        $kpspDm = KpspScreening::where('screening_session_id', $sessionDm->id)->firstOrFail();
        $this->assertSame('Dm', $kpspDm->sdidtk_code);
        $this->assertSame('intervensi_2_minggu', $kpspDm->clinical_action);
        $this->assertFalse($kpspDm->is_re_evaluation);

        // 3. Initial Penyimpangan -> Dp, rujuk_rs_spesialistik
        [$nurseUser, $sessionDp] = $this->createEligibleKpspSession(24);
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $sessionDp), [
                'answers' => [true, true, true, true, true, false, false, false, false, false],
            ]);
        $kpspDp = KpspScreening::where('screening_session_id', $sessionDp->id)->firstOrFail();
        $this->assertSame('Dp', $kpspDp->sdidtk_code);
        $this->assertSame('rujuk_rs_spesialistik', $kpspDp->clinical_action);
        $this->assertFalse($kpspDp->is_re_evaluation);
    }

    public function test_nurse_can_schedule_14_day_kpsp_re_evaluation_session(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(24);

        // Submit initial Dm (skor 7)
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => [true, true, true, true, true, true, true, false, false, false],
            ]);

        // Schedule re-evaluation
        $response = $this->actingAs($nurseUser)
            ->post(route('screening-sessions.schedule-kpsp-re-evaluation', $session));

        $childSession = ScreeningSession::where('parent_session_id', $session->id)->firstOrFail();
        $response->assertRedirect(route('screening-sessions.show', $childSession));

        $this->assertSame('kpsp_re_evaluation_2_weeks', $childSession->evaluation_type);
        $this->assertSame($session->id, $childSession->parent_session_id);
        $this->assertSame($session->patient_id, $childSession->patient_id);
        $this->assertSame('draft', $childSession->status);

        $this->assertDatabaseHas('screening_session_instruments', [
            'screening_session_id' => $childSession->id,
            'instrument_code' => 'KPSP',
            'status' => 'pending',
        ]);
    }

    public function test_cannot_schedule_duplicate_kpsp_re_evaluation(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(24);

        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => [true, true, true, true, true, true, true, false, false, false],
            ]);

        // First schedule
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.schedule-kpsp-re-evaluation', $session));

        $firstCount = ScreeningSession::where('parent_session_id', $session->id)->count();
        $this->assertSame(1, $firstCount);

        // Second schedule attempt should not duplicate
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.schedule-kpsp-re-evaluation', $session));

        $this->assertSame(1, ScreeningSession::where('parent_session_id', $session->id)->count());
    }

    public function test_kpsp_re_evaluation_with_improved_score_resolves_to_stimulasi_rutin_kia(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(24);

        // Initial Dm
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => [true, true, true, true, true, true, true, false, false, false],
            ]);

        // Schedule re-evaluation
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.schedule-kpsp-re-evaluation', $session));

        $childSession = ScreeningSession::where('parent_session_id', $session->id)->firstOrFail();

        // Submit child re-evaluation with score 10 (all true)
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $childSession), [
                'answers' => array_fill(0, 10, true),
            ]);

        $childKpsp = KpspScreening::where('screening_session_id', $childSession->id)->firstOrFail();
        $this->assertTrue($childKpsp->is_re_evaluation);
        $this->assertSame('Ds', $childKpsp->sdidtk_code);
        $this->assertSame('sesuai_umur', $childKpsp->category);
        $this->assertSame('stimulasi_rutin_kia', $childKpsp->clinical_action);
    }

    public function test_kpsp_re_evaluation_with_persistent_meragukan_triggers_hospital_referral(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(24);

        // Initial Dm
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => [true, true, true, true, true, true, true, false, false, false],
            ]);

        // Schedule re-evaluation
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.schedule-kpsp-re-evaluation', $session));

        $childSession = ScreeningSession::where('parent_session_id', $session->id)->firstOrFail();

        // Submit child re-evaluation still with score 8 (meragukan)
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $childSession), [
                'answers' => [true, true, true, true, true, true, true, true, false, false],
            ]);

        $childKpsp = KpspScreening::where('screening_session_id', $childSession->id)->firstOrFail();
        $this->assertTrue($childKpsp->is_re_evaluation);
        $this->assertSame('Dm', $childKpsp->sdidtk_code);
        $this->assertSame('meragukan', $childKpsp->category);
        // Golden rule SDIDTK: Evaluasi ulang yang tetap meragukan HARUS dirujuk ke RS, bukan intervensi 2 minggu lagi
        $this->assertSame('rujuk_rs_spesialistik', $childKpsp->clinical_action);
    }

    public function test_kpsp_re_evaluation_with_penyimpangan_triggers_hospital_referral(): void
    {
        [$nurseUser, $session] = $this->createEligibleKpspSession(24);

        // Initial Dm
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $session), [
                'answers' => [true, true, true, true, true, true, true, false, false, false],
            ]);

        // Schedule re-evaluation
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.schedule-kpsp-re-evaluation', $session));

        $childSession = ScreeningSession::where('parent_session_id', $session->id)->firstOrFail();

        // Submit child re-evaluation worsening to score 5 (penyimpangan)
        $this->actingAs($nurseUser)
            ->post(route('screening-sessions.kpsp.store', $childSession), [
                'answers' => [true, true, true, true, true, false, false, false, false, false],
            ]);

        $childKpsp = KpspScreening::where('screening_session_id', $childSession->id)->firstOrFail();
        $this->assertTrue($childKpsp->is_re_evaluation);
        $this->assertSame('Dp', $childKpsp->sdidtk_code);
        $this->assertSame('kemungkinan_penyimpangan', $childKpsp->category);
        $this->assertSame('rujuk_rs_spesialistik', $childKpsp->clinical_action);
    }

    /**
     * @return array{0: User, 1: ScreeningSession}
     */
    private function createEligibleKpspSession(int $ageMonths): array
    {
        [$nurseUser, $nurse, $patient] = $this->createNurseAndPatient();

        // Calculate birth date for target ageMonths on 2026-10-11
        $years = intdiv($ageMonths, 12);
        $remMonths = $ageMonths % 12;
        $birthDate = sprintf('%04d-%02d-11', 2026 - $years, 10 - $remMonths);

        $patient->update([
            'birth_date' => $birthDate,
            'is_premature' => false,
            'gestational_age_weeks' => null,
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
            'instrument_code' => 'KPSP',
            'status' => 'pending',
        ]);

        return [$nurseUser, $session];
    }

    /**
     * @return array{0: User, 1: Nurse, 2: Patient}
     */
    private function createNurseAndPatient(): array
    {
        $nurseRole = Role::firstOrCreate(['name' => 'perawat']);
        $parentRole = Role::firstOrCreate(['name' => 'orang_tua']);

        $nurseUser = User::create([
            'name' => 'Perawat Test',
            'email' => 'perawat-kpsp-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NRS-KPSP-' . uniqid(),
        ]);

        $parentUser = User::create([
            'name' => 'Orang Tua Test',
            'email' => 'orangtua-kpsp-' . uniqid() . '@test.local',
            'password' => 'password',
            'role_id' => $parentRole->id,
        ]);

        $parentGuardian = ParentGuardian::create([
            'user_id' => $parentUser->id,
        ]);

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-KPSP-' . uniqid(),
            'name' => 'Anak KPSP',
            'birth_date' => '2022-10-11',
            'gender' => 'L',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        return [$nurseUser, $nurse, $patient];
    }
}
