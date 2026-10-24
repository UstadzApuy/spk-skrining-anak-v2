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

    public function test_clinical_symptom_subscales_are_calculated_correctly(): void
    {
        $answers = array_fill(0, 20, false);
        // Depresi: 6, 9, 10, 14, 15, 16, 17 (index 5, 8, 9, 13, 14, 15, 16)
        $answers[5] = true; // item 6
        $answers[8] = true; // item 9
        $answers[16] = true; // item 17

        // Cemas: 3, 4, 5 (index 2, 3, 4)
        $answers[2] = true; // item 3
        $answers[3] = true; // item 4

        // Somatik: 1, 2, 7, 19 (index 0, 1, 6, 18)
        $answers[0] = true; // item 1
        $answers[6] = true; // item 7
        $answers[18] = true; // item 19

        // Kognitif: 8, 12, 13 (index 7, 11, 12)
        $answers[7] = true; // item 8
        $answers[11] = true; // item 12

        // Penurunan Energi: 8, 11, 12, 13, 18, 20 (index 7, 10, 11, 12, 17, 19)
        // items 8 and 12 are already true
        $answers[19] = true; // item 20

        $result = (new SrqScorer())->score($answers);

        $this->assertSame(11, $result->scores['total']);
        $this->assertSame(3, $result->scores['depression']);
        $this->assertSame(2, $result->scores['anxiety']);
        $this->assertSame(3, $result->scores['somatic']);
        $this->assertSame(2, $result->scores['cognitive']);
        $this->assertSame(3, $result->scores['energy']);
        $this->assertSame('gangguan_mental_emosional_distres', $result->categories['overall']);
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
