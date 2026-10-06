<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MchatScreening extends Model
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
        'category',
        'recommendation',
    ];

    /**
     * Get the screening session associated with this M-CHAT-R result.
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
        ];
    }
}