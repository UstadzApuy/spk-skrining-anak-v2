<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_perawat_is_redirected_to_perawat_dashboard(): void
    {
        $this->assertDashboardComponentForRole('perawat', 'Dashboard/Perawat');
    }

    public function test_dokter_is_redirected_to_dokter_dashboard(): void
    {
        $this->assertDashboardComponentForRole('dokter', 'Dashboard/Dokter');
    }

    public function test_orang_tua_cannot_access_dashboard(): void
    {
        $role = Role::create([
            'name' => 'orang_tua',
        ]);

        $user = User::create([
            'name' => 'Wali Pasien Test',
            'email' => 'orang_tua@test.local',
            'password' => 'password',
            'role_id' => $role->id,
        ]);

        $this->actingAs($user)
            ->get(route('dashboard'))
            ->assertForbidden();
    }

    private function assertDashboardComponentForRole(
        string $roleName,
        string $component
    ): void {
        $role = Role::create([
            'name' => $roleName,
        ]);

        $user = User::create([
            'name' => 'User Test',
            'email' => "{$roleName}@test.local",
            'password' => 'password',
            'role_id' => $role->id,
        ]);

        $response = $this->actingAs($user)->get(route('dashboard'));

        $response->assertSuccessful();
        $response->assertInertia(
            fn ($page) => $page->component($component)
        );
    }
}
