<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ParentGuardian extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'phone',
        'address',
    ];

    /**
     * Get the user account associated with this parent/guardian.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the patients associated with this parent/guardian.
     */
    public function patients(): HasMany
    {
        return $this->hasMany(Patient::class);
    }
}