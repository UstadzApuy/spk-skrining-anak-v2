<script setup>
import { Head } from '@inertiajs/vue3';

defineProps({
    session: {
        type: Object,
        required: true,
    },
});
</script>

<template>
    <Head title="Pengisian SRQ-20 Selesai" />

    <main class="flex min-h-screen items-center justify-center bg-gray-50 px-4 py-8">
        <section class="w-full max-w-lg rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm sm:p-10">
            <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-8 w-8 text-green-700"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    aria-hidden="true"
                >
                    <path d="M20 6 9 17l-5-5" />
                </svg>
            </div>

            <h1 class="mt-6 text-2xl font-bold text-gray-900">
                Pengisian Berhasil
            </h1>

            <p class="mt-3 text-base leading-7 text-gray-600">
                Terima kasih telah melengkapi kuesioner SRQ-20.
                Jawaban Anda telah berhasil disimpan dan akan ditinjau
                oleh tenaga kesehatan.
            </p>

            <div class="mt-6 rounded-lg bg-gray-50 p-4 text-sm leading-6 text-gray-600">
                Silakan serahkan kembali perangkat kepada perawat
                yang mendampingi Anda.
            </div>
        </section>
    </main>
</template>
