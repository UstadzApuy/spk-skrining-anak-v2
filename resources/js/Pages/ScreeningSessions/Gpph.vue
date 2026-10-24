<script setup>
import { ref, computed } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    session: {
        type: Object,
        required: true,
    },
    questions: {
        type: Array,
        required: true,
    },
    existingAnswers: {
        type: Array,
        default: () => [],
    },
    existingExaminerDoubtful: {
        type: Boolean,
        default: false,
    },
});

const scaleOptions = [
    {
        label: 'Tidak Pernah',
        sublabel: 'Nilai 0: Gejala ini tidak pernah terlihat dalam 6 bulan terakhir.',
        value: 0,
        color: 'border-emerald-600 dark:border-emerald-500 bg-emerald-50/80 dark:bg-emerald-950/60 text-emerald-950 dark:text-emerald-100',
        activeRing: 'border-emerald-600 bg-emerald-600 text-white',
    },
    {
        label: 'Kadang-kadang',
        sublabel: 'Nilai 1: Muncul sesekali, tidak intensif dan tidak mendominasi.',
        value: 1,
        color: 'border-blue-600 dark:border-blue-500 bg-blue-50/80 dark:bg-blue-950/60 text-blue-950 dark:text-blue-100',
        activeRing: 'border-blue-600 bg-blue-600 text-white',
    },
    {
        label: 'Sering',
        sublabel: 'Nilai 2: Sering terlihat dan cukup mengganggu aktivitas belajar/sosial.',
        value: 2,
        color: 'border-amber-600 dark:border-amber-500 bg-amber-50/80 dark:bg-amber-950/60 text-amber-950 dark:text-amber-100',
        activeRing: 'border-amber-600 bg-amber-600 text-white',
    },
    {
        label: 'Selalu',
        sublabel: 'Nilai 3: Hampir selalu terjadi setiap hari dengan intensitas berat.',
        value: 3,
        color: 'border-rose-600 dark:border-rose-500 bg-rose-50/80 dark:bg-rose-950/60 text-rose-950 dark:text-rose-100',
        activeRing: 'border-rose-600 bg-rose-600 text-white',
    },
];

const gpphDetails = [
    {
        domain: 'Aktivitas Motorik Berlebih (Hiperaktivitas)',
        guidance: 'Amati apakah anak terus-menerus bergerak lincah tanpa lelah, sulit duduk tenang di kursi, atau seolah digerakkan oleh mesin motor.',
        clinical_focus: 'Menilai tingkat kegelisahan motorik kasar di mana anak tampak selalu bergerak lincah tanpa tujuan jelas, seolah tubuhnya didorong oleh motor penggerak tanpa mengenal rasa lelah.',
        behavior_examples: 'Berlari-lari di dalam ruangan saat anak lain duduk rapi, melompat-lompat di atas kursi atau meja, tidak dapat tenang saat jam makan atau istirahat.',
        scoring_guide: 'Pilih 0 jika tenang dan wajar sesuai usianya; 1 jika sesekali gelisah namun mudah ditenangkan; 2 jika sering berlari dan mengganggu; 3 jika hampir tidak pernah bisa duduk diam sepanjang hari.',
    },
    {
        domain: 'Regulasi Gairah & Impulsivitas',
        guidance: 'Amati apakah anak mudah menjadi terlalu gembira dan bertindak spontan tanpa berpikir bahaya atau konsekuensi tindakannya.',
        clinical_focus: 'Menilai ketidakmampuan anak dalam menahan dorongan instan (inhibitory control), di mana kegembiraan atau respons emosi meledak-ledak tanpa memperhitungkan keselamatan diri atau orang lain.',
        behavior_examples: 'Tiba-tiba berteriak kegirangan tanpa kendali, berlari menyeberang jalan tanpa melihat kanan-kiri, menyambar barang berbahaya tanpa izin.',
        scoring_guide: 'Pilih 0 jika mampu menahan diri; 1 jika sesekali bertindak spontan yang wajar; 2 jika sering bertindak tergesa-gesa dan berisiko bahaya; 3 jika sangat impulsif dan butuh pengawasan ekstra setiap detik.',
    },
    {
        domain: 'Interaksi Teman Sebaya & Batasan Sosial',
        guidance: 'Amati apakah anak sering merebut mainan, menyenggol, menyela, atau mengganggu anak-anak lain yang sedang beraktivitas.',
        clinical_focus: 'Menilai kesulitan anak menghormati ruang pribadi dan aktivitas bermain orang lain, sering memicu konflik antarteman karena ketidaksabaran atau kebiasaan menginterupsi.',
        behavior_examples: 'Merebut mainan teman yang sedang dimainkan, merusak susunan balok karya teman, menyenggol atau mendorong teman saat berbaris atau mendengarkan guru.',
        scoring_guide: 'Pilih 0 jika rukun dan menghormati teman; 1 jika pernah berebut mainan sesekali; 2 jika sering memicu pertengkaran di kelompok; 3 jika terus-menerus mengganggu hingga dijauhi oleh teman sebaya.',
    },
    {
        domain: 'Ketahanan Atensi & Ketuntasan Tugas',
        guidance: 'Amati apakah anak cepat bosan dan meninggalkan kegiatan/permainan yang baru dimulai sebelum menyelesaikannya.',
        clinical_focus: 'Menilai defisit atensi berkelanjutan (sustained attention), di mana anak tidak mampu mempertahankan minat untuk menuntaskan kegiatan atau permainan sederhana sesuai umurnya.',
        behavior_examples: 'Baru mewarnai sedikit sudah ditinggalkan, memainkan puzzle 2 keping lalu beralih ke mobil-mobilan, meninggalkan tugas sekolah setengah jadi dan berpindah ke hal lain.',
        scoring_guide: 'Pilih 0 jika terbiasa menuntaskan kegiatan; 1 jika kadang bosan pada tugas yang panjang; 2 jika sebagian besar kegiatan terbengkalai; 3 jika hampir tidak pernah menyelesaikan satu pun aktivitas hingga tuntas.',
    },
    {
        domain: 'Gelisah Motorik Halus (Fidgeting)',
        guidance: 'Amati apakah tangan atau kaki anak selalu bergerak, mengetuk-ngetuk meja, atau menggoyang-goyangkan kepala terus-menerus.',
        clinical_focus: 'Menilai kegelisahan motorik involunter seperti mengetukkan jari, mengayunkan kaki, menggoyangkan badan atau kepala saat sedang duduk diam.',
        behavior_examples: 'Kaki berayun-ayun terus-menerus di kursi, tangan memilin ujung baju atau pensil tanpa henti, memutar badan ke kiri dan kanan saat harus duduk tenang.',
        scoring_guide: 'Pilih 0 jika postur tubuh tenang; 1 jika ada gerakan kecil yang tidak mengganggu; 2 jika kaki atau tangan sering mengetuk berisik; 3 jika gerakan gelisah ekstrem terjadi tanpa henti.',
    },
    {
        domain: 'Daya Konsentrasi & Kerentanan Distraksi',
        guidance: 'Amati apakah anak sulit mempertahankan perhatian pada penjelasan guru/orang tua dan sangat mudah teralihkan oleh suara atau pemandangan sekitar.',
        clinical_focus: 'Menilai kerentanan fokus anak terhadap stimulus minor di sekitarnya (suara burung, derit pintu, orang melintas di luar jendela) yang membuat perhatian anak buyar seketika.',
        behavior_examples: 'Pandangan langsung buyar begitu ada orang lewat, tidak mendengar saat namanya dipanggil di kelas karena melamun, lupa arahan yang baru saja diberikan.',
        scoring_guide: 'Pilih 0 jika fokus mendengarkan; 1 jika kadang menoleh bila ada bunyi keras; 2 jika sangat mudah teralihkan oleh stimulus kecil; 3 jika tidak mampu fokus lebih dari 1 menit.',
    },
    {
        domain: 'Toleransi Frustrasi & Penundaan Kepuasan',
        guidance: 'Amati reaksi anak jika keinginannya tidak langsung dipenuhi: apakah anak langsung merajuk, marah besar, atau tidak sabar menunggu giliran.',
        clinical_focus: 'Menilai ketidakmampuan menunda pemenuhan keinginan (delayed gratification), anak menuntut respon instan dan cepat marah atau frustrasi jika diminta menunggu giliran.',
        behavior_examples: 'Menangis atau menjerit jika tidak langsung dibelikan mainan, tidak sabar menunggu giliran bermain ayunan, memaksa orang tua melayani saat itu juga.',
        scoring_guide: 'Pilih 0 jika mampu mengantre dan sabar menunggu; 1 jika mengeluh sedikit saat menunggu; 2 jika sering merajuk jika diminta sabar; 3 jika langsung histeris bila ada penundaan keinginan.',
    },
    {
        domain: 'Labilitas Emosi & Kepekaan Berlebih',
        guidance: 'Amati frekuensi menangis anak: apakah anak sangat mudah menangis hanya karena masalah kecil atau teguran biasa.',
        clinical_focus: 'Menilai ambang toleransi emosional yang sangat rendah, di mana teguran ringan, kegagalan kecil, atau kritik sederhana langsung memicu tangisan hebat yang sulit ditenangkan.',
        behavior_examples: 'Menangis tersedu-sedu hanya karena tidak sengaja tersenggol teman, menangis keras jika ditegur guru dengan lembut, cengeng sepanjang hari di sekolah.',
        scoring_guide: 'Pilih 0 jika emosi stabil dan wajar; 1 jika menangis hanya jika ada rasa sakit fisik nyata; 2 jika sangat sensitif dan mudah tersinggung; 3 jika menangis berulang kali setiap hari karena hal sepele.',
    },
    {
        domain: 'Stabilitas Afektif (Mood Swing)',
        guidance: 'Amati apakah emosi anak berfluktuasi dengan cepat dan drastis dari tertawa riang menjadi cemberut atau marah dalam waktu singkat.',
        clinical_focus: 'Menilai perubahan suasana hati (affective instability) yang terjadi cepat dan tiba-tiba tanpa pemicu lingkungan yang jelas atau sepadan.',
        behavior_examples: 'Semenit lalu tertawa riang, tiba-tiba menjadi murung, marah, atau memusuhi orang di dekatnya tanpa alasan masuk akal.',
        scoring_guide: 'Pilih 0 jika suasana hati stabil; 1 jika ada perubahan mood wajar saat lelah atau lapar; 2 jika perubahan drastis terjadi beberapa kali seminggu; 3 jika mood bergejolak ekstrem setiap hari.',
    },
    {
        domain: 'Ledakan Kemarahan & Perilaku Eksplosif',
        guidance: 'Amati apakah anak memiliki episode ledakan amarah hebat, menjerit, melempar barang, atau perilaku agresif yang tak terduga.',
        clinical_focus: 'Menilai episode amukan emosi tak terkontrol (temper tantrum eksplosif) yang berpotensi membahayakan fisik anak sendiri, orang lain, atau merusak benda sekitar.',
        behavior_examples: 'Melempar piring atau mainan dengan keras ke lantai, memukul dinding atau orang tua saat kesal, bergulingan di lantai sambil berteriak histeris tak terkendali.',
        scoring_guide: 'Pilih 0 jika tidak pernah mengamuk eksplosif; 1 jika tantrum ringan yang cepat reda; 2 jika sering mengamuk dengan melempar barang; 3 jika agresi destruktif parah dan sulit ditenangkan sama sekali.',
    },
];

const form = useForm({
    answers: Array.from(
        { length: 10 },
        (_, index) => props.existingAnswers[index] ?? null
    ),
    examiner_doubtful: props.existingExaminerDoubtful,
});

const currentIndex = ref(0);

const currentQuestionText = computed(() => props.questions[currentIndex.value] ?? '');
const currentDetail = computed(() => gpphDetails[currentIndex.value] ?? { domain: 'Pengamatan Klinis GPPH', guidance: 'Amati gejala perilaku anak sehari-hari.' });

const answeredCount = computed(() => {
    return form.answers.filter(
        (answer) => answer !== null && answer !== ''
    ).length;
});

const allAnswered = computed(() => answeredCount.value === 10);

const progressPercent = computed(() => {
    return Math.round(((currentIndex.value + 1) / props.questions.length) * 100);
});

function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function goToNext() {
    if (currentIndex.value < props.questions.length - 1) {
        currentIndex.value++;
        scrollToTop();
    }
}

function goToPrev() {
    if (currentIndex.value > 0) {
        currentIndex.value--;
        scrollToTop();
    }
}

function goToQuestion(index) {
    if (index >= 0 && index < props.questions.length) {
        currentIndex.value = index;
        scrollToTop();
    }
}

function selectAnswer(val) {
    form.answers[currentIndex.value] = val;
}

function submit() {
    form.post(`/screening-sessions/${props.session.id}/gpph`);
}
</script>

<template>
    <Head title="Pengisian GPPH / ACTRS" />

    <AuthenticatedLayout>
        <!-- Top Navigation Breadcrumb & Header -->
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4">
                <nav class="flex items-center gap-2 text-xs font-semibold text-gray-500">
                    <Link :href="`/screening-sessions/${session.id}`" class="text-teal hover:text-navy transition font-bold">
                        Detail Sesi #{{ session.id }}
                    </Link>
                    <span>&rsaquo;</span>
                    <span class="text-gray-400">Instrumen Skrining</span>
                    <span>&rsaquo;</span>
                    <span class="text-navy font-bold">GPPH / ACTRS (Deteksi Gangguan Pemusatan Perhatian)</span>
                </nav>

                <div class="flex items-center gap-3">
                    <span class="rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700 border border-blue-200">
                        SESI ID: #{{ session.id }}
                    </span>
                    <span class="rounded-full bg-amber-50 px-3 py-1 text-xs font-bold text-amber-700 border border-amber-200">
                        Target Usia: 36–72 Bulan
                    </span>
                </div>
            </div>
        </template>

        <div class="mx-auto max-w-4xl space-y-6">
            <!-- Patient Quick Pill & Back Link -->
            <div class="flex flex-wrap items-center justify-between gap-4">
                <Link
                    :href="`/screening-sessions/${session.id}`"
                    class="inline-flex items-center gap-1.5 text-xs font-bold text-gray-600 hover:text-navy transition"
                >
                    &larr; Kembali ke Detail Sesi Skrining
                </Link>

                <div class="flex items-center gap-3 rounded-xl bg-white px-4 py-2 border border-sand/40 shadow-2xs text-xs">
                    <span class="text-gray-400 font-semibold">Pasien:</span>
                    <span class="font-bold text-navy">{{ session.patient?.name ?? '-' }}</span>
                    <span class="text-gray-300">|</span>
                    <span class="text-gray-400 font-semibold">No. RM:</span>
                    <span class="font-bold text-teal">{{ session.patient?.medical_record_number ?? '-' }}</span>
                    <span class="text-gray-300">|</span>
                    <span class="text-gray-400 font-semibold">Umur:</span>
                    <span class="font-bold text-navy">{{ session.age_months }} Bulan</span>
                </div>
            </div>

            <!-- TITLE & PROGRESS SECTION (Matching Visily UI Mockup #3) -->
            <section class="rounded-2xl border border-sand/40 bg-white p-6 shadow-xs space-y-5">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="flex h-5 w-5 items-center justify-center rounded-full bg-blue-600 text-white text-2xs font-black">
                                ✓
                            </span>
                            <span class="text-xs font-bold uppercase tracking-wider text-blue-700">
                                Abbreviated Conners Teacher Rating Scale (GPPH ACTRS)
                            </span>
                        </div>
                        <h1 class="mt-1 text-xl sm:text-2xl font-black text-navy tracking-tight">
                            Deteksi Dini Gangguan Pemusatan Perhatian & Hiperaktivitas
                        </h1>
                    </div>

                    <div class="text-right">
                        <span class="text-xs font-bold text-gray-400 block uppercase tracking-wider">Status Pengisian</span>
                        <span class="text-sm font-black" :class="allAnswered ? 'text-emerald-600' : 'text-blue-600'">
                            {{ answeredCount }} dari {{ questions.length }} Butir Terisi
                        </span>
                    </div>
                </div>

                <!-- Progress Bar & Stepper Counter -->
                <div class="space-y-2">
                    <div class="flex items-center justify-between text-xs font-bold">
                        <span class="uppercase tracking-wider text-blue-700">
                            PROGRES PENGERJAAN
                        </span>
                        <span class="text-gray-600">
                            BUTIR {{ currentIndex + 1 }} DARI {{ questions.length }}
                        </span>
                    </div>

                    <!-- Progress bar -->
                    <div class="h-2 w-full overflow-hidden rounded-full bg-blue-100">
                        <div
                            class="h-full bg-blue-600 transition-all duration-300 ease-out"
                            :style="{ width: `${progressPercent}%` }"
                        />
                    </div>
                </div>

                <!-- Question Navigation Pills / Quick Jumper -->
                <div class="flex flex-wrap items-center gap-1.5 pt-1">
                    <button
                        v-for="(q, idx) in questions"
                        :key="idx"
                        type="button"
                        @click="goToQuestion(idx)"
                        class="flex h-8 w-8 items-center justify-center rounded-lg text-xs font-bold transition shadow-2xs"
                        :class="
                            currentIndex === idx
                                ? 'bg-blue-600 text-white ring-2 ring-blue-400 ring-offset-1'
                                : form.answers[idx] !== null && form.answers[idx] !== ''
                                ? 'bg-emerald-50 dark:bg-emerald-950/80 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold hover:bg-emerald-100 dark:hover:bg-emerald-900/60'
                                : 'bg-gray-50 dark:bg-white/10 text-gray-600 dark:text-gray-300 border border-gray-200 dark:border-white/10 hover:bg-gray-100 dark:hover:bg-white/20'
                        "
                        :title="`Menuju butir ke-${idx + 1}`"
                    >
                        {{ idx + 1 }}
                    </button>
                </div>
            </section>

            <!-- SINGLE QUESTION STEP CARD (Per Page 1 Soal + Petunjuk + Penjelasan Detail) -->
            <form @submit.prevent="submit" class="space-y-6">
                <section class="rounded-2xl border border-sand/40 bg-white p-6 sm:p-8 shadow-xs space-y-6">
                    <!-- Domain Badge & Question Header -->
                    <div class="space-y-2">
                        <div class="flex items-center gap-2">
                            <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-bold border bg-rose-50 dark:bg-rose-950/70 text-rose-800 dark:text-rose-300 border-rose-300 dark:border-rose-700">
                                Aspek: {{ currentDetail.domain }}
                            </span>
                            <span class="text-xs font-semibold text-gray-400">
                                Butir Soal Nomor {{ currentIndex + 1 }}
                            </span>
                        </div>

                        <!-- Question Text -->
                        <h2 class="text-lg sm:text-xl font-black text-navy leading-relaxed">
                            {{ currentQuestionText }}
                        </h2>
                    </div>

                    <!-- PETUNJUK PENGISIAN & OBSERVASI (Selalu Ada di Setiap Halaman) -->
                    <div class="rounded-xl border border-blue-200 dark:border-blue-800/60 bg-blue-50/70 dark:bg-blue-950/40 p-4 sm:p-5 text-xs text-blue-950 dark:text-blue-100 space-y-1.5">
                        <div class="flex items-center gap-2 font-bold text-blue-900 dark:text-blue-300 text-sm">
                            <svg class="h-4 w-4 shrink-0 text-blue-700 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <span>Petunjuk Pengamatan Klinis GPPH</span>
                        </div>
                        <p class="leading-relaxed font-medium">
                            {{ currentDetail.guidance }}
                        </p>
                        <div class="mt-2 pt-2 border-t border-blue-200/60 dark:border-blue-800/40 flex flex-wrap gap-4 text-3xs sm:text-2xs font-semibold text-blue-800 dark:text-blue-200">
                            <span>&bull; <strong>Nilai 0</strong> = Tidak Pernah &bull; <strong>Nilai 1</strong> = Kadang-kadang &bull; <strong>Nilai 2</strong> = Sering &bull; <strong>Nilai 3</strong> = Selalu</span>
                        </div>
                    </div>

                    <!-- PENJELASAN DETAIL & PANDUAN OBSERVASI (Tanpa Gambar, Penjelasan Rinci) -->
                    <div class="rounded-2xl border border-sand/50 dark:border-white/10 bg-[#FAF9F5] dark:bg-[#071D37] p-5 sm:p-6 space-y-4 shadow-2xs">
                        <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-teal dark:text-teal-300">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                            <span>Penjelasan Detail Gejala & Contoh Perilaku</span>
                        </div>

                        <!-- Makna Klinis Gejala -->
                        <div class="space-y-1">
                            <span class="font-bold text-navy dark:text-white text-xs block">Definisi & Signifikansi Gejala:</span>
                            <p class="text-xs sm:text-sm text-gray-700 dark:text-gray-200 leading-relaxed font-medium">
                                {{ currentDetail.clinical_focus }}
                            </p>
                        </div>

                        <!-- Contoh Perilaku Nyata -->
                        <div class="rounded-xl border border-amber-200 dark:border-amber-800/60 bg-amber-50/70 dark:bg-amber-950/40 p-3.5 space-y-1 text-xs">
                            <div class="flex items-center gap-1.5 font-bold text-amber-900 dark:text-amber-300">
                                <span>🔍</span>
                                <span>Contoh Manifestasi Perilaku di Kelas / Rumah:</span>
                            </div>
                            <p class="text-amber-950 dark:text-amber-100 leading-relaxed text-2xs sm:text-xs">
                                {{ currentDetail.behavior_examples }}
                            </p>
                        </div>

                        <!-- Panduan Rubrik Skor -->
                        <div class="rounded-xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-3.5 space-y-1 text-2xs sm:text-xs">
                            <span class="font-bold text-navy dark:text-white block">Panduan Skoring Skala (0–3):</span>
                            <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                                {{ currentDetail.scoring_guide }}
                            </p>
                        </div>
                    </div>

                    <!-- KARTU PILIHAN JAWABAN (4 Interactive Selection Cards - Visily Mockup #3) -->
                    <div class="space-y-3">
                        <label class="block text-xs font-bold uppercase tracking-wider text-gray-500">
                            Tingkat Frekuensi Gejala:
                        </label>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <button
                                v-for="opt in scaleOptions"
                                :key="opt.value"
                                type="button"
                                @click="selectAnswer(opt.value)"
                                class="flex items-center justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === opt.value
                                        ? opt.color + ' ring-2 ring-opacity-20'
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-blue-300 dark:hover:border-blue-500/40 hover:bg-blue-50/20 dark:hover:bg-blue-950/20 text-gray-800 dark:text-gray-200'
                                "
                            >
                                <div class="space-y-1">
                                    <div class="flex items-center gap-2">
                                        <span class="flex h-5 w-5 items-center justify-center rounded-full text-xs font-black" :class="form.answers[currentIndex] === opt.value ? 'bg-navy dark:bg-white text-white dark:text-navy' : 'bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-gray-300'">
                                            {{ opt.value }}
                                        </span>
                                        <span class="block text-base font-black text-navy dark:text-white">
                                            {{ opt.label }}
                                        </span>
                                    </div>
                                    <span class="block text-xs text-gray-600 dark:text-gray-400 font-medium">
                                        {{ opt.sublabel }}
                                    </span>
                                </div>

                                <div
                                    class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border-2 transition ml-3"
                                    :class="
                                        form.answers[currentIndex] === opt.value
                                            ? opt.activeRing
                                            : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                    "
                                >
                                    <span v-if="form.answers[currentIndex] === opt.value" class="text-xs font-black">✓</span>
                                </div>
                            </button>
                        </div>
                    </div>

                    <!-- CATATAN KERAGUAN PEMERIKSA (Klinis SDIDTK) -->
                    <div class="rounded-xl border border-amber-200 dark:border-amber-800/60 bg-amber-50/60 dark:bg-amber-950/40 p-4 flex items-center justify-between gap-4">
                        <div class="space-y-0.5">
                            <span class="text-xs font-bold text-amber-900 dark:text-amber-300 block">Status Keraguan Pemeriksa (Optional)</span>
                            <p class="text-2xs text-amber-800 dark:text-amber-200">
                                Centang bila pemeriksa meragukan hasil observasi ini (secara klinis otomatis direkomendasikan rujukan lanjutan).
                            </p>
                        </div>
                        <label class="flex items-center gap-2 text-xs font-bold text-amber-950 dark:text-amber-100 cursor-pointer shrink-0">
                            <input
                                v-model="form.examiner_doubtful"
                                type="checkbox"
                                class="rounded border-amber-300 dark:border-amber-600 text-amber-600 focus:ring-amber-500 h-4 w-4"
                            />
                            <span>Pemeriksa Ragu</span>
                        </label>
                    </div>
                </section>

                <!-- BOTTOM ACTION BAR (Back, Auto-saved Notice, Next / Submit) -->
                <section class="flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-sand/40 bg-white p-5 shadow-xs">
                    <button
                        type="button"
                        @click="goToPrev"
                        :disabled="currentIndex === 0"
                        class="rounded-xl border border-sand/60 px-5 py-2.5 text-xs font-bold text-navy hover:bg-sand-light disabled:opacity-40 disabled:cursor-not-allowed transition shadow-2xs"
                    >
                        &larr; Butir Sebelumnya
                    </button>

                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="flex h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                        <span>Jawaban tersimpan otomatis</span>
                        <span>&bull;</span>
                        <span class="font-bold text-navy">{{ answeredCount }} / {{ questions.length }} Terjawab</span>
                    </div>

                    <div class="flex items-center gap-3">
                        <button
                            v-if="currentIndex < questions.length - 1"
                            type="button"
                            @click="goToNext"
                            class="rounded-xl bg-blue-600 hover:bg-blue-700 px-6 py-2.5 text-xs font-bold text-white transition shadow-xs"
                        >
                            Butir Selanjutnya &rarr;
                        </button>

                        <button
                            v-else
                            type="submit"
                            :disabled="form.processing || !allAnswered"
                            class="rounded-xl bg-emerald-600 hover:bg-emerald-700 px-6 py-2.5 text-xs font-bold text-white disabled:opacity-50 disabled:cursor-not-allowed transition shadow-sm"
                        >
                            {{ form.processing ? 'Menghitung Skor...' : 'Simpan Jawaban & Hitung Skor GPPH' }}
                        </button>
                    </div>
                </section>
            </form>

            <!-- GUIDELINES REFERENCE CARD (Matching Visily UI Mockup #3) -->
            <section class="rounded-2xl border border-sand/40 bg-[#FAF7F0] p-6 shadow-xs space-y-4">
                <h3 class="text-xs font-bold uppercase tracking-wider text-navy">
                    PEDOMAN KLINIS & ACUAN EVALUASI GPPH (ACTRS)
                </h3>

                <div class="grid grid-cols-1 gap-4 sm:grid-cols-3 text-xs">
                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Ambang Batas Skor (Threshold)</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Total Skor &ge; 13: <strong>Kemungkinan GPPH</strong>.<br>
                            Total Skor &lt; 13 & ragu: <strong>Kemungkinan GPPH (Ragu)</strong>.<br>
                            Total Skor &lt; 13 & tidak ragu: <strong>Bukan GPPH</strong>.
                        </p>
                    </div>

                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Aturan Tindak Lanjut</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Anak dengan kemungkinan GPPH perlu dirujuk ke Rumah Sakit / Klinik Tumbuh Kembang untuk pemeriksaan mendalam oleh Dokter Spesialis Anak atau Psikiater Anak.
                        </p>
                    </div>

                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Kesesuaian Rentang Usia</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Standar baku Kemenkes RI diperuntukkan bagi anak usia 36 hingga 72 bulan (3–6 tahun).
                        </p>
                    </div>
                </div>
            </section>
        </div>
    </AuthenticatedLayout>
</template>
