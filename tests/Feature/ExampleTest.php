<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertRedirect(route('login'));
    }

    public function test_login_page_returns_successful_response(): void
    {
        $response = $this->get(route('login'));

        $response->assertStatus(200);
    }

    public function test_uppercase_spk_redirects(): void
    {
        $response = $this->get('/SPK/login');

        $response->assertRedirect('/spk/login');
    }
}
