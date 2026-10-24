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
    guidance: {
        type: Object,
        default: null,
    },
    existingAnswers: {
        type: Array,
        default: () => [],
    },
});

const form = useForm({
    answers: Array.from(
        { length: 10 },
        (_, index) => props.existingAnswers[index] ?? null
    ),
});

const currentIndex = ref(0);

const currentQuestion = computed(() => {
    return props.questions[currentIndex.value] ?? {};
});

const answeredCount = computed(() => {
    return form.answers.filter(
        (answer) => answer !== null && answer !== ''
    ).length;
});

const allAnswered = computed(() => answeredCount.value === 10);

const liveDomainScores = computed(() => {
    const domains = {
        'Gerak kasar': { name: 'Gerak Kasar', score: 0, total: 0, missed: [] },
        'Gerak halus': { name: 'Gerak Halus', score: 0, total: 0, missed: [] },
        'Bicara dan bahasa': { name: 'Bicara & Bahasa', score: 0, total: 0, missed: [] },
        'Sosialisasi dan kemandirian': { name: 'Sosialisasi & Kemandirian', score: 0, total: 0, missed: [] },
    };

    (props.questions || []).forEach((q, idx) => {
        const d = domains[q.domain] || domains['Gerak kasar'];
        d.total++;
        if (form.answers[idx] === true) {
            d.score++;
        } else if (form.answers[idx] === false) {
            d.missed.push(q.number);
        }
    });

    return domains;
});

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
    form.post(`/screening-sessions/${props.session.id}/kpsp`);
}

function formatDate(value) {
    if (!value) return '-';
    const [year, month, day] = String(value).slice(0, 10).split('-');
    return `${day}/${month}/${year}`;
}

function getDomainBadgeClass(domain) {
    switch (domain) {
        case 'Gerak kasar':
            return 'bg-emerald-50 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold';
        case 'Gerak halus':
            return 'bg-sky-50 dark:bg-sky-950/70 text-sky-800 dark:text-sky-300 border-sky-300 dark:border-sky-800 font-bold';
        case 'Bicara dan bahasa':
            return 'bg-violet-50 dark:bg-violet-950/70 text-violet-800 dark:text-violet-300 border-violet-300 dark:border-violet-800 font-bold';
        case 'Sosialisasi dan kemandirian':
            return 'bg-amber-50 dark:bg-amber-950/70 text-amber-800 dark:text-amber-300 border-amber-300 dark:border-amber-800 font-bold';
        default:
            return 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-300 dark:border-white/10 font-semibold';
    }
}
</script>

<template>
    <Head title="Pengisian KPSP" />

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
                    <span class="text-navy font-bold">KPSP ({{ session.form_age_months }} Bulan)</span>
                </nav>

                <div class="flex items-center gap-3">
                    <span class="rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700 border border-blue-200">
                        SESI ID: #{{ session.id }}
                    </span>
                    <span class="rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-700 border border-emerald-200">
                        Formulir KPSP: {{ session.form_age_months }} Bulan
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

            <!-- SDIDTK 2-Week Re-evaluation Alert Banner -->
            <div
                v-if="session.is_re_evaluation || session.evaluation_type === 'kpsp_re_evaluation_2_weeks'"
                class="rounded-2xl border-2 border-amber-300 bg-amber-50 dark:bg-amber-950/40 p-4 sm:p-5 text-amber-950 dark:text-amber-100 shadow-xs flex items-start gap-3.5"
            >
                <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-amber-200 dark:bg-amber-900/80 text-amber-800 dark:text-amber-200 text-lg font-black">
                    🔄
                </div>
                <div class="space-y-1">
                    <div class="flex flex-wrap items-center gap-2">
                        <span class="rounded-md bg-amber-600 px-2 py-0.5 text-3xs font-black uppercase text-white">
                            Sesi Re-evaluasi 2 Minggu
                        </span>
                        <h3 class="text-sm font-black text-amber-950 dark:text-amber-100">
                            Evaluasi Ulang KPSP Pasca Intervensi Stimulasi Dini (SDIDTK Loop)
                        </h3>
                    </div>
                    <p class="text-xs leading-relaxed text-amber-900/90 dark:text-amber-200/90">
                        Sesi ini mengevaluasi perkembangan anak setelah 14 hari intervensi terarah dari sesi skrining awal
                        <span v-if="session.parent_session_id" class="font-bold">#{{ session.parent_session_id }}</span>.
                        <strong>Golden Rule SDIDTK Kemenkes RI:</strong> Bila hasil evaluasi ulang ini tetap Meragukan (Dm: 7–8) atau menunjukkan Kemungkinan Penyimpangan (Dp: &le; 6), sistem akan merekomendasikan rujukan langsung ke Rumah Sakit.
                    </p>
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
                                Kuesioner Pra Skrining Perkembangan (KPSP)
                            </span>
                        </div>
                        <h1 class="mt-1 text-xl sm:text-2xl font-black text-navy tracking-tight">
                            Pemeriksaan Perkembangan Anak (Formulir {{ session.form_age_months }} Bulan)
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
                        :key="q.number"
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
                        :title="`Menuju butir ke-${q.number}`"
                    >
                        {{ q.number }}
                    </button>
                </div>

                <!-- Live Domain Sektor Status Indicators -->
                <div class="flex flex-wrap items-center gap-2 pt-2 border-t border-sand/30 dark:border-white/10 text-xs">
                    <span class="text-3xs font-extrabold uppercase tracking-wider text-gray-500">
                        Skor per Sektor:
                    </span>
                    <span
                        v-for="(d, dName) in liveDomainScores"
                        :key="dName"
                        class="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-0.5 text-3xs border"
                        :class="d.missed.length > 0
                            ? 'bg-rose-50 dark:bg-rose-950/60 border-rose-300 dark:border-rose-800 text-rose-800 dark:text-rose-200 font-bold'
                            : (d.score === d.total && d.total > 0)
                            ? 'bg-emerald-50 dark:bg-emerald-950/60 border-emerald-300 dark:border-emerald-800 text-emerald-800 dark:text-emerald-200 font-bold'
                            : 'bg-gray-100 dark:bg-white/10 border-gray-200 dark:border-white/10 text-gray-600 dark:text-gray-400 font-medium'"
                    >
                        <span>{{ d.name }}:</span>
                        <span>{{ d.score }}/{{ d.total }}</span>
                        <span v-if="d.missed.length > 0" class="text-rose-600 dark:text-rose-300">⚠️ (Kurang: #{{ d.missed.join(', #') }})</span>
                        <span v-else-if="d.score === d.total && d.total > 0" class="text-emerald-600 dark:text-emerald-400">✓</span>
                    </span>
                </div>
            </section>

            <!-- SINGLE QUESTION STEP CARD (Per Page 1 Soal + Petunjuk + Gambar Penjelas) -->
            <form @submit.prevent="submit" class="space-y-6">
                <section class="rounded-2xl border border-sand/40 bg-white p-6 sm:p-8 shadow-xs space-y-6">
                    <!-- Domain Badge & Question Header -->
                    <div class="space-y-2">
                        <div class="flex items-center gap-2">
                            <span
                                class="inline-flex items-center rounded-full px-3 py-1 text-xs font-bold border"
                                :class="getDomainBadgeClass(currentQuestion.domain)"
                            >
                                Sektor: {{ currentQuestion.domain }}
                            </span>
                            <span class="text-xs font-semibold text-gray-400">
                                Butir Soal Nomor {{ currentQuestion.number }}
                            </span>
                        </div>

                        <!-- Question Text -->
                        <h2 class="text-lg sm:text-xl font-black text-navy leading-relaxed">
                            {{ currentQuestion.text }}
                        </h2>
                    </div>

                    <!-- PETUNJUK PENGISIAN & OBSERVASI (Selalu Ada di Setiap Halaman) -->
                    <div class="rounded-xl border border-blue-200 dark:border-blue-800/60 bg-blue-50/70 dark:bg-blue-950/40 p-4 sm:p-5 text-xs text-blue-950 dark:text-blue-100 space-y-1.5">
                        <div class="flex items-center gap-2 font-bold text-blue-900 dark:text-blue-300 text-sm">
                            <svg class="h-4 w-4 shrink-0 text-blue-700 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <span>Petunjuk Pemeriksaan & Penilaian</span>
                        </div>
                        <p class="leading-relaxed">
                            {{ currentQuestion.guidance_note ?? 'Lakukan pengamatan langsung kemampuan anak atau tanyakan pada orang tua/pengasuh sesuai petunjuk pada butir ini.' }}
                        </p>
                        <div class="mt-2 pt-2 border-t border-blue-200/60 dark:border-blue-800/40 flex flex-wrap gap-4 text-3xs sm:text-2xs font-semibold text-blue-800 dark:text-blue-200">
                            <span>&bull; <strong>Pilih 'Ya'</strong> jika anak dapat melakukan, pernah atau sering melakukan secara mandiri.</span>
                            <span>&bull; <strong>Pilih 'Tidak'</strong> jika anak belum pernah atau belum dapat melakukan tugas tersebut.</span>
                        </div>
                    </div>

                    <!-- GAMBAR PENJELAS (Ilustrasi Klinis Resmi SDIDTK atau Diagram Panduan Pengamatan) -->
                    <div class="rounded-2xl border border-gray-200 bg-[#FAF9F5] p-5 text-center flex flex-col items-center justify-center">
                        <!-- 1. Jika ada gambar utama soal -->
                        <div v-if="currentQuestion.image" class="w-full max-w-xl space-y-3">
                            <div class="inline-block rounded-xl border border-gray-200 bg-white p-3 shadow-xs">
                                <img
                                    :src="currentQuestion.image"
                                    :alt="'Gambar Penjelas Butir ' + currentQuestion.number"
                                    class="max-h-60 max-w-full object-contain mx-auto rounded-lg"
                                />
                            </div>
                            <p class="text-xs font-bold text-gray-700">
                                Gambar Penjelas: KPSP {{ session.form_age_months }} Bulan &bull; Butir {{ currentQuestion.number }}
                            </p>
                            <p class="text-2xs text-gray-500 max-w-lg mx-auto">
                                Perhatikan posisi tubuh, sudut gerakan, atau contoh stimulus pada gambar di atas sebagai acuan baku penilaian Kemenkes RI.
                            </p>

                            <!-- Jika soal ini juga memiliki contoh Ya / Tidak berdampingan -->
                            <div v-if="currentQuestion.image_ya && currentQuestion.image_tidak" class="mt-4 pt-4 border-t border-gray-200/80">
                                <span class="text-xs font-bold uppercase tracking-wider text-navy block mb-2">
                                    Contoh Perbandingan Hasil Goresan / Respon Anak:
                                </span>
                                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-left">
                                    <div class="rounded-xl border border-emerald-200 bg-white p-2.5 space-y-1">
                                        <span class="text-2xs font-bold text-emerald-800 block">✓ Contoh 'Ya' (Benar):</span>
                                        <img :src="currentQuestion.image_ya" alt="Contoh Ya" class="max-h-20 object-contain mx-auto rounded" />
                                    </div>
                                    <div class="rounded-xl border border-rose-200 bg-white p-2.5 space-y-1">
                                        <span class="text-2xs font-bold text-rose-800 block">✕ Contoh 'Tidak' (Belum Mampu):</span>
                                        <img :src="currentQuestion.image_tidak" alt="Contoh Tidak" class="max-h-20 object-contain mx-auto rounded" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 2. Jika tidak ada gambar utama tapi ada gambar opsi Ya & Tidak (misal form 42 butir 1) -->
                        <div v-else-if="currentQuestion.image_ya || currentQuestion.image_tidak" class="w-full max-w-xl space-y-3">
                            <span class="text-xs font-bold uppercase tracking-wider text-navy block">
                                Acuan Gambar Penjelas Kriteria Jawaban (Kemenkes SDIDTK):
                            </span>
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-left">
                                <div v-if="currentQuestion.image_ya" class="rounded-xl border border-emerald-200 bg-white p-3 space-y-1.5 shadow-2xs">
                                    <span class="text-2xs font-bold text-emerald-800 block">✓ Contoh Hasil 'Ya':</span>
                                    <img :src="currentQuestion.image_ya" alt="Contoh Ya" class="max-h-28 object-contain mx-auto rounded" />
                                </div>
                                <div v-if="currentQuestion.image_tidak" class="rounded-xl border border-rose-200 bg-white p-3 space-y-1.5 shadow-2xs">
                                    <span class="text-2xs font-bold text-rose-800 block">✕ Contoh Hasil 'Tidak':</span>
                                    <img :src="currentQuestion.image_tidak" alt="Contoh Tidak" class="max-h-28 object-contain mx-auto rounded" />
                                </div>
                            </div>
                            <p class="text-2xs text-gray-500 max-w-md mx-auto">
                                Bandingkan hasil goresan atau kemampuan anak dengan contoh acuan visual baku di atas.
                            </p>
                        </div>

                        <!-- 3. Fallback domain illustration jika butir ini berupa instruksi lisan murni -->
                        <div v-else class="py-4 px-6 space-y-2">
                            <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-100 text-blue-700 shadow-2xs">
                                <svg v-if="currentQuestion.domain === 'Gerak kasar'" class="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                                </svg>
                                <svg v-else-if="currentQuestion.domain === 'Gerak halus'" class="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                                </svg>
                                <svg v-else-if="currentQuestion.domain === 'Bicara dan bahasa'" class="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                                </svg>
                                <svg v-else class="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                            </div>
                            <h4 class="text-sm font-bold text-navy">
                                Pengamatan Klinis: {{ currentQuestion.domain }}
                            </h4>
                            <p class="text-xs text-gray-500 max-w-md mx-auto">
                                Lakukan pengamatan interaksi langsung terhadap respon anak atau konfirmasi kejadian sehari-hari bersama orang tua/pengasuh.
                            </p>
                        </div>
                    </div>

                    <!-- KARTU PILIHAN JAWABAN (Interactive Selection Cards - Visily Mockup #3) -->
                    <div class="space-y-3">
                        <label class="block text-xs font-bold uppercase tracking-wider text-gray-500">
                            Pilih Jawaban Pemeriksaan:
                        </label>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <!-- Opsi Ya -->
                            <button
                                type="button"
                                @click="selectAnswer(true)"
                                class="flex flex-col justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === true
                                        ? 'border-emerald-600 dark:border-emerald-500 bg-emerald-50/80 dark:bg-emerald-950/60 text-emerald-950 dark:text-emerald-100 ring-2 ring-emerald-500/20'
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-emerald-300 dark:hover:border-emerald-500/40 hover:bg-emerald-50/20 dark:hover:bg-emerald-950/20 text-gray-800 dark:text-gray-200'
                                "
                            >
                                <div class="flex items-start justify-between w-full">
                                    <div class="space-y-1">
                                        <span class="block text-base font-black text-emerald-800 dark:text-emerald-300">
                                            Ya (Bisa / Pernah Melakukan)
                                        </span>
                                        <span class="block text-xs text-gray-600 dark:text-gray-400 font-medium">
                                            Anak mampu melakukan tugas perkembangan ini atau teramati melakukannya.
                                        </span>
                                    </div>

                                    <div
                                        class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border-2 transition ml-3"
                                        :class="
                                            form.answers[currentIndex] === true
                                                ? 'border-emerald-600 bg-emerald-600 text-white'
                                                : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                        "
                                    >
                                        <span v-if="form.answers[currentIndex] === true" class="text-xs font-black">✓</span>
                                    </div>
                                </div>

                                <!-- Gambar Opsi Ya jika tersedia -->
                                <div v-if="currentQuestion.image_ya" class="mt-3 w-full rounded-xl border border-emerald-300 dark:border-emerald-700 bg-white dark:bg-[#0C2038] p-2.5 shadow-2xs">
                                    <span class="block text-3xs font-bold uppercase tracking-wider text-emerald-800 dark:text-emerald-300 mb-1">
                                        Contoh Hasil Kriteria 'Ya':
                                    </span>
                                    <img
                                        :src="currentQuestion.image_ya"
                                        alt="Contoh Kriteria Ya"
                                        class="max-h-24 max-w-full object-contain mx-auto rounded"
                                    />
                                </div>
                            </button>

                            <!-- Opsi Tidak -->
                            <button
                                type="button"
                                @click="selectAnswer(false)"
                                class="flex flex-col justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === false
                                        ? 'border-rose-600 dark:border-rose-500 bg-rose-50/80 dark:bg-rose-950/60 text-rose-950 dark:text-rose-100 ring-2 ring-rose-500/20'
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-rose-300 dark:hover:border-rose-500/40 hover:bg-rose-50/20 dark:hover:bg-rose-950/20 text-gray-800 dark:text-gray-200'
                                "
                            >
                                <div class="flex items-start justify-between w-full">
                                    <div class="space-y-1">
                                        <span class="block text-base font-black text-rose-800 dark:text-rose-300">
                                            Tidak (Belum Pernah / Belum Bisa)
                                        </span>
                                        <span class="block text-xs text-gray-600 dark:text-gray-400 font-medium">
                                            Anak belum dapat atau belum pernah melakukan tugas perkembangan ini.
                                        </span>
                                    </div>

                                    <div
                                        class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border-2 transition ml-3"
                                        :class="
                                            form.answers[currentIndex] === false
                                                ? 'border-rose-600 bg-rose-600 text-white'
                                                : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                        "
                                    >
                                        <span v-if="form.answers[currentIndex] === false" class="text-xs font-black">✓</span>
                                    </div>
                                </div>

                                <!-- Gambar Opsi Tidak jika tersedia -->
                                <div v-if="currentQuestion.image_tidak" class="mt-3 w-full rounded-xl border border-rose-300 dark:border-rose-700 bg-white dark:bg-[#0C2038] p-2.5 shadow-2xs">
                                    <span class="block text-3xs font-bold uppercase tracking-wider text-rose-800 mb-1">
                                        Contoh Hasil Kriteria 'Tidak':
                                    </span>
                                    <img
                                        :src="currentQuestion.image_tidak"
                                        alt="Contoh Kriteria Tidak"
                                        class="max-h-24 max-w-full object-contain mx-auto rounded"
                                    />
                                </div>
                            </button>
                        </div>
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
                            {{ form.processing ? 'Menghitung Skor...' : 'Simpan Jawaban & Hitung KPSP' }}
                        </button>
                    </div>
                </section>
            </form>

            <!-- GUIDELINES REFERENCE CARD (Matching Visily UI Mockup #3) -->
            <section class="rounded-2xl border border-sand/40 bg-[#FAF7F0] p-6 shadow-xs space-y-4">
                <h3 class="text-xs font-bold uppercase tracking-wider text-navy">
                    PEDOMAN KLINIS & ACUAN EVALUASI (KEMENKES RI)
                </h3>

                <div class="grid grid-cols-1 gap-4 sm:grid-cols-3 text-xs">
                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Ambang Batas Skor (Threshold)</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Skor 9–10: <strong>Sesuai</strong> (Perkembangan sesuai umur).<br>
                            Skor 7–8: <strong>Meragukan</strong> (Perlu stimulasi 2 minggu).<br>
                            Skor &le; 6: <strong>Penyimpangan</strong> (Perlu rujukan medis).
                        </p>
                    </div>

                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Aturan Evaluasi Klinis</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Pertanyaan dengan jawaban 'Tidak' menjadi fokus rincian stimulasi 4 sektor perkembangan (Gerak Kasar, Gerak Halus, Bicara & Bahasa, Sosialisasi).
                        </p>
                    </div>

                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Kesesuaian Rentang Usia</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Formulir {{ session.form_age_months }} Bulan dipilih berdasarkan tanggal skrining dan tanggal lahir (disertai penyesuaian umur prematuritas bila ada).
                        </p>
                    </div>
                </div>
            </section>
        </div>
    </AuthenticatedLayout>
</template>
