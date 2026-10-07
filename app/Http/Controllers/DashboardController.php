<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    /**
     * Display the dashboard according to the authenticated user's role.
     */
    public function index(Request $request): Response
    {
        $role = $request->user()->role?->name;

        $page = match ($role) {
            'administrator' => 'Dashboard/Administrator',
            'perawat' => 'Dashboard/Perawat',
            'dokter' => 'Dashboard/Dokter',
            'orang_tua' => 'Dashboard/OrangTua',
            default => abort(403),
        };

        return Inertia::render($page);
    }
}