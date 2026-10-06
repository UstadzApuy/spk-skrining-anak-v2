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
        Schema::create('screening_session_instruments', function (Blueprint $table) {
            $table->id();

            $table->foreignId('screening_session_id')
                ->constrained('screening_sessions')
                ->restrictOnDelete();

            /*
             * Kode instrumen yang dipilih dalam satu sesi skrining:
             * KPSP, MCHAT, GPPH, SDQ, atau SRQ.
             */
            $table->string('instrument_code', 20);

            /*
             * Status pengerjaan instrumen.
             */
            $table->string('status', 20)
                ->default('pending');

            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();

            $table->timestamps();

            /*
             * Satu instrumen hanya boleh muncul satu kali
             * dalam satu sesi skrining.
             */
            $table->unique(
                ['screening_session_id', 'instrument_code'],
                'screening_session_instruments_session_instrument_unique'
            );
        });

        DB::statement("
            ALTER TABLE screening_session_instruments
            ADD CONSTRAINT screening_session_instruments_code_check
            CHECK (
                instrument_code IN (
                    'KPSP',
                    'MCHAT',
                    'GPPH',
                    'SDQ',
                    'SRQ'
                )
            )
        ");

        DB::statement("
            ALTER TABLE screening_session_instruments
            ADD CONSTRAINT screening_session_instruments_status_check
            CHECK (
                status IN (
                    'pending',
                    'in_progress',
                    'completed',
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
        Schema::dropIfExists('screening_session_instruments');
    }
};