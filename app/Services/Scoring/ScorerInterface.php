<?php

namespace App\Services\Scoring;

interface ScorerInterface
{
    /**
     * Return the instrument code handled by this scorer.
     */
    public function instrumentCode(): string;

    /**
     * Calculate the screening result from the provided answers and context.
     *
     * @param array<string, mixed> $answers
     * @param array<string, mixed> $context
     */
    public function score(
        array $answers,
        array $context = []
    ): ScoringResult;
}