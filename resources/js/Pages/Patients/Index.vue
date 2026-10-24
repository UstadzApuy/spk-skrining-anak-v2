<script setup>
import { ref, computed } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    patients: {
        type: Array,
        required: true,
    },
});

const page = usePage();
const user = page.props.auth.user;

const searchQuery = ref('');

function formatDate(value) {
    if (!value) return '-';
    const [year, month, day] = String(value).slice(0, 10).split('-');
    return `${day}/${month}/${year}`;
}

const filteredPatients = computed(() => {
    if (!searchQuery.value.trim()) {
        return props.patients;
    }
    const q = searchQuery.value.toLowerCase();
    return props.patients.filter((p) =>
        p.name?.toLowerCase().includes(q) ||
        p.medical_record_number?.toLowerCase().includes(q) ||
        p.parent_guardian?.user?.name?.toLowerCase().includes(q)
    );
});
</script>

<template>
    <Head title="Data Pasien" />

    <AuthenticatedLayout>
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4">
                <div>
                    <h2 class="text-xl font-bold text-gray-900">
                        Manajemen Data Pasien Anak
                    </h2>
                    <p class="mt-1 text-sm text-gray-500">
                        Pendaftaran anak, pencatatan orang tua/wali, dan inisiasi sesi skrining tumbuh kembang.
                    </p>
                </div>

                <div v-if="user.role === 'perawat'" class="flex items-center gap-3">
                    <Link
                        href="/patients/create"
                        class="rounded-lg bg-teal-700 px-4 py-2 text-sm font-semibold text-white hover:bg-teal-800 transition shadow-sm"
                    >
                        + Tambah Pasien Baru
                    </Link>
                </div>
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

            <!-- Summary & Search Filter (Visily UI #1) -->
            <div class="flex flex-wrap items-center justify-between gap-4">
                <div class="relative w-full max-w-xs">
                    <input
                        v-model="searchQuery"
                        type="text"
                        placeholder="Cari nama, No. RM, wali..."
                        class="w-full rounded-lg border-gray-300 pl-9 text-sm shadow-sm focus:border-teal-600 focus:ring-teal-600"
                    />
                    <svg
                        class="absolute left-3 top-2.5 h-4 w-4 text-gray-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>

                <div class="text-xs text-gray-500">
                    Menampilkan <span class="font-semibold text-gray-900">{{ filteredPatients.length }}</span> dari {{ patients.length }} pasien
                </div>
            </div>

            <div class="overflow-hidden rounded-xl bg-white shadow-sm border border-gray-100">
                <div v-if="filteredPatients.length" class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200 text-left">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    No. Rekam Medis
                                </th>
                                <th class="px-6 py-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Nama Anak
                                </th>
                                <th class="px-6 py-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Tanggal Lahir
                                </th>
                                <th class="px-6 py-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Jenis Kelamin
                                </th>
                                <th class="px-6 py-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Orang Tua / Wali
                                </th>
                                <th class="px-6 py-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Status
                                </th>
                                <th class="px-6 py-3 text-right text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Aksi
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-200">
                            <tr
                                v-for="patient in filteredPatients"
                                :key="patient.id"
                                class="hover:bg-gray-50/60 transition"
                            >
                                <td class="whitespace-nowrap px-6 py-4 text-sm font-semibold text-teal-800">
                                    {{ patient.medical_record_number }}
                                </td>

                                <td class="px-6 py-4 text-sm font-medium text-gray-900">
                                    {{ patient.name }}
                                    <span v-if="patient.is_premature" class="ml-1.5 inline-flex items-center rounded bg-amber-50 px-1.5 py-0.5 text-2xs font-semibold text-amber-700 border border-amber-200">
                                        Prematur
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-600">
                                    {{ formatDate(patient.birth_date) }}
                                </td>

                                <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-600">
                                    {{ patient.gender === 'L' ? 'Laki-laki' : patient.gender === 'P' ? 'Perempuan' : '-' }}
                                </td>

                                <td class="px-6 py-4 text-sm text-gray-600">
                                    {{ patient.parent_guardian?.user?.name ?? '-' }}
                                    <span v-if="patient.guardian_relationship" class="text-xs text-gray-400 block">
                                        ({{ patient.guardian_relationship }})
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-6 py-4">
                                    <span
                                        class="rounded-full px-2.5 py-0.5 text-xs font-semibold"
                                        :class="
                                            patient.is_active
                                                ? 'bg-emerald-100 text-emerald-800'
                                                : 'bg-gray-100 text-gray-600'
                                        "
                                    >
                                        {{ patient.is_active ? 'Aktif' : 'Tidak Aktif' }}
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-6 py-4 text-right space-x-2">
                                    <!-- Mulai Sesi Skrining (Visily UI #1 action) -->
                                    <Link
                                        v-if="user.role === 'perawat' && patient.is_active"
                                        :href="`/screening-sessions/create?patient_id=${patient.id}`"
                                        class="inline-flex items-center rounded-lg bg-teal-50 px-3 py-1.5 text-xs font-semibold text-teal-800 hover:bg-teal-100 transition border border-teal-200"
                                    >
                                        Mulai Sesi
                                    </Link>

                                    <Link
                                        v-if="user.role === 'perawat'"
                                        :href="`/patients/${patient.id}/edit`"
                                        class="text-xs font-semibold text-gray-600 hover:text-gray-900"
                                    >
                                        Ubah
                                    </Link>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div v-else class="px-6 py-12 text-center">
                    <h4 class="text-sm font-semibold text-gray-900">
                        Tidak ada data pasien yang cocok
                    </h4>
                    <p class="mt-1 text-sm text-gray-500">
                        Coba ubah kata kunci pencarian Anda.
                    </p>
                </div>
            </div>

            <p class="text-xs text-gray-400">
                Login sebagai {{ user.name }} ({{ user.role }})
            </p>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
.text-2xs {
    font-size: 0.6875rem;
    line-height: 0.95rem;
}
</style>