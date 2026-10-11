
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sdq_screenings', function (Blueprint $table) {
            $table->string('emotional_category', 30)->nullable();
            $table->string('conduct_category', 30)->nullable();
            $table->string('hyperactivity_category', 30)->nullable();
            $table->string('peer_category', 30)->nullable();
        });

        // Backfill categories for existing SDQ results.
        DB::statement("
            UPDATE sdq_screenings
            SET
                emotional_category = CASE
                    WHEN emotional_score <= 3 THEN 'normal'
                    WHEN emotional_score = 4 THEN 'ambang_borderline'
                    ELSE 'abnormal'
                END,
                conduct_category = CASE
                    WHEN conduct_score <= 2 THEN 'normal'
                    WHEN conduct_score = 3 THEN 'ambang_borderline'
                    ELSE 'abnormal'
                END,
                hyperactivity_category = CASE
                    WHEN hyperactivity_score <= 5 THEN 'normal'
                    WHEN hyperactivity_score = 6 THEN 'ambang_borderline'
                    ELSE 'abnormal'
                END,
                peer_category = CASE
                    WHEN peer_score <= 2 THEN 'normal'
                    WHEN peer_score = 3 THEN 'ambang_borderline'
                    ELSE 'abnormal'
                END
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ALTER COLUMN emotional_category SET NOT NULL
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ALTER COLUMN conduct_category SET NOT NULL
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ALTER COLUMN hyperactivity_category SET NOT NULL
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ALTER COLUMN peer_category SET NOT NULL
        ");

        foreach ([
            'emotional_category',
            'conduct_category',
            'hyperactivity_category',
            'peer_category',
        ] as $column) {
            DB::statement("
                ALTER TABLE sdq_screenings
                ADD CONSTRAINT sdq_screenings_{$column}_check
                CHECK (
                    {$column} IN (
                        'normal',
                        'ambang_borderline',
                        'abnormal'
                    )
                )
            ");
        }
    }

    public function down(): void
    {
        foreach ([
            'emotional_category',
            'conduct_category',
            'hyperactivity_category',
            'peer_category',
        ] as $column) {
            DB::statement("
                ALTER TABLE sdq_screenings
                DROP CONSTRAINT IF EXISTS sdq_screenings_{$column}_check
            ");
        }

        Schema::table('sdq_screenings', function (Blueprint $table) {
            $table->dropColumn([
                'emotional_category',
                'conduct_category',
                'hyperactivity_category',
                'peer_category',
            ]);
        });
    }
};
