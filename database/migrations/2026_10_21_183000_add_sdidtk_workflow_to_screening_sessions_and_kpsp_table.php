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
        Schema::table('screening_sessions', function (Blueprint $table) {
            $table->string('evaluation_type', 40)->default('initial')->after('status');
            $table->foreignId('parent_session_id')->nullable()->after('evaluation_type')->constrained('screening_sessions')->nullOnDelete();
        });

        Schema::table('kpsp_screenings', function (Blueprint $table) {
            $table->string('sdidtk_code', 10)->nullable()->after('category');
            $table->string('clinical_action', 50)->nullable()->after('sdidtk_code');
            $table->boolean('is_re_evaluation')->default(false)->after('clinical_action');
        });

        // Backfill existing kpsp_screenings records with official SDIDTK codes & actions
        $records = DB::table('kpsp_screenings')->get();
        foreach ($records as $record) {
            $code = match ($record->category) {
                'sesuai_umur', 'sesuai' => 'Ds',
                'meragukan' => 'Dm',
                'kemungkinan_penyimpangan', 'penyimpangan' => 'Dp',
                default => 'Ds',
            };
            $action = match ($code) {
                'Ds' => 'stimulasi_rutin_kia',
                'Dm' => 'intervensi_2_minggu',
                'Dp' => 'rujuk_rs_spesialistik',
            };
            DB::table('kpsp_screenings')->where('id', $record->id)->update([
                'sdidtk_code' => $code,
                'clinical_action' => $action,
                'is_re_evaluation' => false,
            ]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kpsp_screenings', function (Blueprint $table) {
            $table->dropColumn(['sdidtk_code', 'clinical_action', 'is_re_evaluation']);
        });

        Schema::table('screening_sessions', function (Blueprint $table) {
            $table->dropForeign(['parent_session_id']);
            $table->dropColumn(['evaluation_type', 'parent_session_id']);
        });
    }
};
