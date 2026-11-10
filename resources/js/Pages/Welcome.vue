<script setup>
import { Head, Link, usePage } from '@inertiajs/vue3';
import { useTheme } from '@/Composables/useTheme';
import TestingGuide from '@/Components/TestingGuide.vue';

const page = usePage();
const authUser = page.props.auth?.user;
const { isDark, toggleTheme } = useTheme();

const instruments = [
    {
        code: 'KPSP',
        title: 'Kuesioner Pra Skrining Perkembangan',
        age: 'Usia 3 – 72 Bulan',
        desc: '16 kelompok formulir untuk deteksi gerak kasar, gerak halus, bicara-bahasa, serta sosialisasi & kemandirian.',
        badge: 'bg-teal/15 text-teal border-teal/30 dark:bg-teal/20 dark:text-teal-light dark:border-teal/40',
    },
    {
        code: 'M-CHAT-R',
        title: 'Modified Checklist for Autism in Toddlers',
        age: 'Usia 16 – 30 Bulan',
        desc: 'Skrining risiko gangguan spektrum autisme (ASD) pada balita berdasarkan 20 butir perilaku.',
        badge: 'bg-forest/15 text-forest border-forest/30 dark:bg-forest/20 dark:text-forest-light dark:border-forest/40',
    },
    {
        code: 'GPPH / ACTRS',
        title: 'Abbreviated Conners Teacher Rating Scale',
        age: 'Usia 36 – 72 Bulan',
        desc: 'Deteksi dini hiperaktivitas dan gangguan pemusatan perhatian anak prasekolah skala 0–3.',
        badge: 'bg-ochre/15 text-ochre-dark border-ochre/30 dark:bg-ochre/20 dark:text-ochre-light dark:border-ochre/40',
    },
    {
        code: 'SDQ',
        title: 'Strengths and Difficulties Questionnaire',
        age: 'Usia 4 – 11 Tahun',
        desc: 'Evaluasi 5 subskala: emosi, perilaku, hiperaktivitas, teman sebaya, dan kekuatan prososial.',
        badge: 'bg-navy/10 text-navy border-navy/20 dark:bg-white/10 dark:text-sand-light dark:border-white/15',
    },
    {
        code: 'SRQ-20',
        title: 'Self Reporting Questionnaire',
        age: 'Orang Tua / Pengasuh',
        desc: 'Skrining distres emosional dan kesehatan mental pendamping utama yang mendampingi anak.',
        badge: 'bg-earth/15 text-earth border-earth/30 dark:bg-earth/20 dark:text-sand dark:border-earth/40',
    },
];
</script>

<template>
    <Head title="Selamat Datang - SPK Skrining Anak" />

    <div class="min-h-screen bg-[#EAE6DC] dark:bg-[#071322] text-gray-900 dark:text-gray-100 flex flex-col justify-between transition-colors duration-150">
        <!-- Top Navigation -->
        <header class="border-b border-sand/30 dark:border-white/10 bg-white/95 dark:bg-[#071D37]/90 backdrop-blur-xs shadow-2xs sticky top-0 z-20 transition-colors">
            <div class="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
                <div class="flex items-center gap-3">
                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-gradient-to-br from-ochre to-earth text-white font-black text-xl shadow-md ring-2 ring-sand/40">
                        SPK
                    </div>
                    <div>
                        <h1 class="text-base font-extrabold text-navy dark:text-white leading-tight">
                            SPK ClinicalInsight
                        </h1>
                        <p class="text-2xs font-bold text-teal dark:text-teal-light">
                            UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus &bull; Kota Balikpapan
                        </p>
                    </div>
                </div>

                <div class="flex items-center gap-3">
                    <!-- Dark mode toggle button -->
                    <button
                        type="button"
                        class="rounded-xl p-2 text-gray-600 dark:text-sand hover:bg-sand/20 dark:hover:bg-white/10 transition border border-transparent hover:border-sand/40 dark:hover:border-white/15"
                        :title="isDark ? 'Mode Terang' : 'Mode Gelap'"
                        @click="toggleTheme"
                    >
                        <svg v-if="isDark" class="h-4 w-4 text-ochre-light" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                        </svg>
                        <svg v-else class="h-4 w-4 text-navy" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                        </svg>
                    </button>

                    <Link
                        v-if="authUser"
                        href="/dashboard"
                        class="inline-flex items-center gap-2 rounded-xl bg-teal px-4 py-2 text-xs font-bold text-white shadow-xs hover:bg-navy transition ring-1 ring-sand/30"
                    >
                        Buka Dashboard &rarr;
                    </Link>
                    <Link
                        v-else
                        href="/login"
                        class="inline-flex items-center gap-2 rounded-xl bg-teal px-5 py-2.5 text-xs font-bold text-white shadow-xs hover:bg-navy transition ring-1 ring-sand/30"
                    >
                        Masuk ke Aplikasi &rarr;
                    </Link>
                </div>
            </div>
        </header>

        <!-- Main Content -->
        <main class="mx-auto max-w-6xl px-6 py-10 flex-1 w-full space-y-10">
            <!-- Hero Section with Municipal Banner -->
            <section class="relative overflow-hidden rounded-3xl bg-navy text-white shadow-xl border border-sand/40">
                <!-- Banner Image Background with Light Overlay -->
                <div class="absolute inset-0 bg-banner-hero bg-cover bg-center"></div>
                <div class="absolute inset-0 bg-gradient-to-r from-navy/65 via-navy/45 to-navy/30"></div>

                <div class="relative z-10 px-8 py-12 sm:py-16 max-w-4xl mx-auto text-center space-y-4">
                    <span class="inline-flex items-center gap-1.5 rounded-full bg-sand/20 border border-sand/30 px-3.5 py-1 text-2xs font-bold uppercase tracking-wider text-sand-light backdrop-blur-xs">
                        <span class="h-1.5 w-1.5 rounded-full bg-ochre animate-pulse" />
                        UPTD BLK-ABK KOTA BALIKPAPAN &bull; STANDAR SDIDTK KEMENKES RI
                    </span>

                    <h2 class="text-3xl font-black tracking-tight sm:text-4xl lg:text-5xl text-white">
                        Sistem Pendukung Keputusan Skrining Tumbuh Kembang Anak
                    </h2>

                    <p class="text-sm sm:text-base text-sand-light/90 max-w-2xl mx-auto leading-relaxed">
                        Aplikasi skrining berkala berbasis aturan untuk deteksi dini masalah perilaku, emosi, dan perkembangan anak dengan penghitungan skor otomatis, sintesis rekomendasi stimulasi, dan tinjauan klinis terpadu.
                    </p>

                    <!-- Primary Action Button -->
                    <div class="pt-4 flex flex-wrap justify-center gap-4">
                        <Link
                            href="/login"
                            class="inline-flex items-center gap-2 rounded-xl bg-ochre hover:bg-ochre-light text-navy-dark px-7 py-3.5 text-sm font-black shadow-lg transition transform hover:-translate-y-0.5 ring-1 ring-sand/40"
                        >
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                            </svg>
                            Masuk ke Sistem
                        </Link>
                    </div>
                </div>
            </section>

            <!-- Demo Accounts Card -->
            <div class="rounded-2xl bg-white dark:bg-[#0C2038] p-6 shadow-xs border border-sand/40 dark:border-white/10 max-w-3xl mx-auto transition-colors">
                <h3 class="text-xs font-extrabold uppercase tracking-wider text-earth dark:text-ochre-light text-center mb-4">
                    Akun Uji Coba Tersedia (Kata Sandi: <code class="text-teal dark:text-teal-light font-bold">password</code>)
                </h3>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <!-- Perawat Card -->
                    <div class="rounded-xl border border-teal/30 dark:border-teal/40 bg-teal/5 dark:bg-teal/15 p-4">
                        <div class="flex items-center justify-between">
                            <span class="text-xs font-extrabold uppercase tracking-wide text-teal dark:text-teal-light">Peran Perawat</span>
                            <span class="rounded bg-teal/15 text-teal dark:text-teal-light text-3xs px-2 py-0.5 font-bold uppercase">Pelaksana</span>
                        </div>
                        <p class="mt-2 text-sm font-bold text-navy dark:text-white">perawat@spk.test</p>
                        <p class="mt-1 text-xs text-gray-600 dark:text-gray-300">
                            Pendaftaran pasien, pembuatan sesi skrining, dan pengisian seluruh kuesioner.
                        </p>
                    </div>

                    <!-- Dokter Card -->
                    <div class="rounded-xl border border-forest/30 dark:border-forest/40 bg-forest/5 dark:bg-forest/15 p-4">
                        <div class="flex items-center justify-between">
                            <span class="text-xs font-extrabold uppercase tracking-wide text-forest dark:text-forest-light">Peran Dokter</span>
                            <span class="rounded bg-forest/15 text-forest dark:text-forest-light text-3xs px-2 py-0.5 font-bold uppercase">Peninjau</span>
                        </div>
                        <p class="mt-2 text-sm font-bold text-navy dark:text-white">dokter@spk.test</p>
                        <p class="mt-1 text-xs text-gray-600 dark:text-gray-300">
                            Peninjauan hasil scoring, stimulasi & red flags, interpretasi klinis, dan finalisasi laporan.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Instruments Grid -->
            <div>
                <h3 class="text-lg font-black text-navy dark:text-white text-center mb-1">
                    5 Paket Instrumen Skrining Terintegrasi
                </h3>
                <p class="text-xs text-gray-500 dark:text-gray-400 text-center mb-8 max-w-xl mx-auto">
                    Seluruh perhitungan scoring dan rekomendasi mengacu secara ketat pada literatur baku Kemenkes RI.
                </p>

                <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                    <div
                        v-for="inst in instruments"
                        :key="inst.code"
                        class="rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-xs border border-sand/40 dark:border-white/10 flex flex-col justify-between hover:border-teal/50 dark:hover:border-teal/50 hover:shadow-md transition"
                    >
                        <div>
                            <div class="flex items-center justify-between gap-2 mb-2">
                                <span class="font-extrabold text-navy dark:text-white text-sm">{{ inst.code }}</span>
                                <span
                                    class="rounded-full px-2 py-0.5 text-3xs font-bold border"
                                    :class="inst.badge"
                                >
                                    {{ inst.age }}
                                </span>
                            </div>
                            <h4 class="text-xs font-bold text-teal dark:text-teal-light mb-1.5">{{ inst.title }}</h4>
                            <p class="text-xs text-gray-600 dark:text-gray-300 leading-relaxed">{{ inst.desc }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Footer -->
        <footer class="border-t border-sand/30 dark:border-white/10 bg-white dark:bg-[#071D37]/90 py-6 text-center text-xs text-gray-500 dark:text-gray-400 transition-colors">
            UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus Kota Balikpapan &bull; SPK Skrining Tumbuh Kembang &copy; 2026.
        </footer>

        <TestingGuide />
    </div>
</template>

<style scoped>
.text-2xs {
    font-size: 0.6875rem;
    line-height: 0.95rem;
}
</style>