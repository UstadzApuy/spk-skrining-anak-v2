<script setup>
import { computed, ref, watch } from 'vue';
import { Link, router, usePage } from '@inertiajs/vue3';
import { useTheme } from '@/Composables/useTheme';

const page = usePage();
const user = computed(() => page.props.auth.user);
const { isDark, toggleTheme } = useTheme();

// Sidebar off-canvas untuk mobile & tablet portrait (< lg / 1024px)
const sidebarOpen = ref(false);

// Tutup sidebar otomatis saat berpindah halaman
watch(
    () => page.url,
    () => {
        sidebarOpen.value = false;
    }
);

const logout = () => {
    router.post('/spk/logout');
};

const isNurse = computed(() => user.value?.role === 'perawat');
const isDoctor = computed(() => user.value?.role === 'dokter');
const isStaff = computed(() => isNurse.value || isDoctor.value);

function userInitial(name) {
    if (!name) return 'U';
    return name.charAt(0).toUpperCase();
}
</script>

<template>
    <div class="min-h-screen bg-[#EAE6DC] dark:bg-[#071322] text-gray-900 dark:text-gray-100 transition-colors duration-150">
        <!-- Overlay backdrop untuk sidebar off-canvas (mobile & tablet portrait) -->
        <div
            v-show="sidebarOpen"
            class="fixed inset-0 z-30 bg-navy-dark/60 backdrop-blur-2xs lg:hidden print:hidden"
            @click="sidebarOpen = false"
        ></div>

        <!-- Sidebar Navigation (Matching Visily UI + Balikpapan Cultural & Clinical Identity) -->
        <aside
            class="fixed inset-y-0 left-0 flex w-64 flex-col bg-navy text-white print:hidden z-40 border-r border-navy-light dark:border-white/10 shadow-xl transition-transform duration-200 ease-in-out lg:translate-x-0"
            :class="sidebarOpen ? 'translate-x-0' : '-translate-x-full'"
        >
            <!-- Visible Batik Texture in sidebar -->
            <div class="absolute inset-0 bg-batik-pattern bg-cover bg-center opacity-45 pointer-events-none"></div>
            <div class="absolute inset-0 bg-navy/70 pointer-events-none"></div>

            <!-- Content within sidebar (relative z-10) -->
            <div class="relative z-10 flex h-full flex-col">
                <!-- Logo & Brand Header (Linked to Dashboard) -->
                <Link
                    href="/spk/dashboard"
                    class="flex items-center gap-3 border-b border-white/10 px-6 py-5 hover:bg-white/5 transition group cursor-pointer"
                    title="Kembali ke Dashboard"
                >
                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-ochre to-earth text-white shadow-md ring-1 ring-sand/30 group-hover:scale-105 group-hover:ring-sand transition-transform duration-200">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                        </svg>
                    </div>
                    <div class="min-w-0 flex-1">
                        <h1 class="text-sm font-extrabold text-white tracking-tight leading-tight truncate group-hover:text-sand-light transition-colors">
                            ClinicalInsight
                        </h1>
                        <span class="text-2xs font-bold tracking-wider text-sand uppercase block truncate group-hover:text-sand transition-colors">
                            UPTD BLK-ABK
                        </span>
                    </div>
                    <!-- Tombol tutup sidebar (hanya mobile / tablet portrait) -->
                    <button
                        type="button"
                        class="rounded-lg p-1.5 text-sand/70 hover:bg-white/10 hover:text-white transition lg:hidden"
                        title="Tutup menu"
                        @click.prevent="sidebarOpen = false"
                    >
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </Link>

                <!-- Navigation Links -->
                <nav class="flex-1 px-3 py-6 space-y-1.5">
                    <!-- 1. Patient Selection (Primary Hub / Dashboard) -->
                    <Link
                        href="/spk/dashboard"
                        class="flex items-center justify-between rounded-xl px-3.5 py-2.5 text-xs font-bold transition shadow-xs"
                        :class="
                            $page.url === '/spk/dashboard' || $page.url === '/spk' || $page.url === '/'
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre shadow-teal/30'
                                : 'text-sand/80 hover:bg-white/10 hover:text-white'
                        "
                    >
                        <div class="flex items-center gap-3">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                            <span>{{ isStaff ? 'Pilihan Pasien' : 'Dashboard Anak' }}</span>
                        </div>
                        <svg
                            v-if="$page.url === '/spk/dashboard' || $page.url === '/spk' || $page.url === '/'"
                            class="h-3.5 w-3.5 text-sand"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" />
                        </svg>
                    </Link>

                    <!-- 2. Data Pasien & Wali (Manajemen Lengkap) -->
                    <Link
                        v-if="isStaff"
                        href="/spk/patients"
                        class="flex items-center justify-between rounded-xl px-3.5 py-2.5 text-xs font-bold transition shadow-xs"
                        :class="
                            $page.url.startsWith('/spk/patients')
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre shadow-teal/30'
                                : 'text-sand/80 hover:bg-white/10 hover:text-white'
                        "
                    >
                        <div class="flex items-center gap-3">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                            </svg>
                            <span>Data Pasien &amp; Wali</span>
                        </div>
                        <svg
                            v-if="$page.url.startsWith('/spk/patients')"
                            class="h-3.5 w-3.5 text-sand"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" />
                        </svg>
                    </Link>

                    <!-- 3. Sesi Skrining (Riwayat Sesi) -->
                    <Link
                        v-if="isNurse || isDoctor"
                        href="/spk/screening-sessions"
                        class="flex items-center justify-between rounded-xl px-3.5 py-2.5 text-xs font-bold transition shadow-xs"
                        :class="
                            $page.url.startsWith('/spk/screening-sessions')
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre shadow-teal/30'
                                : 'text-sand/80 hover:bg-white/10 hover:text-white'
                        "
                    >
                        <div class="flex items-center gap-3">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
                            </svg>
                            <span>Sesi Skrining</span>
                        </div>
                        <svg
                            v-if="$page.url.startsWith('/spk/screening-sessions')"
                            class="h-3.5 w-3.5 text-sand"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" />
                        </svg>
                    </Link>

                    <!-- 3. Rekapitulasi Skrining (Per Bulan, Hari, Minggu, Tahun) -->
                    <Link
                        v-if="isStaff"
                        href="/spk/rekapitulasi"
                        class="flex items-center justify-between rounded-xl px-3.5 py-2.5 text-xs font-bold transition shadow-xs"
                        :class="
                            $page.url.startsWith('/spk/rekapitulasi')
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre shadow-teal/30'
                                : 'text-sand/80 hover:bg-white/10 hover:text-white'
                        "
                    >
                        <div class="flex items-center gap-3">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                            <span>Rekapitulasi Skrining</span>
                        </div>
                        <svg
                            v-if="$page.url.startsWith('/spk/rekapitulasi')"
                            class="h-3.5 w-3.5 text-sand"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" />
                        </svg>
                    </Link>
                </nav>

                <!-- Bottom User Profile Card -->
                <div class="border-t border-white/10 p-3 bg-navy-dark/80 backdrop-blur-xs">
                    <div class="flex items-center justify-between rounded-xl p-2 hover:bg-white/5 transition border border-transparent hover:border-white/10">
                        <div class="flex items-center gap-2.5 min-w-0">
                            <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-sand/20 text-sand font-black text-xs ring-1 ring-sand/30 shadow-2xs">
                                {{ userInitial(user?.name) }}
                            </div>
                            <div class="min-w-0 flex-1">
                                <p class="truncate text-xs font-bold text-white leading-tight">
                                    {{ user?.name }}
                                </p>
                                <p class="truncate text-3xs font-semibold text-sand-light/80 capitalize">
                                    {{ isDoctor ? 'Dokter Spesialis Anak' : isNurse ? 'Perawat Pemeriksa' : 'Orang Tua' }}
                                </p>
                            </div>
                        </div>

                        <div class="flex items-center gap-1 shrink-0">
                            <!-- Dark Mode Toggle Button -->
                            <button
                                type="button"
                                class="rounded-lg p-1.5 text-sand/70 hover:bg-white/10 hover:text-sand-light transition"
                                :title="isDark ? 'Mode Terang' : 'Mode Gelap'"
                                @click="toggleTheme"
                            >
                                <svg v-if="isDark" class="h-4 w-4 text-ochre-light" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                                </svg>
                                <svg v-else class="h-4 w-4 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                                </svg>
                            </button>

                            <button
                                type="button"
                                class="rounded-lg p-1.5 text-sand/60 hover:bg-rose-500/20 hover:text-rose-300 transition"
                                title="Keluar dari Aplikasi"
                                @click="logout"
                            >
                                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Main Content Area -->
        <div class="min-h-screen pl-0 lg:pl-64 print:pl-0">
            <!-- Top bar mobile: hamburger + brand (tersembunyi di >= lg) -->
            <div class="sticky top-0 z-20 flex items-center gap-3 border-b border-white/10 bg-navy px-4 py-3 text-white lg:hidden print:hidden">
                <button
                    type="button"
                    class="rounded-lg p-2 text-sand hover:bg-white/10 hover:text-white transition -ml-1"
                    title="Buka menu navigasi"
                    @click="sidebarOpen = true"
                >
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                    </svg>
                </button>
                <Link href="/spk/dashboard" class="flex min-w-0 items-center gap-2.5">
                    <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-gradient-to-br from-ochre to-earth text-white shadow-md ring-1 ring-sand/30">
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                        </svg>
                    </div>
                    <div class="min-w-0 leading-tight">
                        <h1 class="truncate text-xs font-extrabold tracking-tight">ClinicalInsight</h1>
                        <span class="block truncate text-3xs font-bold uppercase tracking-wider text-sand">UPTD BLK-ABK</span>
                    </div>
                </Link>
            </div>

            <header
                v-if="$slots.header"
                class="border-b border-sand/30 dark:border-white/10 bg-white/95 dark:bg-[#071D37]/90 backdrop-blur-xs px-4 py-4 sm:px-6 lg:px-8 print:hidden lg:sticky lg:top-0 lg:z-10 shadow-2xs"
            >
                <slot name="header" />
            </header>

            <main class="p-4 sm:p-6 lg:p-8 print:p-0">
                <slot />
            </main>
        </div>
    </div>
</template>

<style scoped>
.text-2xs {
    font-size: 0.6875rem;
    line-height: 0.95rem;
}
.text-3xs {
    font-size: 0.625rem;
    line-height: 0.85rem;
}
</style>