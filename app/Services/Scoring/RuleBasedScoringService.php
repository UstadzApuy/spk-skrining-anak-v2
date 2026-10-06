<?php

namespace App\Services\Scoring;

use InvalidArgumentException;

final class RuleBasedScoringService
{
    /**
     * @var array<string, ScorerInterface>
     */
    private array $scorers = [];

    /**
     * @param iterable<ScorerInterface> $scorers
     */
    public function __construct(iterable $scorers = [])
    {
        foreach ($scorers as $scorer) {
            $this->register($scorer);
        }
    }

    /**
     * Register a scorer by its instrument code.
     */
    public function register(ScorerInterface $scorer): void
    {
        $instrumentCode = strtoupper($scorer->instrumentCode());

        if (isset($this->scorers[$instrumentCode])) {
            throw new InvalidArgumentException(
                "Scorer untuk instrumen {$instrumentCode} sudah terdaftar."
            );
        }

        $this->scorers[$instrumentCode] = $scorer;
    }

    /**
     * Check whether a scorer is available for the instrument.
     */
    public function supports(string $instrumentCode): bool
    {
        return isset($this->scorers[strtoupper($instrumentCode)]);
    }

    /**
     * Calculate the result using the scorer registered for the instrument.
     *
     * @param array<string, mixed> $answers
     * @param array<string, mixed> $context
     */
    public function score(
        string $instrumentCode,
        array $answers,
        array $context = []
    ): ScoringResult {
        $instrumentCode = strtoupper($instrumentCode);

        if (!$this->supports($instrumentCode)) {
            throw new InvalidArgumentException(
                "Scorer untuk instrumen {$instrumentCode} belum tersedia."
            );
        }

        return $this->scorers[$instrumentCode]->score(
            $answers,
            $context
        );
    }
}