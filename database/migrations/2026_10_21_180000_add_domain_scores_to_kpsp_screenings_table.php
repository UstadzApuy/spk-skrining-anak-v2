<?php

use App\Services\KpspCatalogService;
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
            $table->json('domain_scores')->nullable()->after('recommendation');
        });

        // Backfill existing KPSP screening records
        $catalogService = new KpspCatalogService();
        $records = DB::table('kpsp_screenings')->select('id', 'form_age_months', 'answers')->get();

        foreach ($records as $record) {
            $answers = is_string($record->answers) ? json_decode($record->answers, true) : (array) $record->answers;
            $formAge = (int) ($record->form_age_months ?? 0);

            if ($formAge > 0 && is_array($answers) && count($answers) === 10) {
                $domainScores = $catalogService->calculateDomainScores($formAge, $answers);

                DB::table('kpsp_screenings')
                    ->where('id', $record->id)
                    ->update([
                        'domain_scores' => json_encode($domainScores),
                    ]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kpsp_screenings', function (Blueprint $table) {
            $table->dropColumn('domain_scores');
        });
    }
};
