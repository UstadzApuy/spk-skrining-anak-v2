<?php

namespace App\Services\Scoring;

use InvalidArgumentException;

final class SrqScorer implements ScorerInterface
{
    public function instrumentCode(): string
    {
        return 'SRQ';
    }

    /**
     * @param array<string, mixed> $answers
     * @param array<string, mixed> $context
     */
    public function score(
        array $answers,
        array $context = []
    ): ScoringResult {
        if (count($answers) !== 20) {
            throw new InvalidArgumentException(
                'SRQ-20 harus memiliki tepat 20 jawaban.'
            );
        }

        foreach ($answers as $answer) {
            if (!is_bool($answer)) {
                throw new InvalidArgumentException(
                    'Setiap jawaban SRQ-20 harus berupa boolean.'
                );
            }
        }

        $score = count(
            array_filter(
                $answers,
                fn (bool $answer): bool => $answer
            )
        );

        $category = match (true) {
            $score >= 6 => 'gangguan_mental_emosional_distres',
            default => 'di_bawah_nilai_pisah',
        };

        return new ScoringResult(
            instrumentCode: $this->instrumentCode(),
            scores: [
                'total' => $score,
            ],
            categories: [
                'overall' => $category,
            ],
            recommendation: null,
        );
    }
}