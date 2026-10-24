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
        Schema::table('screening_sessions', function (Blueprint $table) {
            $table->foreignId('created_by_user_id')
                ->nullable()
                ->constrained('users')
                ->restrictOnDelete();
        });

        // Isi pembuat sesi lama berdasarkan akun perawat penanggung jawab.
        DB::statement("
            UPDATE screening_sessions AS ss
            SET created_by_user_id = n.user_id
            FROM nurses AS n
            WHERE ss.nurse_id = n.id
              AND ss.created_by_user_id IS NULL
        ");

        // Pastikan seluruh sesi lama berhasil dipetakan.
        if (DB::table('screening_sessions')
            ->whereNull('created_by_user_id')
            ->exists()) {
            throw new RuntimeException(
                'Migrasi dibatalkan: terdapat sesi yang belum memiliki pengguna pembuat.'
            );
        }

        // Semua sesi harus memiliki pembuat yang tercatat.
        DB::statement("
            ALTER TABLE screening_sessions
            ALTER COLUMN created_by_user_id SET NOT NULL
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('screening_sessions', function (Blueprint $table) {
            $table->dropForeign(['created_by_user_id']);
            $table->dropColumn('created_by_user_id');
        });
    }
};
