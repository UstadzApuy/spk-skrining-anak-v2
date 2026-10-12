<?php

namespace Tests\Unit;

use App\Services\Scoring\SrqScorer;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class SrqScorerTest extends TestCase
{
    public function test_score_of_five_is_below_cutoff(): void
    {
        $result = (new SrqScorer())
            ->score($this->answersWithYesCount(5));

        $this->assertSame(5, $result->scores['total']);
        $this->assertSame(
            'di_bawah_nilai_pisah',
            $result->categories['overall']
        );
    }

    public function test_score_of_six_meets_screening_cutoff(): void
    {
        $result = (new SrqScorer())
            ->score($this->answersWithYesCount(6));

        $this->assertSame(6, $result->scores['total']);
        $this->assertSame(
            'gangguan_mental_emosional_distres',
            $result->categories['overall']
        );
    }

    public function test_srq_requires_exactly_twenty_answers(): void
    {
        $this->expectException(InvalidArgumentException::class);

        (new SrqScorer())->score(array_fill(0, 19, false));
    }

    public function test_srq_answers_must_be_boolean(): void
    {
        $answers = array_fill(0, 20, false);
        $answers[0] = 1;

        $this->expectException(InvalidArgumentException::class);

        (new SrqScorer())->score($answers);
    }

    /**
     * @return array<int, bool>
     */
    private function answersWithYesCount(int $yesCount): array
    {
        return array_merge(
            array_fill(0, $yesCount, true),
            array_fill(0, 20 - $yesCount, false)
        );
    }
}
