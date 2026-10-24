<?php

namespace App\Services;

class KpspCatalogService
{
    /**
     * KPSP form age points specified in SDIDTK guide.
     *
     * @var list<int>
     */
    public const FORM_AGES = [
        3, 6, 9, 12, 15, 18, 21, 24,
        30, 36, 42, 48, 54, 60, 66, 72,
    ];

    /**
     * Get the list of available form age points.
     *
     * @return list<int>
     */
    public function getAvailableFormAges(): array
    {
        return self::FORM_AGES;
    }

    /**
     * Get the 10 questions for a specific KPSP form age, enriched with images and guidance notes.
     *
    /**
     * Get the 10 questions for a specific KPSP form age, enriched with images and guidance notes.
     *
     * @return list<array{number: int, text: string, domain: string, image?: ?string, image_ya?: ?string, image_tidak?: ?string, guidance_note?: string}>|null
     */
    public function getFormQuestions(int $formAgeMonths): ?array
    {
        $forms = $this->getAllForms();
        $questions = $forms[$formAgeMonths] ?? null;

        if ($questions === null) {
            return null;
        }

        $imageMap = $this->getQuestionImagesMap();
        $yaImageMap = $this->getQuestionYaImagesMap();
        $tidakImageMap = $this->getQuestionTidakImagesMap();

        return array_map(function ($q) use ($formAgeMonths, $imageMap, $yaImageMap, $tidakImageMap) {
            $key = "{$formAgeMonths}_{$q['number']}";

            $q['image'] = $imageMap[$key] ?? (file_exists(public_path("images/kpsp/kpsp_{$key}.png")) ? "/images/kpsp/kpsp_{$key}.png" : null);
            $q['image_ya'] = $yaImageMap[$key] ?? (file_exists(public_path("images/kpsp/kpsp_{$key}_ya.png")) ? "/images/kpsp/kpsp_{$key}_ya.png" : null);
            $q['image_tidak'] = $tidakImageMap[$key] ?? (file_exists(public_path("images/kpsp/kpsp_{$key}_tidak.png")) ? "/images/kpsp/kpsp_{$key}_tidak.png" : null);

            $q['guidance_note'] = $this->getQuestionGuidanceNote($q['domain'], $q['text']);

            return $q;
        }, $questions);
    }

    /**
     * Map of KPSP questions with official drawings from Kemenkes SDIDTK manual.
     *
     * @return array<string, string>
     */
    protected function getQuestionImagesMap(): array
    {
        return [
            '3_6' => '/images/kpsp/kpsp_3_6.png',
            '3_7' => '/images/kpsp/kpsp_3_7.png',
            '3_8' => '/images/kpsp/kpsp_3_8.png',
            '3_9' => '/images/kpsp/kpsp_3_9.png',
            '3_10' => '/images/kpsp/kpsp_3_10.png',
            '6_1' => '/images/kpsp/kpsp_6_1.png',
            '6_2' => '/images/kpsp/kpsp_6_2.png',
            '6_3' => '/images/kpsp/kpsp_6_3.png',
            '6_5' => '/images/kpsp/kpsp_6_5.png',
            '9_1' => '/images/kpsp/kpsp_9_1.png',
            '9_9' => '/images/kpsp/kpsp_9_9.png',
            '12_2' => '/images/kpsp/kpsp_12_2.png',
            '21_3' => '/images/kpsp/kpsp_21_3.png',
            '30_1' => '/images/kpsp/kpsp_30_1.png',
            '30_2' => '/images/kpsp/kpsp_30_2.png',
            '30_3' => '/images/kpsp/kpsp_30_3.png',
            '36_2' => '/images/kpsp/kpsp_36_2.png',
            '36_3' => '/images/kpsp/kpsp_36_3.png',
            '42_3' => '/images/kpsp/kpsp_42_3.png',
            '42_5' => '/images/kpsp/kpsp_42_5.png',
            '48_1' => '/images/kpsp/kpsp_48_1.png',
            '48_2' => '/images/kpsp/kpsp_48_2.png',
            '48_3' => '/images/kpsp/kpsp_48_3.png',
            '54_1' => '/images/kpsp/kpsp_54_1.png',
            '54_2' => '/images/kpsp/kpsp_54_2.png',
            '54_3' => '/images/kpsp/kpsp_54_3.png',
            '54_4' => '/images/kpsp/kpsp_54_4.png',
            '60_1' => '/images/kpsp/kpsp_60_1.png',
            '60_2' => '/images/kpsp/kpsp_60_2.png',
            '60_3' => '/images/kpsp/kpsp_60_3.png',
            '66_1' => '/images/kpsp/kpsp_66_1.png',
            '66_2' => '/images/kpsp/kpsp_66_2.png',
            '66_3' => '/images/kpsp/kpsp_66_3.png',
            '72_1' => '/images/kpsp/kpsp_72_1.png',
            '72_2' => '/images/kpsp/kpsp_72_2.png',
        ];
    }

    /**
     * Map of KPSP questions with specific sample drawing for 'Ya' answer.
     *
     * @return array<string, string>
     */
    protected function getQuestionYaImagesMap(): array
    {
        return [
            '30_2' => '/images/kpsp/kpsp_30_2_ya.png',
            '36_2' => '/images/kpsp/kpsp_36_2_ya.png',
            '42_1' => '/images/kpsp/kpsp_42_1_ya.png',
        ];
    }

    /**
     * Map of KPSP questions with specific sample drawing for 'Tidak' answer.
     *
     * @return array<string, string>
     */
    protected function getQuestionTidakImagesMap(): array
    {
        return [
            '30_2' => '/images/kpsp/kpsp_30_2_tidak.png',
            '36_2' => '/images/kpsp/kpsp_36_2_tidak.png',
            '42_1' => '/images/kpsp/kpsp_42_1_tidak.png',
        ];
    }

    /**
     * Provide specific observational guidance tailored to developmental domains.
     */
    protected function getQuestionGuidanceNote(string $domain, string $text): string
    {
        return match ($domain) {
            'Gerak kasar' => 'Lakukan pengamatan langsung pada aktivitas motorik kasar anak atau tanyakan pada orang tua/pengasuh. Pastikan anak dalam kondisi nyaman dan tidak lelah. Pilih Ya bila anak mampu melakukan tugas ini dengan stabil. Pilih Tidak bila anak belum mampu atau gerakannya belum terkendali.',
            'Gerak halus' => 'Sediakan alat bantu yang diminta (pensil, kertas, kubus, remah/kismis). Amati koordinasi tangan dan mata anak secara seksama. Berikan kesempatan anak mencoba hingga 2–3 kali tanpa membantu gerakannya. Pilih Ya jika anak berhasil menyelesaikan tugas sesuai kriteria. Pilih Tidak bila belum berhasil.',
            'Bicara dan bahasa' => 'Ajak anak berbicara, perhatikan respons vokal/verbal anak, atau tanyakan perbendaharaan kata kepada orang tua/pengasuh. Pilih Ya bila anak merespons atau mengeluarkan kata/kalimat sesuai petunjuk. Pilih Tidak bila anak belum mampu atau belum pernah menunjukkan kemampuan tersebut.',
            'Sosialisasi dan kemandirian' => 'Amati interaksi sosial anak saat berada di ruang periksa atau tanyakan kebiasaan sehari-hari kepada orang tua/pengasuh. Pilih Ya bila anak menunjukkan perilaku sosial/kemandirian tersebut. Pilih Tidak jika anak selalu membutuhkan bantuan penuh atau belum mampu melakukannya.',
            default => 'Lakukan evaluasi sesuai petunjuk butir pemeriksaan. Pilih Ya jika anak dapat atau pernah melakukan. Pilih Tidak bila anak belum dapat atau belum pernah.',
        };
    }

    /**
     * Get developmental guidance (milestones, stimulation, red flags)
     * matching the child's chronological / corrected age.
     *
     * @return array{
     *     group_key: string,
     *     label: string,
     *     min_months: int,
     *     max_months: int,
     *     gross_motor: list<string>,
     *     fine_motor: list<string>,
     *     speech_language: list<string>,
     *     social_independence: list<string>,
     *     stimulation: list<string>,
     *     red_flags: list<string>
     * }|null
     */
    public function getDevelopmentalGuidance(int $ageMonths): ?array
    {
        $allGuidance = $this->getAllGuidance();

        foreach ($allGuidance as $key => $data) {
            if ($ageMonths >= $data['min_months'] && $ageMonths <= $data['max_months']) {
                return array_merge(['group_key' => $key], $data);
            }
        }

        // If child is older than 72 months, provide the 60-72 group as closest reference
        if ($ageMonths > 72) {
            return array_merge(['group_key' => '60-72'], $allGuidance['60-72']);
        }

        return null;
    }

    /**
     * Calculate domain breakdown scores for a specific KPSP form age and answer set.
     * Evaluates child's performance across the 4 standard SDIDTK domains:
     * - Gerak kasar (Gross motor)
     * - Gerak halus (Fine motor)
     * - Bicara dan bahasa (Speech & language)
     * - Sosialisasi dan kemandirian (Social & independence)
     *
     * @param int $formAgeMonths
     * @param array<int, mixed> $answers
     * @return array{
     *     domains: array<string, array{
     *         key: string,
     *         name: string,
     *         score: int,
     *         total: int,
     *         percentage: float,
     *         status: string,
     *         status_label: string,
     *         missed_questions: list<array{number: int, text: string}>
     *     }>,
     *     lacking_domains: list<string>,
     *     optimal_domains: list<string>,
     *     all_optimal: bool
     * }
     */
    public function calculateDomainScores(int $formAgeMonths, array $answers): array
    {
        $allForms = $this->getAllForms();
        $questions = $allForms[(string) $formAgeMonths] ?? $allForms[$formAgeMonths] ?? null;

        $domainDefs = [
            'gerak_kasar' => [
                'name' => 'Gerak Kasar',
                'label' => 'Gerak kasar',
            ],
            'gerak_halus' => [
                'name' => 'Gerak Halus',
                'label' => 'Gerak halus',
            ],
            'bicara_bahasa' => [
                'name' => 'Bicara dan Bahasa',
                'label' => 'Bicara dan bahasa',
            ],
            'sosialisasi_kemandirian' => [
                'name' => 'Sosialisasi dan Kemandirian',
                'label' => 'Sosialisasi dan kemandirian',
            ],
        ];

        $domainResults = [];
        foreach ($domainDefs as $key => $def) {
            $domainResults[$key] = [
                'key' => $key,
                'name' => $def['name'],
                'score' => 0,
                'total' => 0,
                'percentage' => 0.0,
                'status' => 'sesuai',
                'status_label' => 'Sesuai (Optimal)',
                'missed_questions' => [],
            ];
        }

        if ($questions === null) {
            return [
                'domains' => $domainResults,
                'lacking_domains' => [],
                'optimal_domains' => [],
                'all_optimal' => true,
            ];
        }

        $flatAnswers = array_values($answers);

        foreach ($questions as $idx => $q) {
            $rawDomain = trim($q['domain'] ?? '');
            $matchedKey = null;

            foreach ($domainDefs as $key => $def) {
                if (strcasecmp($rawDomain, $def['label']) === 0) {
                    $matchedKey = $key;
                    break;
                }
            }

            if ($matchedKey === null) {
                $matchedKey = 'gerak_kasar';
            }

            $domainResults[$matchedKey]['total']++;

            $ans = $flatAnswers[$idx] ?? false;
            $isYes = in_array($ans, [true, 1, '1', 'true'], true);

            if ($isYes) {
                $domainResults[$matchedKey]['score']++;
            } else {
                $domainResults[$matchedKey]['missed_questions'][] = [
                    'number' => (int) ($q['number'] ?? ($idx + 1)),
                    'text' => (string) ($q['text'] ?? ''),
                ];
            }
        }

        $lackingDomains = [];
        $optimalDomains = [];

        foreach ($domainResults as $key => &$d) {
            if ($d['total'] > 0) {
                $d['percentage'] = round(($d['score'] / $d['total']) * 100, 1);
            } else {
                $d['percentage'] = 100.0;
            }

            if ($d['score'] < $d['total']) {
                $d['status'] = 'perlu_stimulasi';
                $d['status_label'] = 'Perlu Stimulasi';
                $lackingDomains[] = $d['name'];
            } else {
                $d['status'] = 'sesuai';
                $d['status_label'] = 'Sesuai (Optimal)';
                $optimalDomains[] = $d['name'];
            }
        }
        unset($d);

        return [
            'domains' => $domainResults,
            'lacking_domains' => $lackingDomains,
            'optimal_domains' => $optimalDomains,
            'all_optimal' => empty($lackingDomains),
        ];
    }

    /**
     * All 16 KPSP forms with 10 questions each, verified from KPSP.pdf.
     *
     * @return array<int, list<array{number: int, text: string, domain: string}>>
     */
    public function getAllForms(): array
    {
        return [
            "3" => [
                        [
                                    "number" => 1,
                                    "text" => "Pada saat bayi terlentang, apakah masing-masing lengan dan tungkai bergerak dengan mu dah? Jawab ‘Tidak’ bila salah satu atau kedua tungkai atau lengan bayi bergerak tak terarah atau tak terkenda li.",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Jangan membuat suara apapun. Pada saat bayi terlentang apakah ia melihat dan menatap wajah Anda?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Pada saat Anda mengajak bayi berbicara dan tersenyum, apakah ia tersenyum kembali kep ada Anda?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Apakah bayi dapat mengeluarkan suara-suara lain (mengoceh) selain menangis?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Apakah bayi suka tertawa keras walau tidak digelitik atau diraba-raba?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Ambil gulungan wool merah, lalu letakkan di atas wajah di depan mata bayi. Gerakkan w ool dari samping kiri ke kanan kepala atau sebaliknya. Apakah ia dapat mengikuti gerakan Anda dengan menggerakkan kepalanya dari kanan atau kiri ke tengah?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Ambil gulungan wool merah, lalu letakkan di atas wajah di depan mata bayi. Gerakkan w ool dari samping kiri ke kanan kepala atau sebaliknya. Apakah ia dapat mengikuti gerakan Anda dengan menggerakkan kepalanya dari satu sisi hampir sampai pada sisi yang lain?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Pada saat bayi tengkurap di alas yang datar, apakah ia dapat mengangkat kepalanya sep erti pada gambar?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Pada saat bayi tengkurap di alas yang datar, apakah ia dapat mengangkat kepalanya seh ingga membentuk sudut 45˚ seperti pada gambar?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Pada saat bayi tengkurap di alas yang datar, apakah ia dapat mengangkat kepalanya deng an tegak seperti pada gambar?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "6" => [
                        [
                                    "number" => 1,
                                    "text" => "Bayi diposisikan terlentang. Ambil gulungan wool merah, letakkan di atas waja h di depan mata bayi. Gerakkan wool dari samping kiri ke kanan kepala. Apakah ia dapat m engikuti gerakan Anda dengan menggerakkan kepala sepenuhnya dari satu ke sisi yang lai n?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Pada posisi bayi terlentang, pegang kedua tangannya lalu tarik perlahan ke po sisi duduk. Dapatkah bayi mempertahankan lehernya secara kaku seperti pada gambar? Jawab ‘Tidak’ bila kepala bayi jatuh kembali seperti gambar.",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Ketika bayi tengkurap di alas yang datar, apakah ia dapat mengangkat dada den gan kedua lengannya sebagai penyangga seperti pada gambar?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Dapatkah bayi mempertahankan posisi k epala dalam keadaan tegak dan stabil? Jawab ‘Tidak’ bila kepala bayi cenderung jatuh ke kanan, kiri, at au ke dadanya.",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Sentuhkan pensil di punggung tangan atau ujung jari bayi (jangan meletakkan di atas telapak tangan bayi). Apakah bayi dapat menggenggam pensil itu selama beberapa detik?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Dapatkah bayi mengarahkan matanya pada be nda kecil sebesar kacang, kismis atau uang logam? Jawab ‘Tidak’ jika ia tidak dapat mengarahkan ma tanya.",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Dapatkah bayi meraih mainan yang diletakka n agak jauh namun masih berada dalam jangkauan tangannya?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, pernahkah bayi berbalik paling sedikit 2 kali, dari terlentang ke tengkurap atau sebaliknya?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, pernahkah bayi mengeluarkan suara gembir a bernada tinggi atau memekik tetapi bukan menangis?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, pernahkah orang tua atau pengasuh melih at bayi tersenyum ketika melihat mainan yang lucu, gambar, atau binatang peliharaan pada saat ia bermain sendiri?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ]
            ],
            "9" => [
                        [
                                    "number" => 1,
                                    "text" => "Bayi dipangku orang tua atau pengasuh, Taruh kismis di atas meja. Dapatkah ba yi memungut dengan tangannya benda−benda kecil seperti kismis, kacang-kacangan, potongan biskuit dengan gerakan miring atau menggerapai seperti gambar?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Taruh 2 kubus di atas meja, buat agar bayi dapat memungut dan memegang kubus pada masing-masing tangannya. Dapatkah ia melakukannya?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Tarik perhatian bayi dengan memperliha tkan gulungan wool merah, kemudian jatuhkan ke lantai. Apakah bayi mencoba mencari benda tersebut, misa lnya mencari di bawah meja atau di belakang kursi?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Letakkan suatu mainan yang diinginkan bayi di luar jangkauannya, apakah ia mencoba mendapatkan mainan dengan mengulurkan lengan atau badannya?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah bayi menengok ke belakang sep erti mendengar kedatangan seseorang pada saat bayi sedang bermain sendiri dan seseorang diam-diam datan g berdiri di belakangnya? Suara keras tidak ikut dihitung. Jawab ‘Ya’ hanya jika melihat reaksinya terhadap s uara yang perlahan atau bisikan.",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat mengatakan 2 suku kata yang sama, misalnya => “Ma-ma”, “Da-da” atau “Pa-pa”? Jawab ‘Ya’ bila ia dapat mengeluarka n salah 1 suara tersebut.",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah bayi dapat makan kue kering s endiri?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh apakah pernah melihat bayi memindahka n mainan atau kue kering dari satu tangan ke tangan yang lain? Benda−benda panjang seperti send ok atau kerincingan bertangkai tidak ikut dinilai.",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Tanpa disangga oleh bantal, kursi atau dinding, dapatkah bayi duduk sendiri s elama 60 detik?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Jika Anda mengangkat bayi melalui ketiaknya ke posisi berdiri, dapatkah ia me nyangga sebagian berat badan dengan kedua kakinya? Jawab ‘Ya’ bila ia mencoba berdiri dan sebagian berat b adan tertumpu pada kedua kakinya.",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "12" => [
                        [
                                    "number" => 1,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Letakkan pensil di telapak tangan anak. Cob a ambil pensil tersebut dengan perlahan-lahan. Apakah anak menggenggam pensil dengan erat dan Anda merasa kesulitan mendapatkan pensil itu kembali?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Letakkan kismis di atas meja. Dapatkah anak memungut dengan tangannya benda−benda kecil seperti kismis, kacang−kacangan, poton gan biskuit dengan gerakan miring atau menggerapai seperti gambar?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Berikan 2 kubus kepada bayi. Tanpa bantuan, apakah anak dapat mempertemukan 2 kubus kecil yang ia pegang?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Sebut 2−3 kata yang dapat ditiru oleh anak (tidak perlu kata−kata yang lengkap). A pakah ia mencoba meniru kata-kata tadi?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada ibu atau pengasuh, apakah anak dapat mengangkat badannya ke posisi berdiri tanpa bantuan?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada ibu atau pengasuh, apakah anak dapat duduk sendiri tanpa bantuan d ari posisi tidur atau tengkurap?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada ibu atau pengasuh, apakah anak dapat memahami makna kata ’jangan’?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada ibu atau pengasuh, apakah anak akan mencari atau terlihat menghara pkan muncul kembali jika ibu atau pengasuh bersembunyi di belakang sesuatu atau di pojok, kemudian mun cul dan menghilang secara berulang-ulang di hadapan anak?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Tanyakan kepada ibu atau pengasuh, apakah anak dapat membedakan ibu atau pengasuh dengan orang yang belum ia kenal? Ia akan menunjukkan sikap malu-malu atau ragu-ragu pada saat permu laan bertemu dengan orang yang belum dikenalnya.",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Berdirikan anak. Apakah anak dapat berdiri dengan berpegangan pada kursi atau meja selama 30 detik atau lebih?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "15" => [
                        [
                                    "number" => 1,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Berikan 2 kubus kepada anak. Tanpa bantu an, apakah anak dapat mempertemukan 2 kubus kecil yang ia pegang?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Berikan sebuah kubus dan cangkir. Apakah anak dapat memasukkan 1 kubus ke dalam cangkir?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat berjalan dengan berp egangan?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat mengatakan ‘papa’ ke tika ia memanggil atau melihat ayahnya, atau mengatakan ‘mama’ jika memanggil atau melihat ibunya? Jaw mengatakan salah satu di antaranya.",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat mengucapkan 1 kata y ang bermakna selain ‘mama’, ‘papa’, atau nama panggilan orang?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat bertepuk tangan atau melambai-lambai tanpa bantuan? Jawab ‘Tidak’ bila ia membutuhkan bantuan.",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat menunjukkan apa yang diinginkannya tanpa menangis atau merengek? Jawab ‘Ya’ bila ia menunjuk, menarik atau mengeluarkan suara yang menyenangkan.",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Coba berdirikan anak. Apakah anak dapat berdiri sendiri tanpa berpegangan selam a 30 detik atau lebih?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Letakkan kubus di lantai, tanpa berpegangan atau menyentuh lantai, apakah anak dapat membungkuk untuk memungut kubus di lantai dan kemudian berdiri kembali?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Apakah anak dapat berjalan di sepanjang ruangan tanpa jatuh atau terhuyung-huyu ng?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "18" => [
                        [
                                    "number" => 1,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Berikan anak sebuah pensil dan kertas. Apak ah anak dapat mencoret- coret kertas tanpa bantuan atau petunjuk?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat menyebutkan sedikitnya 3 kata yang bermakna?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat menunjukkan apa yang di inginkannya tanpa menangis atau merengek?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat minum dari cangkir atau gelas sendiri tanpa banyak yang tumpah?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak suka meniru bila ibu atau pen gasuh sedang melakukan pekerjaan rumah tangga (merapikan mainan, menyapu, dll)?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Gelindingkan bola tenis ke arah anak. Apakah anak dapat menggelindingkan atau mele mpar bola tersebut kembali kepada Anda?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Letakkan kubus di lantai, tanpa berpegangan atau menyentuh lantai, apakah anak dap at membungkuk untuk memungut kubus di lantai dan kemudian berdiri kembali?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Minta anak untuk berjalan sepanjang ruangan. Dapatkah ia berjalan tanpa terhuyung- huyung atau terjatuh?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Dapatkah anak berjalan mundur minimal 5 langkah tanpa kehilangan keseimbangan?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Berikan anak perintah berikut ini dengan bantuan telunjuk atau isyarat => “Ambil kertas” “Ambil pensil” “Tutup pintu” Dapatkah anak melakukan perintah tersebut dengan bantuan telunjuk atau isyarat?",
                                    "domain" => "Bicara dan bahasa"
                        ]
            ],
            "21" => [
                        [
                                    "number" => 1,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Berikan anak sebuah pensil dan kertas. Apakah anak dapat mencoret- coret kertas tanpa bantuan atau petunjuk?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Minta anak untuk menyusun kubus. Apakah anak dapat menyusun 2 kubus?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Tunjukkan gambar di bawah pada anak dan minta ia untuk menunjuk gambar sesuai dengan yang Anda sebutkan namanya. Apakah anak dapat menunjuk mi nimal 1 gambar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Tanpa bimbingan, petunjuk, atau bantuan Anda, dapatkah anak menunjuk paling sedikit 1 bagian tubuhnya dengan benar (rambut, mata, hidung, mulut, at au bagian badan yang lain)?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat mengucapkan minimal 7 kata yang mempunyai arti (selain kata ‘mama’ dan ‘papa’)?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat minum dari cangkir atau gelas sendiri tanpa banyak yang tumpah?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak suka meniru bila ibu atau pengasuh sedang melakukan pekerjaan rumah tangga (merapikan mainan, menyapu, dll)?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat berlari tanpa terja tuh?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Letakkan kubus di lantai, tanpa berpegangan atau menyentuh lantai, apakah anak dapat membungkuk untuk memungut kubus di lantai dan kemudian berdiri kembali?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Dapatkah anak berjalan mundur minimal 5 langkah tanpa kehilangan keseimbangan?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "24" => [
                        [
                                    "number" => 1,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Berikan anak sebuah pensil dan kertas. Apaka h anak dapat mencoret- coret kertas tanpa bantuan atau petunjuk?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Minta anak untuk menyusun kubus. Apakah anak dapat menyusun 4 kubus?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Bayi dipangku orang tua atau pengasuh. Tanpa bimbingan, petunjuk, atau bantuan Anda , dapatkah anak menunjuk paling sedikit 2 bagian tubuhnya dengan benar (rambut, mata, hidung, mulut, atau ba gian badan yang lain)?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak mampu menggabungkan 2 kata ber beda ketika berbicara, misalnya “Minum susu” atau “Main bola”? “Terima kasih” dan “Da-dah” tida k termasuk.",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat melepas pakaiannya seper ti baju, rok, atau celana?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat makan dengan menggunakan sendok sendiri tanpa banyak yang tumpah?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat berlari tanpa terjatuh?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat berjalan naik tangga sen diri? Jawab ‘Ya’ jika ia naik tangga dengan posisi tegak atau berpegangan pada dinding atau pegangan tangga. tangga dengan merangkak, orang tua tidak memperbolehkan anak naik tangga, atau anak harus berpegangan pada seseorang.",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Letakkan bola tenis di depan kaki anak. Apakah ia dapat menendang ke depan tanpa be rpegangan pada apapun?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Ikuti perintah dengan seksama. Jangan memberi isyarat dengan telunjuk atau mata pa da saat memberikan perintah berikut ini => “Ambil kertas” “Ambil pensil” “Tutup pintu” Dapatkah anak melakukan perintah tersebut?",
                                    "domain" => "Bicara dan bahasa"
                        ]
            ],
            "30" => [
                        [
                                    "number" => 1,
                                    "text" => "Beri kubus di depan anak. Dapatkah anak menyusun 4 buah kubus menyerupai kereta api dengan cerobong asap (dicontohkan)?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Buat garis lurus ke bawah sepanjang sekurang-kurangnya 2,5 cm. Minta anak untuk menggambar garis lain di samping garis ini. Jawab ‘Ya’ bila ia menggambar garis seperti ini => Jawab ‘Tidak’ bila ia menggambar garis seperti ini =>",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Tanpa bimbingan, petunjuk, atau bantuan Anda, dapatkah anak menyebut 2 gambar d i antara gambar-gambar di bawah dengan benar? Menyebut dengan suara binatang tidak ikut dinilai.",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Tanpa bimbingan, petunjuk, atau bantuan Anda, dapatkah anak menunjuk 4 gambar d i antara gambar-gambar di atas ini dengan benar ketika Anda sebutkan namanya?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanpa bimbingan, petunjuk, atau bantuan Anda, dapatkah anak menunjuk paling sed ikit 6 bagian tubuhnya?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat memahami perintah ya ng terdiri dari 2 langkah, misalnya “Tolong ambil bola dan berikan kepada Ayah”?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak berpakaian sendiri seper ti baju, rok, celana (topi dan kaos kaki tidak ikut dinilai)?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak bermain peran, misalnya menyuapi boneka?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Letakkan bola tenis di depan kaki anak. Dapatkah anak menendang ke depan tanpa berpegangan pada apapun? Mendorong bola tidak ikut dinilai.",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Minta anak untuk melompat atau mengangkat kedua kakinya pada saat bersamaan. Da patkah ia melakukannya?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "36" => [
                        [
                                    "number" => 1,
                                    "text" => "Beri kubus di depan anak. Dapatkah anak menyusun 6 buah kubus satu persatu di atas k ubus yang lain tanpa menjatuhkan kubus tersebut?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Buat garis lurus ke bawah sepanjang sekurang-kurangnya 2,5 cm. Minta anak untuk meng gambar garis lain di samping garis ini. Jawab ‘Ya’ bila ia menggambar garis seperti ini => Jawab ‘Tidak’ bila ia menggambar garis seperti ini =>",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Tanpa bimbingan, petunjuk, atau bantuan Anda, dapatkah anak menyebut 4 gambar di ant ara gambar-gambar di bawah ini dengan benar? Menyebut dengan suara binatang tidak ikut dinilai.",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat memahami perintah yang te rdiri dari 2 langkah, misalnya “Tolong ambil bola dan berikan kepada Ayah”?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah sebagian dari bicara anak dapat dipa hami oleh orang asing (yang tidak bertemu setiap hari)?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak merangkai kalimat sederhana y ang terdiri dari minimal 3 kata, misalnya “Aku makan roti” atau ”Ibu minta susu”?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak menggosok gigi dengan bantuan ?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak mengenakan baju, celana, atau sepatu sendiri (tidak termasuk mengancing dan menali)?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Berikan kepada anak sebuah bola tenis. Minta ia untuk melemparkan ke arah dada Anda. Dapatkah anak melempar bola dengan lurus ke arah perut atau dada Anda dari jarak 1,5 meter?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Letakkan selembar kertas seukuran buku ini di atas lantai. Apakah anak dapat melompa ti bagian lebar kertas dengan mengangkat kedua kakinya secara bersamaan tanpa didahului lari?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "42" => [
                        [
                                    "number" => 1,
                                    "text" => "Buat garis lurus ke bawah sepanjang sekurang-kurangnya 2,5 cm. Minta anak untu k menggambar garis lain di samping garis ini. Jawab ‘Ya’ bila ia menggambar garis seperti ini => Jawab ‘Tidak’ bila ia menggambar garis seperti ini =>",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Beri kubus di depan anak. Dapatkah anak menyusun 8 buah kubus satu persatu di atas kubus yang lain tanpa menjatuhkannya?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Tunjukkan anak gambar di bawah ini dan tanyakan => “Mana yang dapat terbang?” “Mana yang dapat mengeong?” “Mana yang dapat bicara?” “Mana yang dapat menggonggong?” “Mana yang dapat meringkik?” Apakah anak dapat menunjuk 2 kegiatan yang sesuai?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Tanyakan kepada anak pertanyaan berikut ini satu persatu => “Apa yang kamu lakukan bila kedinginan?” Jawaban => pakai jaket, pakai selimut “Apa yang kamu lakukan bila kamu kelelahan?” Jawaban => tidur, berbaring, istira hat “Apa yang kamu lakukan bila kamu merasa lapar?” Jawaban => makan “Apa yang kamu lakukan bila kamu merasa haus?” Jawaban => minum Apakah anak dapat menjawab 3 pertanyaan dengan benar tanpa gerakan dan isyarat ?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Minta anak untuk menyebut 1 warna. Dapatkah anak menyebut 1 warna dengan benar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat mencuci tangannya sendiri dengan baik setelah makan?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak menyebut nama teman bermain d i luar rumah atau saudara yang tidak tinggal serumah?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak mengenakan kaos (T-shirt) tan pa dibantu?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Letakkan selembar kertas seukuran buku ini di atas lantai. Apakah anak dapat melompa ti bagian lebar kertas dengan mengangkat kedua kakinya secara bersamaan tanpa didahului lari?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Minta anak untuk berdiri 1 kaki tanpa berpegangan. Jika perlu tunjukkan caranya dan beri anak kesempatan sebanyak 3 kali. Dapatkah ia mempertahankan keseimbangan dalam waktu 1 detik atau le bih?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "48" => [
                        [
                                    "number" => 1,
                                    "text" => "Berikan contoh membuat jembatan dari 3 buah kubus, yaitu dengan meletakkan 2 kubus dengan sedikit jarak (kira kira satu jari), lalu letakkan balok ketiga di atas kedua balo k sehingga terbentuk seperti jembatan. Minta anak untuk melakukan. Dapatkan anak melakukannya?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Beri pensil dan kertas. Jangan membantu anak dan jangan menyebut lingkaran. Buatlah lingkaran di atas kertas tersebut. Minta anak menirunya. Dapatkah anak menggambar lingkaran?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Tunjukkan anak gambar di bawah ini dan tanyakan => - “Yang mana yang dapat terbang?” - “Yang mana yang dapat menggongg ong?” - “Yang mana yang dapat mengeong?” - “Yang mana yang dapat meringkik ?” - “Yang mana yang dapat bicara?” Apakah anak dapat menunjuk 2 kegiatan yang sesuai?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Dapatkah anak menyebut nama lengkapnya tanpa dibantu? Jawab ‘Tidak’ jika ia menyeb ut sebagian namanya atau ucapannya sulit dimengerti.",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Mengenal konsep angka satu Letakkan 5 kubus di atas meja dan selembar kertas di samping kubus. Katakan kepada anak “Ambil 1 kubus dan letakkan di atas kertas”. Setelah anak selesai meletakkan, tanyakan “Ada berapa ba nyak kubus di atas kertas?” Dapatkah anak melakukan dengan hanya mengambil satu kubus dan bisa menyebutkan “Sa tu”?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada anak pertanyaan di bawah satu persatu => “Apa kegunaan kursi?” Jawaban => untuk duduk “Apa kegunaan cangkir?” Jawaban => untuk minum “Apa kegunaan pensil?” Jawaban => untuk mencoret, menulis, menggambar Dapatkah anak menjawab ketiga pertanyaan terkait kegunaan benda tersebut dengan be nar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak mengikuti peraturan permainan saat bermain dengan teman-temannya (misal => ular tangga, petak umpet, dll)?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak mengenakan kaos (T-shirt) tanp a dibantu?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Letakkan selembar kertas seukuran buku ini di atas lantai. Apakah anak dapat melompat i bagian lebar kertas dengan mengangkat kedua kakinya secara bersamaan tanpa didahului lari?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Minta anak untuk berdiri 1 kaki tanpa berpegangan. Jika perlu tunjukkan caranya dan ber i anak kesempatan . sebanyak 3 kali. Dapatkah ia mempertahankan keseimbangan dalam waktu 2 detik atau lebih ?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "54" => [
                        [
                                    "number" => 1,
                                    "text" => "Jangan mengoreksi atau membantu anak. Jangan menyebut kata “Lebih panjang”. Pe rlihatkan gambar kedua garis ini pada anak. Tanyakan => “Mana garis yang lebih panjang?” Minta an ak menunjuk garis yang lebih panjang. Setelah anak menunjuk, putar lembar ini dan ulangi pertanyaan t ersebut. Apakah anak dapat menunjuk garis yang lebih panjang sebanyak 3 kali dengan benar?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Jangan membantu anak dan jangan memberitahu nama gambar ini. Minta anak untuk menggambar seperti contoh di kertas kosong yang tersedia. Berikan 3 kali kesempatan. Apakah anak dapat menggambar + seperti contoh di bawah?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Berikan anak pensil dan kertas lalu katakan kepada anak “Buatlah gambar orang” (anak laki-laki, anak perempuan, papa, mama, dll). Jangan memberi perintah lebih dari itu. Jangan be rtanya atau mengingatkan anak bila ada bagian yang belum tergambar. Dalam memberi nilai, hitunglah bera pa bagian tubuh yang tergambar. Untuk bagian tubuh yang berpasangan seperti mata, telinga, lengan, dan kaki, setiap pasang dinilai 1 bagian. Pastikan anak telah menyelesaikan gambar sebelum memberikan penilaian. Dapatkah anak menggambar orang dengan sedikitnya 3 bagian tubuh?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Memahami konsep 2 warna Minta anak untuk menyebutkan 2 warna. Dapatkah anak menyebut 2 warna dengan benar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah bicara anak mampu dipahami seluruhny a oleh orang lain (yang tidak bertemu setiap hari)?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak mengikuti peraturan permainan saat bermain dengan teman-temannya (misal => ular tangga, petak umpet, dll)?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak menggosok gigi tanpa dibantu?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat mengancingkan bajunya ata u pakaian boneka?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Mengenal konsep 2 kata depan Minta anak untuk mengikuti perintah di bawah, jangan memberi isyarat. “Ambil benda (misalnya kertas, balok) dan letakkan di atas meja” “Ambil benda (misalnya kertas, balok) dan letakkan di bawah meja” “Ambil benda (misalnya kertas, balok) dan letakkan di depan ibu” “Ambil benda (misalnya kertas, balok) dan letakkan di samping ibu” “Ambil benda (misalnya kertas, balok) dan letakkan di belakang ibu” Dapatkah anak melakukan sedikitnya 2 perintah (memahami 2 kata depan)?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Minta anak untuk berdiri 1 kaki tanpa berpegangan. Jika perlu tunjukkan caranya dan beri anak kesempatan sebanyak 3 kali. Dapatkah ia mempertahankan keseimbangan dalam waktu 2 de tik atau lebih?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "60" => [
                        [
                                    "number" => 1,
                                    "text" => "Perlihatkan gambar kedua garis ini pada anak. Tanyakan => “Mana garis yang lebih panjang?” Minta anak menunjuk garis yang lebih panjang. Setelah anak menunjuk, putar lembar ini dan ulangi pertanyaan tersebut. Apakah anak dapat menunjuk garis yang lebih panjang sebanyak 3 kali dengan ben ar?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Berikan anak pensil dan kertas lalu katakan kepada anak “Buatlah gambar orang” (anak laki-laki, anak perempuan, papa, mama, dll). Jangan memberi perintah lebih dari itu. Jangan be rtanya atau mengingatkan anak bila ada bagian yang belum tergambar. Dalam memberi nilai, hitunglah bera pa bagian tubuh yang tergambar. Untuk bagian tubuh yang berpasangan seperti mata, telinga, lengan d an kaki, setiap pasang dinilai 1 bagian. Pastikan anak telah menyelesaikan gambar sebelum memberikan penilaian. Dapatkah anak menggambar orang dengan sedikitnya 3 bagian tubuh?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Memahami konsep 4 warna Minta anak untuk menyebutkan 4 warna. Dapatkah anak menyebut keempat warna ter sebut dengan benar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Tanyakan kepada anak pertanyaan berikut ini satu persatu => “Apa yang kamu lakukan saat kedinginan?” Jawaban => pakai jaket, pakai selimut “Apa yang kamu lakukan saat kelelahan?” Jawaban => tidur, berbaring, istirahat “Apa yang kamu lakukan saat merasa lapar?” Jawaban => makan “Apa yang kamu lakukan saat merasa haus?” Jawaban => minum Dapatkah anak menjawab 3 pertanyaan terkait kata sifat tersebut dengan benar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat mengancingkan bajunya a tau pakaian boneka?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak bereaksi dengan tenang dan ti dak rewel (tanpa menangis atau menggelayut) pada saat ditinggal oleh orang tua atau pengasuh?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak sepenuhnya berpakaian sendi ri tanpa dibantu?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Mengenal konsep 4 kata depan Minta anak untuk mengikuti perintah di bawah, jangan memberi isyarat => “Ambil benda (misalnya kertas, balok) dan letakkan di atas meja” “Ambil benda (misalnya kertas, balok) dan letakkan di bawah meja” “Ambil benda (misalnya kertas, balok) dan letakkan di depan ibu” “Ambil benda (misalnya kertas, balok) dan letakkan di samping ibu” “Ambil benda (misalnya kertas, balok) dan letakkan di belakang ibu” Dapatkah anak melakukan sedikitnya 4 perintah (memahami 4 kata depan)?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Minta anak untuk berdiri 1 kaki tanpa berpegangan. Jika perlu tunjukkan caranya da n beri anak kesempatan sebanyak 3 kali. Dapatkah ia mempertahankan keseimbangan dalam waktu 4 detik atau lebih?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Minta anak untuk melompat dengan 1 kaki beberapa kali tanpa berpegangan (lompatan dengan 2 kaki tidak ikut dinilai). Dapatkah anak melompat 2-3 kali dengan 1 kaki?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "66" => [
                        [
                                    "number" => 1,
                                    "text" => "Menggambar + Jangan membantu anak dan jangan memberitahu nama gambar ini. Minta anak untuk menggambar seperti contoh di kertas kosong yang tersedia. Berikan 3 kali kesempatan. Apakah anak dapat menggambar + seperti contoh di bawah?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Menggambar kotak dengan dicontohkan Berikan kepada anak pensil dan kertas. Tunjukkan kepada anak contoh gambar di bawah. Anda bisa mencontohkan cara membuat kotak. Dapatkah anak menggambar kotak seperti conto h di bawah?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Menggambar orang dengan sedikitnya 6 bagian tubuh Berikan anak pensil dan kertas lalu katakan kepada anak “Buatlah gambar orang ” (anak laki-laki, anak perempuan, papa, mama, dll). Jangan memberi perintah lebih dari itu. Jangan b ertanya atau mengingatkan anak bila ada bagian yang belum tergambar. Dalam memberi nilai, hitunglah ber apa bagian tubuh yang tergambar. Untuk bagian tubuh yang berpasangan seperti mata, telinga, lengan dan kaki, setiap pasang dinilai 1 bagian. Pastikan anak telah menyelesaikan gambar sebelum memberikan penilaian . Dapatkah anak menggambar orang dengan sedikitnya 6 bagian tubuh? Jawaban ‘Ya’ => Jawaban ‘Tidak’ =>",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Mengetahui konsep angka 5 Letakkan 8 kubus di atas meja dan selembar kertas di samping kubus. Katakan kepada a nak “Ambil 5 kubus dan letakkan di atas kertas”. Setelah anak selesai meletakkan, tanyakan “Ada berapa banyak kubus di atas kertas?” Dapatkah anak melakukannya?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Memahami/mengartikan 5 kata Pastikan anak mendengar pemeriksa lalu katakan “Saya akan mengucapkan 1 kata dan say a ingin kamu menyebutkan apa arti kata itu”. Setiap kata dapat diberikan sebanyak 3 kali bila per lu. Pemeriksa dapat mengatakan “Beritahu saya sesuatu tentang itu” tetapi jangan tanya apa kegunaannya. Tanyalah setiap kata dalam satu waktu. “Apakah bola itu?”, “Apakah sungai itu?”, “Apakah meja itu?”, “Apakah mobil/motor it u?”, “Apakah rumah itu?” “Apakah pisang itu?” “Apakah pintu itu?” “Apakah atap itu?” Anak dikatakan dapat mengartikan jika anak mengartikan yang sesuai dalam istilah => 1) kegunaan, 2) bentuk, 3) terbuat dari apa, 4) kategori umum. Dapatkah anak mengartikan 5 kata yang sesuai?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Mengetahui konsep analogi berlawanan Minta anak untuk melengkapi kalimat di bawah ini, jangan membantu kecuali mengulang pertanyaan => “Jika kuda besar, maka tikus...?” Jawaban => kecil “Jika api panas, maka es...?” Jawaban => dingin “Jika ibu seorang wanita, maka ayah seorang...” Jawaban => pria, laki-laki Apakah anak menjawab ketiga pertanyaan dengan benar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak bereaksi dengan tenang dan tida k rewel (tanpa menangis atau menggelayut) pada saat ditinggal oleh orang tua atau pengasuh?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, dapatkah anak sepenuhnya berpakaian sendiri tanpa dibantu?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Minta anak untuk berdiri 1 kaki tanpa berpegangan. Jika perlu tunjukkan caranya dan beri anak kesempatan sebanyak 3 kali. Dapatkah ia mempertahankan keseimbangan dalam waktu 6 detik atau le bih?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Apakah anak dapat menangkap bola kecil sebesar bola tenis atau bola kasti hanya deng an menggunakan kedua tangannya?",
                                    "domain" => "Gerak kasar"
                        ]
            ],
            "72" => [
                        [
                                    "number" => 1,
                                    "text" => "Menggambar kotak tanpa dicontohkan Berikan kepada anak pensil dan kertas. Tunjukkan kepada anak contoh gambar di bawah. Tanpa menyebutkan nama dan tanpa mencontohkan atau menggerakkan jari telunjuk atau pensil untuk menunjukk an bagaimana cara menggambarnya, katakan kepada anak “Gambarlah yang seperti gambar ini”. Lihat contoh di bawah untuk menilai gambar anak. Dapatkah anak menggambar kotak seperti contoh di bawah?",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 2,
                                    "text" => "Menggambar orang dengan sedikitnya 6 bagian tubuh Berikan anak pensil dan kertas lalu katakan kepada anak “Buatlah gambar orang” (anak laki-laki, anak perempuan, papa, mama, dll). Jangan memberi perintah lebih dari itu. Jangan bertanya atau mengi ngatkan anak bila ada bagian yang belum tergambar. Dalam memberi nilai, hitunglah berapa bagian tubuh yang tergambar. Untuk bagian tubuh yang berpasangan seperti mata, telinga, lengan dan kaki, setiap pasang dinilai 1 bagian. Pastik an anak telah menyelesaikan gambar sebelum memberikan penilaian. Dapatkah anak menggambar orang dengan sedikitnya 6 bagia n tubuh? Jawaban ‘Ya’ => Jawaban ‘Tidak’ =>",
                                    "domain" => "Gerak halus"
                        ],
                        [
                                    "number" => 3,
                                    "text" => "Mengetahui konsep analogi berlawanan Minta anak untuk melengkapi kalimat di bawah ini, jangan membantu kecuali meng ulang pertanyaan => “Jika kuda besar, maka tikus...?” Jawaban => kecil “Jika api panas, maka es...?” Jawaban => dingin “Jika ibu seorang wanita, maka ayah seorang...” Jawaban => pria, laki-laki “Jika pagi ada matahari, malam ada...” Jawaban => bulan Apakah anak menjawab ketiga pertanyaan dengan benar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 4,
                                    "text" => "Memahami/mengartikan 7 kata Pastikan anak mendengar pemeriksa lalu katakan “Saya akan mengucapkan 1 kata dan say a ingin kamu menyebutkan apa arti kata itu”. Setiap kata dapat diberikan sebanyak 3 kali bila perlu. Pemeriksa dapat m engatakan “Beritahu saya sesuatu tentang itu” tetapi jangan tanya apa kegunaannya. Tanyalah setiap kata dalam satu waktu. “Apakah bola itu?”, “Apakah sungai itu?”, “Apakah meja itu?”, “Apakah mobil/motor it u?”, “Apakah rumah itu?” “Apakah pisang itu?” “Apakah pintu itu?” “Apakah atap itu?” Anak dikatakan dapat mengartikan jika anak mengartikan yang sesuai dalam istilah => 1) kegunaan, 2) bentuk, 3) terbuat dari apa, 4) kategori umum. Dapatkah anak mengartikan 7 kata yang sesuai?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 5,
                                    "text" => "Mengetahui komposisi benda Isi titik−titik di bawah ini dengan jawaban anak. Jangan membantu kecuali mengulang i pertanyaan sampai 3 kali bila anak menanyakannya. \"Sendok dibuat dari apa?\" Jawaban => besi, baja, plastik, kayu \"Sepatu dibuat dari apa?\" Jawaban => kulit, karet, kain, plastik, kayu \"Pintu dibuat dari apa?\" Jawaban => kayu, besi, kaca Apakah anak dapat menjawab ketiga pertanyaan diatas dengan benar?",
                                    "domain" => "Bicara dan bahasa"
                        ],
                        [
                                    "number" => 6,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat menggosok giginya tanpa b antuan?",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 7,
                                    "text" => "Tanyakan kepada orang tua atau pengasuh, apakah anak dapat menyiapkan dan mengambil makanan tanpa bantuan, termasuk menggunakan mangkok, sendok, menuangkan makanan dan susu ke mangkok tanpa b anyak tumpah? Jawab ‘Ya’ jika anak dapat melakukannya, termasuk menuangkan susu dari beberapa jenis kotak atau wad ah makanan.",
                                    "domain" => "Sosialisasi dan kemandirian"
                        ],
                        [
                                    "number" => 8,
                                    "text" => "Apakah anak dapat menangkap bola kecil sebesar bola tenis atau bola kasti hanya deng an menggunakan kedua tangannya?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 9,
                                    "text" => "Tunjukkan kepada anak bagaimana cara berjalan di garis lurus dengan menempatkan tumi t dari 1 kaki di depan jari kaki lain. Berjalanlah 8 langkah, lalu minta anak untuk melakukannya. Berikan contoh dan kesemp atan sebanyak 3 kali bila perlu. Dapatkah anak melakukannya sebanyak 4 langkah atau lebih dengan meletakkan tumit tid ak lebih dari 2,5 cm dari jari kaki lain tanpa berpegangan?",
                                    "domain" => "Gerak kasar"
                        ],
                        [
                                    "number" => 10,
                                    "text" => "Minta anak untuk berdiri 1 kaki tanpa berpegangan. Jika perlu tunjukkan caranya dan beri anak kesempatan sebanyak 3 kali. Dapatkah ia mempertahankan keseimbangan dalam waktu 11 detik atau lebih?",
                                    "domain" => "Gerak kasar"
                        ]
            ]
];
    }

    /**
     * All 10 developmental milestone, stimulation, and red flag groups.
     *
     * @return array<string, array{
     *     label: string,
     *     min_months: int,
     *     max_months: int,
     *     gross_motor: list<string>,
     *     fine_motor: list<string>,
     *     speech_language: list<string>,
     *     social_independence: list<string>,
     *     stimulation: list<string>,
     *     red_flags: list<string>
     * }>
     */
    public function getAllGuidance(): array
    {
        return [
            "0-2" => [
                        "label" => "0–2 Bulan",
                        "min_months" => 0,
                        "max_months" => 2,
                        "gross_motor" => [
                                    "Mengangkat kepala setinggi 45 derajat saat tengkurap.",
                                    "Menahan kepala tetap tegak ketika tubuh ditegakkan."
                        ],
                        "fine_motor" => [
                                    "Meraba dan memegang benda yang menyentuh telapak tangan.",
                                    "Menggerakkan kepala dari kiri atau kanan ke tengah.",
                                    "Pandangan mengikuti gerakan benda dan mulai mengenali orang dari kejauhan."
                        ],
                        "speech_language" => [
                                    "Membuat suara seperti berkumur atau cooing.",
                                    "Mengoceh spontan.",
                                    "Bereaksi terkejut terhadap suara keras.",
                                    "Menoleh ke arah sumber suara."
                        ],
                        "social_independence" => [
                                    "Membalas senyum ketika diajak bicara atau tersenyum.",
                                    "Tertawa keras.",
                                    "Melihat dan menatap wajah orang di dekatnya.",
                                    "Mengenali ibu melalui penglihatan, penciuman, pendengaran, dan kontak fisik.",
                                    "Menenangkan diri sendiri untuk beberapa saat.",
                                    "Menunjukkan rasa bosan saat aktivitas monoton."
                        ],
                        "stimulation" => [
                                    "Melatih bayi mengangkat kepala 45 derajat saat tengkurap, menahan kepala, dan berguling.",
                                    "Melatih bayi meraba serta memegang benda dengan berbagai tekstur.",
                                    "Menggantung benda berwarna cerah dan berbunyi di dekat jangkauan pandang bayi.",
                                    "Melatih bayi mengenali suara dan berbicara dengan nada lembut.",
                                    "Menirukan ocehan dan mimik wajah bayi.",
                                    "Menunjukkan ketertarikan, kontak mata, dan kehangatan pada bayi.",
                                    "Memberikan rasa aman dan nyaman melalui pelukan dan sentuhan lembut.",
                                    "Mengenali penyebab bayi rewel dan mengatasinya secara responsif.",
                                    "Membentuk rutinitas tidur, menyusui, dan interaksi yang teratur."
                        ],
                        "red_flags" => [
                                    "Tonus otot sangat lemah atau bayi terkulai lemas.",
                                    "Tidak merespons atau tidak terkejut terhadap suara keras.",
                                    "Pengasuh tampak tidak tertarik atau acuh tak acuh terhadap bayi.",
                                    "Pada umur 2 bulan => tidak dapat mengangkat kepala ketika tengkurap.",
                                    "Pada umur 2 bulan => tidak dapat membawa tangan ke mulut.",
                                    "Pada umur 2 bulan => pandangan mata tidak mengikuti gerakan benda.",
                                    "Pada umur 2 bulan => jarang menatap wajah atau kurangnya fiksasi kontak mata.",
                                    "Pada umur 2 bulan => tidak tersenyum kepada orang di sekitarnya."
                        ]
            ],
            "3-5" => [
                        "label" => "3–5 Bulan",
                        "min_months" => 3,
                        "max_months" => 5,
                        "gross_motor" => [
                                    "Berbalik dari posisi tengkurap ke terlentang.",
                                    "Mengangkat kepala 90 derajat ketika tengkurap dan menopang tubuh dengan kedua siku.",
                                    "Mempertahankan posisi kepala tetap stabil dan tegak saat didudukkan.",
                                    "Kaki menendang aktif ketika bayi ditegakkan di permukaan keras."
                        ],
                        "fine_motor" => [
                                    "Kepala menoleh bebas ke berbagai arah mengikuti objek.",
                                    "Memegang dan menggoyangkan mainan kerincingan.",
                                    "Menggenggam mainan atau jari orang lain dengan erat.",
                                    "Meraih benda yang berada dalam jangkauan tangannya.",
                                    "Menyatukan kedua tangan di tengah tubuh dan mengamatinya.",
                                    "Mengikuti benda yang bergerak 180 derajat serta memperhatikan benda kecil."
                        ],
                        "speech_language" => [
                                    "Mengeluarkan suara gembira bernada tinggi dan memekik.",
                                    "Mengoceh dengan ekspresi dan menirukan variasi suara vokal.",
                                    "Mencari arah datangnya sumber suara."
                        ],
                        "social_independence" => [
                                    "Memasukkan tangan atau benda ke mulut.",
                                    "Memperhatikan wajah orang-orang di sekitarnya secara seksama.",
                                    "Mengenali orang atau benda dari kejauhan.",
                                    "Tersenyum ketika melihat mainan atau gambar yang menarik.",
                                    "Menirukan gerakan bibir dan ekspresi wajah.",
                                    "Menangis dengan pola nada berbeda sesuai kebutuhan (lapar, lelah, popok basah).",
                                    "Menunjukkan ekspresi rasa senang atau sedih.",
                                    "Merespons ungkapan kasih sayang dan ajakan bermain.",
                                    "Menyukai interaksi dan permainan sosial dengan orang lain."
                        ],
                        "stimulation" => [
                                    "Menggendong bayi tegak menghadap ke depan untuk melatih kontrol kepala dan persepsi visual.",
                                    "Membantu bayi belajar duduk dengan sandaran bantal yang aman.",
                                    "Melatih menyangga berat badan dengan menyentuhkan telapak kaki ke permukaan datar.",
                                    "Membantu bayi memegang benda pada kedua tangan secara bergantian.",
                                    "Melatih mengambil dan mengamati benda kecil yang aman (kismis, biskuit).",
                                    "Meletakkan mainan sedikit di luar jangkauan untuk mendorong gerakan meraih dan berguling.",
                                    "Mengarahkan bayi ke sumber suara musik, kerincingan, atau panggilan nama.",
                                    "Menirukan suara ocehan bayi dan mengulanginya untuk merangsang dialog vokal.",
                                    "Memberi rasa aman melalui kontak mata, senyum hangat, pelukan, dan percakapan harian.",
                                    "Menjaga rutinitas tidur, mandi, dan makan yang teratur.",
                                    "Bermain cilukba sederhana dan mengajak bayi melihat dirinya di cermin yang aman."
                        ],
                        "red_flags" => [
                                    "Tidak dapat menahan kepala dengan stabil pada umur 4 bulan.",
                                    "Tidak mampu menggerakkan tangan ke bagian tengah tubuh.",
                                    "Kaki tidak menendang ketika diletakkan pada permukaan keras.",
                                    "Tidak merespons atau tidak menoleh terhadap suara keras.",
                                    "Pandangan tidak mengikuti arah gerak benda.",
                                    "Jarang menatap wajah atau kurangnya fiksasi kontak mata.",
                                    "Tidak membalas senyum kepada orang di sekitarnya."
                        ]
            ],
            "6-8" => [
                        "label" => "6–8 Bulan",
                        "min_months" => 6,
                        "max_months" => 8,
                        "gross_motor" => [
                                    "Duduk stabil dengan kedua tangan menopang tubuh di depan.",
                                    "Berguling ke dua arah (terlentang ke tengkurap dan sebaliknya).",
                                    "Merangkak atau mengesot untuk meraih mainan atau mendekati seseorang.",
                                    "Belajar berdiri dengan kedua kaki menopang sebagian berat badan saat dipegangi."
                        ],
                        "fine_motor" => [
                                    "Memindahkan benda dari satu tangan ke tangan lainnya.",
                                    "Memegang satu benda pada masing-masing tangan secara bersamaan.",
                                    "Memungut benda sebesar kacang atau kismis dengan gerakan meraup.",
                                    "Memasukkan biskuit atau makanan sendiri ke mulut.",
                                    "Mencari benda yang dijatuhkan ke lantai."
                        ],
                        "speech_language" => [
                                    "Mengoceh suku kata berulang seperti “Mamama”, “Bababa”, atau “Dadada”.",
                                    "Menggabungkan bunyi vokal dan bergantian membuat suara dengan orang tua.",
                                    "Mengucapkan bunyi konsonan dengan variasi nada.",
                                    "Merespons dan menoleh ketika namanya dipanggil."
                        ],
                        "social_independence" => [
                                    "Makan biskuit atau finger food sendiri.",
                                    "Bermain tepuk tangan atau cilukba dengan antusias.",
                                    "Menunjukkan rasa ingin tahu yang besar terhadap lingkungan sekitar.",
                                    "Mengenali wajah keluarga yang familiar dan membedakannya dari orang asing.",
                                    "Merespons ekspresi emosi orang lain.",
                                    "Senang dan tertawa melihat bayangan diri sendiri di cermin."
                        ],
                        "stimulation" => [
                                    "Memberikan pelukan hangat, senyuman, mengajak berbicara, dan sering memanggil nama bayi.",
                                    "Meletakkan mainan menarik sedikit di luar jangkauan untuk mendorong bayi merayap dan merangkak.",
                                    "Melatih bayi dari posisi duduk menuju berdiri dengan berpegangan pada furnitur kokoh.",
                                    "Melatih koordinasi motorik halus dengan memindahkan balok atau mainan antar tangan.",
                                    "Menyediakan kertas aman dan krayon besar untuk latihan mencoret-coret.",
                                    "Mengajari memasukkan balok ke dalam wadah dan mengeluarkannya kembali.",
                                    "Menyembunyikan mainan di bawah kain tipis dan menunjukkan cara menemukannya (peek-a-boo).",
                                    "Membacakan buku bergambar tebal dengan warna kontras dan menamai gambar.",
                                    "Mengajarkan konsep sebab-akibat sederhana melalui mainan berbunyi saat ditekan.",
                                    "Melatih melambaikan tangan (“dadah”) dan tepuk tangan (“pok ame-ame”)."
                        ],
                        "red_flags" => [
                                    "Tidak dapat memindahkan benda dari satu tangan ke tangan lain pada umur 6 bulan.",
                                    "Kesulitan membawa makanan atau benda ke arah mulut.",
                                    "Tampak sangat lemas seperti boneka kain (hipotonia) atau sebaliknya sangat kaku (hipertonia).",
                                    "Tidak dapat berguling ke arah mana pun.",
                                    "Tidak merespons suara di sekitarnya atau tidak menoleh saat dipanggil nama.",
                                    "Tidak tertarik atau tidak mencoba meraih benda di dekatnya.",
                                    "Tidak mengeluarkan suara vokal atau ocehan konsonan.",
                                    "Tidak tertawa, tidak memekik, atau tidak menunjukkan ekspresi wajah gembira.",
                                    "Tidak menunjukkan ketertarikan atau afeksi kepada pengasuh utama."
                        ]
            ],
            "9-11" => [
                        "label" => "9–11 Bulan",
                        "min_months" => 9,
                        "max_months" => 11,
                        "gross_motor" => [
                                    "Duduk sendiri dengan stabil tanpa bantuan dari posisi berbaring.",
                                    "Merangkak dengan lincah menggunakan tangan dan lutut.",
                                    "Menarik tubuhnya sendiri untuk posisi berdiri dengan berpegangan.",
                                    "Berdiri selama 30 detik sambil berpegangan pada kursi atau meja.",
                                    "Berjalan beberapa langkah dengan dituntun kedua tangan."
                        ],
                        "fine_motor" => [
                                    "Mengulurkan lengan atau badan dengan mantap untuk meraih mainan.",
                                    "Menggenggam krayon atau pensil dengan telapak tangan.",
                                    "Memindahkan benda kecil antar tangan secara terkontrol.",
                                    "Menjepit benda kecil (kismis) menggunakan ujung ibu jari dan jari telunjuk (pincer grasp).",
                                    "Membenturkan dua kubus satu sama lain untuk membuat bunyi.",
                                    "Mencari mainan yang disembunyikan di balik selimut atau wadah."
                        ],
                        "speech_language" => [
                                    "Menirukan suara, kata, intonasi, atau gerakan orang lain.",
                                    "Menyebut suku kata ganda tanpa arti spesifik.",
                                    "Menyebut satu kata bermakna (misal “Mama”, “Papa”, atau “Cucu”).",
                                    "Bereaksi dan menoleh terhadap suara perlahan, bisikan, atau ketukan halus.",
                                    "Memberi respons anggukan atau gelengan kepala terhadap tawaran."
                        ],
                        "social_independence" => [
                                    "Mengeksplorasi ruangan secara aktif dengan merangkak.",
                                    "Mengenali anggota keluarga akrab dan menunjukkan rasa cemas/takut pada orang asing (stranger anxiety).",
                                    "Memiliki mainan atau selimut favorit.",
                                    "Memahami makna kata larangan seperti “Jangan” atau “Tidak”.",
                                    "Menunjuk sesuatu yang diinginkan menggunakan jari telunjuk."
                        ],
                        "stimulation" => [
                                    "Menyediakan area bermain lantai yang luas, bersih, dan aman dari sudut tajam atau kabel listrik.",
                                    "Melatih keseimbangan berdiri berpegangan (cruising) menyusuri sofa atau meja rendah.",
                                    "Melatih motorik halus menjepit benda kecil, memasukkan kubus ke kaleng, dan menyusun 2 balok.",
                                    "Mendorong anak mencoret-coret bebas di kertas besar.",
                                    "Mendeskripsikan setiap benda dan aktivitas yang dilihat anak sehari-hari.",
                                    "Membacakan buku cerita bergambar, menunjuk gambar hewan, dan menirukan suaranya.",
                                    "Melatih permainan giliran sederhana seperti melempar bola gulir dan petak umpet.",
                                    "Melatih melambaikan tangan saat anggota keluarga pergi dan menyapa saat datang."
                        ],
                        "red_flags" => [
                                    "Tidak mampu duduk sendiri tanpa bantuan pada umur 9 bulan.",
                                    "Tidak dapat menyangga berat badan dengan kedua kaki saat diberdirikan.",
                                    "Tidak dapat melakukan permainan bolak-balik timbal balik (senyum, suara).",
                                    "Tidak dapat memindahkan mainan antar tangan.",
                                    "Jarang atau tidak pernah mengoceh dengan konsonan (“Mama”, “Baba”, “Dada”).",
                                    "Tidak merespons ketika namanya dipanggil dan tidak melihat ke arah yang ditunjuk.",
                                    "Tidak mengenali orang-orang yang familiar di sekitarnya.",
                                    "Tidak ada respons interaksi timbal balik saat diajak berbicara atau tersenyum."
                        ]
            ],
            "12-17" => [
                        "label" => "12–17 Bulan",
                        "min_months" => 12,
                        "max_months" => 17,
                        "gross_motor" => [
                                    "Berdiri sendiri tanpa berpegangan selama beberapa detik.",
                                    "Membungkuk untuk memungut mainan di lantai lalu berdiri kembali tanpa jatuh.",
                                    "Berjalan mandiri dengan langkah stabil tanpa perlu dituntun."
                        ],
                        "fine_motor" => [
                                    "Menumpuk dua kubus satu di atas yang lain.",
                                    "Memasukkan benda ke dalam wadah dan mengeluarkannya kembali satu per satu.",
                                    "Mengeksplorasi fungsi benda dengan menggoyang, membenturkan, atau melempar.",
                                    "Memegang krayon dan membuat coretan spontan di atas kertas.",
                                    "Menemukan benda yang disembunyikan sepenuhnya di bawah penutup.",
                                    "Menggunakan benda sesuai fungsinya (misal => menyisir rambut, menaruh cangkir ke mulut)."
                        ],
                        "speech_language" => [
                                    "Memanggil orang tua secara spesifik dengan “Mama” atau “Papa”.",
                                    "Menyebutkan 1–6 kata bermakna selain nama orang tua.",
                                    "Mencoba menirukan kata baru yang didengar dari percakapan.",
                                    "Merespons perintah lisan sederhana satu langkah (misal => “Bawa bolanya ke sini”).",
                                    "Melakukan gerakan tubuh bermakna (menggelengkan kepala untuk tidak, melambaikan tangan untuk dadah)."
                        ],
                        "social_independence" => [
                                    "Menunjuk benda atau hal yang diinginkan tanpa menangis atau merengek.",
                                    "Mengulang suara atau tingkah lucu untuk menarik perhatian orang dewasa.",
                                    "Menunjukkan rasa malu, takut, atau ragu pada situasi baru.",
                                    "Menangis atau cemas ketika berpisah dengan pengasuh utama (separation anxiety).",
                                    "Memiliki mainan, selimut, atau boneka favorit.",
                                    "Menggunakan bahasa tubuh dan intonasi vokal untuk mengekspresikan keinginan."
                        ],
                        "stimulation" => [
                                    "Melatih koordinasi motorik kasar => berjalan mundur, melangkah di permukaan tidak rata, dan naik tangga dengan berpegangan.",
                                    "Bermain puzzle kayu sederhana dengan kepingan besar, menyusun balok, dan melempar bola lembut.",
                                    "Menyediakan kertas gambar lebar dan krayon tebal untuk melatih genggaman tangan.",
                                    "Mengajak bermain tebak bunyi, menyebutkan nama anggota tubuh sambil menyentuhnya, dan menyanyi lagu anak.",
                                    "Memberi kesempatan berinteraksi dan bermain berdampingan dengan anak sebaya.",
                                    "Menarasikan setiap kegiatan harian (mandi, makan, ganti baju) menggunakan kalimat pendek yang jelas.",
                                    "Melatih kemandirian meniru pekerjaan rumah tangga => melepas kaos kaki, memegang sendok, dan merapikan mainan.",
                                    "Memberi pujian spesifik terhadap perilaku baik yang ditunjukkan anak."
                        ],
                        "red_flags" => [
                                    "Tidak dapat berdiri atau menyangga berat badan pada umur 12 bulan.",
                                    "Tidak merespons ketika namanya dipanggil.",
                                    "Tidak memahami instruksi sederhana atau kata larangan “tidak/jangan”.",
                                    "Tidak mencari benda yang dilihatnya disembunyikan.",
                                    "Tidak mengucapkan satu kata pun yang bermakna pada umur 12 bulan.",
                                    "Tidak dapat menunjuk benda menggunakan jari telunjuk.",
                                    "Sikap acuh tak acuh atau menolak kedekatan fisik dengan pengasuh utama.",
                                    "Tidak dapat memegang pensil atau krayon pada umur 15 bulan.",
                                    "Tidak dapat menunjuk benda yang diinginkannya pada umur 15 bulan."
                        ]
            ],
            "18-23" => [
                        "label" => "18–23 Bulan",
                        "min_months" => 18,
                        "max_months" => 23,
                        "gross_motor" => [
                                    "Berjalan mundur beberapa langkah tanpa terjatuh.",
                                    "Naik tangga dengan berpegangan pada dinding atau susuran tangga.",
                                    "Berlari kecil dengan koordinasi yang makin baik."
                        ],
                        "fine_motor" => [
                                    "Menumpuk empat kubus menjadi menara tanpa roboh.",
                                    "Mencoret-coret kertas dengan garis vertikal atau melingkar.",
                                    "Menggelindingkan dan melempar bola kecil ke arah sasaran."
                        ],
                        "speech_language" => [
                                    "Menyebutkan sedikitnya 7–20 kata yang memiliki arti jelas.",
                                    "Menunjuk benda atau gambar yang disebutkan namanya.",
                                    "Mengatakan kata penolakan “tidak” atau “gamau”.",
                                    "Menunjuk minimal satu bagian tubuh saat ditanya (mata, hidung, perut).",
                                    "Mengikuti satu perintah lisan sederhana tanpa bantuan gerakan isyarat."
                        ],
                        "social_independence" => [
                                    "Membantu melepas pakaian sederhana (topi, celana karet, kaos kaki).",
                                    "Meniru aktivitas rumah tangga seperti menyapu atau mengelap meja.",
                                    "Memegang cangkir atau gelas kecil untuk minum sendiri dengan sedikit tumpah.",
                                    "Mengajak orang lain bermain dengan membawa mainan kepadanya.",
                                    "Menunjukkan kasih sayang kepada keluarga dan kehati-hatian pada orang baru.",
                                    "Bermain pura-pura sederhana (menyuapi boneka, berbicara di telepon mainan).",
                                    "Mengeksplorasi lingkungan dengan tetap sesekali menoleh memastikan orang tua dekat.",
                                    "Mengenali konsep perbedaan jenis kelamin sederhana."
                        ],
                        "stimulation" => [
                                    "Menyediakan ruang bergerak yang aman untuk berlatih berlari, melompat kecil, dan menendang bola.",
                                    "Memberikan mainan dorong atau tarik (wagon, mobil-mobilan bertali) untuk melatih keseimbangan.",
                                    "Melatih keterampilan menumpuk balok, memasukkan bentuk ke lubang yang cocok (shape sorter), dan puzzle 2-3 keping.",
                                    "Mengajarkan nama bagian tubuh, warna dasar, dan nama hewan melalui buku bergambar.",
                                    "Mengajak bernyanyi bersama dengan gerakan tubuh dan ekspresi wajah.",
                                    "Melatih rutinitas makan mandiri menggunakan sendok dan minum dari cangkir terbuka.",
                                    "Menggunakan kata-kata sederhana untuk membantu anak melabeli emosinya (marah, senang, sedih).",
                                    "Melatih kebiasaan berbagi dan bergiliran melalui interaksi permainan sehari-hari."
                        ],
                        "red_flags" => [
                                    "Tidak dapat berjalan mandiri tanpa bantuan pada umur 18 bulan.",
                                    "Tidak mampu menyebut minimal 6 kata bermakna pada umur 18 bulan.",
                                    "Tidak mampu meniru tindakan, gerakan, atau kata-kata orang lain.",
                                    "Tidak peduli atau tidak bereaksi saat pengasuh datang atau pergi.",
                                    "Tidak dapat menunjuk dengan satu jari untuk menunjukkan sesuatu yang menarik perhatiannya.",
                                    "Tidak mengetahui fungsi benda sehari-hari yang familiar (sendok, cangkir, sisir, telepon)."
                        ]
            ],
            "24-35" => [
                        "label" => "24–35 Bulan",
                        "min_months" => 24,
                        "max_months" => 35,
                        "gross_motor" => [
                                    "Berjalan naik tangga sendiri dengan melangkah satu kaki per anak tangga sambil berpegangan.",
                                    "Berlari cepat dan berhenti tanpa terjatuh.",
                                    "Menendang bola kecil ke arah depan tanpa kehilangan keseimbangan."
                        ],
                        "fine_motor" => [
                                    "Menirukan membuat garis lurus vertikal atau horizontal di kertas.",
                                    "Menumpuk empat sampai enam kubus menjadi menara yang kokoh.",
                                    "Menemukan mainan yang disembunyikan di bawah dua atau tiga lapisan penutup.",
                                    "Membuka tutup botol ulir atau memutar kenop pintu sederhana."
                        ],
                        "speech_language" => [
                                    "Menyusun kalimat sederhana yang terdiri dari dua sampai empat kata (misal => “Mau minum susu”).",
                                    "Mengulangi kata-kata yang didengar dari percakapan orang dewasa.",
                                    "Menyebutkan nama orang atau teman yang dikenalnya dengan benar.",
                                    "Menunjuk 3–6 bagian tubuh atau lebih saat diminta.",
                                    "Menunjuk dan menyebutkan nama minimal empat gambar benda atau hewan.",
                                    "Mulai mengenali bentuk dasar (lingkaran, kotak) dan warna utama.",
                                    "Mampu mengikuti perintah dua langkah berurutan (misal => “Ambil sepatumu lalu taruh di dekat pintu”).",
                                    "Melengkapi kata terakhir dari lirik lagu anak atau cerita yang sering dibacakan."
                        ],
                        "social_independence" => [
                                    "Menunjukkan kemandirian yang semakin besar dan sesekali bersikap menentang (temper tantrum).",
                                    "Makan sendiri menggunakan sendok dengan makanan jarang tumpah.",
                                    "Menirukan tingkah laku orang dewasa secara spontan dalam bermain peran.",
                                    "Bersemangat bermain di dekat atau bersama anak lain (parallel play).",
                                    "Bermain peran imajinatif sederhana (berpura-pura memasak, mengendarai mobil)."
                        ],
                        "stimulation" => [
                                    "Mendorong aktivitas motorik aktif => memanjat tangga taman bermain, melompat dengan dua kaki, dan berjalan jinjit.",
                                    "Mengajak membuat kreasi seni sederhana => menempel kertas origami, bermain lilin mainan (playdough), dan menggambar garis.",
                                    "Melatih mengelompokkan benda berdasarkan warna atau ukuran (besar/kecil).",
                                    "Mengajak bicara menggunakan kalimat lengkap dan tata bahasa yang baik, bukan baby talk.",
                                    "Membacakan cerita setiap hari dan menanyakan pertanyaan terbuka (siapa, apa yang terjadi, di mana).",
                                    "Melatih kemandirian buang air di toilet (toilet training) dengan sabar dan konsisten.",
                                    "Mengajarkan mencuci tangan dengan sabun, mengeringkan tangan, dan memakai sandal sendiri.",
                                    "Menenangkan anak dengan pelukan hangat saat mengalami tantrum, lalu membantu mengutarakan perasaannya."
                        ],
                        "red_flags" => [
                                    "Tidak dapat berjalan dengan stabil atau sering terjatuh tanpa sebab jelas pada umur 24 bulan.",
                                    "Tidak mampu merangkai kalimat dua kata (subjek + predikat) pada umur 24 bulan.",
                                    "Tidak mampu memahami atau mengikuti perintah lisan sederhana.",
                                    "Tidak dapat meniru tindakan fisik maupun kata-kata orang lain.",
                                    "Kontak mata sangat minim atau anak tampak hidup dalam dunianya sendiri.",
                                    "Kehilangan kemampuan bicara atau keterampilan motorik yang sebelumnya sudah dikuasai."
                        ]
            ],
            "36-47" => [
                        "label" => "36–47 Bulan",
                        "min_months" => 36,
                        "max_months" => 47,
                        "gross_motor" => [
                                    "Berdiri dengan satu kaki selama minimal 2 detik tanpa berpegangan.",
                                    "Melompat ke depan sejauh minimal 20 cm dengan kedua kaki bersamaan.",
                                    "Naik dan turun tangga dengan kaki bergantian tanpa berpegangan pada dinding."
                        ],
                        "fine_motor" => [
                                    "Menumpuk delapan kubus menjadi menara yang tinggi.",
                                    "Menyusun puzzle sederhana sebanyak 3–4 keping.",
                                    "Meniru menggambar lingkaran dengan bentuk yang bulat rapi.",
                                    "Menggambar sosok orang sederhana yang memuat sedikitnya tiga bagian tubuh (kepala, badan, kaki/tangan)."
                        ],
                        "speech_language" => [
                                    "Percakapan anak sebagian besar sudah dapat dipahami oleh orang luar keluarga.",
                                    "Mampu bercakap-cakap dalam 2–3 kalimat berurutan.",
                                    "Menyebutkan nama lengkap diri sendiri, umur, jenis kelamin, dan nama teman bermain.",
                                    "Mengenali dan menyebutkan 2–4 warna dasar dengan tepat.",
                                    "Memahami konsep kata depan (di atas, di bawah, di dalam) dan konsep jumlah dua.",
                                    "Mendengarkan dongeng dengan fokus dan mampu mematuhi instruksi tiga langkah."
                        ],
                        "social_independence" => [
                                    "Mencuci dan mengeringkan tangan sendiri setelah beraktivitas.",
                                    "Memakai dan melepas pakaian serta sepatu sendiri (tanpa kancing/tali yang rumit).",
                                    "Mampu bermain bersama anak lain secara kooperatif dan mematuhi aturan giliran sederhana.",
                                    "Bermain peran kaya imajinasi (dokter-dokteran, sekolah-sekolahan).",
                                    "Memahami konsep kepemilikan benda (“milikku” dan “milikmu”).",
                                    "Menunjukkan empati ketika melihat teman sedih atau menangis.",
                                    "Berpisah dengan tenang dari orang tua di lingkungan sekolah/PAUD yang aman."
                        ],
                        "stimulation" => [
                                    "Melatih ketangkasan fisik => melompat dengan satu kaki bergantian, meniti garis lurus, dan melempar-menangkap bola sedang.",
                                    "Melatih koordinasi motorik halus => menggunting kertas garis lurus dengan gunting tumpul anak, meronce manik besar, dan mewarnai.",
                                    "Mengenalkan angka, konsep menghitung 1 sampai 5, serta mencampur warna dasar.",
                                    "Membacakan dongeng moral setiap hari, meminta anak menceritakan kembali, dan mendiskusikan perasaan tokoh cerita.",
                                    "Mengajarkan nama lengkap ayah, ibu, dan nomor darurat atau alamat sederhana.",
                                    "Mengajarkan konsep keselamatan tubuh pribadi => area tubuh yang tidak boleh dilihat atau disentuh orang lain (underwear rule).",
                                    "Melatih kemandirian buang air, makan memakai sendok-garpu, dan merapikan mainan ke kotak."
                        ],
                        "red_flags" => [
                                    "Sering jatuh atau kesulitan menaiki anak tangga pada umur 36 bulan.",
                                    "Tidak mampu berbicara dalam kalimat 3 kata yang bermakna.",
                                    "Ucapannya sangat tidak jelas atau sering mengeluarkan air liur berlebih.",
                                    "Tidak pernah bermain pura-pura atau bermain peran imajinatif.",
                                    "Menghindari kontak sosial, tidak mau berinteraksi dengan anak lain maupun mainan.",
                                    "Tidak memahami instruksi sederhana satu atau dua langkah.",
                                    "Kehilangan keterampilan perkembangan yang sebelumnya pernah dikuasai."
                        ]
            ],
            "48-59" => [
                        "label" => "48–59 Bulan",
                        "min_months" => 48,
                        "max_months" => 59,
                        "gross_motor" => [
                                    "Berdiri dengan satu kaki selama 6 detik atau lebih secara seimbang.",
                                    "Melompat dengan satu kaki sejauh beberapa langkah.",
                                    "Menari mengikuti irama musik dan menangkap bola yang dipantulkan dari lantai."
                        ],
                        "fine_motor" => [
                                    "Meniru menggambar tanda tambah (+) dan menjiplak bentuk segitiga/kotak.",
                                    "Menggambar orang dengan sedikitnya 4–6 bagian tubuh yang jelas.",
                                    "Mengancingkan dan membuka kancing baju sendiri.",
                                    "Mampu membedakan perbandingan ukuran (panjang/pendek, besar/kecil, berat/ringan).",
                                    "Mengingat bagian alur cerita dongeng dan memahami urutan waktu (pagi, siang, malam).",
                                    "Menghitung jari tangan dan memahami konsep berhitung nyata benda 1–5."
                        ],
                        "speech_language" => [
                                    "Berbicara dengan artikulasi yang jelas dan sepenuhnya dipahami orang lain.",
                                    "Mampu bernyanyi lagu anak secara lengkap dan bercerita tentang pengalamannya.",
                                    "Menyebutkan nama lengkap dan usia tanpa dibantu.",
                                    "Menyebutkan nama-nama hari dalam seminggu dan berbagai macam warna.",
                                    "Sering bertanya “mengapa”, “bagaimana”, dan menggunakan kosakata baru.",
                                    "Mampu memprediksi apa yang akan terjadi selanjutnya dalam cerita bergambar."
                        ],
                        "social_independence" => [
                                    "Berpakaian lengkap dan menggosok gigi secara mandiri tanpa bantuan.",
                                    "Bereaksi tenang dan adaptif saat ditinggal orang tua di sekolah atau kegiatan bermain.",
                                    "Bermain peran sebagai orang dewasa (polisi, koki, guru, astronot).",
                                    "Bermain kooperatif dalam kelompok, bernegosiasi, dan berbagi mainan secara adil.",
                                    "Mampu mengungkapkan kesukaan, bakat, dan minat pribadinya dengan percaya diri."
                        ],
                        "stimulation" => [
                                    "Permainan fisik ketangkasan => lompat tali, engklek, balap karung anak, bermain sepeda roda tiga, dan berenang.",
                                    "Kegiatan prakarya dan kreativitas => melipat kertas origami sederhana, menggunting bentuk, menempel kolase, dan menggambar bebas.",
                                    "Mengenalkan angka, lambang huruf alfabet, membaca plang jalan atau label kemasan bersama anak.",
                                    "Mengajak berkebun atau memelihara hewan peliharaan sambil belajar tentang siklus kehidupan dan tanggung jawab.",
                                    "Membatasi screen time (gawai dan televisi) maksimal 1 jam per hari dengan pendampingan interaktif orang tua.",
                                    "Mengajarkan sopan santun => meminta tolong, berterima kasih, meminta maaf, dan mendengarkan orang lain berbicara.",
                                    "Memberikan pilihan terbatas kepada anak untuk melatih pengambilan keputusan (misal => memilih warna baju yang dipakai)."
                        ],
                        "red_flags" => [
                                    "Tidak dapat melompat di tempat dengan kedua kaki pada umur 48 bulan.",
                                    "Mengalami kesulitan memegang krayon atau tidak dapat menggambar orang sederhana.",
                                    "Bicara tidak jelas dan tidak mampu menjawab pertanyaan sederhana (siapa, di mana).",
                                    "Tidak menghiraukan anak lain dan tidak mau berinteraksi dengan orang di luar keluarga inti.",
                                    "Tidak menunjukkan ketertarikan pada permainan interaktif atau bermain pura-pura.",
                                    "Menolak berpakaian, tidur, atau menggunakan toilet secara ekstrem tanpa alasan yang jelas."
                        ]
            ],
            "60-72" => [
                        "label" => "60–72 Bulan",
                        "min_months" => 60,
                        "max_months" => 72,
                        "gross_motor" => [
                                    "Berdiri dengan satu kaki selama 11 detik atau lebih dengan tenang.",
                                    "Melompat jauh dengan dua kaki dan melompat lincah dengan satu kaki.",
                                    "Berjalan di garis lurus dengan menempelkan tumit ke ujung jari kaki (tandem walking)."
                        ],
                        "fine_motor" => [
                                    "Menangkap bola kecil seukuran bola tenis dengan kedua tangan secara konsisten.",
                                    "Menggambar orang lengkap dengan sedikitnya enam bagian tubuh (kepala, mata, hidung, mulut, badan, tangan, kaki).",
                                    "Mampu menggambar bentuk geometris (kotak, segitiga, persegi panjang) dengan rapi.",
                                    "Mampu menulis beberapa angka dan huruf kapital namanya sendiri.",
                                    "Mengenal angka dan mampu menghitung 5–10 benda nyata secara akurat."
                        ],
                        "speech_language" => [
                                    "Berbicara dengan tata bahasa yang baik, kalimat kompleks, dan artikulasi sangat jelas.",
                                    "Mampu menyebutkan nama lengkap diri, nama orang tua, alamat rumah, dan nomor telepon penting.",
                                    "Menjelaskan kegunaan dan bahan pembuat suatu benda (misal => sendok dibuat dari logam untuk makan).",
                                    "Menceritakan kembali cerita panjang secara runtut dari awal, tengah, hingga akhir.",
                                    "Memahami konsep analogi berlawanan (api panas, es dingin; gajah besar, semut kecil) dan seluruh warna."
                        ],
                        "social_independence" => [
                                    "Menunjukkan rasa empati, simpati, dan kepedulian tulus terhadap perasaan orang lain.",
                                    "Mematuhi peraturan permainan kelompok yang lebih terstruktur (ular tangga, petak umpet, gobak sodor).",
                                    "Memahami konsep identitas diri dan perbedaan gender secara sehat.",
                                    "Senang bernyanyi, menari, dan tampil berekspresi di depan teman atau keluarga.",
                                    "Mampu menyelesaikan perselisihan kecil dengan teman sebaya melalui kompromi."
                        ],
                        "stimulation" => [
                                    "Melanjutkan aktivitas penguatan fisik => bersepeda roda dua, permainan bola, senam, halang rintang, dan berenang.",
                                    "Mendorong eksplorasi seni rupa menggunakan beragam media (cat air, plastisin, barang bekas daur ulang).",
                                    "Membacakan buku cerita naratif dan meminta anak memprediksi akhir cerita atau membuat akhir cerita versi mereka sendiri.",
                                    "Mengenalkan konsep waktu lebih mendalam => jam analog sederhana, kalender, konsep kemarin-hari ini-besok, dan nilai uang logam/kertas.",
                                    "Melibatkan anak dalam tanggung jawab rumah tangga harian => menyiapkan meja makan, menyiram tanaman, dan merapikan tempat tidur.",
                                    "Memperkuat pemahaman tentang keselamatan diri => perlindungan dari orang asing, batas tubuh privasi, dan meminta pertolongan.",
                                    "Mendampingi penggunaan teknologi secara cerdas dan membatasi screen time maksimal 1 jam per hari."
                        ],
                        "red_flags" => [
                                    "Tidak dapat membuat gambar garis, bentuk kotak, atau bentuk sederhana pada umur 60 bulan.",
                                    "Keseimbangan tubuh sangat buruk, mudah limbung atau jatuh saat berdiri satu kaki.",
                                    "Tidak mampu mengenali bentuk dasar, huruf alfabet, atau warna pada umur 60 bulan.",
                                    "Tidak dapat menyebutkan nama lengkap dirinya sendiri.",
                                    "Tidak menunjukkan variasi ekspresi emosi yang wajar (tampak datar atau apatis).",
                                    "Tidak dapat membedakan kenyataan dan khayalan.",
                                    "Pada umur 72 bulan => tidak dapat melompat dengan satu kaki.",
                                    "Pada umur 72 bulan => tidak dapat menuliskan namanya sendiri.",
                                    "Pada umur 72 bulan => tidak dapat menceritakan kembali kejadian sederhana secara runtut.",
                                    "Pada umur 72 bulan => tidak memiliki teman dan tidak peduli pada perasaan orang lain."
                        ]
            ]
];
    }
}
