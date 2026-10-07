<script setup>
import { Head, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

defineProps({
    patients: {
        type: Array,
        required: true,
    },
});

const user = usePage().props.auth.user;
</script>

<template>
    <Head title="Pasien" />

    <AuthenticatedLayout>
        <template #header>
            <div>
                <h2 class="text-xl font-semibold text-gray-900">
                    Data Pasien
                </h2>

                <p class="mt-1 text-sm text-gray-500">
                    Pengelolaan data pasien untuk proses skrining anak.
                </p>
            </div>
        </template>

        <div class="space-y-6">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="text-lg font-semibold text-gray-900">
                        Daftar Pasien
                    </h3>

                    <p class="mt-1 text-sm text-gray-500">
                        Total {{ patients.length }} pasien
                    </p>
                </div>

                <button
                    type="button"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-semibold text-white hover:bg-gray-800"
                >
                    Tambah Pasien
                </button>
            </div>

            <div class="overflow-hidden rounded-xl bg-white shadow-sm">
                <div v-if="patients.length" class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    No. RM
                                </th>

                                <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Nama
                                </th>

                                <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Tanggal Lahir
                                </th>

                                <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Jenis Kelamin
                                </th>

                                <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Orang Tua/Wali
                                </th>

                                <th class="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    Status
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-200">
                            <tr
                                v-for="patient in patients"
                                :key="patient.id"
                            >
                                <td class="whitespace-nowrap px-6 py-4 text-sm font-medium text-gray-900">
                                    {{ patient.medical_record_number }}
                                </td>

                                <td class="px-6 py-4 text-sm text-gray-700">
                                    {{ patient.name }}
                                </td>

                                <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-700">
                                    {{ patient.birth_date }}
                                </td>

                                <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-700">
                                    {{ patient.gender }}
                                </td>

                                <td class="px-6 py-4 text-sm text-gray-700">
                                    {{ patient.parent_guardian?.user?.name ?? '-' }}
                                </td>

                                <td class="whitespace-nowrap px-6 py-4">
                                    <span
                                        class="rounded-full px-2.5 py-1 text-xs font-medium"
                                        :class="
                                            patient.is_active
                                                ? 'bg-green-100 text-green-700'
                                                : 'bg-gray-100 text-gray-600'
                                        "
                                    >
                                        {{ patient.is_active ? 'Aktif' : 'Tidak Aktif' }}
                                    </span>
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
                        Belum ada pasien
                    </h4>

                    <p class="mt-1 text-sm text-gray-500">
                        Data pasien belum tersedia.
                    </p>
                </div>
            </div>

            <p class="text-xs text-gray-400">
                Login sebagai {{ user.name }} ({{ user.role }})
            </p>
        </div>
    </AuthenticatedLayout>
</template>