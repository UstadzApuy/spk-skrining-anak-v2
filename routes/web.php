<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PatientController;
use App\Http\Controllers\ScreeningSessionController;
use App\Http\Controllers\SdqScreeningController;
use App\Http\Controllers\SrqScreeningController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'create'])
        ->name('login');

    Route::post('/login', [LoginController::class, 'store'])
        ->name('login.store');
});

Route::middleware('auth')->group(function () {
    Route::post('/logout', [LoginController::class, 'destroy'])
        ->name('logout');

    Route::get('/dashboard', [DashboardController::class, 'index'])
        ->name('dashboard');

    Route::middleware('role:perawat')->group(function () {
        Route::get('/patients', [PatientController::class, 'index'])
            ->name('patients.index');

        Route::get('/patients/create', [PatientController::class, 'create'])
            ->name('patients.create');

        Route::post('/patients', [PatientController::class, 'store'])
            ->name('patients.store');

        Route::get('/patients/{patient}/edit', [PatientController::class, 'edit'])
            ->name('patients.edit');

        Route::put('/patients/{patient}', [PatientController::class, 'update'])
            ->name('patients.update');

        Route::get('/screening-sessions/create', [
            ScreeningSessionController::class,
            'create',
        ])->name('screening-sessions.create');

        Route::post('/screening-sessions', [
            ScreeningSessionController::class,
            'store',
        ])->name('screening-sessions.store');

        Route::get(
            '/screening-sessions/{screeningSession}/sdq',
            [SdqScreeningController::class, 'create']
        )->name('screening-sessions.sdq.create');

        Route::post(
            '/screening-sessions/{screeningSession}/sdq',
            [SdqScreeningController::class, 'store']
        )->name('screening-sessions.sdq.store');

        Route::get(
            '/screening-sessions/{screeningSession}/srq',
            [SrqScreeningController::class, 'create']
        )->name('screening-sessions.srq.create');

        Route::post(
            '/screening-sessions/{screeningSession}/srq',
            [SrqScreeningController::class, 'store']
        )->name('screening-sessions.srq.store');

        Route::get(
            '/screening-sessions/{screeningSession}/srq/complete',
            [SrqScreeningController::class, 'complete']
        )->name('screening-sessions.srq.complete');
    });

    Route::middleware('role:perawat,dokter')->group(function () {
        Route::get('/screening-sessions', [
            ScreeningSessionController::class,
            'index',
        ])->name('screening-sessions.index');

        Route::get(
            '/screening-sessions/{screeningSession}',
            [ScreeningSessionController::class, 'show']
        )->name('screening-sessions.show');
    });
});

Route::get('/', function () {
    return Inertia::render('Welcome');
});
