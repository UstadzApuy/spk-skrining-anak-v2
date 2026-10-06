<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SdqScreening extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'screening_session_id',
        'answers',
        'emotional_score',
        'conduct_score',
        'hyperactivity_score',
        'peer_score',
        'total_difficulties_score',
        'prosocial_score',
        'total_difficulties_category',
        'prosocial_category',
        'recommendation',
    ];

    /**
     * Get the screening session associated with this SDQ result.
     */
    public function screeningSession(): BelongsTo
    {
        return $this->belongsTo(ScreeningSession::class);
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'answers' => 'array',
            'emotional_score' => 'integer',
            'conduct_score' => 'integer',
            'hyperactivity_score' => 'integer',
            'peer_score' => 'integer',
            'total_difficulties_score' => 'integer',
            'prosocial_score' => 'integer',
        ];
    }
}