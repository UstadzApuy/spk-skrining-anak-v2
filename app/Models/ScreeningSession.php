<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ScreeningSession extends Model
{
    use HasFactory;
    
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'patient_id',
        'nurse_id',
        'doctor_id',
        'screening_date',
        'age_months',
        'status',
        'evaluation_type',
        'parent_session_id',
        'notes',
        'doctor_notes',
        'reviewed_at',
        'created_by_user_id',
        'case_type',
        'referral_source',
        'referral_target',
        'interventions',
        'recap_notes',
    ];

    /**
     * Get the patient associated with this screening session.
     */
    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    /**
     * Get the nurse who handled this screening session.
     */
    public function nurse(): BelongsTo
    {
        return $this->belongsTo(Nurse::class);
    }

    /**
     * Get the doctor who reviewed this screening session.
     */
    public function doctor(): BelongsTo
    {
        return $this->belongsTo(Doctor::class);
    }

    /**
     * Get the user who created this screening session.
     */
    public function createdByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by_user_id');
    }

    /**
     * Get the instruments selected for this screening session.
     */
    public function screeningSessionInstruments(): HasMany
    {
        return $this->hasMany(ScreeningSessionInstrument::class);
    }

    /**
     * Get the parent screening session if this session is a re-evaluation.
     */
    public function parentSession(): BelongsTo
    {
        return $this->belongsTo(ScreeningSession::class, 'parent_session_id');
    }

    /**
     * Get any re-evaluation screening sessions conducted for this session.
     */
    public function reEvaluations(): HasMany
    {
        return $this->hasMany(ScreeningSession::class, 'parent_session_id');
    }

    /**
     * Check if this session is a 2-week re-evaluation session.
     */
    public function isReEvaluation(): bool
    {
        return $this->evaluation_type === 'kpsp_re_evaluation_2_weeks' || $this->parent_session_id !== null;
    }

    /**
     * Get the KPSP screening result.
     */
    public function kpspScreening(): HasOne
    {
        return $this->hasOne(KpspScreening::class);
    }

    /**
     * Get the M-CHAT-R screening result.
     */
    public function mchatScreening(): HasOne
    {
        return $this->hasOne(MchatScreening::class);
    }

    /**
     * Get the GPPH screening result.
     */
    public function gpphScreening(): HasOne
    {
        return $this->hasOne(GpphScreening::class);
    }

    /**
     * Get the SDQ screening result.
     */
    public function sdqScreening(): HasOne
    {
        return $this->hasOne(SdqScreening::class);
    }

    /**
     * Get the SRQ-20 screening result.
     */
    public function srqScreening(): HasOne
    {
        return $this->hasOne(SrqScreening::class);
    }

    /**
     * Get the clinical interpretations recorded by the doctor.
     */
    public function screeningInterpretations(): HasMany
    {
        return $this->hasMany(ScreeningInterpretation::class);
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'screening_date' => 'date',
            'age_months' => 'integer',
            'reviewed_at' => 'datetime',
            'interventions' => 'array',
        ];
    }
}