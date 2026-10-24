<script setup>
import { ref, computed } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    patients: {
        type: Array,
        default: () => [],
    },
    stats: {
        type: Object,
        default: () => ({
            active_profiles: 0,
            today_screenings: 0,
            pending_reports: 0,
        }),
    },
});

const page = usePage();
const authUser = computed(() => page.props.auth?.user);
const isNurse = computed(() => authUser.value?.role === 'perawat');
const isDoctor = computed(() => authUser.value?.role === 'dokter');

// Filter & Search states
const searchQuery = ref('');
const activeFilter = ref('all'); // 'all' | 'active' | 'pending' | 'premature'
const sortBy = ref('recent'); // 'recent' | 'name_asc' | 'name_desc' | 'age_asc' | 'age_desc' | 'mrn'

function formatDate(value) {
    if (!value) return '-';
    const [year, month, day] = String(value).slice(0, 10).split('-');
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    const mIdx = parseInt(month, 10) - 1;
    return `${day} ${months[mIdx] ?? month} ${year}`;
}

function getInitials(name) {
    if (!name) return 'AN';
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
}

// Avatar color palettes matching official palette (Navy, Teal, Forest, Ochre, Earth, Sand)
const avatarGradients = [
    'from-navy to-teal',
    'from-teal to-forest',
    'from-forest to-ochre',
    'from-ochre to-earth',
    'from-earth to-navy',
    'from-teal to-ochre',
];

function getAvatarGradient(index) {
    return avatarGradients[index % avatarGradients.length];
}

const filteredPatients = computed(() => {
    let list = [...props.patients];

    // Search filter
    if (searchQuery.value.trim()) {
        const q = searchQuery.value.toLowerCase();
        list = list.filter((p) =>
            p.name?.toLowerCase().includes(q) ||
            p.medical_record_number?.toLowerCase().includes(q) ||
            p.birth_date?.includes(q) ||
            p.guardian_name?.toLowerCase().includes(q)
        );
    }

    // Tab filter
    if (activeFilter.value === 'active') {
        list = list.filter((p) => p.is_active);
    } else if (activeFilter.value === 'pending') {
        list = list.filter((p) =>
            p.latest_session &&
            ['in_progress', 'pending_doctor_review'].includes(p.latest_session.status)
        );
    } else if (activeFilter.value === 'premature') {
        list = list.filter((p) => p.is_premature);
    }

    // Sorting
    list.sort((a, b) => {
        if (sortBy.value === 'recent') {
            const dateA = a.latest_session?.screening_date || '1970-01-01';
            const dateB = b.latest_session?.screening_date || '1970-01-01';
            return dateB.localeCompare(dateA);
        }
        if (sortBy.value === 'name_asc') {
            return a.name.localeCompare(b.name);
        }
        if (sortBy.value === 'name_desc') {
            return b.name.localeCompare(a.name);
        }
        if (sortBy.value === 'age_asc') {
            return (a.age_months ?? 0) - (b.age_months ?? 0);
        }
        if (sortBy.value === 'age_desc') {
            return (b.age_months ?? 0) - (a.age_months ?? 0);
        }
        if (sortBy.value === 'mrn') {
            return a.medical_record_number.localeCompare(b.medical_record_number);
        }
        return 0;
    });

    return list;
});

// Overlapping avatar samples for hero card
const heroAvatars = computed(() => {
    return props.patients.slice(0, 5);
});
const remainingHeroCount = computed(() => {
    return Math.max(0, props.patients.length - 5);
});
</script>

<template>
    <Head title="Patient Selection - ClinicalInsight DSS" />

    <AuthenticatedLayout>
        <div class="space-y-6">
            <!-- HERO BANNER with Official Municipal UPTD BLK-ABK Banner -->
            <section class="relative overflow-hidden rounded-3xl bg-navy text-white shadow-xl border border-sand/30">
                <!-- Background banner image with light transparent overlay -->
                <div class="absolute inset-0 bg-banner-hero bg-cover bg-center"></div>
                <div class="absolute inset-0 bg-gradient-to-r from-navy/65 via-navy/40 to-transparent"></div>

                <div class="relative z-10 grid grid-cols-1 gap-6 p-8 lg:grid-cols-12 lg:items-center">
                    <div class="space-y-4 lg:col-span-8">
                        <span class="inline-flex items-center gap-1.5 rounded-full bg-sand/20 border border-sand/30 px-3 py-1 text-2xs font-bold uppercase tracking-wider text-sand-light backdrop-blur-xs">
                            <span class="h-1.5 w-1.5 rounded-full bg-ochre animate-pulse" />
                            UPTD BLK-ABK BALIKPAPAN &bull; CLINICAL DECISION SUPPORT
                        </span>

                        <h1 class="text-3xl font-extrabold tracking-tight sm:text-4xl text-white">
                            Initiate New Screening Session
                        </h1>

                        <p class="max-w-2xl text-sm text-sand-light/90 leading-relaxed">
                            Pilih profil pasien untuk memulai evaluasi klinis sesuai rentang usia anak. SPK menyediakan instrumen terarah untuk <strong class="text-sand font-bold">KPSP</strong>, <strong class="text-sand font-bold">M-CHAT-R</strong>, <strong class="text-sand font-bold">GPPH</strong>, <strong class="text-sand font-bold">SDQ</strong>, dan <strong class="text-sand font-bold">SRQ-20</strong> standar SDIDTK Kemenkes RI.
                        </p>

                        <!-- Action buttons & avatar stack -->
                        <div class="flex flex-wrap items-center gap-4 pt-2">
                            <Link
                                v-if="isNurse"
                                href="/patients/create"
                                class="inline-flex items-center gap-2 rounded-xl bg-ochre hover:bg-ochre-light text-navy font-extrabold px-5 py-2.5 text-xs shadow-md transition ring-1 ring-sand/40"
                            >
                                <svg class="h-4 w-4 text-navy" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                                </svg>
                                Add New Patient
                            </Link>

                            <!-- Overlapping avatar cluster -->
                            <div class="flex items-center -space-x-2">
                                <div
                                    v-for="(hp, idx) in heroAvatars"
                                    :key="hp.id"
                                    class="flex h-8 w-8 items-center justify-center rounded-full border-2 border-navy text-2xs font-extrabold text-white shadow-xs bg-gradient-to-tr"
                                    :class="getAvatarGradient(idx)"
                                    :title="hp.name"
                                >
                                    {{ getInitials(hp.name) }}
                                </div>
                                <div
                                    v-if="remainingHeroCount > 0"
                                    class="flex h-8 w-8 items-center justify-center rounded-full border-2 border-navy bg-navy-dark text-2xs font-bold text-sand shadow-xs"
                                >
                                    +{{ remainingHeroCount }}
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Illustration Card -->
                    <div class="hidden lg:col-span-4 lg:flex lg:justify-end">
                        <div class="relative overflow-hidden rounded-2xl bg-navy-dark/75 p-5 backdrop-blur-md border border-sand/30 shadow-lg text-center max-w-xs">
                            <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-sand/15 text-sand mb-3 border border-sand/30">
                                <svg class="h-8 w-8 text-ochre" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                </svg>
                            </div>
                            <h4 class="text-xs font-bold text-sand uppercase tracking-wider">
                                Standar SDIDTK & Kemenkes RI
                            </h4>
                            <p class="text-2xs text-sand-light/80 mt-1 leading-relaxed">
                                Skoring otomatis, filter instrumen cerdas, dan rekomendasi stimulasi tumbuh kembang terpadu UPTD BLK-ABK.
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- STATS ROW (Visily UI #1: 3 Stat Cards) -->
            <section class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                <!-- Stat 1: Active Profiles -->
                <div class="flex items-center justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div>
                        <span class="text-2xs font-bold uppercase tracking-wider text-earth dark:text-ochre-light">
                            Active Profiles
                        </span>
                        <p class="mt-1 text-3xl font-extrabold text-navy dark:text-white">
                            {{ stats.active_profiles ?? patients.length }}
                        </p>
                    </div>
                    <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-navy/10 text-navy border border-navy/20 dark:bg-white/10 dark:text-sand-light dark:border-white/15">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                        </svg>
                    </div>
                </div>

                <!-- Stat 2: Today's Screenings -->
                <div class="flex items-center justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div>
                        <span class="text-2xs font-bold uppercase tracking-wider text-teal dark:text-teal-light">
                            Today's Screenings
                        </span>
                        <p class="mt-1 text-3xl font-extrabold text-teal dark:text-teal-light">
                            {{ stats.today_screenings ?? 0 }}
                        </p>
                    </div>
                    <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-teal/10 text-teal border border-teal/20 dark:bg-teal/20 dark:text-teal-light dark:border-teal/30">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    </div>
                </div>

                <!-- Stat 3: Pending Reports -->
                <div class="flex items-center justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div>
                        <span class="text-2xs font-bold uppercase tracking-wider text-ochre-dark dark:text-ochre-light">
                            Pending Reports
                        </span>
                        <p class="mt-1 text-3xl font-extrabold text-ochre dark:text-ochre-light">
                            {{ stats.pending_reports ?? 0 }}
                        </p>
                    </div>
                    <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-ochre/10 text-ochre border border-ochre/20 dark:bg-ochre/20 dark:text-ochre-light dark:border-ochre/30">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                    </div>
                </div>
            </section>

            <!-- SEARCH, FILTER & TAB CONTROLS (Visily UI #1) -->
            <section class="rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    <!-- Search Input -->
                    <div class="relative flex-1">
                        <input
                            v-model="searchQuery"
                            type="text"
                            placeholder="Search by patient name, ID, or birth date..."
                            class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] py-2.5 pl-10 pr-4 text-xs dark:text-white dark:placeholder-gray-400 shadow-2xs focus:border-teal focus:ring-1 focus:ring-teal"
                        />
                        <svg class="absolute left-3.5 top-3 h-4 w-4 text-gray-400 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>

                    <!-- Filter Tabs & Funnel -->
                    <div class="flex flex-wrap items-center gap-2">
                        <button
                            type="button"
                            @click="activeFilter = 'all'"
                            class="rounded-lg px-3.5 py-2 text-xs font-bold transition"
                            :class="activeFilter === 'all'
                                ? 'bg-teal text-white shadow-xs'
                                : 'bg-[#F5F1E6] dark:bg-[#071D37] text-navy dark:text-sand-light hover:bg-sand/30 dark:hover:bg-white/10 border border-sand/40 dark:border-white/15'"
                        >
                            All
                        </button>

                        <button
                            type="button"
                            @click="activeFilter = 'active'"
                            class="rounded-lg px-3.5 py-2 text-xs font-bold transition"
                            :class="activeFilter === 'active'
                                ? 'bg-teal text-white shadow-xs'
                                : 'bg-[#F5F1E6] dark:bg-[#071D37] text-navy dark:text-sand-light hover:bg-sand/30 dark:hover:bg-white/10 border border-sand/40 dark:border-white/15'"
                        >
                            Active
                        </button>

                        <button
                            type="button"
                            @click="activeFilter = 'pending'"
                            class="rounded-lg px-3.5 py-2 text-xs font-bold transition"
                            :class="activeFilter === 'pending'
                                ? 'bg-teal text-white shadow-xs'
                                : 'bg-[#F5F1E6] dark:bg-[#071D37] text-navy dark:text-sand-light hover:bg-sand/30 dark:hover:bg-white/10 border border-sand/40 dark:border-white/15'"
                        >
                            Pending
                        </button>

                        <button
                            type="button"
                            @click="activeFilter = 'premature'"
                            class="rounded-lg px-3.5 py-2 text-xs font-bold transition"
                            :class="activeFilter === 'premature'
                                ? 'bg-teal text-white shadow-xs'
                                : 'bg-[#F5F1E6] dark:bg-[#071D37] text-navy dark:text-sand-light hover:bg-sand/30 dark:hover:bg-white/10 border border-sand/40 dark:border-white/15'"
                        >
                            Premature
                        </button>

                        <div class="h-6 w-px bg-sand/40 dark:bg-white/15 mx-1 hidden sm:block" />

                        <div class="flex items-center gap-1.5 text-xs text-gray-500 dark:text-gray-400">
                            <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
                            </svg>
                        </div>
                    </div>
                </div>
            </section>

            <!-- PATIENT DIRECTORY HEADER & SORTING -->
            <div class="flex flex-wrap items-center justify-between gap-4 pt-2">
                <div>
                    <h2 class="text-xl font-extrabold text-navy dark:text-white">
                        Patient Directory
                    </h2>
                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
                        Showing {{ filteredPatients.length }} profiles matching your criteria
                    </p>
                </div>

                <div class="flex items-center gap-2 text-xs">
                    <span class="text-gray-500 dark:text-gray-400 font-medium">Sort by:</span>
                    <select
                        v-model="sortBy"
                        class="rounded-lg border border-sand/60 dark:border-white/15 bg-white dark:bg-[#0C2038] py-1.5 pl-2.5 pr-8 text-xs font-bold text-navy dark:text-white focus:border-teal focus:ring-1 focus:ring-teal shadow-2xs"
                    >
                        <option value="recent">Recent Activity</option>
                        <option value="name_asc">Name (A – Z)</option>
                        <option value="name_desc">Name (Z – A)</option>
                        <option value="age_asc">Age: Youngest First</option>
                        <option value="age_desc">Age: Oldest First</option>
                        <option value="mrn">Medical Record No</option>
                    </select>
                </div>
            </div>

            <!-- PATIENT CARDS GRID (Visily UI #1) -->
            <div class="grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3">
                <!-- Patient Profile Card -->
                <div
                    v-for="(patient, pIdx) in filteredPatients"
                    :key="patient.id"
                    class="group relative flex flex-col justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-xs border border-sand/40 dark:border-white/10 transition hover:border-teal/60 dark:hover:border-teal hover:shadow-md"
                >
                    <div>
                        <!-- Header Card: Avatar + Gender badge + Info -->
                        <div class="flex items-start gap-3.5">
                            <!-- Avatar circle with Gender Badge -->
                            <div class="relative shrink-0">
                                <div
                                    class="flex h-12 w-12 items-center justify-center rounded-2xl text-sm font-black text-white shadow-xs bg-gradient-to-tr"
                                    :class="getAvatarGradient(pIdx)"
                                >
                                    {{ getInitials(patient.name) }}
                                </div>
                                <!-- Gender badge (Standard semantic colors: Blue for M, Pink for F) -->
                                <span
                                     class="absolute -bottom-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full text-3xs font-extrabold text-white border-2 border-white dark:border-[#0C2038] shadow-xs"
                                     :class="patient.gender === 'L' ? 'bg-blue-600' : 'bg-pink-500'"
                                     :title="patient.gender === 'L' ? 'Laki-laki (M)' : 'Perempuan (F)'"
                                 >
                                     {{ patient.gender === 'L' ? 'M' : 'F' }}
                                 </span>
                            </div>

                            <!-- Name, MRN & Age -->
                            <div class="min-w-0 flex-1">
                                <div class="flex items-center justify-between gap-1">
                                    <h3 class="truncate text-sm font-bold text-navy dark:text-white group-hover:text-blue-500 transition">
                                        {{ patient.name }}
                                    </h3>
                                </div>

                                <div class="mt-0.5 flex flex-wrap items-center gap-1.5 text-2xs text-gray-500 dark:text-gray-400">
                                    <span class="font-bold text-teal dark:text-teal-light">{{ patient.medical_record_number }}</span>
                                    <span>&bull;</span>
                                    <span>Age: {{ patient.age_display }} ({{ patient.age_months }}m)</span>
                                </div>

                                <div class="mt-1 flex items-center gap-1.5 text-2xs text-gray-500 dark:text-gray-400">
                                    <svg class="h-3 w-3 text-gray-400 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                    </svg>
                                    <span>DOB: {{ formatDate(patient.birth_date) }}</span>
                                </div>

                                <!-- Premature badge -->
                                <div v-if="patient.is_premature" class="mt-1.5">
                                    <span class="inline-flex items-center rounded-md bg-amber-50 dark:bg-amber-950/40 px-1.5 py-0.5 text-3xs font-bold text-amber-800 dark:text-amber-300 border border-amber-200 dark:border-amber-800/40">
                                        Prematur ({{ patient.gestational_age_weeks }} mgg)
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Card Divider & Bottom Action Area -->
                    <div class="mt-4 pt-3.5 border-t border-gray-100 dark:border-white/10 flex items-center justify-between gap-2">
                        <div>
                            <!-- Status Badge (Standard semantic colors) -->
                            <div class="flex items-center gap-1.5">
                                <span
                                    v-if="patient.latest_session?.status === 'reviewed'"
                                    class="inline-block rounded-md bg-emerald-100 dark:bg-emerald-950/50 px-2 py-0.5 text-3xs font-bold text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800/50 uppercase"
                                >
                                    Completed
                                </span>
                                <span
                                    v-else-if="patient.latest_session?.status === 'pending_doctor_review' || patient.latest_session?.status === 'in_progress'"
                                    class="inline-block rounded-md bg-amber-100 dark:bg-amber-950/50 px-2 py-0.5 text-3xs font-bold text-amber-800 dark:text-amber-300 border border-amber-300 dark:border-amber-800/50 uppercase"
                                >
                                    Pending
                                </span>
                                <span
                                    v-else
                                    class="inline-block rounded-md bg-blue-100 dark:bg-blue-950/50 px-2 py-0.5 text-3xs font-bold text-blue-800 dark:text-blue-300 border border-blue-300 dark:border-blue-800/50 uppercase"
                                >
                                    Active
                                </span>

                                <span class="text-3xs font-bold text-gray-500 dark:text-gray-400">
                                    {{ patient.sessions_count ? `${patient.sessions_count} sesi` : '0 sesi' }}
                                </span>
                            </div>

                            <p class="text-3xs text-gray-400 dark:text-gray-400 mt-1">
                                <span v-if="patient.latest_session">
                                    Terakhir: {{ formatDate(patient.latest_session.screening_date) }}
                                </span>
                                <span v-else>
                                    Belum pernah skrining
                                </span>
                            </p>
                        </div>

                        <!-- Direct link to THIS patient's screening sessions list (Standard clear blue button) -->
                        <div>
                            <Link
                                :href="`/screening-sessions?patient_id=${patient.id}`"
                                class="inline-flex items-center gap-1.5 rounded-xl bg-blue-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-blue-700 shadow-xs transition"
                            >
                                Lihat Sesi Skrining &rarr;
                            </Link>
                        </div>
                    </div>
                </div>

                <!-- Create New Profile Dashed Card (Visily UI #1) -->
                <Link
                    v-if="isNurse"
                    href="/patients/create"
                    class="group flex min-h-[170px] flex-col items-center justify-center rounded-2xl border-2 border-dashed border-sand/80 dark:border-white/20 p-6 text-center transition hover:border-teal dark:hover:border-teal hover:bg-sand-light/50 dark:hover:bg-white/5"
                >
                    <div class="flex h-12 w-12 items-center justify-center rounded-full bg-sand/20 dark:bg-white/10 text-teal dark:text-sand group-hover:bg-teal group-hover:text-white transition mb-2">
                        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                        </svg>
                    </div>
                    <span class="text-sm font-bold text-navy dark:text-white group-hover:text-teal dark:group-hover:text-teal-light transition">
                        Create New Profile
                    </span>
                    <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                        Register a new pediatric patient
                    </p>
                </Link>
            </div>

            <!-- Visily UI #1 Footer -->
            <footer class="mt-12 border-t border-gray-200/80 dark:border-white/10 pt-6 flex flex-wrap items-center justify-between gap-4 text-2xs text-gray-500 dark:text-gray-400">
                <div class="flex items-center gap-4">
                    <span class="hover:text-gray-700 dark:hover:text-gray-300">Documentation</span>
                    <span>&bull;</span>
                    <span class="hover:text-gray-700 dark:hover:text-gray-300">Clinical Guidelines</span>
                    <span>&bull;</span>
                    <span class="hover:text-gray-700 dark:hover:text-gray-300">Support</span>
                </div>
                <div>
                    SYSTEM VERSION V3.0 &bull; MEDICAL DATA ENCRYPTED
                </div>
            </footer>
        </div>
    </AuthenticatedLayout>
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
