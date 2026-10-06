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
        Schema::create('gpph_screenings', function (Blueprint $table) {
            $table->id();

            /*
             * Satu sesi skrining hanya memiliki satu hasil GPPH.
             */
            $table->foreignId('screening_session_id')
                ->unique()
                ->constrained('screening_sessions')
                ->restrictOnDelete();

            /*
             * 10 jawaban GPPH/ACTRS disimpan dalam format JSONB.
             *
             * Setiap item memiliki skor 0 sampai 3.
             */
            $table->jsonb('answers');

            /*
             * Jumlah skor dari 10 item.
             * Nilai maksimum: 30.
             */
            $table->unsignedTinyInteger('score');

            /*
             * Menyimpan apakah pemeriksa meragukan hasil
             * ketika skor berada di bawah 13.
             */
            $table->boolean('examiner_doubtful')->default(false);

            /*
             * Kategori hasil GPPH.
             */
            $table->string('category', 40);

            /*
             * Rekomendasi tindak lanjut berdasarkan hasil skrining.
             */
            $table->text('recommendation')->nullable();

            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE gpph_screenings
            ADD CONSTRAINT gpph_screenings_score_check
            CHECK (score BETWEEN 0 AND 30)
        ");

        DB::statement("
            ALTER TABLE gpph_screenings
            ADD CONSTRAINT gpph_screenings_category_check
            CHECK (
                category IN (
                    'normal',
                    'meragukan',
                    'kemungkinan_gpph'
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gpph_screenings');
    }
};