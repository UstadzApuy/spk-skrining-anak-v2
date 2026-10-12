<script setup>
import { Head, Link, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

defineProps({
    sessions: {
        type: Object,
        required: true,
    },
});

const page = usePage();

function formatDate(value) {
    if (!value) {
        return '-';
    }

    const [year, month, day] = String(value)
        .slice(0, 10)
        .split('-');

    return `${day}/${month}/${year}`;
}

function statusLabel(status) {
    const labels = {
        draft: 'Draft',
        in_progress: 'Sedang Berlangsung',
        pending_parent: 'Menunggu Orang Tua',
        pending_doctor_review: 'Menunggu Tinjauan Dokter',
        reviewed: 'Selesai Ditinjau',
        cancelled: 'Dibatalkan',
    };

    return labels[status] ?? status;
}

function statusClass(status) {
    const classes = {
        draft: 'bg-gray-100 text-gray-700',
        in_progress: 'bg-blue-100 text-blue-700',
        pending_parent: 'bg-yellow-100 text-yellow-800',
        pending_doctor_review: 'bg-orange-100 text-orange-800',
        reviewed: 'bg-green-100 text-green-700',
        cancelled: 'bg-red-100 text-red-700',
    };

    return classes[status] ?? 'bg-gray-100 text-gray-700';
}

function instrumentStatusLabel(status) {
    const labels = {
        pending: 'Belum Dikerjakan',
        in_progress: 'Sedang Dikerjakan',
        completed: 'Selesai',
        cancelled: 'Dibatalkan',
    };

    return labels[status] ?? status;
}

const instrumentLabels = {
    KPSP: 'KPSP',
    MCHAT: 'M-CHAT-R',
    GPPH: 'GPPH',
    SDQ: 'SDQ',
    SRQ: 'SRQ',
};
</script>

<template>
    <Head title="Sesi Skrining" />

    <AuthenticatedLayout>
        <template #header>
            <div>
                <h2 class="text-xl font-semibold text-gray-900">
                    Sesi Skrining
                </h2>

                <p class="mt-1 text-sm text-gray-500">
                    Pengelolaan pemeriksaan skrining anak dan status
                    pengerjaan instrumennya.
                </p>
            </div>
        </template>

        <div class="space-y-6">
            <div
                v-if="page.props.flash?.success"
                role="status"
                aria-live="polite"
                class="rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800"
            >
                {{ page.props.flash.success }}
            </div>

            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h3 class="text-lg font-semibold text-gray-900">
                        Daftar Sesi
                    </h3>

                    <p class="mt-1 text-sm text-gray-500">
                        Total {{ sessions.total ?? sessions.data.length }}
                        sesi skrining
                    </p>
                </div>

                <div class="flex flex-wrap gap-3">
                    <Link
                        v-if="page.props.auth?.user?.role === 'perawat'"
                        href="/patients"
                        class="rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50"
                    >
                        Kembali ke Data Pasien
                    </Link>

                    <Link
                        v-if="page.props.auth?.user?.role === 'perawat'"
                        href="/screening-sessions/create"
                        class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-semibold text-white hover:bg-gray-800"
                    >
                        Buat Sesi Skrining
                    </Link>
                </div>
            </div>

            <div class="overflow-hidden rounded-xl bg-white shadow-sm">
                <div
                    v-if="sessions.data.length"
                    class="overflow-x-auto"
                >
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th
                                    class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500"
                                >
                                    Tanggal Pemeriksaan
                                </th>

                                <th
                                    class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500"
                                >
                                    Pasien
                                </th>

                                <th
                                    class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500"
                                >
                                    Umur
                                </th>

                                <th
                                    class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500"
                                >
                                    Instrumen
                                </th>

                                <th
                                    class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500"
                                >
                                    Status Sesi
                                </th>

                                <th
                                    class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500"
                                >
                                    Aksi
                                </th>

                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-200">
                            <tr
                                v-for="session in sessions.data"
                                :key="session.id"
                                class="hover:bg-gray-50"
                            >
                                <td
                                    class="whitespace-nowrap px-6 py-4 text-sm text-gray-700"
                                >
                                    {{ formatDate(session.screening_date) }}
                                </td>

                                <td class="px-6 py-4">
                                    <p class="text-sm font-medium text-gray-900">
                                        {{ session.patient?.name ?? 'Pasien tidak ditemukan' }}
                                    </p>

                                    <p class="mt-1 text-xs text-gray-500">
                                        No. RM:
                                        {{ session.patient?.medical_record_number ?? '-' }}
                                    </p>
                                </td>

                                <td
                                    class="whitespace-nowrap px-6 py-4 text-sm text-gray-700"
                                >
                                    {{ session.age_months }} bulan
                                </td>

                                <td class="px-6 py-4">
                                    <div
                                        v-if="session.screening_session_instruments?.length"
                                        class="space-y-2"
                                    >
                                        <div
                                            v-for="instrument in session.screening_session_instruments"
                                            :key="instrument.id"
                                            class="flex flex-wrap items-center gap-2"
                                        >
                                            <span
                                                class="text-sm font-medium text-gray-800"
                                            >
                                                {{ instrumentLabels[instrument.instrument_code] ?? instrument.instrument_code }}
                                            </span>

                                            <span
                                                class="text-xs text-gray-500"
                                            >
                                                {{
                                                    instrumentStatusLabel(
                                                        instrument.status
                                                    )
                                                }}
                                            </span>
                                        </div>
                                    </div>

                                    <span
                                        v-else
                                        class="text-sm text-gray-400"
                                    >
                                        Belum ada instrumen
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-6 py-4">
                                    <span
                                        class="rounded-full px-2.5 py-1 text-xs font-medium"
                                        :class="statusClass(session.status)"
                                    >
                                        {{ statusLabel(session.status) }}
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-6 py-4">
                                    <Link
                                        :href="`/screening-sessions/${session.id}`"
                                        class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50"
                                    >
                                        Lihat Detail
                                    </Link>
                                </td>

                            </tr>
                        </tbody>
                    </table>
                </div>

                <div
                    v-else
                    class="px-6 py-12 text-center"
                >
                    <h4 class="text-sm font-semibold text-gray-900">
                        Belum ada sesi skrining
                    </h4>

                    <p class="mt-1 text-sm text-gray-500">
                        Sesi pemeriksaan yang dibuat akan ditampilkan di sini.
                    </p>
                </div>
            </div>

            <div
                v-if="sessions.links?.length > 3"
                class="flex flex-wrap justify-center gap-1"
            >
                <template
                    v-for="(link, index) in sessions.links"
                    :key="index"
                >
                    <Link
                        v-if="link.url"
                        :href="link.url"
                        class="rounded-lg border px-3 py-2 text-sm"
                        :class="
                            link.active
                                ? 'border-gray-900 bg-gray-900 text-white'
                                : 'border-gray-200 bg-white text-gray-700 hover:bg-gray-50'
                        "
                    >
                        <span v-html="link.label" />
                    </Link>

                    <span
                        v-else
                        class="rounded-lg border border-gray-100 px-3 py-2 text-sm text-gray-400"
                    >
                        <span v-html="link.label" />
                    </span>
                </template>
            </div>
        </div>
    </AuthenticatedLayout>
</template>