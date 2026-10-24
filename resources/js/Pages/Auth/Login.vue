<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3';
import { useTheme } from '@/Composables/useTheme';

const { isDark, toggleTheme } = useTheme();

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post('/login');
};

function fillAndSubmit(email) {
    form.email = email;
    form.password = 'password';
    form.post('/login');
}
</script>

<template>
    <Head title="Masuk ke Sistem - SPK Skrining Anak" />

    <main class="relative flex min-h-screen items-center justify-center bg-navy px-4 py-10 overflow-hidden">
        <!-- Background Batik Texture & Semi-transparent Navy Overlay -->
        <div class="absolute inset-0 bg-batik-pattern opacity-50 bg-cover bg-center"></div>
        <div class="absolute inset-0 bg-gradient-to-tr from-navy/70 via-navy/50 to-teal/40"></div>

        <!-- Floating Theme Toggle in Top Right -->
        <div class="absolute top-4 right-4 z-20">
            <button
                type="button"
                @click="toggleTheme"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white/20 dark:bg-black/30 backdrop-blur-md text-white border border-white/20 shadow-md hover:scale-105 transition"
                :title="isDark ? 'Mode Terang' : 'Mode Gelap'"
            >
                <svg v-if="isDark" class="h-5 w-5 text-ochre-light" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                <svg v-else class="h-5 w-5 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
            </button>
        </div>

        <div class="relative z-10 w-full max-w-md overflow-hidden rounded-3xl bg-white/95 dark:bg-[#071D37]/95 backdrop-blur-md p-8 shadow-2xl border border-sand/40 dark:border-white/10 transition-colors">
            <!-- Decorative Top Gradient Accent -->
            <div class="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-ochre via-teal to-forest"></div>

            <div class="mb-6 text-center pt-2">
                <Link href="/" class="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-ochre to-earth text-white font-black text-xl shadow-md ring-2 ring-sand/40 mb-3 hover:scale-105 transition transform">
                    SPK
                </Link>
                <h1 class="text-2xl font-black text-navy dark:text-white tracking-tight">
                    Masuk ke Sistem
                </h1>
                <p class="mt-1 text-xs font-bold text-teal dark:text-teal-light">
                    UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus
                </p>
                <p class="text-2xs text-gray-500 dark:text-gray-400 mt-0.5">
                    Dinas Kesehatan Kota Balikpapan &bull; Standar SDIDTK
                </p>
            </div>

            <!-- Quick Demo Login Buttons -->
            <div class="mb-6 rounded-2xl bg-[#FAF7F0] dark:bg-[#041224]/80 p-4 border border-sand/40 dark:border-white/10 space-y-2">
                <span class="text-2xs font-extrabold uppercase tracking-wider text-earth dark:text-sand block text-center mb-1">
                    Login Cepat Akun Demo (1-Klik)
                </span>
                <div class="grid grid-cols-2 gap-2">
                    <button
                        type="button"
                        :disabled="form.processing"
                        @click="fillAndSubmit('perawat@spk.test')"
                        class="rounded-xl bg-teal/10 dark:bg-teal/20 px-3 py-2 text-xs font-bold text-teal dark:text-teal-light hover:bg-teal hover:text-white border border-teal/30 dark:border-teal/40 transition text-center disabled:opacity-50 group shadow-2xs"
                    >
                        Perawat
                        <span class="block text-2xs font-medium text-teal dark:text-sand-light/80 group-hover:text-sand-light">perawat@spk.test</span>
                    </button>

                    <button
                        type="button"
                        :disabled="form.processing"
                        @click="fillAndSubmit('dokter@spk.test')"
                        class="rounded-xl bg-forest/10 dark:bg-forest/20 px-3 py-2 text-xs font-bold text-forest dark:text-forest-light hover:bg-forest hover:text-white border border-forest/30 dark:border-forest/40 transition text-center disabled:opacity-50 group shadow-2xs"
                    >
                        Dokter
                        <span class="block text-2xs font-medium text-forest dark:text-sand-light/80 group-hover:text-sand-light">dokter@spk.test</span>
                    </button>
                </div>
            </div>

            <div class="relative mb-6">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-sand/40 dark:border-white/10" />
                </div>
                <div class="relative flex justify-center text-xs">
                    <span class="bg-white dark:bg-[#071D37] px-2.5 text-gray-400 dark:text-gray-400 uppercase font-semibold text-2xs">Atau login manual</span>
                </div>
            </div>

            <form @submit.prevent="submit" class="space-y-4">
                <div>
                    <label
                        for="email"
                        class="mb-1.5 block text-xs font-bold text-navy dark:text-gray-200"
                    >
                        Email Pengguna
                    </label>

                    <input
                        id="email"
                        v-model="form.email"
                        type="email"
                        required
                        autocomplete="email"
                        class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-[#041224] text-navy dark:text-white dark:placeholder-gray-400 px-3.5 py-2.5 text-sm outline-none focus:border-teal focus:ring-2 focus:ring-teal/20"
                        placeholder="contoh: perawat@spk.test"
                    />

                    <p
                        v-if="form.errors.email"
                        class="mt-1 text-xs text-rose-600 font-medium"
                    >
                        {{ form.errors.email }}
                    </p>
                </div>

                <div>
                    <label
                        for="password"
                        class="mb-1.5 block text-xs font-bold text-navy dark:text-gray-200"
                    >
                        Password
                    </label>

                    <input
                        id="password"
                        v-model="form.password"
                        type="password"
                        required
                        autocomplete="current-password"
                        class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-[#041224] text-navy dark:text-white dark:placeholder-gray-400 px-3.5 py-2.5 text-sm outline-none focus:border-teal focus:ring-2 focus:ring-teal/20"
                        placeholder="Masukkan password"
                    />

                    <p
                        v-if="form.errors.password"
                        class="mt-1 text-xs text-rose-600 font-medium"
                    >
                        {{ form.errors.password }}
                    </p>
                </div>

                <div class="flex items-center">
                    <input
                        id="remember"
                        v-model="form.remember"
                        type="checkbox"
                        class="h-4 w-4 rounded border-sand/60 dark:border-white/20 bg-white dark:bg-[#041224] text-teal focus:ring-teal"
                    />

                    <label
                        for="remember"
                        class="ml-2 text-xs font-medium text-gray-600 dark:text-gray-300"
                    >
                        Ingat sesi saya
                    </label>
                </div>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="w-full rounded-xl bg-gradient-to-r from-teal to-navy hover:from-teal-dark hover:to-navy-dark px-4 py-3 text-sm font-extrabold text-white transition disabled:cursor-not-allowed disabled:opacity-50 shadow-md ring-1 ring-sand/30"
                >
                    {{ form.processing ? 'Memproses...' : 'Masuk ke Aplikasi' }}
                </button>
            </form>

            <div class="mt-6 text-center border-t border-sand/30 dark:border-white/10 pt-4">
                <Link href="/" class="text-xs font-bold text-teal dark:text-teal-light hover:text-navy dark:hover:text-sand transition">
                    &larr; Kembali ke Halaman Utama
                </Link>
            </div>
        </div>
    </main>
</template>

<style scoped>
.text-2xs {
    font-size: 0.6875rem;
    line-height: 0.95rem;
}
</style>