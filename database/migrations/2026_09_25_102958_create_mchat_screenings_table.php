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
        Schema::create('mchat_screenings', function (Blueprint $table) {
            $table->id();

            /*
             * Satu sesi skrining hanya memiliki satu hasil M-CHAT-R.
             */
            $table->foreignId('screening_session_id')
                ->unique()
                ->constrained('screening_sessions')
                ->restrictOnDelete();

            /*
             * 20 jawaban M-CHAT-R disimpan dalam format JSONB.
             * Contoh:
             * {
             *     "item_1": true,
             *     "item_2": false,
             *     ...
             *     "item_20": true
             * }
             */
            $table->jsonb('answers');

            /*
             * Skor risiko M-CHAT-R berdasarkan aturan penskoran.
             * Nilai valid: 0 sampai 20.
             */
            $table->unsignedTinyInteger('score');

            /*
             * Kategori hasil skrining M-CHAT-R.
             */
            $table->string('category', 30);

            /*
             * Rekomendasi tindak lanjut berdasarkan hasil skrining.
             */
            $table->text('recommendation')->nullable();

            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE mchat_screenings
            ADD CONSTRAINT mchat_screenings_score_check
            CHECK (score BETWEEN 0 AND 20)
        ");

        DB::statement("
            ALTER TABLE mchat_screenings
            ADD CONSTRAINT mchat_screenings_category_check
            CHECK (
                category IN (
                    'risiko_rendah',
                    'risiko_sedang_tinggi'
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mchat_screenings');
    }
};