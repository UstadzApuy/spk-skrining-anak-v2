<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Nurse extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'registration_number',
    ];

    /**
     * Get the user account associated with this nurse.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the screening sessions handled by this nurse.
     */
    public function screeningSessions(): HasMany
    {
        return $this->hasMany(ScreeningSession::class);
    }
}