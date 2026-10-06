<?php

namespace Tests\Feature\Auth;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoginTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Role::create([
            'name' => 'administrator',
        ]);
    }

    public function test_login_page_can_be_rendered(): void
    {
        $response = $this->get(route('login'));

        $response->assertSuccessful();
    }

    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = User::create([
            'name' => 'Administrator Test',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role_id' => Role::where('name', 'administrator')->value('id'),
        ]);

        $response = $this->post(route('login.store'), [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $response->assertRedirect(route('dashboard'));
        $this->assertAuthenticatedAs($user);
    }

    public function test_user_cannot_login_with_invalid_credentials(): void
    {
        User::create([
            'name' => 'Administrator Test',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role_id' => Role::where('name', 'administrator')->value('id'),
        ]);

        $response = $this->from(route('login'))->post(route('login.store'), [
            'email' => 'admin@test.local',
            'password' => 'wrong-password',
        ]);

        $response->assertRedirect(route('login'));
        $response->assertSessionHasErrors('email');
        $this->assertGuest();
    }

    public function test_authenticated_user_can_access_dashboard(): void
    {
        $user = User::create([
            'name' => 'Administrator Test',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role_id' => Role::where('name', 'administrator')->value('id'),
        ]);

        $this->actingAs($user);

        $response = $this->get(route('dashboard'));

        $response->assertSuccessful();
        $this->assertAuthenticatedAs($user);
    }

    public function test_guest_cannot_access_dashboard(): void
    {
        $response = $this->get(route('dashboard'));

        $response->assertRedirect(route('login'));
    }
}