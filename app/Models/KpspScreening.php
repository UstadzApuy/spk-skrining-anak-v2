<?php

namespace App\Models;

use App\Services\KpspCatalogService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KpspScreening extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'screening_session_id',
        'form_age_months',
        'answers',
        'score',
        'category',
        'sdidtk_code',
        'clinical_action',
        'is_re_evaluation',
        'recommendation',
        'domain_scores',
    ];

    /**
     * Get the screening session associated with this KPSP result.
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
            'form_age_months' => 'integer',
            'answers' => 'array',
            'score' => 'integer',
            'is_re_evaluation' => 'boolean',
            'domain_scores' => 'array',
        ];
    }

    /**
     * Get domain breakdown scores, computing on the fly if not yet set in database.
     *
     * @param mixed $value
     * @return array<string, mixed>
     */
    public function getDomainScoresAttribute($value): array
    {
        if (is_array($value) && !empty($value)) {
            return $value;
        }

        if (is_string($value)) {
            $decoded = json_decode($value, true);
            if (is_array($decoded) && !empty($decoded)) {
                return $decoded;
            }
        }

        if (!empty($this->form_age_months) && is_array($this->answers) && count($this->answers) === 10) {
            return app(KpspCatalogService::class)->calculateDomainScores(
                (int) $this->form_age_months,
                $this->answers
            );
        }

        return [];
    }
}