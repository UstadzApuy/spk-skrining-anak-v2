<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Kolom penghubung ke data SILKABK (sistem utama).
 * Data lama SPK tetap ada; kolom ini hanya terisi untuk
 * user & pasien yang disinkron dari SILKABK.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->unsignedBigInteger('silkabk_user_id')->nullable()->unique();
        });

        Schema::table('patients', function (Blueprint $table) {
            $table->unsignedBigInteger('silkabk_patient_id')->nullable()->unique();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['silkabk_user_id']);
            $table->dropColumn('silkabk_user_id');
        });

        Schema::table('patients', function (Blueprint $table) {
            $table->dropUnique(['silkabk_patient_id']);
            $table->dropColumn('silkabk_patient_id');
        });
    }
};
