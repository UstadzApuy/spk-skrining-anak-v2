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
        Schema::table('srq_screenings', function (Blueprint $table) {
            $table->unsignedTinyInteger('depression_score')->default(0)->after('score');
            $table->unsignedTinyInteger('anxiety_score')->default(0)->after('depression_score');
            $table->unsignedTinyInteger('somatic_score')->default(0)->after('anxiety_score');
            $table->unsignedTinyInteger('cognitive_score')->default(0)->after('somatic_score');
            $table->unsignedTinyInteger('energy_score')->default(0)->after('cognitive_score');
        });

        // Backfill existing records from answers JSONB
        // SRQ items:
        // Depression: 6, 9, 10, 14, 15, 16, 17 (0-indexed: 5, 8, 9, 13, 14, 15, 16)
        // Anxiety: 3, 4, 5 (0-indexed: 2, 3, 4)
        // Somatic: 1, 2, 7, 19 (0-indexed: 0, 1, 6, 18)
        // Cognitive: 8, 12, 13 (0-indexed: 7, 11, 12)
        // Energy: 8, 11, 12, 13, 18, 20 (0-indexed: 7, 10, 11, 12, 17, 19)
        $records = DB::table('srq_screenings')->select('id', 'answers')->get();

        foreach ($records as $record) {
            $answers = json_decode($record->answers, true) ?: [];
            if (count($answers) === 20) {
                $countTrue = static function (array $indices) use ($answers): int {
                    $cnt = 0;
                    foreach ($indices as $idx) {
                        if (!empty($answers[$idx])) {
                            $cnt++;
                        }
                    }
                    return $cnt;
                };

                DB::table('srq_screenings')
                    ->where('id', $record->id)
                    ->update([
                        'depression_score' => $countTrue([5, 8, 9, 13, 14, 15, 16]),
                        'anxiety_score'    => $countTrue([2, 3, 4]),
                        'somatic_score'    => $countTrue([0, 1, 6, 18]),
                        'cognitive_score'  => $countTrue([7, 11, 12]),
                        'energy_score'     => $countTrue([7, 10, 11, 12, 17, 19]),
                    ]);
            }
        }

        DB::statement('
            ALTER TABLE srq_screenings
            ADD CONSTRAINT srq_screenings_depression_score_check
            CHECK (depression_score BETWEEN 0 AND 7)
        ');

        DB::statement('
            ALTER TABLE srq_screenings
            ADD CONSTRAINT srq_screenings_anxiety_score_check
            CHECK (anxiety_score BETWEEN 0 AND 3)
        ');

        DB::statement('
            ALTER TABLE srq_screenings
            ADD CONSTRAINT srq_screenings_somatic_score_check
            CHECK (somatic_score BETWEEN 0 AND 4)
        ');

        DB::statement('
            ALTER TABLE srq_screenings
            ADD CONSTRAINT srq_screenings_cognitive_score_check
            CHECK (cognitive_score BETWEEN 0 AND 3)
        ');

        DB::statement('
            ALTER TABLE srq_screenings
            ADD CONSTRAINT srq_screenings_energy_score_check
            CHECK (energy_score BETWEEN 0 AND 6)
        ');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        foreach ([
            'depression_score',
            'anxiety_score',
            'somatic_score',
            'cognitive_score',
            'energy_score',
        ] as $col) {
            DB::statement("ALTER TABLE srq_screenings DROP CONSTRAINT IF EXISTS srq_screenings_{$col}_check");
        }

        Schema::table('srq_screenings', function (Blueprint $table) {
            $table->dropColumn([
                'depression_score',
                'anxiety_score',
                'somatic_score',
                'cognitive_score',
                'energy_score',
            ]);
        });
    }
};
