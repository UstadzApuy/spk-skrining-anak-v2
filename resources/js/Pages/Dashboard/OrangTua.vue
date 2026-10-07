<script setup>
import { Head, usePage } from '@inertiajs/vue3';

const user = usePage().props.auth.user;
</script>

<template>

    <Head title="Dashboard Orang Tua" />

    <main class="flex min-h-screen items-center justify-center bg-gray-100 px-4">
        <div class="w-full max-w-lg rounded-xl bg-white p-8 text-center shadow">
            <h1 class="text-2xl font-bold text-gray-900">
                Dashboard Orang Tua
            </h1>

            <p class="mt-2 text-gray-600">
                Selamat datang, {{ user.name }}.
            </p>

            <p class="mt-4 text-sm text-gray-500">
                Area pengisian instrumen skrining untuk anak.
            </p>
        </div>
    </main>
</template>