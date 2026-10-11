<?php

namespace App\Services;

use DateTimeImmutable;
use InvalidArgumentException;

class KpspAgeCalculator
{
    /**
     * KPSP form age groups specified in the SDIDTK guide.
     *
     * @var list<int>
     */
    private const KPSP_FORM_AGES = [
        3, 6, 9, 12, 15, 18, 21, 24,
        30, 36, 42, 48, 54, 60, 66, 72,
    ];

    /**
     * Calculate the child's age and determine the appropriate KPSP form.
     *
     * @return array{
     *     age: array{years: int, months: int, days: int},
     *     age_months: int,
     *     form_age_months: int|null
     * }
     */
    public function calculate(
        string $birthDate,
        string $screeningDate,
        bool $isPremature,
        ?int $gestationalAgeWeeks,
    ): array {
        $birth = new DateTimeImmutable($birthDate);
        $screening = new DateTimeImmutable($screeningDate);

        if ($birth > $screening) {
            throw new InvalidArgumentException(
                'Tanggal lahir tidak boleh setelah tanggal pemeriksaan.'
            );
        }

        $age = $this->calculateChronologicalAge($birth, $screening);

        if ($isPremature && $age['years'] < 2) {
            if (
                $gestationalAgeWeeks === null
                || $gestationalAgeWeeks < 1
                || $gestationalAgeWeeks > 40
            ) {
                throw new InvalidArgumentException(
                    'Usia kehamilan harus diisi antara 1 dan 40 minggu.'
                );
            }

            if ($gestationalAgeWeeks < 38) {
                $correctionWeeks = 40 - $gestationalAgeWeeks;

                // Follow the SDIDTK example: 4 weeks = 1 month,
                // with the remaining weeks converted to days.
                $correctionMonths = intdiv($correctionWeeks, 4);
                $correctionDays = ($correctionWeeks % 4) * 7;

                $age = $this->subtractAge(
                    $age,
                    $correctionMonths,
                    $correctionDays,
                );
            }
        }

        $ageMonths = ($age['years'] * 12) + $age['months'];

        // Round up only for KPSP form selection when remaining
        // days are greater than 16. Do not alter the recorded age.
        $formSelectionMonths = $ageMonths
            + ($age['days'] > 16 ? 1 : 0);

        $formAgeMonths = $this->selectKpspFormAge(
            $formSelectionMonths
        );

        return [
            'age' => $age,
            'age_months' => $ageMonths,
            'form_age_months' => $formAgeMonths,
        ];
    }

    /**
     * Calculate chronological age using the SDIDTK borrowing convention.
     *
     * One borrowed month is treated as 30 days; one borrowed year
     * is treated as 12 months.
     *
     * @return array{years: int, months: int, days: int}
     */
    private function calculateChronologicalAge(
        DateTimeImmutable $birth,
        DateTimeImmutable $screening,
    ): array {
        $years = (int) $screening->format('Y')
            - (int) $birth->format('Y');

        $months = (int) $screening->format('n')
            - (int) $birth->format('n');

        $days = (int) $screening->format('j')
            - (int) $birth->format('j');

        if ($days < 0) {
            $days += 30;
            $months--;
        }

        if ($months < 0) {
            $months += 12;
            $years--;
        }

        return [
            'years' => $years,
            'months' => $months,
            'days' => $days,
        ];
    }

    /**
     * Subtract a prematurity correction from an age.
     *
     * @param array{years: int, months: int, days: int} $age
     * @return array{years: int, months: int, days: int}
     */
    private function subtractAge(
        array $age,
        int $correctionMonths,
        int $correctionDays,
    ): array {
        $years = $age['years'];
        $months = $age['months'];
        $days = $age['days'] - $correctionDays;

        if ($days < 0) {
            $days += 30;
            $months--;
        }

        $months -= $correctionMonths;

        if ($months < 0) {
            $months += 12;
            $years--;
        }

        // Corrected age cannot be represented as a negative age.
        if ($years < 0) {
            return [
                'years' => 0,
                'months' => 0,
                'days' => 0,
            ];
        }

        return [
            'years' => $years,
            'months' => $months,
            'days' => $days,
        ];
    }

    /**
     * Select an exact or younger available KPSP age group.
     */
    private function selectKpspFormAge(int $ageMonths): ?int
    {
        $selectedAge = null;

        foreach (self::KPSP_FORM_AGES as $formAge) {
            if ($formAge > $ageMonths) {
                break;
            }

            $selectedAge = $formAge;
        }

        return $selectedAge;
    }
}