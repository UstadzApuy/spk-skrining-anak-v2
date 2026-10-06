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
        Schema::create('srq_screenings', function (Blueprint $table) {
            $table->id();

            /*
             * Satu sesi skrining hanya memiliki satu hasil SRQ-20.
             */
            $table->foreignId('screening_session_id')
                ->unique()
                ->constrained('screening_sessions')
                ->restrictOnDelete();

            /*
             * 20 jawaban SRQ-20 disimpan dalam format JSONB.
             *
             * Setiap jawaban berupa:
             * true  = Ya
             * false = Tidak
             */
            $table->jsonb('answers');

            /*
             * Skor total SRQ-20.
             * Ya = 1, Tidak = 0.
             * Nilai valid: 0 sampai 20.
             */
            $table->unsignedTinyInteger('score');

            /*
             * Kategori hasil berdasarkan nilai pisah 5/6.
             */
            $table->string('category', 50);

            /*
             * Rekomendasi tindak lanjut berdasarkan hasil skrining.
             */
            $table->text('recommendation')->nullable();

            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE srq_screenings
            ADD CONSTRAINT srq_screenings_score_check
            CHECK (score BETWEEN 0 AND 20)
        ");

        DB::statement("
            ALTER TABLE srq_screenings
            ADD CONSTRAINT srq_screenings_category_check
            CHECK (
                category IN (
                    'di_bawah_nilai_pisah',
                    'gangguan_mental_emosional_distres'
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('srq_screenings');
    }
};