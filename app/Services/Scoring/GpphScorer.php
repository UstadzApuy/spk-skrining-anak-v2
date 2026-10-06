<?php

namespace App\Services\Scoring;

use InvalidArgumentException;

final class GpphScorer implements ScorerInterface
{
    public function instrumentCode(): string
    {
        return 'GPPH';
    }

    /**
     * @param array<string, mixed> $answers
     * @param array<string, mixed> $context
     */
    public function score(
        array $answers,
        array $context = []
    ): ScoringResult {
        if (count($answers) !== 10) {
            throw new InvalidArgumentException(
                'GPPH harus memiliki tepat 10 jawaban.'
            );
        }

        foreach ($answers as $answer) {
            if (!is_int($answer) || $answer < 0 || $answer > 3) {
                throw new InvalidArgumentException(
                    'Setiap jawaban GPPH harus berupa bilangan bulat 0 sampai 3.'
                );
            }
        }

        $examinerDoubtful = $context['examiner_doubtful'] ?? false;

        if (!is_bool($examinerDoubtful)) {
            throw new InvalidArgumentException(
                'examiner_doubtful harus berupa boolean.'
            );
        }

        $score = array_sum($answers);

        $category = match (true) {
            $score >= 13 => 'kemungkinan_gpph',
            $examinerDoubtful => 'meragukan',
            default => 'normal',
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