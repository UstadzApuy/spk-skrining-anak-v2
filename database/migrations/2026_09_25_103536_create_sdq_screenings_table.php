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
        Schema::create('sdq_screenings', function (Blueprint $table) {
            $table->id();

            /*
             * Satu sesi skrining hanya memiliki satu hasil SDQ.
             */
            $table->foreignId('screening_session_id')
                ->unique()
                ->constrained('screening_sessions')
                ->restrictOnDelete();

            /*
             * 25 jawaban SDQ disimpan dalam format JSONB.
             *
             * Setiap jawaban memiliki nilai 0 sampai 2.
             */
            $table->jsonb('answers');

            /*
             * Skor empat subskala kesulitan SDQ.
             */
            $table->unsignedTinyInteger('emotional_score');
            $table->unsignedTinyInteger('conduct_score');
            $table->unsignedTinyInteger('hyperactivity_score');
            $table->unsignedTinyInteger('peer_score');

            /*
             * Total Skor Kesulitan:
             * Emotional + Conduct + Hyperactivity + Peer.
             */
            $table->unsignedSmallInteger('total_difficulties_score');

            /*
             * Skor Kekuatan/Perilaku Prososial.
             * Tidak dijumlahkan dengan Total Skor Kesulitan.
             */
            $table->unsignedTinyInteger('prosocial_score');

            /*
             * Kategori Total Skor Kesulitan.
             * Aturan kategorisasi memperhatikan kelompok umur.
             */
            $table->string('total_difficulties_category', 30);

            /*
             * Kategori Skor Kekuatan/Prososial.
             * Aturan kategorisasi memperhatikan kelompok umur.
             */
            $table->string('prosocial_category', 30);

            /*
             * Rekomendasi tindak lanjut berdasarkan hasil SDQ.
             */
            $table->text('recommendation')->nullable();

            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_emotional_score_check
            CHECK (emotional_score BETWEEN 0 AND 10)
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_conduct_score_check
            CHECK (conduct_score BETWEEN 0 AND 10)
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_hyperactivity_score_check
            CHECK (hyperactivity_score BETWEEN 0 AND 10)
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_peer_score_check
            CHECK (peer_score BETWEEN 0 AND 10)
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_total_difficulties_score_check
            CHECK (total_difficulties_score BETWEEN 0 AND 40)
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_prosocial_score_check
            CHECK (prosocial_score BETWEEN 0 AND 10)
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_total_difficulties_category_check
            CHECK (
                total_difficulties_category IN (
                    'normal',
                    'ambang_borderline',
                    'abnormal'
                )
            )
        ");

        DB::statement("
            ALTER TABLE sdq_screenings
            ADD CONSTRAINT sdq_screenings_prosocial_category_check
            CHECK (
                prosocial_category IN (
                    'normal',
                    'ambang_borderline',
                    'abnormal'
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sdq_screenings');
    }
};