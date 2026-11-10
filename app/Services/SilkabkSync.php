<?php

namespace App\Services;

use App\Models\Doctor;
use App\Models\Nurse;
use App\Models\ParentGuardian;
use App\Models\Patient;
use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Sinkronisasi satu arah: SILKABK (sistem utama) → SPK Skrining.
 *
 * - User SILKABK dibuat/diperbarui di SPK (dicocokkan lewat silkabk_user_id,
 *   lalu email), termasuk hash password sehingga akun yang sama bisa dipakai.
 * - Pasien SILKABK dibuat/diperbarui di SPK (dicocokkan lewat
 *   silkabk_patient_id, lalu nomor rekam medis). Pasien lama SPK tidak diubah.
 */
class SilkabkSync
{
    /** Pemetaan role SILKABK → role SPK. Role yang tidak ada = tidak punya akses. */
    public const ROLE_MAP = [
        'super_admin' => 'perawat',
        'psikolog'    => 'perawat',
        'dokter'      => 'dokter',
        'admin'       => 'administrator',
        'orang_tua'   => 'orang_tua',
    ];

    private function silkabk()
    {
        return DB::connection('silkabk');
    }

    public static function mapRole(?string $silkabkRole): ?string
    {
        return self::ROLE_MAP[$silkabkRole] ?? null;
    }

    /**
     * Sinkron satu user SILKABK ke SPK.
     *
     * @param  string|null  $fallbackRole  role SPK bila role SILKABK tidak punya pemetaan
     *                                     (dipakai untuk wali pasien → orang_tua)
     * @return User|null  null bila user tidak ditemukan atau tidak berhak akses
     */
    public function syncUser(int $silkabkUserId, ?string $fallbackRole = null): ?User
    {
        $row = $this->silkabk()->table('users')->where('id', $silkabkUserId)->first();

        if (! $row) {
            return null;
        }

        $roleName = self::mapRole($row->role) ?? $fallbackRole;

        if (! $roleName) {
            return null;
        }

        $role = Role::firstOrCreate(['name' => $roleName]);

        $user = User::where('silkabk_user_id', $row->id)->first()
            ?? User::whereRaw('LOWER(email) = ?', [Str::lower($row->email)])->first()
            ?? new User(['password' => Str::random(40)]);

        $user->forceFill([
            'name'            => $row->name,
            'email'           => $row->email,
            'role_id'         => $role->id,
            'silkabk_user_id' => $row->id,
        ])->save();

        // Salin hash password apa adanya (bypass cast "hashed") agar password
        // SILKABK juga berlaku di SPK. Akun nonaktif diberi password acak.
        DB::table('users')->where('id', $user->id)->update([
            'password' => $row->is_active ? $row->password : Hash::make(Str::random(40)),
        ]);

        $this->syncProfiles($user, $roleName, $row->id);

        return $user->refresh();
    }

    private function syncProfiles(User $user, string $roleName, int $silkabkUserId): void
    {
        if ($roleName === 'perawat') {
            Nurse::firstOrCreate(['user_id' => $user->id]);
        }

        if ($roleName === 'dokter') {
            Doctor::firstOrCreate(['user_id' => $user->id]);
        }

        $guardian = $this->silkabk()->table('parent_guardians')
            ->where('user_id', $silkabkUserId)
            ->first();

        if ($guardian || $roleName === 'orang_tua') {
            ParentGuardian::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'phone'   => $guardian->phone ?? null,
                    'address' => $guardian->address ?? null,
                ]
            );
        }
    }

    /**
     * Sinkron semua pasien SILKABK ke SPK.
     *
     * @return int jumlah pasien yang disinkron
     */
    public function syncPatients(): int
    {
        $rows = $this->silkabk()->table('patients as p')
            ->join('parent_guardians as g', 'g.id', '=', 'p.guardian_id')
            ->select('p.*', 'g.user_id as guardian_user_id', 'g.relationship as guardian_relationship')
            ->orderBy('p.id')
            ->get();

        $count = 0;

        DB::transaction(function () use ($rows, &$count) {
            $guardianCache = [];

            foreach ($rows as $row) {
                $guardianUserId = (int) $row->guardian_user_id;

                if (! array_key_exists($guardianUserId, $guardianCache)) {
                    $guardianCache[$guardianUserId] = $this->syncUser($guardianUserId, 'orang_tua')
                        ?->parentGuardian;
                }

                $parentGuardian = $guardianCache[$guardianUserId];

                if (! $parentGuardian) {
                    continue;
                }

                $patient = Patient::where('silkabk_patient_id', $row->id)->first()
                    ?? Patient::where('medical_record_number', $row->medical_record_number)->first()
                    ?? new Patient();

                $patient->forceFill([
                    'silkabk_patient_id'    => $row->id,
                    'parent_guardian_id'    => $parentGuardian->id,
                    'medical_record_number' => $row->medical_record_number,
                    'name'                  => $row->name,
                    'birth_date'            => $row->birth_date,
                    'gender'                => Str::upper(Str::substr($row->gender, 0, 1)),
                    'address'               => $row->address,
                    'guardian_relationship' => $row->guardian_relationship,
                    'is_active'             => (bool) $row->is_active,
                ])->save();

                $count++;
            }
        });

        return $count;
    }
}
