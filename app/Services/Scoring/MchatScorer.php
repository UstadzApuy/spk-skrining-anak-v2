<?php

namespace App\Services\Scoring;

use InvalidArgumentException;

final class MchatScorer implements ScorerInterface
{
    /**
     * Items where the response "Tidak" is scored as 1.
     */
    private const NEGATIVE_SCORED_ITEMS = [
        1,
        3,
        4,
        6,
        7,
        8,
        9,
        10,
        11,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
    ];

    public function instrumentCode(): string
    {
        return 'MCHAT';
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
                'M-CHAT harus memiliki tepat 20 jawaban.'
            );
        }

        foreach ($answers as $answer) {
            if (!is_bool($answer)) {
                throw new InvalidArgumentException(
                    'Setiap jawaban M-CHAT harus berupa boolean.'
                );
            }
        }

        $score = 0;

        foreach (self::NEGATIVE_SCORED_ITEMS as $itemNumber) {
            $index = $itemNumber - 1;

            if ($answers[$index] === false) {
                $score++;
            }
        }

        foreach ([2, 5, 12] as $itemNumber) {
            $index = $itemNumber - 1;

            if ($answers[$index] === true) {
                $score++;
            }
        }

        $category = match (true) {
            $score <= 2 => 'risiko_rendah',
            default => 'risiko_sedang_tinggi',
        };

        $recommendation = match ($category) {
            'risiko_rendah' =>
                'Lanjutkan stimulasi dan jadwalkan kunjungan berikutnya.',
            'risiko_sedang_tinggi' =>
                'Rujuk ke RS tumbuh kembang level 1 untuk pemeriksaan lebih lanjut.',
        };

        return new ScoringResult(
            instrumentCode: $this->instrumentCode(),
            scores: [
                'total' => $score,
            ],
            categories: [
                'overall' => $category,
            ],
            recommendation: $recommendation,
        );
    }
}