<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->text('address')->nullable()->after('gender');
            $table->string('education', 50)->nullable()->default('tidak_sekolah')->after('address');
        });

        Schema::table('screening_sessions', function (Blueprint $table) {
            $table->string('case_type', 20)->nullable()->after('age_months'); // 'baru', 'lama'
            $table->string('referral_source', 100)->nullable()->after('case_type'); // 'Puskesmas', 'RS', etc.
            $table->string('referral_target', 100)->nullable()->after('referral_source'); // Rujukan ke: 'RSUD Kanujoso', 'Sp.A', etc.
            $table->json('interventions')->nullable()->after('referral_target'); // ['psikolog', 'aba', 'ot', 'tw', 'si', 'fisioterapi', 'perawatan_medis', 'konseling', 'rehabilitasi', 'rujukan']
            $table->text('recap_notes')->nullable()->after('interventions');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('screening_sessions', function (Blueprint $table) {
            $table->dropColumn([
                'case_type',
                'referral_source',
                'referral_target',
                'interventions',
                'recap_notes',
            ]);
        });

        Schema::table('patients', function (Blueprint $table) {
            $table->dropColumn([
                'address',
                'education',
            ]);
        });
    }
};
