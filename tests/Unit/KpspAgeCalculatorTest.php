<?php

namespace Tests\Unit;

use App\Services\KpspAgeCalculator;
use Tests\TestCase;

class KpspAgeCalculatorTest extends TestCase
{
    public function test_it_does_not_round_up_when_age_is_16_days(): void
    {
        $result = app(KpspAgeCalculator::class)->calculate(
            '2026-04-25',
            '2026-10-11',
            false,
            null,
        );

        $this->assertSame([
            'years' => 0,
            'months' => 5,
            'days' => 16,
        ], $result['age']);

        $this->assertSame(5, $result['age_months']);
        $this->assertSame(3, $result['form_age_months']);
    }

    public function test_it_rounds_up_when_age_is_more_than_16_days(): void
    {
        $result = app(KpspAgeCalculator::class)->calculate(
            '2026-04-24',
            '2026-10-11',
            false,
            null,
        );

        $this->assertSame([
            'years' => 0,
            'months' => 5,
            'days' => 17,
        ], $result['age']);

        $this->assertSame(5, $result['age_months']);
        $this->assertSame(6, $result['form_age_months']);
    }

    public function test_it_corrects_age_for_prematurity_using_sdidtk_example(): void
    {
        $result = app(KpspAgeCalculator::class)->calculate(
            '2020-06-01',
            '2020-08-20',
            true,
            34,
        );

        $this->assertSame([
            'years' => 0,
            'months' => 1,
            'days' => 5,
        ], $result['age']);

        $this->assertSame(1, $result['age_months']);
        $this->assertNull($result['form_age_months']);
    }

    public function test_it_does_not_correct_prematurity_when_age_is_two_years(): void
    {
        $result = app(KpspAgeCalculator::class)->calculate(
            '2018-08-20',
            '2020-08-20',
            true,
            34,
        );

        $this->assertSame([
            'years' => 2,
            'months' => 0,
            'days' => 0,
        ], $result['age']);

        $this->assertSame(24, $result['age_months']);
        $this->assertSame(24, $result['form_age_months']);
    }
}