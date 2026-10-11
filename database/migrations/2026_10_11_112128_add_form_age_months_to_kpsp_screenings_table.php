<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('kpsp_screenings', function (Blueprint $table) {
            $table->unsignedSmallInteger('form_age_months')->nullable();
        });

        DB::statement("
            ALTER TABLE kpsp_screenings
            ADD CONSTRAINT kpsp_screenings_form_age_months_check
            CHECK (
                form_age_months IS NULL OR
                form_age_months IN (
                    3, 6, 9, 12, 15, 18, 21, 24,
                    30, 36, 42, 48, 54, 60, 66, 72
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement("
            ALTER TABLE kpsp_screenings
            DROP CONSTRAINT kpsp_screenings_form_age_months_check
        ");

        Schema::table('kpsp_screenings', function (Blueprint $table) {
            $table->dropColumn('form_age_months');
        });
    }
};