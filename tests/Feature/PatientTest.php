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

    public function test_perawat_can_open_patient_creation_form(): void
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

        $response = $this->actingAs($nurse)
            ->get(route('patients.create'));

        $response->assertSuccessful();

        $response->assertInertia(
            fn ($page) => $page
                ->component('Patients/Create')
                ->has('parentGuardians', 1)
                ->where('parentGuardians.0.id', $parentGuardian->id)
                ->where('parentGuardians.0.user.name', 'Orang Tua Test')
        );
    }

    public function test_perawat_can_create_patient_with_valid_data(): void
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

        $response = $this->actingAs($nurse)
            ->post(route('patients.store'), [
                'parent_guardian_id' => $parentGuardian->id,
                'medical_record_number' => 'RM-NEW-001',
                'name' => 'Anak Baru',
                'birth_date' => '2024-05-10',
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ]);

        $response->assertRedirect(route('patients.index'));
        $response->assertSessionHas('success', 'Data pasien berhasil ditambahkan.');

            $this->assertDatabaseHas('patients', [
                'parent_guardian_id' => $parentGuardian->id,
                'medical_record_number' => 'RM-NEW-001',
                'name' => 'Anak Baru',
                'gender' => 'P',
                'is_premature' => false,
                'gestational_age_weeks' => null,
                'is_active' => true,
            ]);

            $indexResponse = $this->actingAs($nurse)
                ->get(route('patients.index'));

            $indexResponse->assertInertia(
                fn ($page) => $page
                    ->component('Patients/Index')
                    ->where(
                        'flash.success',
                        'Data pasien berhasil ditambahkan.'
                    )
            );
        }

    public function test_premature_patient_requires_gestational_age(): void
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
        ]);

        $response = $this->actingAs($nurse)
            ->post(route('patients.store'), [
                'parent_guardian_id' => $parentGuardian->id,
                'medical_record_number' => 'RM-PREMATURE-001',
                'name' => 'Anak Prematur',
                'birth_date' => '2025-01-01',
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => true,
                'gestational_age_weeks' => null,
            ]);

        $response->assertSessionHasErrors('gestational_age_weeks');

        $this->assertDatabaseMissing('patients', [
            'medical_record_number' => 'RM-PREMATURE-001',
        ]);
    }

    public function test_patient_medical_record_number_must_be_unique(): void
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
        ]);

        Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-DUPLICATE-001',
            'name' => 'Pasien Lama',
            'birth_date' => '2024-01-01',
            'gender' => 'L',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        $response = $this->actingAs($nurse)
            ->from(route('patients.create'))
            ->post(route('patients.store'), [
                'parent_guardian_id' => $parentGuardian->id,
                'medical_record_number' => 'RM-DUPLICATE-001',
                'name' => 'Pasien Baru',
                'birth_date' => '2025-01-01',
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ]);

        $response->assertRedirect(route('patients.create'));
        $response->assertSessionHasErrors('medical_record_number');
    }

    public function test_patient_cannot_use_parent_guardian_with_non_parent_role(): void
    {
        $nurseRole = Role::create([
            'name' => 'perawat',
        ]);

        $doctorRole = Role::create([
            'name' => 'dokter',
        ]);

        $nurse = User::create([
            'name' => 'Perawat Test',
            'email' => 'perawat@test.local',
            'password' => 'password',
            'role_id' => $nurseRole->id,
        ]);

        $doctor = User::create([
            'name' => 'Dokter Test',
            'email' => 'dokter@test.local',
            'password' => 'password',
            'role_id' => $doctorRole->id,
        ]);

        $parentGuardian = ParentGuardian::create([
            'user_id' => $doctor->id,
        ]);

        $response = $this->actingAs($nurse)
            ->from(route('patients.create'))
            ->post(route('patients.store'), [
                'parent_guardian_id' => $parentGuardian->id,
                'medical_record_number' => 'RM-INVALID-GUARDIAN',
                'name' => 'Anak Invalid',
                'birth_date' => '2024-01-01',
                'gender' => 'L',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ]);

        $response->assertRedirect(route('patients.create'));
        $response->assertSessionHasErrors('parent_guardian_id');

        $this->assertDatabaseMissing('patients', [
            'medical_record_number' => 'RM-INVALID-GUARDIAN',
        ]);
    }

    public function test_perawat_can_open_patient_edit_form(): void
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
        ]);

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-EDIT-001',
            'name' => 'Anak Sebelum Edit',
            'birth_date' => '2024-05-10',
            'gender' => 'P',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        $response = $this->actingAs($nurse)
            ->get(route('patients.edit', $patient));

        $response->assertSuccessful();

        $response->assertInertia(
            fn ($page) => $page
                ->component('Patients/Edit')
                ->where('patient.id', $patient->id)
                ->where('patient.medical_record_number', 'RM-EDIT-001')
                ->where('patient.name', 'Anak Sebelum Edit')
                ->where('patient.birth_date', '2024-05-10')
                ->where('patient.gender', 'P')
                ->where('patient.is_premature', false)
                ->has('parentGuardians', 1)
                ->where('parentGuardians.0.id', $parentGuardian->id)
        );
    }

    public function test_perawat_can_update_patient(): void
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
        ]);

        $patient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-EDIT-001',
            'name' => 'Anak Sebelum Edit',
            'birth_date' => '2024-05-10',
            'gender' => 'P',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        $response = $this->actingAs($nurse)
            ->put(route('patients.update', $patient), [
                'parent_guardian_id' => $parentGuardian->id,
                'medical_record_number' => 'RM-EDIT-001',
                'name' => 'Anak Setelah Edit',
                'birth_date' => '2024-06-15',
                'gender' => 'L',
                'guardian_relationship' => 'Ayah',
                'is_premature' => true,
                'gestational_age_weeks' => 32,
            ]);

        $response->assertRedirect(route('patients.index'));
        $response->assertSessionHas(
            'success',
            'Data pasien berhasil diperbarui.'
        );

        $this->assertDatabaseHas('patients', [
            'id' => $patient->id,
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-EDIT-001',
            'name' => 'Anak Setelah Edit',
            'birth_date' => '2024-06-15',
            'gender' => 'L',
            'guardian_relationship' => 'Ayah',
            'is_premature' => true,
            'gestational_age_weeks' => 32,
            'is_active' => true,
        ]);
    }

    public function test_patient_update_rejects_duplicate_medical_record_number(): void
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
        ]);

        $existingPatient = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-EXISTING-001',
            'name' => 'Pasien Lama',
            'birth_date' => '2024-01-01',
            'gender' => 'L',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        $patientToUpdate = Patient::create([
            'parent_guardian_id' => $parentGuardian->id,
            'medical_record_number' => 'RM-EDIT-002',
            'name' => 'Pasien yang Diubah',
            'birth_date' => '2024-06-01',
            'gender' => 'P',
            'guardian_relationship' => 'Ibu',
            'is_premature' => false,
            'gestational_age_weeks' => null,
            'is_active' => true,
        ]);

        $response = $this->actingAs($nurse)
            ->from(route('patients.edit', $patientToUpdate))
            ->put(route('patients.update', $patientToUpdate), [
                'parent_guardian_id' => $parentGuardian->id,
                'medical_record_number' => $existingPatient->medical_record_number,
                'name' => 'Pasien yang Diubah',
                'birth_date' => '2024-06-01',
                'gender' => 'P',
                'guardian_relationship' => 'Ibu',
                'is_premature' => false,
                'gestational_age_weeks' => null,
            ]);

        $response->assertRedirect(route('patients.edit', $patientToUpdate));
        $response->assertSessionHasErrors('medical_record_number');

        $this->assertDatabaseHas('patients', [
            'id' => $patientToUpdate->id,
            'medical_record_number' => 'RM-EDIT-002',
            'name' => 'Pasien yang Diubah',
        ]);
    }

}
