<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('screening_interpretations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('screening_session_id')
                ->constrained('screening_sessions')
                ->onDelete('cascade');
            $table->string('instrument_code', 20);
            $table->foreignId('doctor_id')
                ->constrained('doctors')
                ->onDelete('restrict');
            $table->text('clinical_notes')->nullable();
            $table->string('follow_up_decision', 100)->nullable();
            $table->text('follow_up_notes')->nullable();
            $table->string('status', 30)->default('draft');
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->unique(
                ['screening_session_id', 'instrument_code'],
                'uq_session_instrument_interpretation'
            );
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('screening_interpretations');
    }
};
