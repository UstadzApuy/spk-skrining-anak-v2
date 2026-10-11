<?php

namespace Tests\Unit;

use App\Services\Scoring\SdqScorer;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class SdqScorerTest extends TestCase
{
    public function test_total_difficulties_category_uses_agreed_thresholds(): void
    {
        $scorer = new SdqScorer();

        $this->assertSame(
            'normal',
            $scorer->score($this->answersWithTotalScore(13))
                ->categories['total_difficulties']
        );

        $this->assertSame(
            'ambang_borderline',
            $scorer->score($this->answersWithTotalScore(14))
                ->categories['total_difficulties']
        );

        $this->assertSame(
            'ambang_borderline',
            $scorer->score($this->answersWithTotalScore(15))
                ->categories['total_difficulties']
        );

        $this->assertSame(
            'abnormal',
            $scorer->score($this->answersWithTotalScore(16))
                ->categories['total_difficulties']
        );
    }

    public function test_conduct_category_uses_agreed_thresholds(): void
    {
        $scorer = new SdqScorer();

        $this->assertSame(
            'normal',
            $scorer->score($this->answersWithConductScore(2))
                ->categories['conduct']
        );

        $this->assertSame(
            'ambang_borderline',
            $scorer->score($this->answersWithConductScore(3))
                ->categories['conduct']
        );

        $this->assertSame(
            'abnormal',
            $scorer->score($this->answersWithConductScore(4))
                ->categories['conduct']
        );
    }

    public function test_sdq_requires_exactly_25_answers(): void
    {
        $this->expectException(InvalidArgumentException::class);

        (new SdqScorer())->score(array_fill(0, 24, 0));
    }

    public function test_sdq_answers_must_be_integers_between_zero_and_two(): void
    {
        $answers = array_fill(0, 25, 0);
        $answers[0] = 3;

        $this->expectException(InvalidArgumentException::class);

        (new SdqScorer())->score($answers);
    }

    /**
     * Build 25 raw answers from the desired scored values.
     *
     * @param array<int, int> $itemScores One-based item numbers and scores.
     * @return array<int, int>
     */
    private function answersWithItemScores(array $itemScores): array
    {
        $reverseItems = [7, 11, 14, 21, 25];
        $answers = [];

        for ($item = 1; $item <= 25; $item++) {
            $score = $itemScores[$item] ?? 0;

            $answers[] = in_array($item, $reverseItems, true)
                ? 2 - $score
                : $score;
        }

        return $answers;
    }

    /**
     * @return array<int, int>
     */
    private function answersWithTotalScore(int $total): array
    {
        $items = [
            3, 8, 13, 16, 24,
            5, 7, 12, 18, 22,
            2, 10, 15, 21, 25,
            6, 11, 14, 19, 23,
        ];

        $itemScores = [];

        foreach ($items as $item) {
            $itemScores[$item] = min(2, $total);
            $total -= $itemScores[$item];
        }

        return $this->answersWithItemScores($itemScores);
    }

    /**
     * @return array<int, int>
     */
    private function answersWithConductScore(int $total): array
    {
        $itemScores = [];

        foreach ([5, 7, 12, 18, 22] as $item) {
            $itemScores[$item] = min(2, $total);
            $total -= $itemScores[$item];
        }

        return $this->answersWithItemScores($itemScores);
    }
}
