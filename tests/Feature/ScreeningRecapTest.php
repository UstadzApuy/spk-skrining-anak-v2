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

    public function test_administrator_can_access_rekapitulasi_page(): void
    {
        $adminUser = $this->createUserWithRole('administrator');

        $this->actingAs($adminUser)
            ->get(route('screening-recap.index'))
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('ScreeningSessions/Recap')
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
