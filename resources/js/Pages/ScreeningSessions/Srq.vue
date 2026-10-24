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
        text: 'Apakah Anda sering merasa sakit kepala?',
        category: 'Gejala Somatik',
        tip: 'Apakah Anda sering mengalami sakit kepala atau pusing berulang dalam 1 bulan terakhir?',
    },
    {
        text: 'Apakah Anda kehilangan nafsu makan?',
        category: 'Gejala Somatik',
        tip: 'Apakah selera makan Anda menurun drastis atau merasa tidak bernafsu untuk makan?',
    },
    {
        text: 'Apakah tidur Anda tidak nyenyak?',
        category: 'Gejala Cemas',
        tip: 'Apakah Anda sering sulit tidur, sering terbangun di malam hari, atau bangun tanpa rasa segar?',
    },
    {
        text: 'Apakah Anda mudah merasa takut?',
        category: 'Gejala Cemas',
        tip: 'Apakah Anda mudah kaget, merasa was-was, atau merasa takut tanpa sebab yang jelas?',
    },
    {
        text: 'Apakah Anda merasa cemas, tegang, atau khawatir?',
        category: 'Gejala Cemas',
        tip: 'Apakah pikiran Anda sering terasa tegang, gelisah, atau mencemaskan banyak hal?',
    },
    {
        text: 'Apakah tangan Anda gemetar?',
        category: 'Gejala Depresi',
        tip: 'Apakah tangan Anda sering gemetar atau bergetar saat merasa tegang atau lelah?',
    },
    {
        text: 'Apakah Anda mengalami gangguan pencernaan?',
        category: 'Gejala Somatik',
        tip: 'Apakah Anda sering mual, kembung, perih di lambung, atau sakit perut saat banyak pikiran?',
    },
    {
        text: 'Apakah Anda merasa sulit berpikir jernih?',
        category: 'Gejala Kognitif & Penurunan Energi',
        tip: 'Apakah pikiran terasa buntu, sulit berkonsentrasi, atau lambat mencerna hal sehari-hari?',
    },
    {
        text: 'Apakah Anda merasa tidak bahagia?',
        category: 'Gejala Depresi',
        tip: 'Apakah perasaan murung, sedih, atau rasa hampa sering mendominasi hari-hari Anda?',
    },
    {
        text: 'Apakah Anda lebih sering menangis?',
        category: 'Gejala Depresi',
        tip: 'Apakah Anda menjadi mudah menangis atau sering merasa ingin menangis sendiri?',
    },
    {
        text: 'Apakah Anda merasa sulit untuk menikmati aktivitas sehari-hari?',
        category: 'Gejala Penurunan Energi',
        tip: 'Apakah kegiatan yang biasanya menyenangkan kini terasa hambar atau melelahkan?',
    },
    {
        text: 'Apakah Anda merasa kesulitan untuk mengambil keputusan?',
        category: 'Gejala Kognitif & Penurunan Energi',
        tip: 'Apakah Anda sering merasa bingung dan sangat ragu-ragu menentukan pilihan sederhana?',
    },
    {
        text: 'Apakah aktivitas atau tugas sehari-hari Anda terbengkalai?',
        category: 'Gejala Kognitif & Penurunan Energi',
        tip: 'Apakah pekerjaan rumah tangga, mengurus keluarga, atau pekerjaan kantor menjadi sering tertunda?',
    },
    {
        text: 'Apakah Anda merasa tidak mampu berperan dalam kehidupan ini?',
        category: 'Gejala Depresi',
        tip: 'Apakah Anda merasa putus asa terhadap kemampuan Anda menjalankan peran sehari-hari?',
    },
    {
        text: 'Apakah Anda kehilangan minat terhadap banyak hal?',
        category: 'Gejala Depresi',
        tip: 'Apakah Anda kehilangan ketertarikan terhadap hobi, keluarga, atau rencana masa depan?',
    },
    {
        text: 'Apakah Anda merasa tidak berharga?',
        category: 'Gejala Depresi',
        tip: 'Apakah Anda sering menyalahkan diri sendiri atau merasa menjadi beban bagi orang lain?',
    },
    {
        text: 'Apakah Anda mempunyai pikiran untuk mengakhiri hidup Anda?',
        category: 'Gejala Depresi (Pikiran Bunuh Diri)',
        tip: 'Jawablah dengan jujur. Jawaban Anda dijaga ketat kerahasiaannya dan ditujukan semata-mata agar kami dapat memberikan dukungan terbaik.',
    },
    {
        text: 'Apakah Anda merasa lelah sepanjang waktu?',
        category: 'Gejala Penurunan Energi',
        tip: 'Apakah badan dan pikiran Anda terasa kehabisan tenaga terus-menerus meskipun sudah beristirahat?',
    },
    {
        text: 'Apakah Anda merasa tidak enak di perut?',
        category: 'Gejala Somatik',
        tip: 'Apakah Anda sering merasakan rasa tidak nyaman, mual, atau perih di area ulu hati/perut?',
    },
    {
        text: 'Apakah Anda mudah lelah?',
        category: 'Gejala Penurunan Energi',
        tip: 'Apakah tenaga Anda cepat terkuras habis bahkan setelah melakukan kegiatan ringan?',
    },
];

const form = useForm({
    answers: Array.from(
        { length: 20 },
        (_, index) => props.existingAnswers[index] ?? null,
    ),
});

const currentIndex = ref(0);

const currentQuestion = computed(() => questions[currentIndex.value] ?? {});

const answeredCount = computed(() =>
    form.answers.filter(
        (answer) => answer === true || answer === false,
    ).length,
);

const allAnswered = computed(() => answeredCount.value === 20);

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
    form.post(`/screening-sessions/${props.session.id}/srq`);
}
</script>

<template>
    <Head title="Pengisian Kuesioner SRQ-20" />

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
                    <span class="text-navy font-bold">SRQ-20 (Kesehatan Orang Tua/Pengasuh)</span>
                </nav>

                <div class="flex items-center gap-2">
                    <span class="rounded-full bg-purple-50 px-3 py-1 text-xs font-bold text-purple-700 border border-purple-200">
                        Sasaran: Orang Tua / Pengasuh
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
                    <span class="text-gray-400">Pasien:</span>
                    <span class="font-bold text-navy">{{ session.patient?.name ?? '-' }}</span>
                    <span class="text-gray-300">&bull;</span>
                    <span class="text-gray-400">No. RM:</span>
                    <span class="font-bold text-teal">{{ session.patient?.medical_record_number ?? '-' }}</span>
                </div>
            </div>

            <!-- Clean Friendly Header Card -->
            <section class="rounded-2xl border border-sand/40 bg-white p-5 sm:p-6 shadow-xs space-y-4">
                <div class="flex flex-wrap items-center justify-between gap-2">
                    <div>
                        <span class="text-2xs font-extrabold uppercase tracking-wider text-purple-700">
                            Kuesioner Kesejahteraan Orang Tua / Pengasuh (SRQ-20)
                        </span>
                        <h1 class="text-lg sm:text-xl font-black text-navy mt-0.5">
                            Pertanyaan {{ currentIndex + 1 }} dari {{ questions.length }}
                        </h1>
                    </div>

                    <div class="text-right">
                        <span class="text-xs font-bold" :class="allAnswered ? 'text-forest' : 'text-purple-700'">
                            {{ answeredCount }} / {{ questions.length }} Terisi
                        </span>
                    </div>
                </div>

                <!-- Progress Bar -->
                <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                    <div
                        class="h-full bg-purple-600 transition-all duration-300 ease-out"
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
                                ? 'bg-purple-700 text-white ring-2 ring-purple-300 dark:ring-purple-400'
                                : form.answers[idx] === true || form.answers[idx] === false
                                ? 'bg-purple-100 dark:bg-purple-950/80 text-purple-900 dark:text-purple-300 border border-purple-200 dark:border-purple-800 font-bold'
                                : 'bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-white/20 border border-transparent dark:border-white/5'
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
                        <span class="inline-flex items-center rounded-full bg-purple-50 dark:bg-purple-950/70 px-3 py-1 text-xs font-bold text-purple-800 dark:text-purple-300 border border-purple-200 dark:border-purple-800">
                            {{ currentQuestion.category }}
                        </span>
                    </div>

                    <!-- Question Text (Big, Clear, Friendly) -->
                    <h2 class="text-xl sm:text-2xl font-black text-navy leading-snug">
                        {{ currentQuestion.text }}
                    </h2>

                    <!-- Gentle 1-Line Helper Tip (Everyday Language for Parents) -->
                    <div class="rounded-xl border border-purple-200/80 dark:border-purple-800/60 bg-purple-50/60 dark:bg-purple-950/40 p-4 text-xs sm:text-sm text-purple-950 dark:text-purple-100 flex items-start gap-3">
                        <span class="text-base select-none">💡</span>
                        <div class="leading-relaxed font-medium">
                            {{ currentQuestion.tip }}
                        </div>
                    </div>

                    <!-- 2 Big, Friendly Selection Cards (Ya vs Tidak) -->
                    <div class="space-y-3 pt-1">
                        <label class="block text-xs font-bold uppercase tracking-wider text-gray-400">
                            Pilih jawaban berdasarkan yang Anda rasakan selama 30 hari terakhir:
                        </label>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <!-- Opsi Ya -->
                            <button
                                type="button"
                                @click="selectAnswer(true)"
                                class="flex items-center justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === true
                                        ? 'border-purple-600 dark:border-purple-500 bg-purple-50/80 dark:bg-purple-950/60 text-purple-950 dark:text-purple-100 ring-2 ring-purple-500/20'
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-purple-300 dark:hover:border-purple-500/40 hover:bg-purple-50/20 dark:hover:bg-purple-950/20 text-gray-700 dark:text-gray-200'
                                "
                            >
                                <div class="space-y-1">
                                    <span class="block text-base sm:text-lg font-black text-purple-900 dark:text-purple-300">
                                        Ya
                                    </span>
                                    <span class="block text-xs text-gray-500 dark:text-gray-400 font-medium">
                                        Saya sering merasakan hal ini dalam 1 bulan terakhir
                                    </span>
                                </div>

                                <div
                                    class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full border-2 transition ml-3"
                                    :class="
                                        form.answers[currentIndex] === true
                                            ? 'border-purple-600 bg-purple-600 text-white'
                                            : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                    "
                                >
                                    <span v-if="form.answers[currentIndex] === true" class="text-xs font-black">✓</span>
                                </div>
                            </button>

                            <!-- Opsi Tidak -->
                            <button
                                type="button"
                                @click="selectAnswer(false)"
                                class="flex items-center justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === false
                                        ? 'border-emerald-600 dark:border-emerald-500 bg-emerald-50/80 dark:bg-emerald-950/60 text-emerald-950 dark:text-emerald-100 ring-2 ring-emerald-500/20'
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-emerald-200 dark:hover:border-emerald-500/40 hover:bg-emerald-50/20 dark:hover:bg-emerald-950/20 text-gray-700 dark:text-gray-200'
                                "
                            >
                                <div class="space-y-1">
                                    <span class="block text-base sm:text-lg font-black text-emerald-800 dark:text-emerald-300">
                                        Tidak
                                    </span>
                                    <span class="block text-xs text-gray-500 dark:text-gray-400 font-medium">
                                        Saya tidak merasakan hal ini
                                    </span>
                                </div>

                                <div
                                    class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full border-2 transition ml-3"
                                    :class="
                                        form.answers[currentIndex] === false
                                            ? 'border-emerald-600 bg-emerald-600 text-white'
                                            : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                    "
                                >
                                    <span v-if="form.answers[currentIndex] === false" class="text-xs font-black">✓</span>
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
                            class="rounded-xl bg-purple-700 hover:bg-purple-800 px-6 py-2.5 text-xs font-bold text-white transition shadow-xs"
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

            <!-- Friendly Confidentiality Reassurance (Subtle, Caring, Not Intimidating) -->
            <div class="text-center text-2xs text-gray-400 py-2">
                🔒 Informasi yang Anda berikan bersifat rahasia dan digunakan untuk mendukung kesehatan serta kesejahteraan keluarga Anda.
            </div>
        </div>
    </AuthenticatedLayout>
</template>
