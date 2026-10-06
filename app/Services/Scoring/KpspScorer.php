<?php

namespace App\Services\Scoring;

use InvalidArgumentException;

final class KpspScorer implements ScorerInterface
{
    public function instrumentCode(): string
    {
        return 'KPSP';
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
                'KPSP harus memiliki tepat 10 jawaban.'
            );
        }

        foreach ($answers as $answer) {
            if (!is_bool($answer)) {
                throw new InvalidArgumentException(
                    'Setiap jawaban KPSP harus berupa boolean.'
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
            $score >= 9 => 'sesuai_umur',
            $score >= 7 => 'meragukan',
            default => 'kemungkinan_penyimpangan',
        };

        $recommendation = match ($category) {
            'sesuai_umur' =>
                'Lanjutkan stimulasi perkembangan sesuai usia anak.',
            'meragukan' =>
                'Berikan stimulasi pada aspek perkembangan yang belum tercapai dan lakukan evaluasi ulang sesuai jadwal.',
            'kemungkinan_penyimpangan' =>
                'Diperlukan tindak lanjut dan pemeriksaan lebih lanjut oleh tenaga kesehatan.',
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