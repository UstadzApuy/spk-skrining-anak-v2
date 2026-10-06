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
        Schema::create('kpsp_screenings', function (Blueprint $table) {
            $table->id();

            /*
             * Satu sesi skrining hanya memiliki satu hasil KPSP.
             */
            $table->foreignId('screening_session_id')
                ->unique()
                ->constrained('screening_sessions')
                ->restrictOnDelete();

            /*
             * 10 jawaban KPSP disimpan dalam format JSONB.
             * Contoh struktur:
             * {
             *     "item_1": true,
             *     "item_2": false,
             *     ...
             *     "item_10": true
             * }
             */
            $table->jsonb('answers');

            /*
             * Jumlah jawaban "Ya" dari 10 item KPSP.
             * Nilai valid: 0 sampai 10.
             */
            $table->unsignedTinyInteger('score');

            /*
             * Kode kategori hasil KPSP.
             */
            $table->string('category', 40);

            /*
             * Rekomendasi tindak lanjut berdasarkan kategori.
             */
            $table->text('recommendation')->nullable();

            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE kpsp_screenings
            ADD CONSTRAINT kpsp_screenings_score_check
            CHECK (score BETWEEN 0 AND 10)
        ");

        DB::statement("
            ALTER TABLE kpsp_screenings
            ADD CONSTRAINT kpsp_screenings_category_check
            CHECK (
                category IN (
                    'sesuai_umur',
                    'meragukan',
                    'kemungkinan_penyimpangan'
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kpsp_screenings');
    }
};