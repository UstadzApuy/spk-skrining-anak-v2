<?php

namespace Database\Seeders;

use App\Models\Doctor;
use App\Models\Role;
use App\Models\User;
use App\Models\Nurse;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $nurseRole = Role::where('name', 'perawat')->firstOrFail();
        $doctorRole = Role::where('name', 'dokter')->firstOrFail();

        $legacyAdmin = User::where('email', 'admin@spk.test')->first();
        if (
            $legacyAdmin
            && ! \App\Models\ScreeningSession::where('created_by_user_id', $legacyAdmin->id)->exists()
        ) {
            $legacyAdmin->delete();
        }

        $legacyParent = User::where('email', 'orangtua@spk.test')->first();
        if (
            $legacyParent
            && (! $legacyParent->parentGuardian || ! $legacyParent->parentGuardian->patients()->exists())
        ) {
            $legacyParent->parentGuardian?->delete();
            $legacyParent->delete();
        }

        $nurse = User::updateOrCreate(
            ['email' => 'perawat@spk.test'],
            [
                'name' => 'Perawat Uji',
                'role_id' => $nurseRole->id,
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );

        Nurse::updateOrCreate(
            ['user_id' => $nurse->id],
            [
                'registration_number' => 'NURSE-001',
            ]
        );

        $doctor = User::updateOrCreate(
            ['email' => 'dokter@spk.test'],
            [
                'name' => 'Dokter Uji',
                'role_id' => $doctorRole->id,
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );

        Doctor::updateOrCreate(
            ['user_id' => $doctor->id],
            [
                'specialization' => 'Dokter Anak',
            ]
        );
    }
}