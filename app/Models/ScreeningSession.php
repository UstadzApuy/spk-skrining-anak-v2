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
        'status',
        'notes',
        'doctor_notes',
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
     * Get the instruments selected for this screening session.
     */
    public function screeningSessionInstruments(): HasMany
    {
        return $this->hasMany(ScreeningSessionInstrument::class);
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
        ];
    }
}