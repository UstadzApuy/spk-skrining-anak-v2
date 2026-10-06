<?php

namespace App\Services\Scoring;

use InvalidArgumentException;

final class SdqScorer implements ScorerInterface
{
    /**
     * Item pada subskala SDQ.
     */
    private const EMOTIONAL_ITEMS = [3, 8, 13, 16, 24];

    private const CONDUCT_ITEMS = [5, 7, 12, 18, 22];

    private const HYPERACTIVITY_ITEMS = [2, 10, 15, 21, 25];

    private const PEER_ITEMS = [6, 11, 14, 19, 23];

    private const PROSOCIAL_ITEMS = [1, 4, 9, 17, 20];

    /**
     * Item yang menggunakan reverse scoring.
     */
    private const REVERSE_ITEMS = [7, 11, 14, 21, 25];

    public function instrumentCode(): string
    {
        return 'SDQ';
    }

    /**
     * @param array<string, mixed> $answers
     * @param array<string, mixed> $context
     */
    public function score(
        array $answers,
        array $context = []
    ): ScoringResult {
        if (count($answers) !== 25) {
            throw new InvalidArgumentException(
                'SDQ harus memiliki tepat 25 jawaban.'
            );
        }

        foreach ($answers as $answer) {
            if (!is_int($answer) || $answer < 0 || $answer > 2) {
                throw new InvalidArgumentException(
                    'Setiap jawaban SDQ harus berupa bilangan bulat 0 sampai 2.'
                );
            }
        }

        $itemScores = [];

        foreach ($answers as $index => $answer) {
            $itemNumber = $index + 1;

            $itemScores[$itemNumber] = in_array(
                $itemNumber,
                self::REVERSE_ITEMS,
                true
            )
                ? 2 - $answer
                : $answer;
        }

        $emotional = $this->sumItems(
            $itemScores,
            self::EMOTIONAL_ITEMS
        );

        $conduct = $this->sumItems(
            $itemScores,
            self::CONDUCT_ITEMS
        );

        $hyperactivity = $this->sumItems(
            $itemScores,
            self::HYPERACTIVITY_ITEMS
        );

        $peer = $this->sumItems(
            $itemScores,
            self::PEER_ITEMS
        );

        $prosocial = $this->sumItems(
            $itemScores,
            self::PROSOCIAL_ITEMS
        );

        $totalDifficulties =
            $emotional
            + $conduct
            + $hyperactivity
            + $peer;

        return new ScoringResult(
            instrumentCode: $this->instrumentCode(),
            scores: [
                'emotional' => $emotional,
                'conduct' => $conduct,
                'hyperactivity' => $hyperactivity,
                'peer' => $peer,
                'total_difficulties' => $totalDifficulties,
                'prosocial' => $prosocial,
            ],
            categories: [
                'emotional' => $this->categorizeEmotional($emotional),
                'conduct' => $this->categorizeConduct($conduct),
                'hyperactivity' => $this->categorizeHyperactivity(
                    $hyperactivity
                ),
                'peer' => $this->categorizePeer($peer),
                'total_difficulties' => $this->categorizeTotalDifficulties(
                    $totalDifficulties
                ),
                'prosocial' => $this->categorizeProsocial($prosocial),
            ],
            recommendation: null,
        );
    }

    /**
     * @param array<int, int> $itemScores
     * @param array<int, int> $items
     */
    private function sumItems(
        array $itemScores,
        array $items
    ): int {
        $total = 0;

        foreach ($items as $itemNumber) {
            $total += $itemScores[$itemNumber];
        }

        return $total;
    }

    private function categorizeEmotional(int $score): string
    {
        return match (true) {
            $score <= 3 => 'normal',
            $score === 4 => 'ambang_borderline',
            default => 'abnormal',
        };
    }

    private function categorizeConduct(int $score): string
    {
        return match (true) {
            $score <= 2 => 'normal',
            $score === 3 => 'ambang_borderline',
            default => 'abnormal',
        };
    }

    private function categorizeHyperactivity(int $score): string
    {
        return match (true) {
            $score <= 5 => 'normal',
            $score === 6 => 'ambang_borderline',
            default => 'abnormal',
        };
    }

    private function categorizePeer(int $score): string
    {
        return match (true) {
            $score <= 2 => 'normal',
            $score === 3 => 'ambang_borderline',
            default => 'abnormal',
        };
    }

    private function categorizeTotalDifficulties(int $score): string
    {
        return match (true) {
            $score <= 13 => 'normal',
            $score <= 15 => 'ambang_borderline',
            default => 'abnormal',
        };
    }

    private function categorizeProsocial(int $score): string
    {
        return match (true) {
            $score >= 6 => 'normal',
            $score === 5 => 'ambang_borderline',
            default => 'abnormal',
        };
    }
}