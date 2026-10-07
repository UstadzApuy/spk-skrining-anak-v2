<?php

namespace Tests\Feature;

use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PatientTest extends TestCase
{
    use RefreshDatabase;

    public function test_perawat_can_access_patient_list(): void
    {
        $nurseRole = Role::create([
            'name' => 'perawat',
        ]);

        $parentRole = Role::create([
            'name' => 'orang_tua',
        ]);

        $nurse = User::create([
            'name' => 'Perawat Test',
            'email' => 'perawat@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $parent = User::create([
            'name' => 'Orang Tua Test',
            'email' => 'orangtua@test.local',
            'password' => 'password',
            'role_id' => $parentRole->id,
        ]);

        $parentGuardian = ParentGuardian::create([
            'user_id' => $parent->id,
            'phone' => '080000000000',
            'address' => 'Alamat Test',
        ]);

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-TEST-PATIENT',
            'name' => 'Anak Test',
            'birth_date' => '2024-01-01',
            'gender' => 'L',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        $response = $this->actingAs($nurse)
            ->get(route('patients.index'));

        $response->assertSuccessful();

        $response->assertInertia(
            fn ($page) => $page
                ->component('Patients/Index')
                ->has('patients', 1)
                ->where('patients.0.id', $patient->id)
                ->where('patients.0.medical_record_number', 'RM-TEST-PATIENT')
                ->where('patients.0.name', 'Anak Test')
        );
    }

    public function test_non_nurse_cannot_access_patient_list(): void
    {
        $doctorRole = Role::create([
            'name' => 'dokter',
        ]);

        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $response = $this->actingAs($doctor)
            ->get(route('patients.index'));

        $response->assertForbidden();
    }

    public function test_guest_cannot_access_patient_list(): void
    {
        $response = $this->get(route('patients.index'));

        $response->assertRedirect(route('login'));
    }
}