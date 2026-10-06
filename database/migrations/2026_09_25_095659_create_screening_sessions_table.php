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
        Schema::create('screening_sessions', function (Blueprint $table) {
            $table->id();

            $table->foreignId('patient_id')
                ->constrained('patients')
                ->restrictOnDelete();

            $table->foreignId('nurse_id')
                ->constrained('nurses')
                ->restrictOnDelete();

            $table->foreignId('doctor_id')
                ->nullable()
                ->constrained('doctors')
                ->restrictOnDelete();

            $table->date('screening_date');

            /*
             * Umur anak dalam bulan pada saat pemeriksaan.
             * Nilai ini dihasilkan oleh sistem dari birth_date,
             * screening_date, dan aturan koreksi umur yang berlaku.
             */
            $table->unsignedSmallInteger('age_months');

            $table->string('status', 30)
                ->default('draft');

            $table->text('notes')->nullable();
            $table->text('doctor_notes')->nullable();

            $table->timestamp('reviewed_at')->nullable();

            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE screening_sessions
            ADD CONSTRAINT screening_sessions_status_check
            CHECK (
                status IN (
                    'draft',
                    'in_progress',
                    'pending_parent',
                    'pending_doctor_review',
                    'reviewed',
                    'cancelled'
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('screening_sessions');
    }
};