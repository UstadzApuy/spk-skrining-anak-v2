<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_administrator_is_redirected_to_administrator_dashboard(): void
    {
        $this->assertDashboardComponentForRole('administrator', 'Dashboard/Administrator');
    }

    public function test_perawat_is_redirected_to_perawat_dashboard(): void
    {
        $this->assertDashboardComponentForRole('perawat', 'Dashboard/Perawat');
    }

    public function test_dokter_is_redirected_to_dokter_dashboard(): void
    {
        $this->assertDashboardComponentForRole('dokter', 'Dashboard/Dokter');
    }

    public function test_orang_tua_is_redirected_to_orang_tua_dashboard(): void
    {
        $this->assertDashboardComponentForRole('orang_tua', 'Dashboard/OrangTua');
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
