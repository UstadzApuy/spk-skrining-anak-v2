<?php

namespace App\Http\Controllers\Concerns;

use App\Models\ScreeningSession;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

trait HandlesParentQuestionnaireFlow
{
    /**
     * Ensure the authenticated nurse owns the target screening session.
     */
    protected function ensureNurseOwnsSession(
        Request $request,
        ScreeningSession $screeningSession
    ): void {
        $user = $request->user();

        abort_unless(
            $user->role?->name === 'perawat',
            403,
            'Akses tidak diizinkan.'
        );

        $nurse = $user->nurse;

        abort_unless(
            $nurse,
            403,
            'Akun perawat belum memiliki profil perawat.'
        );

        abort_unless(
            (int) $screeningSession->nurse_id === (int) $nurse->id,
            403,
            'Akun perawat tidak memiliki akses ke sesi skrining ini.'
        );
    }

    /**
     * Render the parent-friendly completion page without exposing scores.
     */
    protected function renderParentCompletion(
        ScreeningSession $screeningSession,
        string $completedCode
    ): Response {
        $screeningSession->load([
            'patient:id,name,medical_record_number',
        ]);

        return Inertia::render(
            'ScreeningSessions/ParentQuestionnaireCompleted',
            [
                'session' => [
                    'id' => $screeningSession->id,
                    'patient' => $screeningSession->patient,
                ],
                'completedInstrument' => $this->describeParentInstrument(
                    $completedCode
                ),
                'nextInstrument' => $this->resolveNextParentInstrument(
                    $screeningSession,
                    $completedCode
                ),
            ]
        );
    }

    /**
     * Resolve the remaining unfinished parent questionnaire, if any.
     *
     * @return array{code: string, short_label: string, label: string, url: string}|null
     */
    private function resolveNextParentInstrument(
        ScreeningSession $screeningSession,
        string $completedCode
    ): ?array {
        $otherCode = $completedCode === 'SDQ' ? 'SRQ' : 'SDQ';

        if (
            $otherCode === 'SDQ'
            && ($screeningSession->age_months < 48
                || $screeningSession->age_months >= 132)
        ) {
            return null;
        }

        $hasPendingOther = $screeningSession
            ->screeningSessionInstruments()
            ->where('instrument_code', $otherCode)
            ->whereNotIn('status', ['completed', 'cancelled'])
            ->exists();

        if (! $hasPendingOther) {
            return null;
        }

        $routeName = $otherCode === 'SDQ'
            ? 'screening-sessions.sdq.create'
            : 'screening-sessions.srq.create';

        return [
            ...$this->describeParentInstrument($otherCode),
            'url' => route($routeName, $screeningSession, false),
        ];
    }

    /**
     * @return array{code: string, short_label: string, label: string}
     */
    private function describeParentInstrument(string $code): array
    {
        if ($code === 'SDQ') {
            return [
                'code' => 'SDQ',
                'short_label' => 'SDQ',
                'label' => 'SDQ (Kekuatan & Kesulitan Anak)',
            ];
        }

        return [
            'code' => 'SRQ',
            'short_label' => 'SRQ-20',
            'label' => 'SRQ-20 (Kesehatan Mental Orang Tua)',
        ];
    }
}
