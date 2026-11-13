<?php

namespace Tests\Feature;

use App\Models\Doctor;
use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\ScreeningSession;
use App\Models\ScreeningSessionInstrument;
use App\Models\KpspScreening;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class ScreeningRecapTest extends TestCase
{
    use RefreshDatabase;

    public function test_nurse_can_access_rekapitulasi_page(): void
    {
        $nurseUser = $this->createUserWithRole('perawat');
        Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NURSE-001',
        ]);

        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index'))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('ScreeningSessions/Recap')
                ->has('summary')
                ->has('instrumentBreakdown')
                ->has('dailyData')
                ->has('weeklyData')
                ->has('monthlyData')
                ->has('yearlyData')
            );
    }

    public function test_doctor_can_access_rekapitulasi_page(): void
    {
        $doctorUser = $this->createUserWithRole('dokter');
        Doctor::create([
            'user_id' => $doctorUser->id,
            'specialization' => 'Spesialis Anak',
            'license_number' => 'DOC-001',
        ]);

        $this->actingAs($doctorUser)
            ->get(route('screening-recap.index'))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('ScreeningSessions/Recap')
                ->has('summary')
            );
    }

    public function test_parent_cannot_access_rekapitulasi_page(): void
    {
        $parentUser = $this->createUserWithRole('orang_tua');

        $this->actingAs($parentUser)
            ->get(route('screening-recap.index'))
            ->assertForbidden();
    }

    public function test_guest_is_redirected_to_login(): void
    {
        $this->get(route('screening-recap.index'))
            ->assertRedirect(route('login'));
    }

    public function test_rekapitulasi_supports_monthly_daily_weekly_and_yearly_granularity(): void
    {
        $nurseUser = $this->createUserWithRole('perawat');
        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NURSE-001',
        ]);

        $patient = $this->createPatient();

        // Buat 1 sesi pada 2026-10-05
        $session = ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'created_by_user_id' => $nurseUser->id,
            'screening_date' => '2026-10-05',
            'status' => 'reviewed',
            'age_months' => 18,
        ]);

        ScreeningSessionInstrument::create([
            'screening_session_id' => $session->id,
            'instrument_code' => 'KPSP',
            'status' => 'completed',
        ]);

        KpspScreening::create([
            'screening_session_id' => $session->id,
            'form_age_months' => 18,
            'answers' => array_fill(0, 10, true),
            'score' => 10,
            'category' => 'sesuai_umur',
            'recommendation' => 'Sesuai umur.',
        ]);

        // Cek Granularitas Bulanan
        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'granularity' => 'bulanan',
                'year' => 2026,
                'month' => 10,
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('filters.granularity', 'bulanan')
                ->where('summary.total_sessions', 1)
                ->where('summary.reviewed_sessions', 1)
                ->where('instrumentBreakdown.kpsp.sesuai', 1)
            );

        // Cek Granularitas Harian secara mandiri dengan tanggal spesifik
        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'granularity' => 'harian',
                'date' => '2026-10-05',
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('filters.granularity', 'harian')
                ->where('filters.date', '2026-10-05')
                ->where('summary.total_sessions', 1)
                ->where('summary.reviewed_sessions', 1)
                ->has('dailyData', 31)
            );

        // Cek Granularitas Harian pada tanggal lain (harus 0 sesi)
        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'granularity' => 'harian',
                'date' => '2026-10-06',
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('filters.granularity', 'harian')
                ->where('filters.date', '2026-10-06')
                ->where('summary.total_sessions', 0)
            );

        // Cek Granularitas Mingguan secara mandiri dengan nomor minggu (Week 41 = 5-11 Okt 2026)
        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'granularity' => 'mingguan',
                'year' => 2026,
                'week' => 41,
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('filters.granularity', 'mingguan')
                ->where('filters.week', 41)
                ->where('summary.total_sessions', 1)
                ->has('weeklyDaysData', 7)
            );

        // Cek Granularitas Mingguan pada minggu lain (harus 0 sesi)
        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'granularity' => 'mingguan',
                'year' => 2026,
                'week' => 42,
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('filters.granularity', 'mingguan')
                ->where('filters.week', 42)
                ->where('summary.total_sessions', 0)
            );

        // Cek Granularitas Tahunan
        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'granularity' => 'tahunan',
                'year' => 2026,
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('filters.granularity', 'tahunan')
                ->has('monthlyData', 12)
            );
    }

    public function test_rekapitulasi_filters_by_nurse_and_status(): void
    {
        $nurseUser1 = $this->createUserWithRole('perawat');
        $nurse1 = Nurse::create([
            'user_id' => $nurseUser1->id,
            'registration_number' => 'NURSE-001',
        ]);

        $nurseUser2 = $this->createUserWithRole('perawat');
        $nurse2 = Nurse::create([
            'user_id' => $nurseUser2->id,
            'registration_number' => 'NURSE-002',
        ]);

        $patient = $this->createPatient();

        ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse1->id,
            'created_by_user_id' => $nurseUser1->id,
            'screening_date' => '2026-10-01',
            'status' => 'reviewed',
            'age_months' => 24,
        ]);

        ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse2->id,
            'created_by_user_id' => $nurseUser2->id,
            'screening_date' => '2026-10-02',
            'status' => 'pending_doctor_review',
            'age_months' => 24,
        ]);

        // Filter nurse 1
        $this->actingAs($nurseUser1)
            ->get(route('screening-recap.index', [
                'year' => 2026,
                'month' => 10,
                'nurse_id' => $nurse1->id,
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('summary.total_sessions', 1)
                ->where('summary.reviewed_sessions', 1)
            );

        // Filter status pending_doctor_review
        $this->actingAs($nurseUser1)
            ->get(route('screening-recap.index', [
                'year' => 2026,
                'month' => 10,
                'status' => 'pending_doctor_review',
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('summary.total_sessions', 1)
                ->where('summary.pending_doctor_sessions', 1)
            );
    }

    public function test_rekapitulasi_provides_register_rows_with_sdq_and_srq(): void
    {
        $nurseUser = $this->createUserWithRole('perawat');
        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NURSE-RECAP-01',
        ]);

        $patient = $this->createPatient();
        $session = ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'created_by_user_id' => $nurseUser->id,
            'screening_date' => '2026-10-15',
            'status' => 'reviewed',
            'age_months' => 48,
            'case_type' => 'baru',
            'referral_source' => 'Puskesmas',
            'interventions' => ['ot', 'tw'],
        ]);

        \App\Models\SdqScreening::create([
            'screening_session_id' => $session->id,
            'total_difficulties_category' => 'abnormal',
            'prosocial_category' => 'normal',
            'emotional_category' => 'abnormal',
            'conduct_category' => 'abnormal',
            'hyperactivity_category' => 'abnormal',
            'peer_category' => 'abnormal',
            'total_difficulties_score' => 20,
            'emotional_score' => 5,
            'conduct_score' => 5,
            'hyperactivity_score' => 5,
            'peer_score' => 5,
            'prosocial_score' => 8,
            'answers' => array_fill(0, 25, 1),
            'recommendation' => 'Perlu intervensi',
        ]);

        \App\Models\SrqScreening::create([
            'screening_session_id' => $session->id,
            'score' => 8,
            'category' => 'gangguan_mental_emosional_distres',
            'recommendation' => 'Konseling',
            'answers' => array_fill(0, 20, 1),
        ]);

        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', ['year' => 2026, 'month' => 10]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->has('registerRows', 1)
                ->where('registerRows.0.name', $patient->name)
                ->where('registerRows.0.sdq', 1)
                ->where('registerRows.0.srq', 1)
                ->where('registerRows.0.ot', 1)
                ->where('registerRows.0.tw', 1)
                ->where('registerTotals.sdq', 1)
                ->where('registerTotals.srq', 1)
            );
    }

    public function test_rekapitulasi_can_export_monthly_register_excel(): void
    {
        $nurseUser = $this->createUserWithRole('perawat');
        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NURSE-RECAP-02',
        ]);

        $patient = $this->createPatient();
        ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'created_by_user_id' => $nurseUser->id,
            'screening_date' => '2026-10-15',
            'status' => 'reviewed',
            'age_months' => 36,
        ]);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-recap.export', [
                'year' => 2026,
                'month' => 10,
                'format' => 'excel',
            ]));

        $response->assertOk();
        $response->assertHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        $this->assertStringContainsString('Rekapitulasi_SDIDTK_UPTD_BLK_ABK_Oktober_2026.xlsx', $response->headers->get('Content-Disposition'));
        // Pastikan konten file adalah binary OpenXML ZIP valid (Magic Number PK\x03\x04)
        $this->assertStringStartsWith("PK\x03\x04", $response->getContent());
    }

    public function test_rekapitulasi_can_export_monthly_register_csv(): void
    {
        $nurseUser = $this->createUserWithRole('perawat');
        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NURSE-RECAP-03',
        ]);

        $patient = $this->createPatient();
        ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'created_by_user_id' => $nurseUser->id,
            'screening_date' => '2026-10-15',
            'status' => 'reviewed',
            'age_months' => 36,
        ]);

        $response = $this->actingAs($nurseUser)
            ->get(route('screening-recap.export', [
                'year' => 2026,
                'month' => 10,
                'format' => 'csv',
            ]));

        $response->assertOk();
        $response->assertHeader('Content-Type', 'text/csv; charset=UTF-8');
    }

    public function test_rekapitulasi_includes_only_latest_session_per_patient_in_same_month(): void
    {
        $nurseUser = $this->createUserWithRole('perawat');
        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NURSE-001',
        ]);

        $patient = $this->createPatient();

        // Sesi pertama: 2 Oktober 2026 (status: draft, kpsp: meragukan)
        $earlySession = ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-02',
            'age_months' => 24,
            'status' => 'in_progress',
            'created_by_user_id' => $nurseUser->id,
        ]);
        KpspScreening::create([
            'screening_session_id' => $earlySession->id,
            'form_age_months' => 24,
            'answers' => array_fill(1, 10, true),
            'score' => 7,
            'category' => 'meragukan',
            'domain_scores' => ['domains' => [], 'lacking_domains' => ['Gerak Kasar']],
            'sdidtk_code' => 'M',
        ]);

        // Sesi kedua (evaluasi ulang): 16 Oktober 2026 (status: reviewed, kpsp: sesuai)
        $latestSession = ScreeningSession::create([
            'patient_id' => $patient->id,
            'nurse_id' => $nurse->id,
            'screening_date' => '2026-10-16',
            'age_months' => 24,
            'status' => 'reviewed',
            'created_by_user_id' => $nurseUser->id,
        ]);
        KpspScreening::create([
            'screening_session_id' => $latestSession->id,
            'form_age_months' => 24,
            'answers' => array_fill(1, 10, true),
            'score' => 10,
            'category' => 'sesuai_umur',
            'domain_scores' => ['domains' => [], 'lacking_domains' => []],
            'sdidtk_code' => 'S',
        ]);

        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'year' => 2026,
                'month' => 10,
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('ScreeningSessions/Recap')
                ->has('registerRows', 1) // Hanya 1 baris untuk anak ini
                ->where('registerRows.0.session_id', $latestSession->id) // Memastikan sesi terbaru yang dipakai
            );
    }

    public function test_rekapitulasi_counts_gpph_normal_meragukan_and_kemungkinan_accurately_and_maps_mchat(): void
    {
        $nurseUser = $this->createUserWithRole('perawat');
        $nurse = Nurse::create([
            'user_id' => $nurseUser->id,
            'registration_number' => 'NURSE-GPPH-01',
        ]);

        $patient1 = $this->createPatient();
        $patient2 = $this->createPatient();
        $patient3 = $this->createPatient();

        $normalSession = ScreeningSession::create([
            'patient_id' => $patient1->id,
            'nurse_id' => $nurse->id,
            'created_by_user_id' => $nurseUser->id,
            'screening_date' => '2026-10-05',
            'status' => 'reviewed',
            'age_months' => 48,
        ]);
        \App\Models\GpphScreening::create([
            'screening_session_id' => $normalSession->id,
            'answers' => array_fill(0, 10, 0),
            'score' => 0,
            'category' => 'normal',
            'examiner_doubtful' => false,
            'recommendation' => 'Normal.',
        ]);

        $doubtfulSession = ScreeningSession::create([
            'patient_id' => $patient2->id,
            'nurse_id' => $nurse->id,
            'created_by_user_id' => $nurseUser->id,
            'screening_date' => '2026-10-06',
            'status' => 'reviewed',
            'age_months' => 48,
        ]);
        \App\Models\GpphScreening::create([
            'screening_session_id' => $doubtfulSession->id,
            'answers' => array_fill(0, 10, 1),
            'score' => 10,
            'category' => 'meragukan',
            'examiner_doubtful' => true,
            'recommendation' => 'Evaluasi ulang.',
        ]);

        $mchatSession = ScreeningSession::create([
            'patient_id' => $patient3->id,
            'nurse_id' => $nurse->id,
            'created_by_user_id' => $nurseUser->id,
            'screening_date' => '2026-10-07',
            'status' => 'reviewed',
            'age_months' => 24,
        ]);
        ScreeningSessionInstrument::create([
            'screening_session_id' => $mchatSession->id,
            'instrument_code' => 'MCHAT',
            'status' => 'completed',
        ]);
        \App\Models\MchatScreening::create([
            'screening_session_id' => $mchatSession->id,
            'answers' => array_fill(0, 20, true),
            'score' => 3,
            'category' => 'risiko_sedang_tinggi',
            'recommendation' => 'Rujuk.',
        ]);

        $this->actingAs($nurseUser)
            ->get(route('screening-recap.index', [
                'year' => 2026,
                'month' => 10,
            ]))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->where('instrumentBreakdown.gpph.total', 2)
                ->where('instrumentBreakdown.gpph.normal', 1)
                ->where('instrumentBreakdown.gpph.tidak_menunjukkan_gpph', 1)
                ->where('instrumentBreakdown.gpph.meragukan', 1)
                ->where('instrumentBreakdown.gpph.kemungkinan_gpph', 0)
                ->where('sessions.2.instruments.0.code', 'MCHAT')
                ->where('sessions.2.instruments.0.category', 'risiko_sedang_tinggi')
            );
    }

    private function createUserWithRole(string $roleName): User
    {
        $role = Role::firstOrCreate(['name' => $roleName]);

        return User::factory()->create([
            'role_id' => $role->id,
        ]);
    }

    private function createPatient(): Patient
    {
        $parentUser = $this->createUserWithRole('orang_tua');
        $parent = ParentGuardian::create([
            'user_id' => $parentUser->id,
            'phone_number' => '08123456789',
            'address' => 'Jl. Kebangsaan No. 1',
        ]);

        return Patient::create([
            'medical_record_number' => 'RM-' . uniqid(),
            'name' => 'Anak Uji',
            'birth_date' => '2025-04-11',
            'gender' => 'L',
            'parent_guardian_id' => $parent->id,
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'is_active' => true,
        ]);
    }
}
