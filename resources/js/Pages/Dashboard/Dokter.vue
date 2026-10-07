<script setup>
import { Head, usePage } from '@inertiajs/vue3';

const user = usePage().props.auth.user;
</script>

<template>
    <Head title="Dashboard Dokter" />

    <main class="flex min-h-screen items-center justify-center bg-gray-100 px-4">
        <div class="w-full max-w-lg rounded-xl bg-white p-8 text-center shadow">
            <h1 class="text-2xl font-bold text-gray-900">
                Dashboard Dokter
            </h1>

            <p class="mt-2 text-gray-600">
                Selamat datang, {{ user.name }}.
            </p>

            <p class="mt-4 text-sm text-gray-500">
                Area review hasil skrining dan tindak lanjut.
            </p>
        </div>
    </main>
</template>