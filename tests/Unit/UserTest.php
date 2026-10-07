<?php

namespace Tests\Unit;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_has_role_returns_true_for_matching_role(): void
    {
        $role = Role::create([
            'name' => 'administrator',
        ]);

        $user = User::create([
            'name' => 'Administrator Test',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role_id' => $role->id,
        ]);

        $this->assertTrue($user->hasRole('administrator'));
    }

    public function test_user_has_role_returns_false_for_non_matching_role(): void
    {
        $role = Role::create([
            'name' => 'administrator',
        ]);

        $user = User::create([
            'name' => 'Administrator Test',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role_id' => $role->id,
        ]);

        $this->assertFalse($user->hasRole('dokter'));
    }

    public function test_user_has_role_supports_multiple_allowed_roles(): void
    {
        $role = Role::create([
            'name' => 'administrator',
        ]);

        $user = User::create([
            'name' => 'Administrator Test',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role_id' => $role->id,
        ]);

        $this->assertTrue($user->hasRole('dokter', 'administrator'));
        $this->assertFalse($user->hasRole('dokter', 'perawat'));
    }

    public function test_user_without_role_returns_false(): void
    {
        $user = new User([
            'name' => 'User Without Role',
            'email' => 'norole@test.local',
            'password' => 'password',
            'role_id' => null,
        ]);

        $this->assertFalse($user->hasRole('administrator'));
    }
}
