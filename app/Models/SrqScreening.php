<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SrqScreening extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'screening_session_id',
        'answers',
        'score',
        'depression_score',
        'anxiety_score',
        'somatic_score',
        'cognitive_score',
        'energy_score',
        'category',
        'recommendation',
    ];

    /**
     * Get the screening session associated with this SRQ-20 result.
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
            'score' => 'integer',
            'depression_score' => 'integer',
            'anxiety_score' => 'integer',
            'somatic_score' => 'integer',
            'cognitive_score' => 'integer',
            'energy_score' => 'integer',
        ];
    }
}