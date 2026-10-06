<?php

namespace App\Services\Scoring;

final readonly class ScoringResult
{
    /**
     * @param array<string, int> $scores
     * @param array<string, string> $categories
     */
    public function __construct(
        public string $instrumentCode,
        public array $scores,
        public array $categories,
        public ?string $recommendation = null,
    ) {
    }

    /**
     * @return array{
     *     instrument_code: string,
     *     scores: array<string, int>,
     *     categories: array<string, string>,
     *     recommendation: string|null
     * }
     */
    public function toArray(): array
    {
        return [
            'instrument_code' => $this->instrumentCode,
            'scores' => $this->scores,
            'categories' => $this->categories,
            'recommendation' => $this->recommendation,
        ];
    }
}