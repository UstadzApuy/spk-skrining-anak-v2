<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $roles = [
            'perawat',
            'dokter',
            'orang_tua',
        ];

        foreach ($roles as $role) {
            Role::firstOrCreate([
                'name' => $role,
            ]);
        }

        $legacyAdminRole = Role::where('name', 'administrator')->first();
        if ($legacyAdminRole && $legacyAdminRole->users()->count() === 0) {
            $legacyAdminRole->delete();
        }
    }
}