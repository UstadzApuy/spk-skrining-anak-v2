<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('silkabk:sync', function (\App\Services\SilkabkSync $sync) {
    $count = $sync->syncPatients();
    $this->info("{$count} pasien SILKABK tersinkron ke SPK.");
})->purpose('Sinkron pasien (beserta akun wali) dari SILKABK ke SPK');
