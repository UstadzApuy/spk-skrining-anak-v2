<script setup>
import { Head, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const user = usePage().props.auth.user;
</script>

<template>
    <Head title="Dashboard Perawat" />

    <AuthenticatedLayout>
        <template #header>
            <div>
                <h2 class="text-xl font-semibold text-gray-900">
                    Dashboard Perawat
                </h2>

                <p class="mt-1 text-sm text-gray-500">
                    Pengelolaan pasien dan proses skrining anak.
                </p>
            </div>
        </template>

        <div class="rounded-xl bg-white p-6 shadow-sm">
            <h3 class="text-lg font-semibold text-gray-900">
                Selamat datang, {{ user.name }}
            </h3>

            <p class="mt-2 text-sm text-gray-600">
                Gunakan menu navigasi untuk mengelola pasien dan proses skrining.
            </p>
        </div>
    </AuthenticatedLayout>
</template>