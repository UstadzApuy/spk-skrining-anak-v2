<?php

namespace Tests\Feature\Auth;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class RoleMiddlewareTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $administratorRole = Role::create([
            'name' => 'administrator',
        ]);

        Role::create([
            'name' => 'perawat',
        ]);

        User::create([
            'name' => 'Administrator Test',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role_id' => $administratorRole->id,
        ]);

        Route::middleware(['auth', 'role:administrator'])
            ->get('/__test/role-administrator', function () {
                return 'Role middleware works.';
            });
    }

    public function test_user_with_allowed_role_can_access_route(): void
    {
        $user = User::where('email', 'admin@test.local')->firstOrFail();

        $response = $this->actingAs($user)
            ->get('/__test/role-administrator');

        $response->assertSuccessful();
        $response->assertSeeText('Role middleware works.');
    }

    public function test_user_with_different_role_receives_forbidden_response(): void
    {
        $perawatRole = Role::where('name', 'perawat')->firstOrFail();

        $user = User::create([
            'name' => 'Perawat Test',
            'email' => 'perawat@test.local',
            'password' => 'password',
            'role_id' => $perawatRole->id,
        ]);

        $response = $this->actingAs($user)
            ->get('/__test/role-administrator');

        $response->assertForbidden();
    }

    public function test_guest_cannot_reach_role_protected_route(): void
    {
        $response = $this->get('/__test/role-administrator');

        $response->assertRedirect(route('login'));
    }
}