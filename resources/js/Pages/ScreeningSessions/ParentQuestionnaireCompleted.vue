<script setup>
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    session: {
        type: Object,
        required: true,
    },
    completedInstrument: {
        type: Object,
        required: true,
    },
    nextInstrument: {
        type: Object,
        default: null,
    },
});
</script>

<template>
    <Head
        :title="
            nextInstrument
                ? `Pengisian ${completedInstrument.short_label} Selesai`
                : 'Pengisian Kuesioner Selesai'
        "
    />

    <main
        class="flex min-h-screen items-center justify-center bg-[#EAE6DC] dark:bg-[#071322] px-4 py-8"
    >
        <section
            class="w-full max-w-lg rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-8 text-center shadow-sm sm:p-10"
        >
            <div
                class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400"
            >
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-8 w-8"
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

            <template v-if="nextInstrument">
                <h1 class="mt-6 text-2xl font-bold text-navy dark:text-white">
                    Pengisian {{ completedInstrument.short_label }} Berhasil
                </h1>

                <p class="mt-3 text-base leading-7 text-gray-600 dark:text-gray-300">
                    Terima kasih telah melengkapi kuesioner
                    <span class="font-semibold text-navy dark:text-white">{{
                        completedInstrument.label
                    }}</span>
                    untuk
                    <span class="font-bold text-navy dark:text-sand">{{
                        session.patient?.name
                    }}</span
                    >. Masih terdapat satu kuesioner lagi yang perlu diisi.
                </p>

                <div
                    class="mt-6 rounded-xl bg-teal/10 dark:bg-teal/15 p-4 text-sm leading-6 text-navy dark:text-gray-200 border border-teal/30"
                >
                    Silakan lanjutkan ke kuesioner berikutnya:
                    <span class="block mt-1 font-bold text-teal-dark dark:text-teal">{{
                        nextInstrument.label
                    }}</span>
                </div>

                <div class="mt-6 flex flex-col gap-3">
                    <Link
                        :href="nextInstrument.url"
                        class="inline-flex w-full items-center justify-center rounded-xl bg-teal px-6 py-3 text-sm font-bold text-white shadow-sm hover:bg-teal-dark transition"
                    >
                        Lanjut ke Kuesioner {{ nextInstrument.short_label }} &rarr;
                    </Link>

                    <Link
                        href="/spk/dashboard"
                        class="inline-flex items-center justify-center rounded-xl px-4 py-2 text-xs font-medium text-gray-500 hover:text-navy dark:text-gray-400 dark:hover:text-white transition"
                    >
                        Kembali ke Dashboard
                    </Link>
                </div>
            </template>

            <template v-else>
                <h1 class="mt-6 text-2xl font-bold text-navy dark:text-white">
                    Pengisian Berhasil
                </h1>

                <p class="mt-3 text-base leading-7 text-gray-600 dark:text-gray-300">
                    Terima kasih telah melengkapi kuesioner
                    {{ completedInstrument.short_label }} untuk
                    <span class="font-bold text-navy dark:text-sand">{{
                        session.patient?.name
                    }}</span
                    >. Jawaban Anda telah berhasil disimpan dan akan ditinjau oleh tenaga medis UPTD BLK-ABK.
                </p>

                <div
                    class="mt-6 rounded-xl bg-sand/20 dark:bg-white/5 p-4 text-sm leading-6 text-gray-600 dark:text-gray-300 border border-sand/40 dark:border-white/10"
                >
                    Silakan serahkan kembali perangkat kepada perawat yang mendampingi Anda.
                </div>

                <div class="mt-6">
                    <Link
                        href="/spk/dashboard"
                        class="inline-flex items-center justify-center rounded-xl bg-teal px-6 py-2.5 text-sm font-bold text-white shadow-sm hover:bg-teal-dark transition"
                    >
                        Kembali ke Dashboard
                    </Link>
                </div>
            </template>
        </section>
    </main>
</template>
