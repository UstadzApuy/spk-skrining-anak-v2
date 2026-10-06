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
        Schema::create('patients', function (Blueprint $table) {
            $table->id();

            $table->foreignId('parent_guardian_id')
                ->constrained('parent_guardians')
                ->restrictOnDelete();

            $table->string('medical_record_number', 100)->unique();
            $table->string('name', 150);
            $table->date('birth_date');
            $table->string('gender', 1);

            $table->string('guardian_relationship', 50)->nullable();

            $table->boolean('is_premature')->default(false);
            $table->unsignedSmallInteger('gestational_age_weeks')->nullable();

            $table->boolean('is_active')->default(true);

            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE patients
            ADD CONSTRAINT patients_gender_check
            CHECK (gender IN ('L', 'P'))
        ");

        DB::statement("
            ALTER TABLE patients
            ADD CONSTRAINT patients_gestational_age_weeks_check
            CHECK (
                (
                    is_premature = FALSE
                    AND gestational_age_weeks IS NULL
                )
                OR
                (
                    is_premature = TRUE
                    AND gestational_age_weeks BETWEEN 20 AND 45
                )
            )
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('patients');
    }
};