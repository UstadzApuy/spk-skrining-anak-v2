<script setup>
import { computed } from 'vue';
import { Head, useForm } from '@inertiajs/vue3';

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
    'Apakah Anda sering merasa sakit kepala?',
    'Apakah Anda kehilangan nafsu makan?',
    'Apakah tidur Anda tidak nyenyak?',
    'Apakah Anda mudah merasa takut?',
    'Apakah Anda merasa cemas, tegang, atau khawatir?',
    'Apakah tangan Anda gemetar?',
    'Apakah Anda mengalami gangguan pencernaan?',
    'Apakah Anda merasa sulit berpikir jernih?',
    'Apakah Anda merasa tidak bahagia?',
    'Apakah Anda lebih sering menangis?',
    'Apakah Anda merasa sulit untuk menikmati aktivitas sehari-hari?',
    'Apakah Anda merasa kesulitan untuk mengambil keputusan?',
    'Apakah aktivitas/tugas sehari-hari Anda terbengkalai?',
    'Apakah Anda merasa tidak mampu berperan dalam kehidupan ini?',
    'Apakah Anda kehilangan minat terhadap banyak hal?',
    'Apakah Anda merasa tidak berharga?',
    'Apakah Anda mempunyai pikiran untuk mengakhiri hidup Anda?',
    'Apakah Anda merasa lelah sepanjang waktu?',
    'Apakah Anda merasa tidak enak di perut?',
    'Apakah Anda mudah lelah?',
];

const options = [
    { label: 'Ya', value: true },
    { label: 'Tidak', value: false },
];

const form = useForm({
    answers: Array.from(
        { length: 20 },
        (_, index) => props.existingAnswers[index] ?? null,
    ),
});

const answeredCount = computed(() =>
    form.answers.filter(
        (answer) => answer === true || answer === false,
    ).length,
);

const allAnswered = computed(() => answeredCount.value === 20);

function submit() {
    form.post(`/screening-sessions/${props.session.id}/srq`, {
        preserveScroll: true,
    });
}
</script>

<template>
    <Head title="Pengisian SRQ-20" />

    <main class="min-h-screen bg-gray-50 px-4 py-6 sm:px-6">
        <div class="mx-auto max-w-3xl space-y-6">
            <header class="text-center">
                <p class="text-sm font-medium uppercase tracking-wide text-gray-500">
                    Kuesioner untuk Orang Tua/Pengasuh
                </p>

                <h1 class="mt-2 text-2xl font-bold text-gray-900 sm:text-3xl">
                    Self Rating Questionnaire (SRQ-20)
                </h1>

                <p class="mt-2 text-sm text-gray-600">
                    Bacalah setiap pertanyaan dengan saksama.
                </p>
            </header>

            <section class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6">
                <h2 class="text-lg font-semibold text-gray-900">
                    Petunjuk Pengisian
                </h2>

                <div class="mt-3 space-y-3 text-sm leading-6 text-gray-700">
                    <p>
                        Pertanyaan berikut berkaitan dengan masalah yang
                        mungkin Anda alami selama 30 hari terakhir.
                        Kuesioner ini menanyakan keadaan Anda sendiri,
                        bukan keadaan anak.
                    </p>

                    <p>
                        Pilih <strong>Ya</strong> jika Anda mengalami hal
                        yang ditanyakan selama 30 hari terakhir. Pilih
                        <strong>Tidak</strong> jika Anda tidak mengalaminya.
                        Jika ragu, pilih jawaban yang paling sesuai.
                    </p>

                    <p>
                        Jawablah sendiri sesuai keadaan Anda. Jawaban Anda
                        bersifat rahasia.
                    </p>
                </div>
            </section>

            <form class="space-y-5" @submit.prevent="submit">
                <section class="overflow-hidden rounded-xl bg-white shadow-sm">
                    <div
                        class="flex items-center justify-between gap-3 border-b border-gray-200 px-5 py-4 sm:px-6"
                    >
                        <div>
                            <h2 class="font-semibold text-gray-900">
                                Daftar Pertanyaan
                            </h2>

                            <p class="mt-1 text-sm text-gray-500">
                                Terjawab {{ answeredCount }} dari 20 pertanyaan
                            </p>
                        </div>

                        <span
                            class="rounded-full bg-gray-100 px-3 py-1 text-sm font-medium text-gray-700"
                        >
                            {{ Math.round((answeredCount / 20) * 100) }}%
                        </span>
                    </div>

                    <div class="h-1.5 bg-gray-100">
                        <div
                            class="h-1.5 bg-gray-800 transition-all"
                            :style="{ width: `${(answeredCount / 20) * 100}%` }"
                        />
                    </div>

                    <div class="divide-y divide-gray-200">
                        <fieldset
                            v-for="(question, index) in questions"
                            :key="index"
                            class="px-5 py-5 sm:px-6"
                        >
                            <legend class="w-full">
                                <span
                                    class="text-xs font-semibold uppercase tracking-wide text-gray-500"
                                >
                                    Pertanyaan {{ index + 1 }}
                                </span>

                                <span
                                    class="mt-2 block text-sm font-medium leading-6 text-gray-900"
                                >
                                    {{ question }}
                                </span>
                            </legend>

                            <div class="mt-3 grid grid-cols-2 gap-3">
                                <label
                                    v-for="option in options"
                                    :key="option.label"
                                    class="flex cursor-pointer items-center gap-3 rounded-lg border p-4 text-sm transition"
                                    :class="
                                        form.answers[index] === option.value
                                            ? 'border-gray-900 bg-gray-50'
                                            : 'border-gray-200 hover:bg-gray-50'
                                    "
                                >
                                    <input
                                        v-model="form.answers[index]"
                                        type="radio"
                                        :name="`answer-${index}`"
                                        :value="option.value"
                                        class="border-gray-300 text-gray-900 focus:ring-gray-500"
                                    />

                                    <span class="font-medium text-gray-800">
                                        {{ option.label }}
                                    </span>
                                </label>
                            </div>

                            <p
                                v-if="form.errors[`answers.${index}`]"
                                class="mt-2 text-sm text-red-600"
                                role="alert"
                            >
                                Jawaban ini perlu diperiksa.
                            </p>
                        </fieldset>
                    </div>
                </section>

                <div
                    v-if="form.errors.answers"
                    class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700"
                    role="alert"
                >
                    {{ form.errors.answers }}
                </div>

                <div
                    v-if="
                        Object.keys(form.errors).some(
                            (key) => key.startsWith('answers.'),
                        )
                    "
                    class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700"
                    role="alert"
                >
                    Pastikan seluruh 20 pertanyaan telah dijawab dengan benar.
                </div>

                <section class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6">
                    <p class="text-sm leading-6 text-gray-600">
                        Setelah semua pertanyaan terisi, tekan tombol
                        di bawah untuk menyimpan jawaban. Hasil akan
                        ditinjau oleh tenaga kesehatan.
                    </p>

                    <button
                        type="submit"
                        :disabled="form.processing || !allAnswered"
                        class="mt-4 w-full rounded-lg bg-gray-900 px-5 py-3 text-sm font-semibold text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                        {{
                            form.processing
                                ? 'Menyimpan Jawaban...'
                                : 'Simpan Jawaban'
                        }}
                    </button>
                </section>
            </form>

            <footer class="pb-4 text-center text-xs text-gray-500">
                Pastikan perangkat diserahkan kembali kepada petugas
                setelah pengisian selesai.
            </footer>
        </div>
    </main>
</template>
