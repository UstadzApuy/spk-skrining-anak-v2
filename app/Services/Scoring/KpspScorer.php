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

        $sdidtkCode = match ($category) {
            'sesuai_umur' => 'Ds',
            'meragukan' => 'Dm',
            'kemungkinan_penyimpangan' => 'Dp',
        };

        $isReEvaluation = (bool) ($context['is_re_evaluation'] ?? false);

        // Alur Algoritma Bagan SDIDTK Kemenkes RI
        if ($sdidtkCode === 'Ds') {
            $clinicalAction = 'stimulasi_rutin_kia';
            $recommendation = 'Perkembangan anak Normal Sesuai Umur (Ds). Beri pujian pada orang tua. Lanjutkan stimulasi perkembangan di keluarga sesuai umur menggunakan buku KIA dan jadwalkan pemantauan berkala pada umur berikutnya.';
        } elseif ($sdidtkCode === 'Dm') {
            if ($isReEvaluation) {
                // Jika evaluasi ulang 2 minggu TETAP Dm -> Segera Rujuk ke RS
                $clinicalAction = 'rujuk_rs_spesialistik';
                $recommendation = 'Evaluasi ulang perkembangan setelah intervensi 2 minggu tetap Meragukan (Dm). Sesuai alur bagan SDIDTK Kemenkes RI, segera rujuk ke Rumah Sakit untuk penanganan spesialistik anak.';
            } else {
                // Pemeriksaan awal Dm -> Intervensi dini 2 minggu lalu evaluasi ulang
                $clinicalAction = 'intervensi_2_minggu';
                $recommendation = 'Perkembangan anak Meragukan (Dm). Lakukan intervensi dini perkembangan secara intensif selama 2 minggu terfokus pada domain yang belum tercapai, kemudian lakukan evaluasi ulang KPSP.';
            }
        } else {
            // Dp (Ada kemungkinan penyimpangan) -> Langsung Rujuk ke RS
            $clinicalAction = 'rujuk_rs_spesialistik';
            $recommendation = 'Ada kemungkinan penyimpangan perkembangan (Dp). Sesuai alur bagan SDIDTK Kemenkes RI, segera rujuk ke Rumah Sakit untuk penanganan spesialistik oleh dokter spesialis anak.';
        }

        $domainScores = null;
        if (!empty($context['form_age_months'])) {
            $domainScores = app(\App\Services\KpspCatalogService::class)->calculateDomainScores(
                (int) $context['form_age_months'],
                $answers
            );
        }

        $scores = [
            'total' => $score,
            'sdidtk_code' => $sdidtkCode,
            'clinical_action' => $clinicalAction,
            'is_re_evaluation' => $isReEvaluation,
        ];

        if ($domainScores !== null) {
            $scores['domain_scores'] = $domainScores;
        }

        return new ScoringResult(
            instrumentCode: $this->instrumentCode(),
            scores: $scores,
            categories: [
                'overall' => $category,
                'sdidtk_code' => $sdidtkCode,
            ],
            recommendation: $recommendation,
        );
    }
}