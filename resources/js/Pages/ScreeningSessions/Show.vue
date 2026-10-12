
<script setup>
import { Head, Link, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const page = usePage();

defineProps({
    session: {
        type: Object,
        required: true,
    },
});

function formatDate(value) {
    if (!value) {
        return '-';
    }

    const [year, month, day] = String(value)
        .slice(0, 10)
        .split('-');

    return `${day}/${month}/${year}`;
}

const instrumentLabels = {
    KPSP: 'KPSP',
    MCHAT: 'M-CHAT-R',
    GPPH: 'GPPH',
    SDQ: 'SDQ',
    SRQ: 'SRQ',
};

const instrumentStatusLabels = {
    pending: 'Belum Dikerjakan',
    in_progress: 'Sedang Dikerjakan',
    completed: 'Selesai',
    cancelled: 'Dibatalkan',
};

const instrumentStatusClasses = {
    pending: 'bg-gray-100 text-gray-700',
    in_progress: 'bg-blue-100 text-blue-700',
    completed: 'bg-green-100 text-green-700',
    cancelled: 'bg-red-100 text-red-700',
};

const sessionStatusLabels = {
    draft: 'Draft',
    in_progress: 'Sedang Berlangsung',
    pending_parent: 'Menunggu Orang Tua',
    pending_doctor_review: 'Menunggu Tinjauan Dokter',
    reviewed: 'Selesai Ditinjau',
    cancelled: 'Dibatalkan',
};

const sessionStatusClasses = {
    draft: 'bg-gray-100 text-gray-700',
    in_progress: 'bg-blue-100 text-blue-700',
    pending_parent: 'bg-yellow-100 text-yellow-800',
    pending_doctor_review: 'bg-orange-100 text-orange-800',
    reviewed: 'bg-green-100 text-green-700',
    cancelled: 'bg-red-100 text-red-700',
};


function categoryLabel(category) {
    const labels = {
        normal: 'Normal',
        ambang_borderline: 'Ambang / Borderline',
        abnormal: 'Abnormal',
    };

    return labels[category] ?? category ?? '-';
}

function srqCategoryLabel(category) {
    const labels = {
        di_bawah_nilai_pisah: 'Di bawah nilai pisah (skor 0–5)',
        gangguan_mental_emosional_distres:
            'Memenuhi nilai pisah (skor 6–20)',
    };

    return labels[category] ?? category ?? '-';
}

</script>

<template>
    <Head title="Detail Sesi Skrining" />

    <AuthenticatedLayout>
        <template #header>
            <div>
                <h2 class="text-xl font-semibold text-gray-900">
                    Detail Sesi Skrining
                </h2>

                <p class="mt-1 text-sm text-gray-500">
                    Informasi pemeriksaan pasien dan status instrumen skrining.
                </p>
            </div>
        </template>

        <div class="space-y-6">
            <div>
                <Link
                    href="/screening-sessions"
                    class="text-sm font-medium text-gray-600 hover:text-gray-900"
                >
                    &larr; Kembali ke Daftar Sesi
                </Link>
            </div>

            <section class="overflow-hidden rounded-xl bg-white shadow-sm">
                <div
                    class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-200 px-6 py-5"
                >
                    <div>
                        <h3 class="text-lg font-semibold text-gray-900">
                            Informasi Sesi
                        </h3>

                        <p class="mt-1 text-sm text-gray-500">
                            Tanggal pemeriksaan:
                            {{ formatDate(session.screening_date) }}
                        </p>
                    </div>

                    <span
                        class="rounded-full px-3 py-1 text-xs font-semibold"
                        :class="
                            sessionStatusClasses[session.status]
                            ?? 'bg-gray-100 text-gray-700'
                        "
                    >
                        {{
                            sessionStatusLabels[session.status]
                            ?? session.status
                        }}
                    </span>
                </div>

                <dl class="grid grid-cols-1 gap-6 px-6 py-5 sm:grid-cols-2">
                    <div>
                        <dt class="text-sm text-gray-500">
                            Nama Pasien
                        </dt>
                        <dd class="mt-1 text-sm font-semibold text-gray-900">
                            {{ session.patient?.name ?? '-' }}
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Nomor Rekam Medis
                        </dt>
                        <dd class="mt-1 text-sm font-semibold text-gray-900">
                            {{ session.patient?.medical_record_number ?? '-' }}
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Tanggal Lahir
                        </dt>
                        <dd class="mt-1 text-sm text-gray-900">
                            {{ formatDate(session.patient?.birth_date) }}
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Jenis Kelamin
                        </dt>
                        <dd class="mt-1 text-sm text-gray-900">
                            {{
                                session.patient?.gender === 'L'
                                    ? 'Laki-laki'
                                    : session.patient?.gender === 'P'
                                      ? 'Perempuan'
                                      : '-'
                            }}
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Umur Saat Pemeriksaan
                        </dt>
                        <dd class="mt-1 text-sm font-semibold text-gray-900">
                            {{ session.age_months }} bulan
                        </dd>
                    </div>

                    <div>
                        <dt class="text-sm text-gray-500">
                            Jumlah Instrumen
                        </dt>
                        <dd class="mt-1 text-sm text-gray-900">
                            {{ session.screening_session_instruments?.length ?? 0 }}
                            instrumen
                        </dd>
                    </div>
                </dl>
            </section>

            <section class="overflow-hidden rounded-xl bg-white shadow-sm">
                <div class="border-b border-gray-200 px-6 py-5">
                    <h3 class="text-lg font-semibold text-gray-900">
                        Instrumen Skrining
                    </h3>

                    <p class="mt-1 text-sm text-gray-500">
                        Daftar instrumen yang dipilih untuk sesi pemeriksaan ini.
                    </p>
                </div>

                <div
                    v-if="session.screening_session_instruments?.length"
                    class="divide-y divide-gray-200"
                >
                    <div
                        v-for="instrument in session.screening_session_instruments"
                        :key="instrument.id"
                        class="flex flex-wrap items-center justify-between gap-3 px-6 py-4"
                    >
                        <div>
                            <p class="text-sm font-semibold text-gray-900">
                                {{
                                    instrumentLabels[instrument.instrument_code]
                                    ?? instrument.instrument_code
                                }}
                            </p>

                            <p class="mt-1 text-xs text-gray-500">
                                Kode: {{ instrument.instrument_code }}
                            </p>
                        </div>

                        <span
                            class="rounded-full px-3 py-1 text-xs font-medium"
                            :class="
                                instrumentStatusClasses[instrument.status]
                                ?? 'bg-gray-100 text-gray-700'
                            "
                        >
                            {{
                                instrumentStatusLabels[instrument.status]
                                ?? instrument.status
                            }}
                        </span>

                        <Link
                            v-if="
                                page.props.auth?.user?.role === 'perawat'
                                && instrument.instrument_code === 'SDQ'
                                && !['reviewed', 'cancelled'].includes(session.status)
                            "
                            :href="`/screening-sessions/${session.id}/sdq`"
                            class="rounded-lg bg-gray-900 px-3 py-2 text-sm font-semibold text-white hover:bg-gray-800"
                        >
                            {{
                                instrument.status === 'completed'
                                    ? 'Buka Jawaban SDQ'
                                    : 'Kerjakan SDQ'
                            }}
                        </Link>

                        <Link
                            v-if="
                                page.props.auth?.user?.role === 'perawat'
                                && instrument.instrument_code === 'SRQ'
                                && !['reviewed', 'cancelled'].includes(session.status)
                            "
                            :href="`/screening-sessions/${session.id}/srq`"
                            class="rounded-lg bg-gray-900 px-3 py-2 text-sm font-semibold text-white hover:bg-gray-800"
                        >
                            {{
                                instrument.status === 'completed'
                                    ? 'Buka Jawaban SRQ-20'
                                    : 'Kerjakan SRQ-20'
                            }}
                        </Link>

                    </div>
                </div>

                <div v-else class="px-6 py-8 text-center">
                    <p class="text-sm text-gray-500">
                        Belum ada instrumen pada sesi ini.
                    </p>
                </div>
            </section>

            <section
                v-if="session.sdq_screening"
                class="overflow-hidden rounded-xl bg-white shadow-sm"
            >
                <div class="border-b border-gray-200 px-6 py-5">
                    <h3 class="text-lg font-semibold text-gray-900">
                        Hasil Skoring SDQ
                    </h3>

                    <p class="mt-1 text-sm text-gray-500">
                        Hasil skrining berdasarkan jawaban kuesioner SDQ.
                    </p>
                </div>

                <div class="grid grid-cols-1 gap-4 p-6 sm:grid-cols-2 lg:grid-cols-3">
                    <div class="rounded-lg border border-gray-200 p-4">
                        <p class="text-sm text-gray-500">Gejala Emosional (E)</p>
                        <p class="mt-2 text-2xl font-semibold text-gray-900">
                            {{ session.sdq_screening.emotional_score }} / 10
                        </p>
                        <p class="mt-2 text-sm font-semibold text-gray-700">
                            {{ categoryLabel(session.sdq_screening.emotional_category) }}
                        </p>
                    </div>

                    <div class="rounded-lg border border-gray-200 p-4">
                        <p class="text-sm text-gray-500">Masalah Perilaku (C)</p>
                        <p class="mt-2 text-2xl font-semibold text-gray-900">
                            {{ session.sdq_screening.conduct_score }} / 10
                        </p>
                        <p class="mt-2 text-sm font-semibold text-gray-700">
                            {{ categoryLabel(session.sdq_screening.conduct_category) }}
                        </p>
                    </div>

                    <div class="rounded-lg border border-gray-200 p-4">
                        <p class="text-sm text-gray-500">Hiperaktivitas (H)</p>
                        <p class="mt-2 text-2xl font-semibold text-gray-900">
                            {{ session.sdq_screening.hyperactivity_score }} / 10
                        </p>
                        <p class="mt-2 text-sm font-semibold text-gray-700">
                            {{ categoryLabel(session.sdq_screening.hyperactivity_category) }}
                        </p>
                    </div>

                    <div class="rounded-lg border border-gray-200 p-4">
                        <p class="text-sm text-gray-500">Masalah Teman Sebaya (P)</p>
                        <p class="mt-2 text-2xl font-semibold text-gray-900">
                            {{ session.sdq_screening.peer_score }} / 10
                        </p>
                        <p class="mt-2 text-sm font-semibold text-gray-700">
                            {{ categoryLabel(session.sdq_screening.peer_category) }}
                        </p>
                    </div>

                    <div class="rounded-lg border border-gray-200 p-4">
                        <p class="text-sm text-gray-500">
                            Total Skor Kesulitan
                        </p>
                        <p class="mt-2 text-2xl font-semibold text-gray-900">
                            {{ session.sdq_screening.total_difficulties_score }} / 40
                        </p>
                        <p class="mt-2 text-sm font-semibold text-gray-700">
                            {{
                                categoryLabel(
                                    session.sdq_screening.total_difficulties_category
                                )
                            }}
                        </p>
                    </div>

                    <div class="rounded-lg border border-gray-200 p-4">
                        <p class="text-sm text-gray-500">
                            Perilaku Prososial
                        </p>
                        <p class="mt-2 text-2xl font-semibold text-gray-900">
                            {{ session.sdq_screening.prosocial_score }} / 10
                        </p>
                        <p class="mt-2 text-sm font-semibold text-gray-700">
                            {{
                                categoryLabel(
                                    session.sdq_screening.prosocial_category
                                )
                            }}
                        </p>
                    </div>
                </div>

                <div
                    v-if="session.sdq_screening.recommendation"
                    class="border-t border-gray-200 px-6 py-5"
                >
                    <h4 class="text-sm font-semibold text-gray-900">
                        Rekomendasi
                    </h4>
                    <p class="mt-2 text-sm leading-6 text-gray-700">
                        {{ session.sdq_screening.recommendation }}
                    </p>
                </div>

                <p class="border-t border-gray-200 px-6 py-4 text-xs text-gray-500">
                    Hasil SDQ merupakan hasil skrining, bukan diagnosis klinis.
                </p>
            </section>

            <section
                v-if="session.srq_screening"
                class="overflow-hidden rounded-xl bg-white shadow-sm"
            >
                <div class="border-b border-gray-200 px-6 py-5">
                    <h3 class="text-lg font-semibold text-gray-900">
                        Hasil SRQ-20 Orang Tua/Pengasuh
                    </h3>

                    <p class="mt-1 text-sm text-gray-500">
                        Hasil berdasarkan jawaban responden selama 30 hari terakhir.
                    </p>
                </div>

                <div class="p-6">
                    <div class="rounded-lg border border-gray-200 p-5">
                        <p class="text-sm text-gray-500">
                            Skor Total SRQ-20
                        </p>

                        <p class="mt-2 text-3xl font-semibold text-gray-900">
                            {{ session.srq_screening.score }} / 20
                        </p>

                        <p class="mt-2 text-sm font-semibold text-gray-700">
                            {{ srqCategoryLabel(session.srq_screening.category) }}
                        </p>
                    </div>

                    <div
                        v-if="session.srq_screening.answers?.[16] === true"
                        class="mt-4 rounded-lg border border-red-300 bg-red-50 p-4"
                    >
                        <h4 class="text-sm font-semibold text-red-900">
                            Perlu Perhatian Klinis
                        </h4>

                        <p class="mt-2 text-sm leading-6 text-red-800">
                            Responden menjawab Ya pada pertanyaan 17 mengenai
                            pikiran untuk mengakhiri hidup. Pastikan dokter meninjau
                            jawaban ini dan menindaklanjutinya sesuai prosedur klinis
                            yang berlaku, terlepas dari skor total SRQ-20.
                        </p>
                    </div>
                </div>

                <p class="border-t border-gray-200 px-6 py-4 text-xs leading-5 text-gray-500">
                    SRQ-20 merupakan instrumen skrining, bukan alat diagnosis klinis.
                    Skor ini menggambarkan kondisi orang tua/pengasuh yang mengisi
                    kuesioner, bukan hasil pengukuran langsung kondisi mental anak.
                    Dokter perlu menafsirkan hasil sesuai kondisi responden dan
                    informasi klinis yang tersedia.
                </p>
            </section>

        </div>
    </AuthenticatedLayout>
</template>
