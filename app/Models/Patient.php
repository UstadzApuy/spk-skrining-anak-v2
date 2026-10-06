<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Patient extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'parent_guardian_id',
        'medical_record_number',
        'name',
        'birth_date',
        'gender',
        'guardian_relationship',
        'is_premature',
        'gestational_age_weeks',
        'is_active',
    ];

    /**
     * Get the parent/guardian associated with this patient.
     */
    public function parentGuardian(): BelongsTo
    {
        return $this->belongsTo(ParentGuardian::class);
    }

    /**
     * Get the screening sessions for this patient.
     */
    public function screeningSessions(): HasMany
    {
        return $this->hasMany(ScreeningSession::class);
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'is_premature' => 'boolean',
            'gestational_age_weeks' => 'integer',
            'is_active' => 'boolean',
        ];
    }
}