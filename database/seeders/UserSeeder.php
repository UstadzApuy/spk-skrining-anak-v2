<?php

namespace Database\Seeders;

use App\Models\Doctor;
use App\Models\ParentGuardian;
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
        $parentRole = Role::where('name', 'orang_tua')->firstOrFail();

        $legacyAdmin = User::where('email', 'admin@spk.test')->first();
        if (
            $legacyAdmin
            && ! \App\Models\ScreeningSession::where('created_by_user_id', $legacyAdmin->id)->exists()
        ) {
            $legacyAdmin->delete();
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

        $parent = User::updateOrCreate(
            ['email' => 'orangtua@spk.test'],
            [
                'name' => 'Orang Tua Uji',
                'role_id' => $parentRole->id,
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );

        ParentGuardian::updateOrCreate(
            ['user_id' => $parent->id],
            [
                'phone' => '080000000000',
                'address' => 'Data development',
            ]
        );
    }
}