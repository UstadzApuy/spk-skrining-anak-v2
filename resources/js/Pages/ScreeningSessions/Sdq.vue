
<script setup>
import { computed } from 'vue';
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
    'Dapat memperdulikan perasaan orang lain.',
    'Gelisah, terlalu aktif, tidak dapat diam untuk waktu lama.',
    'Sering mengeluh sakit kepala, sakit perut atau sakit lainnya.',
    'Kalau mempunyai mainan, kesenangan atau pensil, anak bersedia berbagi dengan anak-anak lain.',
    'Sering sulit mengendalikan kemarahan.',
    'Cenderung menyendiri, lebih suka bermain seorang diri.',
    'Umumnya bertingkah laku baik, biasanya melakukan apa yang disuruh oleh orang dewasa.',
    'Banyak kekhawatiran atau sering tampak khawatir.',
    'Suka menolong jika seseorang terluka, kecewa atau merasa sakit.',
    'Terus menerus bergerak dengan resah atau menggeliat-geliat.',
    'Mempunyai satu atau lebih teman baik.',
    'Sering berkelahi dengan anak-anak lain atau mengintimidasi mereka.',
    'Sering merasa tidak bahagia, sedih atau menangis.',
    'Pada umumnya disukai oleh anak-anak lain.',
    'Mudah teralih perhatiannya, tidak dapat berkonsentrasi.',
    'Gugup atau sulit berpisah dengan orang tua/pengasuhnya pada situasi baru, mudah kehilangan rasa percaya diri.',
    'Bersikap baik terhadap anak-anak yang lebih muda.',
    'Sering berbohong atau berbuat curang.',
    'Diganggu, dipermainkan, diintimidasi atau diancam oleh anak-anak lain.',
    'Sering menawarkan diri untuk membantu orang lain (orang tua, guru, anak-anak lain).',
    'Sebelum melakukan sesuatu, ia berpikir dahulu tentang akibatnya.',
    'Mencuri dari rumah, sekolah atau tempat lain.',
    'Lebih mudah berteman dengan orang dewasa daripada dengan anak-anak lain.',
    'Banyak yang ditakuti, mudah menjadi takut.',
    'Memiliki perhatian yang baik terhadap apa pun, mampu menyelesaikan tugas atau pekerjaan rumah sampai selesai.',
];

const options = [
    { label: 'Tidak Benar', value: 0 },
    { label: 'Agak Benar', value: 1 },
    { label: 'Selalu Benar', value: 2 },
];

const form = useForm({
    answers: Array.from(
        { length: 25 },
        (_, index) => props.existingAnswers[index] ?? null
    ),
});

const answeredCount = computed(() => {
    return form.answers.filter(
        (answer) => answer !== null && answer !== ''
    ).length;
});

const allAnswered = computed(() => answeredCount.value === 25);

function submit() {
    form.post(`/screening-sessions/${props.session.id}/sdq`);
}

function formatDate(value) {
    if (!value) {
        return '-';
    }

    const [year, month, day] = String(value)
        .slice(0, 10)
        .split('-');

    return `${day}/${month}/${year}`;
}
</script>

<template>
    <Head title="Pengisian SDQ" />

    <AuthenticatedLayout>
        <template #header>
            <div>
                <h2 class="text-xl font-semibold text-gray-900">
                    Pengisian Kuesioner SDQ
                </h2>

                <p class="mt-1 text-sm text-gray-500">
                    Strengths and Difficulties Questionnaire — Usia 4–11 Tahun
                </p>
            </div>
        </template>

        <div class="mx-auto max-w-4xl space-y-6">
            <Link
                :href="`/screening-sessions/${session.id}`"
                class="inline-block text-sm font-medium text-gray-600 hover:text-gray-900"
            >
                &larr; Kembali ke Detail Sesi
            </Link>

            <section class="rounded-xl bg-white p-6 shadow-sm">
                <h3 class="text-lg font-semibold text-gray-900">
                    Informasi Pasien
                </h3>

                <dl class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div>
                        <dt class="text-sm text-gray-500">
                            Nama Pasien
                        </dt>
                        <dd class="mt-1 text-sm font-medium text-gray-900">
                            {{ session.patient?.name ?? '-' }}
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Nomor Rekam Medis
                        </dt>
                        <dd class="mt-1 text-sm font-medium text-gray-900">
                            {{ session.patient?.medical_record_number ?? '-' }}
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Tanggal Pemeriksaan
                        </dt>
                        <dd class="mt-1 text-sm font-medium text-gray-900">
                            {{ formatDate(session.screening_date) }}
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Umur Saat Pemeriksaan
                        </dt>
                        <dd class="mt-1 text-sm font-medium text-gray-900">
                            {{ session.age_months }} bulan
                        </dd>
                    </div>
                </dl>
            </section>

            <section class="rounded-xl border border-blue-200 bg-blue-50 p-5">
                <h3 class="font-semibold text-blue-900">
                    Petunjuk Pengisian
                </h3>

                <p class="mt-2 text-sm leading-6 text-blue-900">
                    Untuk setiap pernyataan, pilih satu jawaban yang paling
                    sesuai dengan keadaan anak selama enam bulan terakhir.
                    Jawablah seluruh 25 pernyataan sebelum menyimpan hasil.
                </p>

                <p class="mt-2 text-sm leading-6 text-blue-900">
                    Pilihan jawaban: Tidak Benar, Agak Benar, atau Selalu Benar.
                </p>
            </section>

            <form
                class="space-y-5"
                @submit.prevent="submit"
            >
                <section class="overflow-hidden rounded-xl bg-white shadow-sm">
                    <div
                        class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-200 px-6 py-5"
                    >
                        <div>
                            <h3 class="text-lg font-semibold text-gray-900">
                                Pernyataan SDQ
                            </h3>

                            <p class="mt-1 text-sm text-gray-500">
                                Jawaban terisi: {{ answeredCount }} dari 25
                            </p>
                        </div>

                        <span
                            class="rounded-full bg-gray-100 px-3 py-1 text-xs font-medium text-gray-700"
                        >
                            {{ Math.round((answeredCount / 25) * 100) }}%
                        </span>
                    </div>

                    <div class="h-1.5 bg-gray-100">
                        <div
                            class="h-1.5 bg-gray-800 transition-all"
                            :style="{ width: `${(answeredCount / 25) * 100}%` }"
                        />
                    </div>

                    <div class="divide-y divide-gray-200">
                        <fieldset
                            v-for="(question, index) in questions"
                            :key="index"
                            class="px-5 py-5 sm:px-6"
                        >
                            <legend class="w-full">
                                <span class="text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Pernyataan {{ index + 1 }}
                                </span>

                                <span class="mt-2 block text-sm font-medium leading-6 text-gray-900">
                                    {{ question }}
                                </span>
                            </legend>

                            <div class="mt-4 grid grid-cols-1 gap-2 sm:grid-cols-3">
                                <label
                                    v-for="option in options"
                                    :key="option.value"
                                    class="flex cursor-pointer items-center gap-3 rounded-lg border p-3 text-sm"
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

                                    <span class="text-gray-700">
                                        {{ option.label }}
                                    </span>
                                </label>
                            </div>
                        </fieldset>
                    </div>
                </section>

                <p
                    v-if="form.errors.answers || form.errors['answers.0']"
                    role="alert"
                    class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700"
                >
                    {{
                        form.errors.answers
                        ?? 'Periksa kembali jawaban SDQ. Semua pernyataan wajib dijawab.'
                    }}
                </p>

                <p
                    v-if="Object.keys(form.errors).some((key) => key.startsWith('answers.'))"
                    role="alert"
                    class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700"
                >
                    Terdapat jawaban yang belum terisi atau tidak valid.
                    Periksa kembali seluruh pernyataan.
                </p>

                <div
                    class="flex flex-wrap items-center justify-between gap-3 rounded-xl bg-white p-5 shadow-sm"
                >
                    <p class="text-sm text-gray-500">
                        Pastikan semua jawaban benar sebelum menyimpan.
                    </p>

                    <button
                        type="submit"
                        :disabled="form.processing || !allAnswered"
                        class="rounded-lg bg-gray-900 px-5 py-3 text-sm font-semibold text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                        {{
                            form.processing
                                ? 'Menyimpan Jawaban...'
                                : 'Simpan Jawaban dan Hitung Skor'
                        }}
                    </button>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>
