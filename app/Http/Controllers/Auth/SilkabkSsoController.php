<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Services\SilkabkSync;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Login otomatis dari SILKABK.
 *
 * SILKABK mengirim token sekali pakai: base64url(json{uid, exp, nonce}) . "." . base64url(HMAC-SHA256)
 * yang ditandatangani dengan SILKABK_SSO_SECRET (sama di kedua .env).
 */
class SilkabkSsoController extends Controller
{
    public function __invoke(Request $request, SilkabkSync $sync): RedirectResponse
    {
        $payload = $this->verify((string) $request->query('token', ''));

        if (! $payload) {
            return redirect()->route('login')
                ->withErrors(['email' => 'Tautan login dari SILKABK tidak valid atau sudah kedaluwarsa. Silakan buka lagi dari SILKABK.']);
        }

        $silkabkUser = DB::connection('silkabk')->table('users')->where('id', $payload['uid'])->first();

        if (! $silkabkUser || ! $silkabkUser->is_active) {
            return redirect()->route('login')
                ->withErrors(['email' => 'Akun SILKABK tidak ditemukan atau tidak aktif.']);
        }

        if (! SilkabkSync::mapRole($silkabkUser->role)) {
            return redirect()->route('login')
                ->withErrors(['email' => 'Role akun Anda di SILKABK tidak memiliki akses ke sistem SPK Skrining.']);
        }

        // Pastikan data pasien terbaru dari SILKABK sudah ada di SPK.
        try {
            $sync->syncPatients();
        } catch (\Throwable $e) {
            Log::error('Sinkron pasien SILKABK gagal: '.$e->getMessage());
        }

        $user = $sync->syncUser((int) $silkabkUser->id);

        if (Auth::check() && Auth::id() !== $user->id) {
            Auth::logout();
        }

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route('dashboard');
    }

    /** @return array{uid:int, exp:int, nonce:string}|null */
    private function verify(string $token): ?array
    {
        $secret = (string) config('services.silkabk.sso_secret');

        if ($secret === '' || substr_count($token, '.') !== 1) {
            return null;
        }

        [$body, $signature] = explode('.', $token);

        $expected = $this->base64UrlEncode(hash_hmac('sha256', $body, $secret, true));

        if (! hash_equals($expected, $signature)) {
            return null;
        }

        $payload = json_decode((string) base64_decode(strtr($body, '-_', '+/')), true);

        if (
            ! is_array($payload)
            || ! isset($payload['uid'], $payload['exp'], $payload['nonce'])
            || (int) $payload['exp'] < time()
        ) {
            return null;
        }

        // Token hanya boleh dipakai sekali.
        if (! Cache::add('silkabk-sso-nonce:'.$payload['nonce'], true, now()->addMinutes(5))) {
            return null;
        }

        return $payload;
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
