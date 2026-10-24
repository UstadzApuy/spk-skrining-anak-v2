<script setup>
import { ref, computed } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    session: {
        type: Object,
        required: true,
    },
    existingAnswers: {
        type: Array,
        default: () => [],
    },
});

const questions = [
    {
        text: 'Dapat memperdulikan perasaan orang lain.',
        category: 'Kepedulian Sosial',
        tip: 'Contoh: Anak peka bila temannya sedang sedih, menangis, atau terluka, dan berusaha menghibur.',
    },
    {
        text: 'Gelisah, terlalu aktif, tidak dapat diam untuk waktu lama.',
        category: 'Aktivitas & Ketenangan',
        tip: 'Contoh: Anak sulit duduk tenang, selalu bergerak atau melompat-lompat saat diminta duduk tertib.',
    },
    {
        text: 'Sering mengeluh sakit kepala, sakit perut atau sakit lainnya.',
        category: 'Keluhan Fisik',
        tip: 'Contoh: Anak sering mengeluh pusing atau mulas, terutama saat merasa cemas atau menghadapi hal baru.',
    },
    {
        text: 'Kalau mempunyai mainan, makanan atau pensil, anak bersedia berbagi dengan anak-anak lain.',
        category: 'Berbagi & Berteman',
        tip: 'Contoh: Mau meminjamkan barangnya atau berbagi camilan dengan temannya dengan senang hati.',
    },
    {
        text: 'Sering sulit mengendalikan kemarahan.',
        category: 'Pengendalian Emosi',
        tip: 'Contoh: Cepat marah, suka menjerit, atau mengamuk bila keinginannya tidak langsung dituruti.',
    },
    {
        text: 'Cenderung menyendiri, lebih suka bermain seorang diri.',
        category: 'Kebiasaan Bermain',
        tip: 'Contoh: Lebih suka bermain sendiri di sudut daripada ikut bermain bersama teman-temannya.',
    },
    {
        text: 'Umumnya bertingkah laku baik, biasanya melakukan apa yang disuruh oleh orang dewasa.',
        category: 'Kepatuhan & Aturan',
        tip: 'Contoh: Patuh dan mau mendengarkan nasihat orang tua atau guru dengan baik.',
    },
    {
        text: 'Banyak kekhawatiran atau sering tampak khawatir.',
        category: 'Perasaan & Rasa Cemas',
        tip: 'Contoh: Sering cemas, ragu-ragu, atau takut menghadapi hal-hal kecil sehari-hari.',
    },
    {
        text: 'Suka menolong jika seseorang terluka, kecewa atau merasa sakit.',
        category: 'Kepedulian Sosial',
        tip: 'Contoh: Spontan mendekat dan membantu jika melihat teman atau adik kesusahan.',
    },
    {
        text: 'Terus menerus bergerak dengan resah atau menggeliat-geliat.',
        category: 'Aktivitas & Ketenangan',
        tip: 'Contoh: Tangan atau kaki selalu mengetuk-ngetuk, atau tubuh menggeliat saat duduk di kursi.',
    },
    {
        text: 'Mempunyai satu atau lebih teman baik.',
        category: 'Pertemanan',
        tip: 'Contoh: Memiliki sahabat dekat untuk bermain, mengobrol, dan berbagi cerita.',
    },
    {
        text: 'Sering berkelahi dengan anak-anak lain atau mengintimidasi mereka.',
        category: 'Perilaku Terhadap Teman',
        tip: 'Contoh: Suka memukul, mendorong, mengejek, atau mengganggu temannya.',
    },
    {
        text: 'Sering merasa tidak bahagia, sedih atau menangis.',
        category: 'Suasana Hati',
        tip: 'Contoh: Tampak murung, sering menangis, atau terlihat kehilangan keceriaan.',
    },
    {
        text: 'Pada umumnya disukai oleh anak-anak lain.',
        category: 'Penerimaan Teman',
        tip: 'Contoh: Mudah berteman dan disenangi oleh teman-teman sebayanya.',
    },
    {
        text: 'Mudah teralih perhatiannya, tidak dapat berkonsentrasi.',
        category: 'Fokus & Konsentrasi',
        tip: 'Contoh: Perhatiannya cepat buyar jika ada suara atau orang lewat saat sedang belajar/bermain.',
    },
    {
        text: 'Gugup atau sulit berpisah dengan orang tua/pengasuh pada situasi baru.',
        category: 'Kemandirian & Rasa Percaya Diri',
        tip: 'Contoh: Menempel terus pada orang tua dan takut ditinggal di tempat baru (seperti sekolah/tempat les).',
    },
    {
        text: 'Bersikap baik terhadap anak-anak yang lebih muda.',
        category: 'Kasih Sayang',
        tip: 'Contoh: Ramah, sabar, dan menyayangi adik atau anak yang usianya lebih kecil.',
    },
    {
        text: 'Sering berbohong atau berbuat curang.',
        category: 'Kejujuran',
        tip: 'Contoh: Suka berbohong untuk menghindari teguran atau suka curang saat bermain.',
    },
    {
        text: 'Diganggu, dipermainkan, diintimidasi atau diancam oleh anak-anak lain.',
        category: 'Pengalaman di Lingkungan',
        tip: 'Contoh: Sering diejek, dijahili, atau dijauhi oleh kelompok temannya di sekolah/rumah.',
    },
    {
        text: 'Sering menawarkan diri untuk membantu orang lain (orang tua, guru, anak-anak lain).',
        category: 'Inisiatif Membantu',
        tip: 'Contoh: Suka berinisiatif membantu merapikan mainan atau membawakan barang tanpa disuruh.',
    },
    {
        text: 'Sebelum melakukan sesuatu, ia berpikir dahulu tentang akibatnya.',
        category: 'Kehati-hatian',
        tip: 'Contoh: Berhati-hati dan memikirkan akibatnya sebelum bertindak, tidak tergesa-gesa.',
    },
    {
        text: 'Mencuri dari rumah, sekolah atau tempat lain.',
        category: 'Penghormatan Hak Milik',
        tip: 'Contoh: Pernah mengambil barang atau uang milik orang lain tanpa izin.',
    },
    {
        text: 'Lebih mudah berteman dengan orang dewasa daripada dengan anak-anak lain.',
        category: 'Pola Bergaul',
        tip: 'Contoh: Lebih suka mengobrol dengan orang tua daripada bermain bersama teman sebayanya.',
    },
    {
        text: 'Banyak yang ditakuti, mudah menjadi takut.',
        category: 'Ketakutan & Rasa Takut',
        tip: 'Contoh: Sangat penakut pada hal-hal seperti gelap, hewan, tempat sepi, atau suara keras.',
    },
    {
        text: 'Memiliki perhatian yang baik terhadap apa pun, mampu menyelesaikan tugas sampai selesai.',
        category: 'Ketekunan Belajar',
        tip: 'Contoh: Tekun dan menyelesaikan tugas sekolah, PR, atau permainannya sampai tuntas.',
    },
];

const options = [
    {
        label: 'Tidak Benar',
        desc: 'Tidak pernah atau jarang sekali seperti ini',
        value: 0,
        badgeColor: 'text-gray-500 dark:text-gray-300 bg-gray-100 dark:bg-white/10',
        activeClass: 'border-slate-500 dark:border-slate-400 bg-slate-100 dark:bg-slate-900/60 text-slate-900 dark:text-slate-100 ring-2 ring-slate-400/30',
        activeDot: 'bg-slate-700 dark:bg-slate-300 text-white dark:text-slate-900',
    },
    {
        label: 'Agak Benar',
        desc: 'Kadang-kadang anak bersikap seperti ini',
        value: 1,
        badgeColor: 'text-amber-800 dark:text-amber-300 bg-amber-100 dark:bg-amber-950/60',
        activeClass: 'border-ochre dark:border-amber-400 bg-ochre/10 dark:bg-amber-950/50 text-ochre dark:text-amber-200 ring-2 ring-ochre/20',
        activeDot: 'bg-ochre dark:bg-amber-400 text-white dark:text-amber-950',
    },
    {
        label: 'Selalu Benar',
        desc: 'Sering atau sangat cocok menggambarkan anak',
        value: 2,
        badgeColor: 'text-teal dark:text-teal-300 bg-teal/15 dark:bg-teal-950/60',
        activeClass: 'border-teal dark:border-teal-400 bg-teal/10 dark:bg-teal-950/50 text-teal dark:text-teal-200 ring-2 ring-teal/20',
        activeDot: 'bg-teal dark:text-white',
    },
];

const form = useForm({
    answers: Array.from(
        { length: 25 },
        (_, index) => props.existingAnswers[index] ?? null
    ),
});

const currentIndex = ref(0);

const currentQuestion = computed(() => questions[currentIndex.value] ?? {});

const answeredCount = computed(() => {
    return form.answers.filter(
        (answer) => answer !== null && answer !== ''
    ).length;
});

const allAnswered = computed(() => answeredCount.value === 25);

const progressPercent = computed(() => {
    return Math.round(((currentIndex.value + 1) / questions.length) * 100);
});

function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function goToNext() {
    if (currentIndex.value < questions.length - 1) {
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
    if (index >= 0 && index < questions.length) {
        currentIndex.value = index;
        scrollToTop();
    }
}

function selectAnswer(val) {
    form.answers[currentIndex.value] = val;
}

function submit() {
    form.post(`/screening-sessions/${props.session.id}/sdq`);
}
</script>

<template>
    <Head title="Pengisian Kuesioner SDQ" />

    <AuthenticatedLayout>
        <!-- Top Navigation -->
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4">
                <nav class="flex items-center gap-2 text-xs font-semibold text-gray-500">
                    <Link :href="`/screening-sessions/${session.id}`" class="text-teal hover:text-navy transition font-bold">
                        Detail Sesi #{{ session.id }}
                    </Link>
                    <span>&rsaquo;</span>
                    <span class="text-gray-400">Instrumen Skrining</span>
                    <span>&rsaquo;</span>
                    <span class="text-navy font-bold">SDQ (Kekuatan & Perilaku Anak)</span>
                </nav>

                <div class="flex items-center gap-2">
                    <span class="rounded-full bg-sand-light px-3 py-1 text-xs font-bold text-navy border border-sand/50">
                        Sasaran: Anak 4–18 Tahun
                    </span>
                </div>
            </div>
        </template>

        <div class="mx-auto max-w-3xl space-y-5">
            <!-- Patient Bar & Back -->
            <div class="flex flex-wrap items-center justify-between gap-3 text-xs">
                <Link
                    :href="`/screening-sessions/${session.id}`"
                    class="inline-flex items-center gap-1.5 font-bold text-gray-600 hover:text-navy transition"
                >
                    &larr; Kembali ke Detail Sesi
                </Link>

                <div class="flex items-center gap-2.5 rounded-xl bg-white px-3.5 py-1.5 border border-sand/40 shadow-2xs">
                    <span class="text-gray-400">Anak:</span>
                    <span class="font-bold text-navy">{{ session.patient?.name ?? '-' }}</span>
                    <span class="text-gray-300">&bull;</span>
                    <span class="text-gray-400">Umur:</span>
                    <span class="font-bold text-teal">{{ session.age_months }} Bulan</span>
                </div>
            </div>

            <!-- Clean Friendly Header Card -->
            <section class="rounded-2xl border border-sand/40 bg-white p-5 sm:p-6 shadow-xs space-y-4">
                <div class="flex flex-wrap items-center justify-between gap-2">
                    <div>
                        <span class="text-2xs font-extrabold uppercase tracking-wider text-teal">
                            Kuesioner Kekuatan & Perilaku Anak (SDQ)
                        </span>
                        <h1 class="text-lg sm:text-xl font-black text-navy mt-0.5">
                            Pertanyaan {{ currentIndex + 1 }} dari {{ questions.length }}
                        </h1>
                    </div>

                    <div class="text-right">
                        <span class="text-xs font-bold" :class="allAnswered ? 'text-forest' : 'text-teal'">
                            {{ answeredCount }} / {{ questions.length }} Terisi
                        </span>
                    </div>
                </div>

                <!-- Progress Bar -->
                <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                    <div
                        class="h-full bg-teal transition-all duration-300 ease-out"
                        :style="{ width: `${progressPercent}%` }"
                    />
                </div>

                <!-- Question Pill Jumper (Compact & Easy to Tap) -->
                <div class="flex flex-wrap items-center gap-1.5 pt-1">
                    <button
                        v-for="(q, idx) in questions"
                        :key="idx"
                        type="button"
                        @click="goToQuestion(idx)"
                        class="flex h-7 w-7 sm:h-8 sm:w-8 items-center justify-center rounded-lg text-xs font-bold transition"
                        :class="
                            currentIndex === idx
                                ? 'bg-navy dark:bg-teal text-white ring-2 ring-navy/30 dark:ring-teal/40'
                                : form.answers[idx] !== null && form.answers[idx] !== ''
                                ? 'bg-forest/15 dark:bg-emerald-950/80 text-forest dark:text-emerald-300 border border-forest/30 dark:border-emerald-800 font-bold hover:bg-forest/25'
                                : 'bg-gray-100 dark:bg-white/10 text-gray-500 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-white/20 border border-transparent dark:border-white/5'
                        "
                        :title="`Nomor ${idx + 1}`"
                    >
                        {{ idx + 1 }}
                    </button>
                </div>
            </section>

            <!-- SINGLE QUESTION CARD (Clean, Breathing, Zero Wall-of-Text) -->
            <form @submit.prevent="submit" class="space-y-5">
                <section class="rounded-2xl border border-sand/40 bg-white p-6 sm:p-8 shadow-xs space-y-6">
                    <!-- Category Badge -->
                    <div>
                        <span class="inline-flex items-center rounded-full bg-sand-light dark:bg-white/10 px-3 py-1 text-xs font-bold text-navy dark:text-sand border border-sand/50 dark:border-white/10">
                            {{ currentQuestion.category }}
                        </span>
                    </div>

                    <!-- Question Text (Big, Clear, Friendly) -->
                    <h2 class="text-xl sm:text-2xl font-black text-navy leading-snug">
                        {{ currentQuestion.text }}
                    </h2>

                    <!-- Gentle 1-Line Helper Tip (Everyday Language for Parents) -->
                    <div class="rounded-xl border border-amber-200/80 dark:border-amber-800/60 bg-amber-50/70 dark:bg-amber-950/40 p-4 text-xs sm:text-sm text-amber-950 dark:text-amber-100 flex items-start gap-3">
                        <span class="text-base select-none">💡</span>
                        <div class="leading-relaxed font-medium">
                            {{ currentQuestion.tip }}
                        </div>
                    </div>

                    <!-- 3 Big, Friendly Selection Cards -->
                    <div class="space-y-3 pt-1">
                        <label class="block text-xs font-bold uppercase tracking-wider text-gray-400">
                            Pilih yang paling sesuai dengan perilaku anak 6 bulan terakhir:
                        </label>

                        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3.5">
                            <button
                                v-for="opt in options"
                                :key="opt.value"
                                type="button"
                                @click="selectAnswer(opt.value)"
                                class="flex flex-col justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === opt.value
                                        ? opt.activeClass
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-sand hover:bg-sand-light/30 dark:hover:bg-white/5 text-gray-700 dark:text-gray-200'
                                "
                            >
                                <div class="space-y-1.5 w-full">
                                    <div class="flex items-center justify-between">
                                        <span class="text-base sm:text-lg font-black" :class="form.answers[currentIndex] === opt.value ? 'text-navy dark:text-white' : 'text-gray-800 dark:text-gray-200'">
                                            {{ opt.label }}
                                        </span>
                                        <div
                                            class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border-2 transition"
                                            :class="
                                                form.answers[currentIndex] === opt.value
                                                    ? opt.activeDot
                                                    : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                            "
                                        >
                                            <span v-if="form.answers[currentIndex] === opt.value" class="text-xs font-black">✓</span>
                                        </div>
                                    </div>

                                    <p class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed font-medium">
                                        {{ opt.desc }}
                                    </p>
                                </div>
                            </button>
                        </div>
                    </div>
                </section>

                <!-- Action Bar -->
                <section class="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-sand/40 bg-white p-4 sm:p-5 shadow-xs">
                    <button
                        type="button"
                        @click="goToPrev"
                        :disabled="currentIndex === 0"
                        class="rounded-xl border border-sand/60 px-5 py-2.5 text-xs font-bold text-navy hover:bg-sand-light disabled:opacity-30 disabled:cursor-not-allowed transition"
                    >
                        &larr; Sebelumnya
                    </button>

                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="flex h-2 w-2 rounded-full bg-forest animate-pulse" />
                        <span>Jawaban tersimpan otomatis</span>
                    </div>

                    <div class="flex items-center gap-2">
                        <button
                            v-if="currentIndex < questions.length - 1"
                            type="button"
                            @click="goToNext"
                            class="rounded-xl bg-teal hover:bg-teal-dark px-6 py-2.5 text-xs font-bold text-white transition shadow-xs"
                        >
                            Selanjutnya &rarr;
                        </button>

                        <button
                            v-else
                            type="submit"
                            :disabled="form.processing || !allAnswered"
                            class="rounded-xl bg-forest hover:bg-forest-dark px-6 py-2.5 text-xs font-bold text-white disabled:opacity-40 disabled:cursor-not-allowed transition shadow-sm"
                        >
                            {{ form.processing ? 'Menyimpan...' : 'Selesai & Simpan Jawaban' }}
                        </button>
                    </div>
                </section>
            </form>

            <!-- Friendly Confidentiality Reassurance (Subtle, Not Scary) -->
            <div class="text-center text-2xs text-gray-400 py-2">
                🔒 Jawaban Anda digunakan oleh tenaga kesehatan UPTD BLK-ABK untuk membantu tumbuh kembang anak secara menyeluruh.
            </div>
        </div>
    </AuthenticatedLayout>
</template>
