<?php

namespace App\Services\Scoring;

use InvalidArgumentException;

final class SrqScorer implements ScorerInterface
{
    /**
     * Item butir pertanyaan pada tiap subskala SRQ-20 (Riskesdas / Litbang Depkes RI / WHO):
     * - Gejala depresi: nomor 6, 9, 10, 14, 15, 16, dan 17.
     * - Gejala cemas: nomor 3, 4, dan 5.
     * - Gejala somatik: nomor 1, 2, 7, dan 19.
     * - Gejala kognitif: nomor 8, 12, dan 13.
     * - Gejala penurunan energi: nomor 8, 11, 12, 13, 18, dan 20.
     */
    public const DEPRESSION_ITEMS = [6, 9, 10, 14, 15, 16, 17];
    public const ANXIETY_ITEMS = [3, 4, 5];
    public const SOMATIC_ITEMS = [1, 2, 7, 19];
    public const COGNITIVE_ITEMS = [8, 12, 13];
    public const ENERGY_ITEMS = [8, 11, 12, 13, 18, 20];

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

        // Jawaban 0-indexed dipetakan ke nomor soal 1-based (1..20)
        $itemScores = [];
        foreach (array_values($answers) as $index => $answer) {
            $itemScores[$index + 1] = $answer ? 1 : 0;
        }

        $totalScore = array_sum($itemScores);
        $depressionScore = $this->sumItems($itemScores, self::DEPRESSION_ITEMS);
        $anxietyScore = $this->sumItems($itemScores, self::ANXIETY_ITEMS);
        $somaticScore = $this->sumItems($itemScores, self::SOMATIC_ITEMS);
        $cognitiveScore = $this->sumItems($itemScores, self::COGNITIVE_ITEMS);
        $energyScore = $this->sumItems($itemScores, self::ENERGY_ITEMS);

        $category = match (true) {
            $totalScore >= 6 => 'gangguan_mental_emosional_distres',
            default => 'di_bawah_nilai_pisah',
        };

        return new ScoringResult(
            instrumentCode: $this->instrumentCode(),
            scores: [
                'total' => $totalScore,
                'depression' => $depressionScore,
                'anxiety' => $anxietyScore,
                'somatic' => $somaticScore,
                'cognitive' => $cognitiveScore,
                'energy' => $energyScore,
            ],
            categories: [
                'overall' => $category,
                'depression' => $this->categorizeSubscale($depressionScore, count(self::DEPRESSION_ITEMS)),
                'anxiety' => $this->categorizeSubscale($anxietyScore, count(self::ANXIETY_ITEMS)),
                'somatic' => $this->categorizeSubscale($somaticScore, count(self::SOMATIC_ITEMS)),
                'cognitive' => $this->categorizeSubscale($cognitiveScore, count(self::COGNITIVE_ITEMS)),
                'energy' => $this->categorizeSubscale($energyScore, count(self::ENERGY_ITEMS)),
            ],
            recommendation: null,
        );
    }

    /**
     * @param array<int, int> $itemScores
     * @param array<int, int> $items
     */
    private function sumItems(array $itemScores, array $items): int
    {
        $sum = 0;
        foreach ($items as $itemNumber) {
            $sum += $itemScores[$itemNumber] ?? 0;
        }

        return $sum;
    }

    private function categorizeSubscale(int $score, int $max): string
    {
        if ($score === 0) {
            return 'tidak_ada_gejala';
        }
        if ($score >= (int) ceil($max / 2)) {
            return 'gejala_signifikan';
        }

        return 'gejala_ringan';
    }
}