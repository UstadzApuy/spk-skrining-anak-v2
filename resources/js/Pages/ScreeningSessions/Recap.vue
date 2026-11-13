<script setup>
import { computed, ref } from 'vue';
import { Head, Link, router } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    filters: {
        type: Object,
        required: true,
    },
    institutionInfo: {
        type: Object,
        default: () => ({
            name: 'UPTD BALAI LAYANAN KESEHATAN ANAK BERKEBUTUHAN KHUSUS',
            city: 'BALIKPAPAN',
            month_name: 'Oktober',
            year: 2026,
        }),
    },
    availableYears: {
        type: Array,
        required: true,
    },
    availableMonths: {
        type: Array,
        required: true,
    },
    availableWeeks: {
        type: Array,
        default: () => [],
    },
    activeDates: {
        type: Array,
        default: () => [],
    },
    prevMonth: {
        type: Object,
        default: null,
    },
    nextMonth: {
        type: Object,
        default: null,
    },
    nurses: {
        type: Array,
        default: () => [],
    },
    summary: {
        type: Object,
        required: true,
    },
    instrumentBreakdown: {
        type: Object,
        required: true,
    },
    statusBreakdown: {
        type: Object,
        required: true,
    },
    demographics: {
        type: Object,
        required: true,
    },
    dailyData: {
        type: Array,
        default: () => [],
    },
    weeklyData: {
        type: Array,
        default: () => [],
    },
    weeklyDaysData: {
        type: Array,
        default: () => [],
    },
    monthlyData: {
        type: Array,
        default: () => [],
    },
    yearlyData: {
        type: Array,
        default: () => [],
    },
    sessions: {
        type: Array,
        default: () => [],
    },
    registerRows: {
        type: Array,
        default: () => [],
    },
    registerTotals: {
        type: Object,
        default: () => ({}),
    },
    periodLabel: {
        type: String,
        default: '',
    },
    annualReports: {
        type: Object,
        default: () => ({}),
    },
});

// Tab tampilan:
// 'register' = Tabel Register Bulanan UPTD BLK-ABK (Default)
// 'klinis'   = Analisis Klinis & Demografi Pasien
// 'tren'     = Tren Tahunan (12 Bulan)
const activeViewTab = ref('register');

// Sub-modul aktif pada tab Tren Tahunan
const activeTrenModule = ref('all'); // 'all' | 'patients' | 'deteksi' | 'diagnosis' | 'intervensi'

function formatNumber(num) {
    if (num === null || num === undefined) return '0';
    return Number(num).toLocaleString('id-ID');
}

const searchQuery = ref('');
const onlyAttention = ref(false);

const selectedYear = computed(() => props.filters.year);
const selectedMonth = computed(() => props.filters.month);

function onYearChange(e) {
    applyFilter({ year: parseInt(e.target.value, 10) });
}

function onMonthChange(monthNum) {
    applyFilter({ month: monthNum });
}

function goToPrevMonth() {
    if (props.prevMonth) {
        applyFilter({ year: props.prevMonth.year, month: props.prevMonth.month });
    }
}

function goToNextMonth() {
    if (props.nextMonth) {
        applyFilter({ year: props.nextMonth.year, month: props.nextMonth.month });
    }
}

function onNurseChange(e) {
    applyFilter({ nurse_id: e.target.value ? parseInt(e.target.value, 10) : null });
}

function onStatusChange(e) {
    applyFilter({ status: e.target.value || null });
}

function applyFilter(override = {}) {
    const params = {
        granularity: 'bulanan',
        year: override.year ?? props.filters.year,
        month: override.month ?? props.filters.month,
        nurse_id: override.nurse_id !== undefined ? override.nurse_id : props.filters.nurse_id,
        status: override.status !== undefined ? override.status : props.filters.status,
    };

    Object.keys(params).forEach((key) => {
        if (params[key] === null || params[key] === undefined || params[key] === '') {
            delete params[key];
        }
    });

    router.get('/spk/rekapitulasi', params, {
        preserveState: true,
        preserveScroll: true,
    });
}

function exportReport(format = 'excel') {
    const params = new URLSearchParams({
        year: selectedYear.value,
        month: selectedMonth.value,
        format: format,
    });

    if (props.filters.nurse_id) {
        params.append('nurse_id', props.filters.nurse_id);
    }
    if (props.filters.status) {
        params.append('status', props.filters.status);
    }

    window.location.href = `/spk/rekapitulasi/export?${params.toString()}`;
}

function printReport() {
    window.print();
}

// Filter baris register berdasarkan pencarian lokal & filter perhatian
const filteredRegisterRows = computed(() => {
    let list = props.registerRows || [];

    if (searchQuery.value.trim()) {
        const q = searchQuery.value.toLowerCase().trim();
        list = list.filter((r) => {
            const name = (r.name || '').toLowerCase();
            const mrn = (r.medical_record_number || '').toLowerCase();
            const addr = (r.address || '').toLowerCase();
            const school = (r.keterangan || '').toLowerCase();
            return name.includes(q) || mrn.includes(q) || addr.includes(q) || school.includes(q);
        });
    }

    if (onlyAttention.value) {
        list = list.filter((r) => {
            return (
                r.gg_motorik_kasar ||
                r.gg_motorik_halus ||
                r.gg_bicara_bahasa ||
                r.gg_sosialisasi ||
                r.sdq ||
                r.mchat ||
                r.gpph ||
                r.srq
            );
        });
    }

    return list;
});

const currentMonthLabel = computed(() => {
    const m = props.availableMonths.find((item) => item.value === selectedMonth.value);
    return m ? m.label : `Bulan ${selectedMonth.value}`;
});
</script>

<template>
    <Head :title="`Rekapitulasi SDIDTK Bulanan - ${currentMonthLabel} ${selectedYear}`" />

    <AuthenticatedLayout>
        <!-- STICKY TOP HEADER -->
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4">
                <div>
                    <div class="flex items-center gap-2 text-2xs font-bold text-gray-500 dark:text-gray-400 mb-1">
                        <Link href="/spk/dashboard" class="hover:text-teal transition">Dashboard</Link>
                        <span>/</span>
                        <Link href="/spk/screening-sessions" class="hover:text-teal transition">Sesi Skrining</Link>
                        <span>/</span>
                        <span class="text-teal font-extrabold">Rekapitulasi Bulanan</span>
                    </div>
                    <h2 class="text-xl font-extrabold text-navy dark:text-white flex items-center gap-2.5">
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-teal/10 text-teal border border-teal/20 dark:bg-teal/20 dark:text-teal-light">
                            <svg class="h-4.5 w-4.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                        </div>
                        <span>Rekapitulasi Skrining Bulanan</span>
                        <span class="rounded-full bg-teal/10 dark:bg-teal-900/50 text-teal dark:text-teal-300 border border-teal/20 px-2.5 py-0.5 text-xs font-bold">
                            {{ currentMonthLabel }} {{ selectedYear }}
                        </span>
                    </h2>
                </div>

                <!-- Tombol Aksi: Export & Cetak -->
                <div class="flex flex-wrap items-center gap-2 shrink-0 print:hidden">
                    <button
                        type="button"
                        @click="exportReport('excel')"
                        class="inline-flex items-center gap-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold px-3.5 py-2 text-xs shadow-xs transition active:scale-95"
                        title="Unduh Register Bulanan format Excel (.xlsx)"
                    >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        Ekspor Excel (.xlsx)
                    </button>

                    <button
                        type="button"
                        @click="exportReport('csv')"
                        class="inline-flex items-center gap-2 rounded-xl bg-slate-700 hover:bg-slate-800 text-white font-bold px-3 py-2 text-xs shadow-xs transition active:scale-95"
                        title="Unduh Data CSV (UTF-8)"
                    >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                        </svg>
                        Ekspor CSV
                    </button>

                    <button
                        type="button"
                        @click="printReport"
                        class="inline-flex items-center gap-2 rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-white/10 hover:bg-sand-light dark:hover:bg-white/15 text-navy dark:text-white font-bold px-3 py-2 text-xs shadow-2xs transition active:scale-95"
                        title="Cetak Laporan / Simpan PDF"
                    >
                        <svg class="h-4 w-4 text-gray-400 dark:text-gray-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        Cetak
                    </button>
                </div>
            </div>
        </template>

        <div class="space-y-6">

            <!-- KOP LAPORAN RESMI UPTD BLK-ABK (Bersih, elegan, tanpa foto background) -->
            <div class="rounded-2xl bg-white dark:bg-[#0C2038] border border-sand/40 dark:border-white/10 p-5 sm:p-6 shadow-xs">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-5 border-b border-sand/30 dark:border-white/10 pb-5">
                    <div class="flex items-start gap-4">
                        <div class="h-12 w-12 rounded-2xl bg-teal/10 dark:bg-teal-900/40 border border-teal/30 flex items-center justify-center shrink-0 text-teal dark:text-teal-light font-black text-sm shadow-2xs">
                            UPTD
                        </div>
                        <div>
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-3xs font-extrabold uppercase tracking-wider bg-teal/10 dark:bg-teal-900/50 text-teal dark:text-teal-light border border-teal/20 mb-1">
                                Laporan Register Bulanan SDIDTK
                            </span>
                            <h1 class="text-lg sm:text-xl font-black text-navy dark:text-white tracking-tight uppercase">
                                {{ institutionInfo.name }}
                            </h1>
                            <p class="text-xs font-semibold text-gray-500 dark:text-gray-400 mt-0.5">
                                KAB/KOTA: <strong class="text-navy dark:text-white">{{ institutionInfo.city }}</strong> &bull;
                                BULAN: <strong class="text-teal font-extrabold">{{ currentMonthLabel }}</strong> &bull;
                                TAHUN: <strong class="text-teal font-extrabold">{{ selectedYear }}</strong>
                            </p>
                        </div>
                    </div>

                    <!-- Navigasi Pemilih Bulan yang Rapi & Proporsional -->
                    <div class="flex items-center gap-2 print:hidden self-start lg:self-center">
                        <button
                            type="button"
                            @click="goToPrevMonth"
                            :disabled="!prevMonth"
                            class="px-3 py-1.5 rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] text-xs font-bold text-navy dark:text-white hover:bg-sand/30 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        >
                            &larr; {{ prevMonth ? prevMonth.label : 'Sebelumnya' }}
                        </button>

                        <div class="flex items-center gap-1.5 bg-[#FAF7F0] dark:bg-[#071D37] border border-sand/60 dark:border-white/15 p-1 rounded-xl">
                            <select
                                :value="selectedMonth"
                                @change="onMonthChange(parseInt($event.target.value, 10))"
                                class="bg-transparent text-navy dark:text-white text-xs font-bold rounded-lg px-2.5 py-1 border-0 focus:ring-1 focus:ring-teal cursor-pointer"
                            >
                                <option
                                    v-for="m in availableMonths"
                                    :key="m.value"
                                    :value="m.value"
                                    class="bg-white dark:bg-[#0C2038] text-navy dark:text-white"
                                >
                                    {{ m.label }}
                                </option>
                            </select>

                            <select
                                :value="selectedYear"
                                @change="onYearChange"
                                class="bg-transparent text-navy dark:text-white text-xs font-bold rounded-lg px-2.5 py-1 border-0 focus:ring-1 focus:ring-teal cursor-pointer"
                            >
                                <option
                                    v-for="y in availableYears"
                                    :key="y"
                                    :value="y"
                                    class="bg-white dark:bg-[#0C2038] text-navy dark:text-white"
                                >
                                    Tahun {{ y }}
                                </option>
                            </select>
                        </div>

                        <button
                            type="button"
                            @click="goToNextMonth"
                            :disabled="!nextMonth"
                            class="px-3 py-1.5 rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] text-xs font-bold text-navy dark:text-white hover:bg-sand/30 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        >
                            {{ nextMonth ? nextMonth.label : 'Selanjutnya' }} &rarr;
                        </button>
                    </div>
                </div>

                <!-- Informasi Catatan Standar UPTD -->
                <div class="pt-3 flex flex-wrap items-center justify-between text-2xs text-gray-500 dark:text-gray-400 gap-2">
                    <p>
                        Format standar UPTD BLK-ABK: Instrumen KMPE disesuaikan menjadi instrumen SDQ dan SRQ-20.
                    </p>
                    <p class="font-bold text-teal">
                        Total Register: {{ summary.total_sessions }} Pasien
                    </p>
                </div>
            </div>

            <!-- STATS ROW (6 KPI Cards Selaras dengan Dashboard) -->
            <section class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3.5">
                <!-- Card 1: Total Pasien -->
                <div class="flex flex-col justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div class="flex items-center justify-between">
                        <span class="text-2xs font-bold uppercase tracking-wider text-earth dark:text-ochre-light">Total Anak</span>
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-navy/10 text-navy dark:bg-white/10 dark:text-sand-light">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                        </div>
                    </div>
                    <div class="mt-2">
                        <p class="text-2xl font-black text-navy dark:text-white">{{ summary.total_sessions }}</p>
                        <p class="text-2xs font-semibold text-gray-500 dark:text-gray-400 mt-0.5">
                            L: {{ demographics.gender.laki_laki }} &bull; P: {{ demographics.gender.perempuan }}
                        </p>
                    </div>
                </div>

                <!-- Card 2: Status Kasus -->
                <div class="flex flex-col justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div class="flex items-center justify-between">
                        <span class="text-2xs font-bold uppercase tracking-wider text-teal dark:text-teal-light">Status Kasus</span>
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-teal/10 text-teal dark:bg-teal/20 dark:text-teal-light">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                    <div class="mt-2">
                        <div class="flex items-baseline gap-1.5">
                            <span class="text-2xl font-black text-teal dark:text-teal-light">{{ registerTotals.case_new || 0 }}</span>
                            <span class="text-2xs text-gray-500 font-bold">Baru</span>
                            <span class="text-gray-300 dark:text-gray-600">|</span>
                            <span class="text-2xl font-black text-navy dark:text-sand-light">{{ registerTotals.case_old || 0 }}</span>
                            <span class="text-2xs text-gray-500 font-bold">Lama</span>
                        </div>
                        <p class="text-2xs font-semibold text-gray-500 dark:text-gray-400 mt-0.5">Register Pemeriksaan</p>
                    </div>
                </div>

                <!-- Card 3: KPSP Meragukan -->
                <div class="flex flex-col justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div class="flex items-center justify-between">
                        <span class="text-2xs font-bold uppercase tracking-wider text-ochre-dark dark:text-ochre-light">KPSP Meragukan</span>
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-ochre/10 text-ochre dark:bg-ochre/20 dark:text-ochre-light">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                        </div>
                    </div>
                    <div class="mt-2">
                        <p class="text-2xl font-black text-ochre dark:text-ochre-light">{{ instrumentBreakdown.kpsp.meragukan }}</p>
                        <p class="text-2xs font-semibold text-gray-500 dark:text-gray-400 mt-0.5">Evaluasi Ulang 14 Hari</p>
                    </div>
                </div>

                <!-- Card 4: KPSP Penyimpangan -->
                <div class="flex flex-col justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div class="flex items-center justify-between">
                        <span class="text-2xs font-bold uppercase tracking-wider text-rose-700 dark:text-rose-400">Penyimpangan</span>
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-rose-500/10 text-rose-600 dark:bg-rose-500/20 dark:text-rose-400">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                    <div class="mt-2">
                        <p class="text-2xl font-black text-rose-600 dark:text-rose-400">{{ instrumentBreakdown.kpsp.penyimpangan }}</p>
                        <p class="text-2xs font-semibold text-gray-500 dark:text-gray-400 mt-0.5">Perlu Rujukan Medis</p>
                    </div>
                </div>

                <!-- Card 5: Masalah Emosional -->
                <div class="flex flex-col justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div class="flex items-center justify-between">
                        <span class="text-2xs font-bold uppercase tracking-wider text-purple-700 dark:text-purple-300">Emosional Anak</span>
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-500/10 text-purple-600 dark:bg-purple-500/20 dark:text-purple-300">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                    <div class="mt-2">
                        <p class="text-2xl font-black text-purple-600 dark:text-purple-300">
                            {{ (registerTotals.sdq || 0) + (registerTotals.mchat || 0) + (registerTotals.gpph || 0) }}
                        </p>
                        <p class="text-2xs font-semibold text-gray-500 dark:text-gray-400 mt-0.5">SDQ &bull; Autis &bull; GPPH</p>
                    </div>
                </div>

                <!-- Card 6: Mental Pengasuh (SRQ) -->
                <div class="flex flex-col justify-between rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/30 dark:border-white/10 transition-colors">
                    <div class="flex items-center justify-between">
                        <span class="text-2xs font-bold uppercase tracking-wider text-forest dark:text-forest-light">Mental Pengasuh</span>
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-forest/10 text-forest dark:bg-forest/20 dark:text-forest-light">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                            </svg>
                        </div>
                    </div>
                    <div class="mt-2">
                        <p class="text-2xl font-black text-forest dark:text-forest-light">{{ registerTotals.srq || 0 }}</p>
                        <p class="text-2xs font-semibold text-gray-500 dark:text-gray-400 mt-0.5">
                            Distres (Alert 17: <strong class="text-rose-600 font-bold">{{ instrumentBreakdown.srq.suicide_alert }}</strong>)
                        </p>
                    </div>
                </div>
            </section>

            <!-- SEARCH, FILTER & TAB CONTROLS BAR -->
            <section class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 sm:p-5 shadow-xs space-y-4 print:hidden">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <!-- Pencarian Pasien / No RM / Sekolah -->
                    <div class="relative flex-1 min-w-[260px] max-w-md">
                        <input
                            v-model="searchQuery"
                            type="text"
                            placeholder="Cari nama anak, no. RM, alamat, atau sekolah..."
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] pl-9 pr-8 py-2 text-xs text-navy dark:text-white placeholder:text-gray-400 focus:border-teal focus:ring-teal"
                        />
                        <svg class="absolute left-3 top-2.5 h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                        <button
                            v-if="searchQuery"
                            type="button"
                            @click="searchQuery = ''"
                            class="absolute right-2.5 top-2 text-gray-400 hover:text-gray-600 dark:hover:text-white text-xs font-bold px-1"
                            title="Hapus pencarian"
                        >
                            ✕
                        </button>
                    </div>

                    <!-- Filter Status & Perawat -->
                    <div class="flex flex-wrap items-center gap-2.5">
                        <select
                            :value="filters.status || ''"
                            @change="onStatusChange"
                            class="rounded-xl border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] text-navy dark:text-white text-xs font-semibold px-3 py-2 focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Status Sesi</option>
                            <option value="reviewed">Selesai Ditinjau Dokter</option>
                            <option value="pending_doctor_review">Menunggu Dokter</option>
                            <option value="in_progress">Sedang Berlangsung</option>
                            <option value="draft">Draf</option>
                        </select>

                        <select
                            v-if="nurses && nurses.length > 0"
                            :value="filters.nurse_id || ''"
                            @change="onNurseChange"
                            class="rounded-xl border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] text-navy dark:text-white text-xs font-semibold px-3 py-2 focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Perawat Pemeriksa</option>
                            <option v-for="n in nurses" :key="n.id" :value="n.id">
                                {{ n.user?.name || `Perawat #${n.id}` }}
                            </option>
                        </select>

                        <label class="flex items-center gap-2 rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] px-3 py-2 text-xs font-bold text-navy dark:text-white cursor-pointer select-none">
                            <input
                                v-model="onlyAttention"
                                type="checkbox"
                                class="rounded border-sand/60 text-teal focus:ring-teal"
                            />
                            <span>Hanya dengan catatan / temuan</span>
                        </label>
                    </div>
                </div>

                <!-- TAB NAVIGASI KONTEN (Pills) -->
                <div class="flex flex-wrap items-center gap-2 pt-2 border-t border-sand/30 dark:border-white/10">
                    <button
                        type="button"
                        @click="activeViewTab = 'register'"
                        :class="[
                            'inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-extrabold transition shadow-2xs',
                            activeViewTab === 'register'
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre'
                                : 'bg-[#FAF7F0] dark:bg-[#071D37] text-gray-600 dark:text-sand/80 hover:bg-sand/30 hover:text-navy dark:hover:text-white border border-sand/40 dark:border-white/10'
                        ]"
                    >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        <span>Tabel Register Bulanan (Format UPTD)</span>
                        <span class="rounded-full bg-white/20 px-2 py-0.5 text-2xs font-black">
                            {{ filteredRegisterRows.length }}
                        </span>
                    </button>

                    <button
                        type="button"
                        @click="activeViewTab = 'klinis'"
                        :class="[
                            'inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-extrabold transition shadow-2xs',
                            activeViewTab === 'klinis'
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre'
                                : 'bg-[#FAF7F0] dark:bg-[#071D37] text-gray-600 dark:text-sand/80 hover:bg-sand/30 hover:text-navy dark:hover:text-white border border-sand/40 dark:border-white/10'
                        ]"
                    >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                        <span>Analisis Klinis &amp; Demografi</span>
                    </button>

                    <button
                        type="button"
                        @click="activeViewTab = 'tren'"
                        :class="[
                            'inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-extrabold transition shadow-2xs',
                            activeViewTab === 'tren'
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre'
                                : 'bg-[#FAF7F0] dark:bg-[#071D37] text-gray-600 dark:text-sand/80 hover:bg-sand/30 hover:text-navy dark:hover:text-white border border-sand/40 dark:border-white/10'
                        ]"
                    >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z" />
                        </svg>
                        <span>Tren Tahunan (12 Bulan)</span>
                    </button>
                </div>
            </section>

            <!-- =================================================================== -->
            <!-- TAB 1: TABEL REGISTER BULANAN STANDAR UPTD (WARNA ASLI KEMBALI)    -->
            <!-- =================================================================== -->
            <div v-if="activeViewTab === 'register'" class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-sm overflow-hidden">
                <div class="p-4 border-b border-slate-200 dark:border-slate-800 flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-slate-50/50 dark:bg-slate-800/30">
                    <div>
                        <h2 class="text-base font-bold text-slate-900 dark:text-white flex items-center gap-2">
                            <span>Buku Register Deteksi Dini Tumbuh Kembang Anak</span>
                            <span class="text-xs px-2 py-0.5 rounded-full bg-teal-100 dark:bg-teal-950 text-teal-800 dark:text-teal-300 font-semibold">
                                Periode: {{ currentMonthLabel }} {{ selectedYear }}
                            </span>
                        </h2>
                        <p class="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                            Format standar UPTD BLK-ABK: KMPE disesuaikan menjadi instrumen SDQ dan SRQ-20.
                        </p>
                    </div>

                    <div class="flex items-center gap-3">
                        <label class="flex items-center gap-2 text-xs font-medium text-slate-700 dark:text-slate-300 cursor-pointer select-none">
                            <input
                                v-model="onlyAttention"
                                type="checkbox"
                                class="rounded border-slate-300 text-teal-600 focus:ring-teal-500"
                            />
                            <span>Hanya yang memiliki catatan / temuan</span>
                        </label>
                    </div>
                </div>

                <!-- Kontainer Tabel dengan Horizontal Scroll -->
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs border-collapse">
                        <!-- Header Baris 1: Grup Kategori Utama (Warna Asli Sebelumnya) -->
                        <thead>
                            <tr class="bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-200 font-black text-center uppercase tracking-wider text-[11px] border-b border-slate-300 dark:border-slate-700">
                                <th rowspan="2" class="px-2 py-2 border-r border-slate-300 dark:border-slate-700 w-10">No</th>
                                <th rowspan="2" class="px-3 py-2 border-r border-slate-300 dark:border-slate-700 min-w-[180px] text-left">Nama Pasien / Anak</th>
                                <th colspan="2" class="px-2 py-1.5 border-r border-slate-300 dark:border-slate-700 bg-blue-50/60 dark:bg-blue-950/40 text-blue-900 dark:text-blue-300">Jenis Kelamin</th>
                                <th colspan="3" class="px-2 py-1.5 border-r border-slate-300 dark:border-slate-700 bg-amber-50/60 dark:bg-amber-950/40 text-amber-900 dark:text-amber-300">Kasus</th>
                                <th rowspan="2" class="px-3 py-2 border-r border-slate-300 dark:border-slate-700 min-w-[160px] text-left">Alamat</th>
                                <th rowspan="2" class="px-2 py-2 border-r border-slate-300 dark:border-slate-700 w-20">Tgl Lahir</th>
                                <th rowspan="2" class="px-2 py-2 border-r border-slate-300 dark:border-slate-700 w-14">Usia</th>
                                <th colspan="4" class="px-2 py-1.5 border-r border-slate-300 dark:border-slate-700 bg-emerald-100/70 dark:bg-emerald-950/50 text-emerald-900 dark:text-emerald-300">
                                    Deteksi Dini Penyimpangan Perkembangan (KPSP 4 Domain)
                                </th>
                                <th colspan="4" class="px-2 py-1.5 border-r border-slate-300 dark:border-slate-700 bg-rose-100/70 dark:bg-rose-950/50 text-rose-900 dark:text-rose-300">
                                    Deteksi Dini Perilaku Emosional (SDQ, M-CHAT, GPPH, SRQ)
                                </th>
                                <th colspan="10" class="px-2 py-1.5 border-r border-slate-300 dark:border-slate-700 bg-amber-100/60 dark:bg-amber-950/40 text-amber-900 dark:text-amber-300">
                                    Layanan Kesehatan / Intervensi yang Diberikan
                                </th>
                                <th colspan="5" class="px-2 py-1.5 border-r border-slate-300 dark:border-slate-700 bg-indigo-100/60 dark:bg-indigo-950/40 text-indigo-900 dark:text-indigo-300">
                                    Pendidikan
                                </th>
                                <th rowspan="2" class="px-3 py-2 min-w-[150px] text-left">Keterangan (Nama Sekolah)</th>
                            </tr>

                            <!-- Header Baris 2: Sub-Kolom (Warna Asli Sebelumnya) -->
                            <tr class="bg-slate-50 dark:bg-slate-800/80 text-slate-700 dark:text-slate-300 font-bold text-center text-[10px] border-b border-slate-200 dark:border-slate-700">
                                <!-- Gender -->
                                <th class="px-2 py-1.5 border-r border-slate-200 dark:border-slate-700 w-10">L</th>
                                <th class="px-2 py-1.5 border-r border-slate-200 dark:border-slate-700 w-10">P</th>
                                <!-- Kasus -->
                                <th class="px-2 py-1.5 border-r border-slate-200 dark:border-slate-700 w-12">Baru</th>
                                <th class="px-2 py-1.5 border-r border-slate-200 dark:border-slate-700 w-12">Lama</th>
                                <th class="px-2 py-1.5 border-r border-slate-200 dark:border-slate-700 min-w-[90px]">Rujukan Dari</th>
                                <!-- KPSP 4 Domain -->
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-emerald-50/70 dark:bg-emerald-950/30 text-emerald-950 dark:text-emerald-300">Motorik Kasar</th>
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-emerald-50/70 dark:bg-emerald-950/30 text-emerald-950 dark:text-emerald-300">Motorik Halus</th>
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-emerald-50/70 dark:bg-emerald-950/30 text-emerald-950 dark:text-emerald-300">Bicara / Bhs</th>
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-emerald-50/70 dark:bg-emerald-950/30 text-emerald-950 dark:text-emerald-300">Sosialisasi</th>
                                <!-- Perilaku Emosional -->
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-rose-50/70 dark:bg-rose-950/30 text-rose-950 dark:text-rose-300">SDQ Anak</th>
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-rose-50/70 dark:bg-rose-950/30 text-rose-950 dark:text-rose-300">M-CHAT (Autis)</th>
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-rose-50/70 dark:bg-rose-950/30 text-rose-950 dark:text-rose-300">GPPH</th>
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 bg-rose-50/70 dark:bg-rose-950/30 text-rose-950 dark:text-rose-300">SRQ Pengasuh</th>
                                <!-- Layanan / Intervensi -->
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Psikolog</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">ABA</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">OT</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">TW</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">SI</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Fisio</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Medis</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Konseling</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Rehab</th>
                                <th class="px-2 py-1 border-r border-slate-200 dark:border-slate-700 min-w-[90px]">Rujukan Ke</th>
                                <!-- Pendidikan -->
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Reguler</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Inklusi</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">SLB</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Panti</th>
                                <th class="px-1.5 py-1 border-r border-slate-200 dark:border-slate-700">Tdk Sek</th>
                            </tr>

                            <!-- Header Baris 3: Kode Penomoran Kolom Standar UPTD (1 s/d 34) -->
                            <tr class="bg-slate-100/60 dark:bg-slate-800/50 text-slate-400 dark:text-slate-500 font-mono text-[9px] text-center border-b border-slate-300 dark:border-slate-700">
                                <th v-for="c in 34" :key="c" class="py-0.5 border-r border-slate-200 dark:border-slate-800">
                                    {{ c }}
                                </th>
                            </tr>
                        </thead>

                        <!-- Body Tabel -->
                        <tbody class="divide-y divide-slate-200 dark:divide-slate-800">
                            <tr
                                v-for="r in filteredRegisterRows"
                                :key="r.session_id"
                                class="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                            >
                                <td class="px-2 py-2 text-center text-slate-500 font-mono border-r border-slate-200 dark:border-slate-800">
                                    {{ r.no }}
                                </td>

                                <td class="px-3 py-2 border-r border-slate-200 dark:border-slate-800">
                                    <Link
                                        :href="`/spk/screening-sessions/${r.session_id}`"
                                        class="font-bold text-teal-600 dark:text-teal-400 hover:underline block leading-tight"
                                    >
                                        {{ r.name }}
                                    </Link>
                                    <span class="text-[10px] text-slate-400 font-mono">
                                        {{ r.medical_record_number }}
                                    </span>
                                </td>

                                <!-- Jenis Kelamin -->
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">
                                    {{ r.is_male ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">
                                    {{ r.is_female ? '1' : '' }}
                                </td>

                                <!-- Kasus -->
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-teal-700 dark:text-teal-400">
                                    {{ r.is_case_new ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-indigo-700 dark:text-indigo-400">
                                    {{ r.is_case_old ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 text-[11px] text-slate-600 dark:text-slate-400">
                                    {{ r.referral_from !== '-' ? r.referral_from : '' }}
                                </td>

                                <!-- Alamat -->
                                <td class="px-3 py-2 border-r border-slate-200 dark:border-slate-800 text-[11px] text-slate-700 dark:text-slate-300 max-w-[180px] truncate" :title="r.address">
                                    {{ r.address }}
                                </td>

                                <!-- Tgl Lahir & Usia -->
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 text-[11px] font-mono text-slate-600 dark:text-slate-400">
                                    {{ r.birth_date }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-mono font-bold text-slate-900 dark:text-slate-100">
                                    {{ r.age_display }}
                                </td>

                                <!-- KPSP 4 Domain -->
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-emerald-50/30 dark:bg-emerald-950/20 font-black text-rose-600 dark:text-rose-400">
                                    {{ r.gg_motorik_kasar ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-emerald-50/30 dark:bg-emerald-950/20 font-black text-rose-600 dark:text-rose-400">
                                    {{ r.gg_motorik_halus ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-emerald-50/30 dark:bg-emerald-950/20 font-black text-rose-600 dark:text-rose-400">
                                    {{ r.gg_bicara_bahasa ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-emerald-50/30 dark:bg-emerald-950/20 font-black text-rose-600 dark:text-rose-400">
                                    {{ r.gg_sosialisasi ? '1' : '' }}
                                </td>

                                <!-- Perilaku Emosional -->
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-rose-50/30 dark:bg-rose-950/20 font-black text-purple-600 dark:text-purple-400">
                                    {{ r.sdq ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-rose-50/30 dark:bg-rose-950/20 font-black text-purple-600 dark:text-purple-400">
                                    {{ r.mchat ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-rose-50/30 dark:bg-rose-950/20 font-black text-purple-600 dark:text-purple-400">
                                    {{ r.gpph ? '1' : '' }}
                                </td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 bg-rose-50/30 dark:bg-rose-950/20 font-black text-blue-600 dark:text-blue-400">
                                    {{ r.srq ? '1' : '' }}
                                </td>

                                <!-- Layanan / Intervensi -->
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.psikolog ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.aba ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.ot ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.tw ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.si ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.fisioterapi ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.perawatan_medis ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.konseling ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.rehabilitasi ? '1' : '' }}</td>
                                <td class="px-2 py-2 text-center border-r border-slate-200 dark:border-slate-800 text-[11px] text-slate-700 dark:text-slate-300 font-medium">
                                    {{ r.rujukan_ke || '' }}
                                </td>

                                <!-- Pendidikan -->
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.sekolah_reguler ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.sekolah_inklusi ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.slb ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.panti ? '1' : '' }}</td>
                                <td class="px-1.5 py-2 text-center border-r border-slate-200 dark:border-slate-800 font-bold text-slate-800 dark:text-slate-200">{{ r.tidak_sekolah ? '1' : '' }}</td>

                                <!-- Keterangan (Nama Sekolah) -->
                                <td class="px-3 py-2 text-[11px] text-slate-700 dark:text-slate-300 font-medium">
                                    <span v-if="r.keterangan && r.keterangan !== '-'" class="px-2 py-0.5 rounded-md bg-slate-100 dark:bg-slate-800 text-slate-800 dark:text-slate-200 border border-slate-200 dark:border-slate-700 inline-block font-semibold">
                                        {{ r.keterangan }}
                                    </span>
                                    <span v-else class="text-slate-400 dark:text-slate-500 italic">-</span>
                                </td>
                            </tr>

                            <tr v-if="filteredRegisterRows.length === 0">
                                <td colspan="34" class="px-6 py-12 text-center text-slate-500">
                                    <p class="font-medium text-sm">Tidak ada sesi skrining untuk bulan {{ currentMonthLabel }} {{ selectedYear }}.</p>
                                    <p class="text-xs text-slate-400 mt-1">Gunakan tombol pemilih bulan di atas untuk melihat periode lain.</p>
                                </td>
                            </tr>
                        </tbody>

                        <!-- Baris Total Kumulatif Register -->
                        <tfoot v-if="filteredRegisterRows.length > 0">
                            <tr class="bg-slate-200 dark:bg-slate-800 font-black text-slate-900 dark:text-white text-center border-t-2 border-slate-300 dark:border-slate-700">
                                <td colspan="2" class="px-3 py-2.5 text-center uppercase tracking-wider text-xs">
                                    TOTAL (BULAN {{ currentMonthLabel }})
                                </td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.male || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.female || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-teal-700 dark:text-teal-300">{{ registerTotals.case_new || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-indigo-700 dark:text-indigo-300">{{ registerTotals.case_old || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700">-</td>
                                <td class="px-3 py-2.5 border-r border-slate-300 dark:border-slate-700">-</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700">-</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700">-</td>
                                <!-- KPSP 4 Domain -->
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-rose-600 dark:text-rose-400">{{ registerTotals.kpsp_motorik_kasar || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-rose-600 dark:text-rose-400">{{ registerTotals.kpsp_motorik_halus || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-rose-600 dark:text-rose-400">{{ registerTotals.kpsp_bicara_bahasa || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-rose-600 dark:text-rose-400">{{ registerTotals.kpsp_sosialisasi || 0 }}</td>
                                <!-- Perilaku Emosional -->
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-purple-600 dark:text-purple-400">{{ registerTotals.sdq || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-purple-600 dark:text-purple-400">{{ registerTotals.mchat || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-purple-600 dark:text-purple-400">{{ registerTotals.gpph || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700 text-blue-600 dark:text-blue-400">{{ registerTotals.srq || 0 }}</td>
                                <!-- Layanan -->
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.psikolog || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.aba || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.ot || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.tw || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.si || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.fisioterapi || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.perawatan_medis || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.konseling || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.rehabilitasi || 0 }}</td>
                                <td class="px-2 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.rujukan_ke || 0 }}</td>
                                <!-- Pendidikan -->
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.sekolah_reguler || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.sekolah_inklusi || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.slb || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.panti || 0 }}</td>
                                <td class="px-1.5 py-2.5 border-r border-slate-300 dark:border-slate-700">{{ registerTotals.tidak_sekolah || 0 }}</td>
                                <td class="px-3 py-2.5 text-center">-</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>

            <!-- =================================================================== -->
            <!-- TAB 2: ANALISIS KLINIS & DEMOGRAFI PASIEN                          -->
            <!-- =================================================================== -->
            <div v-if="activeViewTab === 'klinis'" class="space-y-6">
                <!-- Grid Analisis Hasil 5 Instrumen Klinis -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                    <!-- 1. KPSP -->
                    <div class="rounded-2xl bg-white dark:bg-[#0C2038] border border-sand/30 dark:border-white/10 p-5 shadow-xs flex flex-col justify-between">
                        <div>
                            <div class="flex items-center justify-between pb-3 border-b border-sand/20 dark:border-white/10">
                                <div>
                                    <h3 class="font-extrabold text-navy dark:text-white">KPSP (Perkembangan)</h3>
                                    <p class="text-3xs text-gray-500 dark:text-gray-400">4 Domain Perkembangan Anak</p>
                                </div>
                                <span class="text-3xs px-2.5 py-1 rounded-full bg-forest/15 text-forest dark:bg-forest/30 dark:text-forest-light font-extrabold">
                                    {{ instrumentBreakdown.kpsp.total }} Sesi
                                </span>
                            </div>

                            <!-- Klasifikasi Status KPSP -->
                            <div class="mt-4 space-y-2">
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-gray-600 dark:text-gray-400 font-semibold">Sesuai Umur (S)</span>
                                    <span class="font-black text-forest dark:text-forest-light">{{ instrumentBreakdown.kpsp.sesuai }}</span>
                                </div>
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-gray-600 dark:text-gray-400 font-semibold">Meragukan (M)</span>
                                    <span class="font-black text-ochre dark:text-ochre-light">{{ instrumentBreakdown.kpsp.meragukan }}</span>
                                </div>
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-gray-600 dark:text-gray-400 font-semibold">Penyimpangan (P)</span>
                                    <span class="font-black text-rose-600 dark:text-rose-400">{{ instrumentBreakdown.kpsp.penyimpangan }}</span>
                                </div>
                            </div>

                            <!-- Rincian Nilai Deteksi Penyimpangan per Domain KPSP -->
                            <div class="mt-4 pt-3 border-t border-dashed border-sand/40 dark:border-white/10">
                                <div class="flex items-center justify-between mb-2">
                                    <span class="text-2xs font-extrabold uppercase tracking-wider text-rose-700 dark:text-rose-400">
                                        Deteksi Hambatan per Domain
                                    </span>
                                    <span class="text-3xs text-gray-500 dark:text-gray-400">Temuan</span>
                                </div>
                                <div class="space-y-2">
                                    <!-- 1. Motorik Kasar -->
                                    <div>
                                        <div class="flex items-center justify-between text-xs">
                                            <span class="text-gray-700 dark:text-gray-300 font-medium">Motorik Kasar</span>
                                            <span class="font-black text-rose-600 dark:text-rose-400">
                                                {{ instrumentBreakdown.kpsp.domains?.motorik_kasar ?? registerTotals.kpsp_motorik_kasar ?? 0 }} anak
                                            </span>
                                        </div>
                                        <div class="w-full bg-gray-100 dark:bg-white/10 h-1.5 rounded-full overflow-hidden mt-1">
                                            <div
                                                class="bg-rose-500 h-1.5 rounded-full"
                                                :style="{ width: `${instrumentBreakdown.kpsp.total > 0 ? Math.min(100, Math.round(((instrumentBreakdown.kpsp.domains?.motorik_kasar ?? registerTotals.kpsp_motorik_kasar ?? 0) / instrumentBreakdown.kpsp.total) * 100)) : 0}%` }"
                                            ></div>
                                        </div>
                                    </div>
                                    <!-- 2. Motorik Halus -->
                                    <div>
                                        <div class="flex items-center justify-between text-xs">
                                            <span class="text-gray-700 dark:text-gray-300 font-medium">Motorik Halus</span>
                                            <span class="font-black text-rose-600 dark:text-rose-400">
                                                {{ instrumentBreakdown.kpsp.domains?.motorik_halus ?? registerTotals.kpsp_motorik_halus ?? 0 }} anak
                                            </span>
                                        </div>
                                        <div class="w-full bg-gray-100 dark:bg-white/10 h-1.5 rounded-full overflow-hidden mt-1">
                                            <div
                                                class="bg-rose-500 h-1.5 rounded-full"
                                                :style="{ width: `${instrumentBreakdown.kpsp.total > 0 ? Math.min(100, Math.round(((instrumentBreakdown.kpsp.domains?.motorik_halus ?? registerTotals.kpsp_motorik_halus ?? 0) / instrumentBreakdown.kpsp.total) * 100)) : 0}%` }"
                                            ></div>
                                        </div>
                                    </div>
                                    <!-- 3. Bicara & Bahasa -->
                                    <div>
                                        <div class="flex items-center justify-between text-xs">
                                            <span class="text-gray-700 dark:text-gray-300 font-medium">Bicara &amp; Bahasa</span>
                                            <span class="font-black text-rose-600 dark:text-rose-400">
                                                {{ instrumentBreakdown.kpsp.domains?.bicara_bahasa ?? registerTotals.kpsp_bicara_bahasa ?? 0 }} anak
                                            </span>
                                        </div>
                                        <div class="w-full bg-gray-100 dark:bg-white/10 h-1.5 rounded-full overflow-hidden mt-1">
                                            <div
                                                class="bg-rose-500 h-1.5 rounded-full"
                                                :style="{ width: `${instrumentBreakdown.kpsp.total > 0 ? Math.min(100, Math.round(((instrumentBreakdown.kpsp.domains?.bicara_bahasa ?? registerTotals.kpsp_bicara_bahasa ?? 0) / instrumentBreakdown.kpsp.total) * 100)) : 0}%` }"
                                            ></div>
                                        </div>
                                    </div>
                                    <!-- 4. Sosialisasi & Kemandirian -->
                                    <div>
                                        <div class="flex items-center justify-between text-xs">
                                            <span class="text-gray-700 dark:text-gray-300 font-medium">Sosialisasi &amp; Kemandirian</span>
                                            <span class="font-black text-rose-600 dark:text-rose-400">
                                                {{ instrumentBreakdown.kpsp.domains?.sosialisasi_kemandirian ?? registerTotals.kpsp_sosialisasi ?? 0 }} anak
                                            </span>
                                        </div>
                                        <div class="w-full bg-gray-100 dark:bg-white/10 h-1.5 rounded-full overflow-hidden mt-1">
                                            <div
                                                class="bg-rose-500 h-1.5 rounded-full"
                                                :style="{ width: `${instrumentBreakdown.kpsp.total > 0 ? Math.min(100, Math.round(((instrumentBreakdown.kpsp.domains?.sosialisasi_kemandirian ?? registerTotals.kpsp_sosialisasi ?? 0) / instrumentBreakdown.kpsp.total) * 100)) : 0}%` }"
                                            ></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 2. SDQ -->
                    <div class="rounded-2xl bg-white dark:bg-[#0C2038] border border-sand/30 dark:border-white/10 p-5 shadow-xs">
                        <div class="flex items-center justify-between pb-3 border-b border-sand/20 dark:border-white/10">
                            <div>
                                <h3 class="font-extrabold text-navy dark:text-white">SDQ (Perilaku Emosi)</h3>
                                <p class="text-3xs text-gray-500 dark:text-gray-400">Kuesioner Kekuatan &amp; Kesulitan Anak</p>
                            </div>
                            <span class="text-3xs px-2.5 py-1 rounded-full bg-purple-500/15 text-purple-700 dark:bg-purple-500/30 dark:text-purple-300 font-extrabold">
                                {{ instrumentBreakdown.sdq.total }} Sesi
                            </span>
                        </div>
                        <div class="mt-4 space-y-2.5">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Normal</span>
                                <span class="font-black text-forest dark:text-forest-light">{{ instrumentBreakdown.sdq.normal }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Ambang / Borderline</span>
                                <span class="font-black text-ochre dark:text-ochre-light">{{ instrumentBreakdown.sdq.ambang_borderline }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Abnormal</span>
                                <span class="font-black text-rose-600 dark:text-rose-400">{{ instrumentBreakdown.sdq.abnormal }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- 3. M-CHAT-R -->
                    <div class="rounded-2xl bg-white dark:bg-[#0C2038] border border-sand/30 dark:border-white/10 p-5 shadow-xs">
                        <div class="flex items-center justify-between pb-3 border-b border-sand/20 dark:border-white/10">
                            <div>
                                <h3 class="font-extrabold text-navy dark:text-white">M-CHAT-R (Autis)</h3>
                                <p class="text-3xs text-gray-500 dark:text-gray-400">Deteksi Dini Spektrum Autisme</p>
                            </div>
                            <span class="text-3xs px-2.5 py-1 rounded-full bg-teal/15 text-teal dark:bg-teal/30 dark:text-teal-light font-extrabold">
                                {{ instrumentBreakdown.mchat.total }} Sesi
                            </span>
                        </div>
                        <div class="mt-4 space-y-2.5">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Risiko Rendah</span>
                                <span class="font-black text-forest dark:text-forest-light">{{ instrumentBreakdown.mchat.risiko_rendah }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Risiko Sedang / Tinggi</span>
                                <span class="font-black text-rose-600 dark:text-rose-400">{{ instrumentBreakdown.mchat.risiko_sedang_tinggi }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- 4. GPPH -->
                    <div class="rounded-2xl bg-white dark:bg-[#0C2038] border border-sand/30 dark:border-white/10 p-5 shadow-xs">
                        <div class="flex items-center justify-between pb-3 border-b border-sand/20 dark:border-white/10">
                            <div>
                                <h3 class="font-extrabold text-navy dark:text-white">GPPH (Hiperaktivitas)</h3>
                                <p class="text-3xs text-gray-500 dark:text-gray-400">Gangguan Pemusatan Perhatian</p>
                            </div>
                            <span class="text-3xs px-2.5 py-1 rounded-full bg-ochre/15 text-ochre-dark dark:bg-ochre/30 dark:text-ochre-light font-extrabold">
                                {{ instrumentBreakdown.gpph.total }} Sesi
                            </span>
                        </div>
                        <div class="mt-4 space-y-2.5">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Normal</span>
                                <span class="font-black text-forest dark:text-forest-light">{{ instrumentBreakdown.gpph.normal ?? instrumentBreakdown.gpph.tidak_menunjukkan_gpph }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Meragukan (Evaluasi 1 Bulan)</span>
                                <span class="font-black text-amber-600 dark:text-amber-400">{{ instrumentBreakdown.gpph.meragukan ?? 0 }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Kemungkinan GPPH (Positif)</span>
                                <span class="font-black text-rose-600 dark:text-rose-400">{{ instrumentBreakdown.gpph.kemungkinan_gpph }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- 5. SRQ-20 -->
                    <div class="rounded-2xl bg-white dark:bg-[#0C2038] border border-sand/30 dark:border-white/10 p-5 shadow-xs">
                        <div class="flex items-center justify-between pb-3 border-b border-sand/20 dark:border-white/10">
                            <div>
                                <h3 class="font-extrabold text-navy dark:text-white">SRQ-20 (Pengasuh)</h3>
                                <p class="text-3xs text-gray-500 dark:text-gray-400">Kesehatan Mental Emosional Orang Tua</p>
                            </div>
                            <span class="text-3xs px-2.5 py-1 rounded-full bg-teal/15 text-teal dark:bg-teal/30 dark:text-teal-light font-extrabold">
                                {{ instrumentBreakdown.srq.total }} Sesi
                            </span>
                        </div>
                        <div class="mt-4 space-y-2.5">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Normal (Skor &lt; 6)</span>
                                <span class="font-black text-forest dark:text-forest-light">{{ instrumentBreakdown.srq.di_bawah_nilai_pisah }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Distres Emosional (Skor &ge; 6)</span>
                                <span class="font-black text-rose-600 dark:text-rose-400">{{ instrumentBreakdown.srq.gangguan_mental_emosional_distres }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs pt-1.5 border-t border-sand/20 dark:border-white/10 text-rose-600 dark:text-rose-400 font-extrabold">
                                <span>Peringatan Butir 17</span>
                                <span>{{ instrumentBreakdown.srq.suicide_alert }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- 6. Demografi Umur -->
                    <div class="rounded-2xl bg-white dark:bg-[#0C2038] border border-sand/30 dark:border-white/10 p-5 shadow-xs">
                        <div class="flex items-center justify-between pb-3 border-b border-sand/20 dark:border-white/10">
                            <div>
                                <h3 class="font-extrabold text-navy dark:text-white">Kelompok Usia Anak</h3>
                                <p class="text-3xs text-gray-500 dark:text-gray-400">Distribusi Umur Pasien Skrining</p>
                            </div>
                        </div>
                        <div class="mt-4 space-y-2.5">
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Bayi (&lt; 12 Bulan)</span>
                                <span class="font-black text-navy dark:text-white">{{ demographics.age_groups.bayi }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Batita (1 - 3 Tahun)</span>
                                <span class="font-black text-navy dark:text-white">{{ demographics.age_groups.batita }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Prasekolah (3 - 5 Tahun)</span>
                                <span class="font-black text-navy dark:text-white">{{ demographics.age_groups.prasekolah }}</span>
                            </div>
                            <div class="flex items-center justify-between text-xs">
                                <span class="text-gray-600 dark:text-gray-400 font-semibold">Sekolah (5 - 11 Tahun)</span>
                                <span class="font-black text-navy dark:text-white">{{ demographics.age_groups.sekolah }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- =================================================================== -->
            <!-- TAB 3: TREN TAHUNAN SEPANJANG TAHUN (FORMAT LAPORAN RESMI UPTD BLK-ABK) -->
            <!-- =================================================================== -->
            <div v-if="activeViewTab === 'tren'" class="space-y-8">
                <!-- Sub-Navigation & Header Bar -->
                <div class="rounded-3xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] shadow-xs p-6">
                    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-5 border-b border-sand/30 dark:border-white/10">
                        <div>
                            <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-teal/10 dark:bg-teal/20 text-teal dark:text-teal-light text-2xs font-extrabold mb-2 uppercase tracking-wider">
                                <span class="h-2 w-2 rounded-full bg-teal animate-pulse"></span>
                                Rekapitulasi Tahunan SDIDTK &bull; UPTD BLK-ABK Balikpapan
                            </div>
                            <h2 class="text-xl sm:text-2xl font-black text-navy dark:text-white">
                                Laporan Tren Pelayanan Tahunan (Tahun {{ selectedYear }})
                            </h2>
                            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                Integrasi data 12 bulan: Pasien Terlayani, Hasil Deteksi Dini, Rekapitulasi Diagnosis, dan Layanan Kesehatan.
                            </p>
                        </div>

                        <!-- Selector Sub-Laporan -->
                        <div class="flex flex-wrap items-center gap-1.5 p-1.5 rounded-2xl bg-[#F6F2E9] dark:bg-[#071D37] border border-sand/40 dark:border-white/10">
                            <button
                                type="button"
                                @click="activeTrenModule = 'all'"
                                class="px-3 py-1.5 rounded-xl text-2xs font-extrabold transition cursor-pointer"
                                :class="activeTrenModule === 'all'
                                    ? 'bg-teal text-white shadow-xs'
                                    : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white'"
                            >
                                Semua Laporan
                            </button>
                            <button
                                type="button"
                                @click="activeTrenModule = 'patients'"
                                class="px-3 py-1.5 rounded-xl text-2xs font-extrabold transition cursor-pointer"
                                :class="activeTrenModule === 'patients'
                                    ? 'bg-teal text-white shadow-xs'
                                    : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white'"
                            >
                                1. Pasien Terlayani
                            </button>
                            <button
                                type="button"
                                @click="activeTrenModule = 'deteksi'"
                                class="px-3 py-1.5 rounded-xl text-2xs font-extrabold transition cursor-pointer"
                                :class="activeTrenModule === 'deteksi'
                                    ? 'bg-teal text-white shadow-xs'
                                    : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white'"
                            >
                                2. Deteksi Dini
                            </button>
                            <button
                                type="button"
                                @click="activeTrenModule = 'diagnosis'"
                                class="px-3 py-1.5 rounded-xl text-2xs font-extrabold transition cursor-pointer"
                                :class="activeTrenModule === 'diagnosis'
                                    ? 'bg-teal text-white shadow-xs'
                                    : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white'"
                            >
                                3. Diagnosis
                            </button>
                            <button
                                type="button"
                                @click="activeTrenModule = 'intervensi'"
                                class="px-3 py-1.5 rounded-xl text-2xs font-extrabold transition cursor-pointer"
                                :class="activeTrenModule === 'intervensi'
                                    ? 'bg-teal text-white shadow-xs'
                                    : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white'"
                            >
                                4. Layanan Intervensi
                            </button>
                        </div>
                    </div>

                    <!-- Navigasi Pemilih Tahun Rekapitulasi Tahunan -->
                    <div class="mt-5 pt-4 border-t border-sand/20 dark:border-white/10 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                        <div class="flex flex-wrap items-center gap-2">
                            <span class="text-xs font-bold text-gray-600 dark:text-gray-300">
                                Pilih Tahun Rekapitulasi:
                            </span>
                            <div class="flex flex-wrap items-center gap-1.5">
                                <button
                                    v-for="y in availableYears"
                                    :key="y"
                                    type="button"
                                    @click="applyFilter({ year: y })"
                                    class="px-3.5 py-1.5 rounded-xl text-xs font-extrabold transition cursor-pointer"
                                    :class="y === selectedYear
                                        ? 'bg-ochre text-navy shadow-xs ring-2 ring-ochre/40'
                                        : 'bg-[#FAF7F0] dark:bg-[#071D37] text-gray-700 dark:text-gray-300 border border-sand/40 dark:border-white/10 hover:border-teal'"
                                >
                                    Tahun {{ y }}
                                </button>
                            </div>
                        </div>

                        <div class="text-2xs text-gray-500 dark:text-gray-400 font-medium">
                            Menampilkan data analitis 12 bulan untuk periode anggaran <span class="font-extrabold text-teal dark:text-teal-light">Tahun {{ selectedYear }}</span>
                        </div>
                    </div>
                </div>

                <!-- ================================================================= -->
                <!-- MODUL 1: TOTAL PASIEN TERLAYANI (BERDASARKAN JENIS KELAMIN)       -->
                <!-- ================================================================= -->
                <section
                    v-if="activeTrenModule === 'all' || activeTrenModule === 'patients'"
                    class="rounded-3xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] shadow-xs p-6 space-y-6"
                >
                    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 pb-4 border-b border-sand/30 dark:border-white/10">
                        <div>
                            <div class="flex items-center gap-2">
                                <span class="flex h-7 w-7 items-center justify-center rounded-xl bg-teal/15 text-teal font-black text-xs">1</span>
                                <h3 class="text-lg font-extrabold text-navy dark:text-white">
                                    Total Pasien Terlayani Tahun {{ selectedYear }}
                                </h3>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                Rekapitulasi jumlah pasien anak berkebutuhan khusus yang terlayani per bulan berdasarkan jenis kelamin.
                            </p>
                        </div>

                        <!-- 3 Stat Badge Cards -->
                        <div class="flex flex-wrap items-center gap-3">
                            <div class="px-4 py-2 rounded-2xl bg-blue-50 dark:bg-blue-950/40 border border-blue-200 dark:border-blue-800/40">
                                <span class="text-3xs font-extrabold uppercase text-blue-700 dark:text-blue-300">Laki-laki</span>
                                <p class="text-lg font-black text-blue-900 dark:text-blue-100">
                                    {{ formatNumber(annualReports.patientsReport?.totals?.male) }}
                                </p>
                            </div>
                            <div class="px-4 py-2 rounded-2xl bg-pink-50 dark:bg-pink-950/40 border border-pink-200 dark:border-pink-800/40">
                                <span class="text-3xs font-extrabold uppercase text-pink-700 dark:text-pink-300">Perempuan</span>
                                <p class="text-lg font-black text-pink-900 dark:text-pink-100">
                                    {{ formatNumber(annualReports.patientsReport?.totals?.female) }}
                                </p>
                            </div>
                            <div class="px-4 py-2 rounded-2xl bg-amber-50 dark:bg-amber-950/40 border border-amber-200 dark:border-amber-800/40">
                                <span class="text-3xs font-extrabold uppercase text-amber-700 dark:text-amber-300">Total Pasien</span>
                                <p class="text-lg font-black text-amber-900 dark:text-amber-100">
                                    {{ formatNumber(annualReports.patientsReport?.totals?.total) }}
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Grid Tabel & Narasi Analitik Otomatis -->
                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                        <!-- Tabel Pasien Terlayani 12 Bulan -->
                        <div class="lg:col-span-7 overflow-x-auto rounded-2xl border border-sand/40 dark:border-white/10">
                            <table class="w-full text-left text-xs border-collapse">
                                <thead>
                                    <tr class="bg-[#F8F4EA] dark:bg-[#071D37] text-navy dark:text-sand-light font-extrabold border-b border-sand/30 dark:border-white/10">
                                        <th class="py-3 px-3 text-center w-12">No</th>
                                        <th class="py-3 px-4">Bulan</th>
                                        <th class="py-3 px-4 text-center">Laki-laki</th>
                                        <th class="py-3 px-4 text-center">Perempuan</th>
                                        <th class="py-3 px-4 text-center font-black">Total Pasien</th>
                                        <th class="py-3 px-4 text-center">Status</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                    <tr
                                        v-for="row in annualReports.patientsReport?.rows"
                                        :key="row.month"
                                        :class="[
                                            'transition-colors hover:bg-teal/5 dark:hover:bg-white/5',
                                            row.month === selectedMonth ? 'bg-teal/10 dark:bg-teal/20 font-bold' : ''
                                        ]"
                                    >
                                        <td class="py-2.5 px-3 text-center text-gray-500 dark:text-gray-400 font-bold">{{ row.no }}</td>
                                        <td class="py-2.5 px-4 font-bold text-navy dark:text-white">{{ row.name }}</td>
                                        <td class="py-2.5 px-4 text-center text-blue-700 dark:text-blue-300 font-bold">
                                            {{ row.male > 0 ? formatNumber(row.male) : '-' }}
                                        </td>
                                        <td class="py-2.5 px-4 text-center text-pink-700 dark:text-pink-300 font-bold">
                                            {{ row.female > 0 ? formatNumber(row.female) : '-' }}
                                        </td>
                                        <td class="py-2.5 px-4 text-center font-black text-navy dark:text-white">
                                            {{ row.total > 0 ? formatNumber(row.total) : '-' }}
                                        </td>
                                        <td class="py-2.5 px-4 text-center">
                                            <span
                                                v-if="row.is_in_progress"
                                                class="inline-block px-2 py-0.5 rounded-full text-3xs font-extrabold bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300"
                                            >
                                                Bulan Berjalan
                                            </span>
                                            <span
                                                v-else
                                                class="inline-block px-2 py-0.5 rounded-full text-3xs font-extrabold bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-300"
                                            >
                                                Selesai
                                            </span>
                                        </td>
                                    </tr>
                                </tbody>
                                <tfoot>
                                    <tr class="bg-[#ECE4D0] dark:bg-[#071D37] text-navy dark:text-white font-black border-t-2 border-sand dark:border-white/20">
                                        <td colspan="2" class="py-3 px-4 text-left uppercase tracking-wider text-xs">
                                            Total Pasien Terlayani {{ selectedYear }}
                                        </td>
                                        <td class="py-3 px-4 text-center text-blue-800 dark:text-blue-300">
                                            {{ formatNumber(annualReports.patientsReport?.totals?.male) }}
                                        </td>
                                        <td class="py-3 px-4 text-center text-pink-800 dark:text-pink-300">
                                            {{ formatNumber(annualReports.patientsReport?.totals?.female) }}
                                        </td>
                                        <td class="py-3 px-4 text-center text-base text-navy dark:text-ochre">
                                            {{ formatNumber(annualReports.patientsReport?.totals?.total) }}
                                        </td>
                                        <td class="py-3 px-4 text-center text-3xs text-gray-600 dark:text-gray-400">100%</td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <!-- Narasi Analitik Otomatis (Format Gambar 1) -->
                        <div class="lg:col-span-5 flex flex-col justify-between rounded-2xl bg-gradient-to-br from-[#FFFDF7] to-[#F7F2E6] dark:from-[#09223F] dark:to-[#071D37] border-2 border-dashed border-ochre/40 dark:border-ochre/30 p-5 shadow-xs">
                            <div>
                                <div class="flex items-center gap-2 text-ochre-dark dark:text-ochre font-extrabold text-xs uppercase tracking-wider mb-3">
                                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    Ringkasan Analisis Kunjungan Pasien
                                </div>
                                <p class="text-xs text-gray-700 dark:text-gray-200 leading-relaxed font-medium text-justify">
                                    {{ annualReports.patientsReport?.narrative }}
                                </p>
                            </div>

                            <div class="mt-6 pt-4 border-t border-sand/40 dark:border-white/10 flex items-center justify-between text-3xs text-gray-500 dark:text-gray-400">
                                <span>Sumber: Buku Register Pelayanan UPTD BLK-ABK</span>
                                <span class="font-bold text-teal dark:text-teal-light">Tahun Anggaran {{ selectedYear }}</span>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ================================================================= -->
                <!-- MODUL 2: BERDASARKAN HASIL DETEKSI DINI (KPSP & LANJUTAN)         -->
                <!-- ================================================================= -->
                <section
                    v-if="activeTrenModule === 'all' || activeTrenModule === 'deteksi'"
                    class="rounded-3xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] shadow-xs p-6 space-y-6"
                >
                    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 pb-4 border-b border-sand/30 dark:border-white/10">
                        <div>
                            <div class="flex items-center gap-2">
                                <span class="flex h-7 w-7 items-center justify-center rounded-xl bg-forest/15 text-forest font-black text-xs">2</span>
                                <h3 class="text-lg font-extrabold text-navy dark:text-white">
                                    Berdasarkan Hasil Deteksi Dini Tumbuh Kembang
                                </h3>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                Frekuensi indikasi hambatan pada KPSP (4 domain) serta instrumen lanjutan (KMPE/SDQ, M-CHAT Autis, GPPH).
                            </p>
                        </div>
                    </div>

                    <!-- 2 Tabel Berdampingan Sesuai Gambar 1 -->
                    <div class="grid grid-cols-1 xl:grid-cols-2 gap-6">
                        <!-- Tabel A: KPSP 4 Domain -->
                        <div class="overflow-x-auto rounded-2xl border border-sand/40 dark:border-white/10">
                            <div class="p-3 bg-[#F8F4EA] dark:bg-[#071D37] border-b border-sand/30 dark:border-white/10">
                                <h4 class="text-xs font-black text-navy dark:text-white uppercase tracking-wider">
                                    Deteksi Perkembangan Dasar (KPSP 4 Domain)
                                </h4>
                            </div>
                            <table class="w-full text-left text-xs border-collapse">
                                <thead>
                                    <tr class="bg-[#FAF7F0] dark:bg-[#0C2038] text-navy dark:text-sand-light font-extrabold border-b border-sand/30 dark:border-white/10 text-2xs">
                                        <th class="py-2.5 px-2 text-center w-8">No</th>
                                        <th class="py-2.5 px-3">Bulan</th>
                                        <th class="py-2.5 px-3 text-center">GG Motorik Kasar</th>
                                        <th class="py-2.5 px-3 text-center">GG Motorik Halus</th>
                                        <th class="py-2.5 px-3 text-center">GG Bicara / Bahasa</th>
                                        <th class="py-2.5 px-3 text-center">GG Sosialisasi &amp; Kemandirian</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                    <tr
                                        v-for="row in annualReports.kpspReport?.rows"
                                        :key="row.month"
                                        :class="[
                                            'transition-colors hover:bg-teal/5 dark:hover:bg-white/5',
                                            row.month === selectedMonth ? 'bg-teal/10 dark:bg-teal/20 font-bold' : ''
                                        ]"
                                    >
                                        <td class="py-2 px-2 text-center text-gray-500 dark:text-gray-400 text-3xs">{{ row.no }}</td>
                                        <td class="py-2 px-3 font-bold text-navy dark:text-white">{{ row.name }}</td>
                                        <td class="py-2 px-3 text-center font-extrabold text-rose-600 dark:text-rose-400">
                                            {{ row.motorik_kasar > 0 ? formatNumber(row.motorik_kasar) : '-' }}
                                        </td>
                                        <td class="py-2 px-3 text-center font-extrabold text-rose-600 dark:text-rose-400">
                                            {{ row.motorik_halus > 0 ? formatNumber(row.motorik_halus) : '-' }}
                                        </td>
                                        <td class="py-2 px-3 text-center font-extrabold text-rose-600 dark:text-rose-400">
                                            {{ row.bicara_bahasa > 0 ? formatNumber(row.bicara_bahasa) : '-' }}
                                        </td>
                                        <td class="py-2 px-3 text-center font-extrabold text-rose-600 dark:text-rose-400">
                                            {{ row.sosialisasi > 0 ? formatNumber(row.sosialisasi) : '-' }}
                                        </td>
                                    </tr>
                                </tbody>
                                <tfoot>
                                    <tr class="bg-[#ECE4D0] dark:bg-[#071D37] text-navy dark:text-white font-black border-t-2 border-sand dark:border-white/20">
                                        <td colspan="2" class="py-2.5 px-3 text-left uppercase text-3xs">Total</td>
                                        <td class="py-2.5 px-3 text-center text-rose-700 dark:text-rose-300">
                                            {{ formatNumber(annualReports.kpspReport?.totals?.motorik_kasar) }}
                                        </td>
                                        <td class="py-2.5 px-3 text-center text-rose-700 dark:text-rose-300">
                                            {{ formatNumber(annualReports.kpspReport?.totals?.motorik_halus) }}
                                        </td>
                                        <td class="py-2.5 px-3 text-center text-rose-700 dark:text-rose-300">
                                            {{ formatNumber(annualReports.kpspReport?.totals?.bicara_bahasa) }}
                                        </td>
                                        <td class="py-2.5 px-3 text-center text-rose-700 dark:text-rose-300">
                                            {{ formatNumber(annualReports.kpspReport?.totals?.sosialisasi) }}
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <!-- Tabel B: Masalah Perilaku Emosional, Autis & GPPH -->
                        <div class="overflow-x-auto rounded-2xl border border-sand/40 dark:border-white/10">
                            <div class="p-3 bg-[#F8F4EA] dark:bg-[#071D37] border-b border-sand/30 dark:border-white/10">
                                <h4 class="text-xs font-black text-navy dark:text-white uppercase tracking-wider">
                                    Deteksi Masalah Perilaku, Emosional &amp; Perkembangan Lanjutan
                                </h4>
                            </div>
                            <table class="w-full text-left text-xs border-collapse">
                                <thead>
                                    <tr class="bg-[#FAF7F0] dark:bg-[#0C2038] text-navy dark:text-sand-light font-extrabold border-b border-sand/30 dark:border-white/10 text-2xs">
                                        <th class="py-2.5 px-2 text-center w-8">No</th>
                                        <th class="py-2.5 px-3">Bulan</th>
                                        <th class="py-2.5 px-3 text-center">Masalah Emosional &amp; Perilaku Anak (SDQ)</th>
                                        <th class="py-2.5 px-3 text-center">Mental Emosional Pengasuh (SRQ-20)</th>
                                        <th class="py-2.5 px-3 text-center">Deteksi Dini Autis (M-CHAT)</th>
                                        <th class="py-2.5 px-3 text-center">Deteksi Pemusatan Perhatian (GPPH)</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                    <tr
                                        v-for="row in annualReports.advancedReport?.rows"
                                        :key="row.month"
                                        :class="[
                                            'transition-colors hover:bg-teal/5 dark:hover:bg-white/5',
                                            row.month === selectedMonth ? 'bg-teal/10 dark:bg-teal/20 font-bold' : ''
                                        ]"
                                    >
                                        <td class="py-2 px-2 text-center text-gray-500 dark:text-gray-400 text-3xs">{{ row.no }}</td>
                                        <td class="py-2 px-3 font-bold text-navy dark:text-white">{{ row.name }}</td>
                                        <td class="py-2 px-3 text-center font-extrabold text-purple-700 dark:text-purple-300">
                                            {{ (row.sdq ?? row.kmpe) > 0 ? formatNumber(row.sdq ?? row.kmpe) : '-' }}
                                        </td>
                                        <td class="py-2 px-3 text-center font-extrabold text-indigo-700 dark:text-indigo-300">
                                            {{ row.srq > 0 ? formatNumber(row.srq) : '-' }}
                                        </td>
                                        <td class="py-2 px-3 text-center font-extrabold text-teal dark:text-teal-light">
                                            {{ row.mchat > 0 ? formatNumber(row.mchat) : '-' }}
                                        </td>
                                        <td class="py-2 px-3 text-center font-extrabold text-ochre-dark dark:text-ochre-light">
                                            {{ row.gpph > 0 ? formatNumber(row.gpph) : '-' }}
                                        </td>
                                    </tr>
                                </tbody>
                                <tfoot>
                                    <tr class="bg-[#ECE4D0] dark:bg-[#071D37] text-navy dark:text-white font-black border-t-2 border-sand dark:border-white/20">
                                        <td colspan="2" class="py-2.5 px-3 text-left uppercase text-3xs">Total</td>
                                        <td class="py-2.5 px-3 text-center text-purple-800 dark:text-purple-300">
                                            {{ formatNumber(annualReports.advancedReport?.totals?.sdq ?? annualReports.advancedReport?.totals?.kmpe) }}
                                        </td>
                                        <td class="py-2.5 px-3 text-center text-indigo-800 dark:text-indigo-300">
                                            {{ formatNumber(annualReports.advancedReport?.totals?.srq) }}
                                        </td>
                                        <td class="py-2.5 px-3 text-center text-teal-dark dark:text-teal-light">
                                            {{ formatNumber(annualReports.advancedReport?.totals?.mchat) }}
                                        </td>
                                        <td class="py-2.5 px-3 text-center text-ochre-dark dark:text-ochre">
                                            {{ formatNumber(annualReports.advancedReport?.totals?.gpph) }}
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>

                    <!-- Kotak Narasi Analitis Deteksi Dini -->
                    <div class="rounded-2xl bg-gradient-to-br from-[#FFFDF7] to-[#F7F2E6] dark:from-[#09223F] dark:to-[#071D37] border-2 border-dashed border-teal/40 dark:border-teal/30 p-5 shadow-xs">
                        <div class="flex items-center gap-2 text-teal font-extrabold text-xs uppercase tracking-wider mb-2">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            Interpretasi Hasil Skrining Deteksi Dini Tahunan
                        </div>
                        <p class="text-xs text-gray-700 dark:text-gray-200 leading-relaxed font-medium text-justify">
                            {{ annualReports.advancedReport?.narrative }}
                        </p>
                    </div>
                </section>

                <!-- ================================================================= -->
                <!-- MODUL 3: BERDASARKAN DIAGNOSIS KLINIS (15 KATEGORI UPTD BLK-ABK)  -->
                <!-- ================================================================= -->
                <section
                    v-if="activeTrenModule === 'all' || activeTrenModule === 'diagnosis'"
                    class="rounded-3xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] shadow-xs p-6 space-y-6"
                >
                    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 pb-4 border-b border-sand/30 dark:border-white/10">
                        <div>
                            <div class="flex items-center gap-2">
                                <span class="flex h-7 w-7 items-center justify-center rounded-xl bg-ochre/15 text-ochre-dark dark:text-ochre font-black text-xs">3</span>
                                <h3 class="text-lg font-extrabold text-navy dark:text-white">
                                    Rekapitulasi Berdasarkan Diagnosis Klinis
                                </h3>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                Distribusi 15 kategori diagnosis: Gangguan Fisik vs Gangguan Emosional / Perilaku / Belajar / Komunikasi.
                            </p>
                        </div>
                    </div>

                    <!-- Tabel Diagnosis 15 Kolom Sesuai Gambar 2 -->
                    <div class="overflow-x-auto rounded-2xl border border-sand/40 dark:border-white/10 shadow-xs">
                        <table class="w-full text-left text-2xs border-collapse">
                            <thead>
                                <!-- Header Baris 1: Kategori Utama -->
                                <tr class="bg-[#F6EED8] dark:bg-[#071D37] text-navy dark:text-sand-light font-black border-b border-sand dark:border-white/15">
                                    <th rowspan="2" class="py-3 px-2 text-center w-8 border-r border-sand/40 dark:border-white/10">No</th>
                                    <th rowspan="2" class="py-3 px-3 w-28 border-r border-sand/40 dark:border-white/10">Bulan</th>
                                    <th colspan="7" class="py-2 px-2 text-center bg-amber-100/70 dark:bg-amber-950/40 text-amber-900 dark:text-amber-300 border-r-2 border-sand dark:border-white/20 uppercase tracking-wider font-black">
                                        Gangguan Fisik
                                    </th>
                                    <th colspan="8" class="py-2 px-2 text-center bg-teal/15 dark:bg-teal/20 text-teal-dark dark:text-teal-light uppercase tracking-wider font-black border-r border-sand/40 dark:border-white/10">
                                        Gangguan Emosional / Perilaku / Belajar / DLL
                                    </th>
                                    <th rowspan="2" class="py-3 px-3 text-center w-16 bg-[#ECE4D0] dark:bg-[#071D37] font-black text-navy dark:text-white">
                                        Total
                                    </th>
                                </tr>
                                <!-- Header Baris 2: 15 Sub-Kategori -->
                                <tr class="bg-[#FAF7F0] dark:bg-[#0C2038] text-gray-700 dark:text-gray-300 font-bold border-b border-sand/30 dark:border-white/10 text-3xs">
                                    <!-- Fisik (7 Kolom) -->
                                    <th class="py-2 px-1.5 text-center min-w-[70px]">Tuna Netra</th>
                                    <th class="py-2 px-1.5 text-center min-w-[70px]">Tuna Rungu</th>
                                    <th class="py-2 px-1.5 text-center min-w-[85px]">Tuna Daksa / CP</th>
                                    <th class="py-2 px-1.5 text-center min-w-[75px]">Tuna Ganda</th>
                                    <th class="py-2 px-1.5 text-center min-w-[85px]">GDD / Sindrom Down</th>
                                    <th class="py-2 px-1.5 text-center min-w-[70px]">Tuna Laras</th>
                                    <th class="py-2 px-1.5 text-center min-w-[70px] border-r-2 border-sand dark:border-white/20">Tuna Wicara</th>
                                    <!-- Emosional (8 Kolom) -->
                                    <th class="py-2 px-1.5 text-center min-w-[95px]">ADHD / GPPH / Indigo</th>
                                    <th class="py-2 px-1.5 text-center min-w-[75px]">GG Perilaku</th>
                                    <th class="py-2 px-1.5 text-center min-w-[85px]">Tuna Grahita</th>
                                    <th class="py-2 px-1.5 text-center min-w-[85px]">Keterlambatan Belajar</th>
                                    <th class="py-2 px-1.5 text-center min-w-[95px]">Kesulitan Belajar / Disleksia</th>
                                    <th class="py-2 px-1.5 text-center min-w-[75px]">Anak Berbakat</th>
                                    <th class="py-2 px-1.5 text-center min-w-[75px] font-black text-rose-600 dark:text-rose-400">Autisme</th>
                                    <th class="py-2 px-1.5 text-center min-w-[90px] border-r border-sand/40 dark:border-white/10">Bahasa / Komunikasi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-sand/20 dark:divide-white/5 font-semibold">
                                <tr
                                    v-for="row in annualReports.diagnosisReport?.rows"
                                    :key="row.month"
                                    :class="[
                                        'transition-colors hover:bg-teal/5 dark:hover:bg-white/5',
                                        row.month === selectedMonth ? 'bg-teal/10 dark:bg-teal/20 font-bold' : ''
                                    ]"
                                >
                                    <td class="py-2 px-2 text-center text-gray-500 dark:text-gray-400 text-3xs border-r border-sand/30 dark:border-white/10">{{ row.no }}</td>
                                    <td class="py-2 px-3 font-bold text-navy dark:text-white border-r border-sand/30 dark:border-white/10">{{ row.name }}</td>
                                    <!-- 7 Fisik -->
                                    <td class="py-2 px-1.5 text-center">{{ row.tuna_netra || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.tuna_rungu || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.tuna_daksa || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.tuna_ganda || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.gdd_down || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.tuna_laras || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center border-r-2 border-sand dark:border-white/20">{{ row.tuna_wicara || '-' }}</td>
                                    <!-- 8 Emosional -->
                                    <td class="py-2 px-1.5 text-center">{{ row.adhd_gpph || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.gangguan_perilaku || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.tuna_grahita || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.keterlambatan_belajar || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.kesulitan_belajar || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center">{{ row.anak_berbakat || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center font-black text-rose-600 dark:text-rose-400">{{ row.autisme || '-' }}</td>
                                    <td class="py-2 px-1.5 text-center border-r border-sand/40 dark:border-white/10">{{ row.gangguan_bahasa || '-' }}</td>
                                    <td class="py-2 px-3 text-center font-black text-navy dark:text-white bg-sand-light/30 dark:bg-white/5">
                                        {{ row.total || '-' }}
                                    </td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr class="bg-[#ECE4D0] dark:bg-[#071D37] text-navy dark:text-white font-black border-t-2 border-sand dark:border-white/20">
                                    <td colspan="2" class="py-3 px-3 text-left uppercase text-3xs border-r border-sand/40 dark:border-white/10">Total</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.tuna_netra ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.tuna_rungu ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.tuna_daksa ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.tuna_ganda ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.gdd_down ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.tuna_laras ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center border-r-2 border-sand dark:border-white/20">{{ annualReports.diagnosisReport?.totals?.tuna_wicara ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.adhd_gpph ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.gangguan_perilaku ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.tuna_grahita ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.keterlambatan_belajar ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.kesulitan_belajar ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center">{{ annualReports.diagnosisReport?.totals?.anak_berbakat ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center text-rose-700 dark:text-rose-400 font-black">{{ annualReports.diagnosisReport?.totals?.autisme ?? 0 }}</td>
                                    <td class="py-3 px-1.5 text-center border-r border-sand/40 dark:border-white/10">{{ annualReports.diagnosisReport?.totals?.gangguan_bahasa ?? 0 }}</td>
                                    <td class="py-3 px-3 text-center text-base text-navy dark:text-ochre">
                                        {{ annualReports.diagnosisReport?.grand_total ?? 0 }}
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>

                    <!-- Kotak Narasi Analitis Diagnosis -->
                    <div class="rounded-2xl bg-gradient-to-br from-[#FFFDF7] to-[#F7F2E6] dark:from-[#09223F] dark:to-[#071D37] border-2 border-dashed border-rose-400/40 dark:border-rose-400/30 p-5 shadow-xs">
                        <div class="flex items-center gap-2 text-rose-700 dark:text-rose-400 font-extrabold text-xs uppercase tracking-wider mb-2">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />
                            </svg>
                            Deskripsi Analisis Diagnosis Klinis Tahunan
                        </div>
                        <p class="text-xs text-gray-700 dark:text-gray-200 leading-relaxed font-medium text-justify">
                            {{ annualReports.diagnosisReport?.narrative }}
                        </p>
                    </div>
                </section>

                <!-- ================================================================= -->
                <!-- MODUL 4: LAYANAN KESEHATAN / INTERVENSI YANG DIBERIKAN            -->
                <!-- ================================================================= -->
                <section
                    v-if="activeTrenModule === 'all' || activeTrenModule === 'intervensi'"
                    class="rounded-3xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] shadow-xs p-6 space-y-6"
                >
                    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 pb-4 border-b border-sand/30 dark:border-white/10">
                        <div>
                            <div class="flex items-center gap-2">
                                <span class="flex h-7 w-7 items-center justify-center rounded-xl bg-purple-500/15 text-purple-700 dark:text-purple-300 font-black text-xs">4</span>
                                <h3 class="text-lg font-extrabold text-navy dark:text-white">
                                    Layanan Kesehatan / Intervensi yang Diberikan
                                </h3>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                Rekapitulasi frekuensi tindakan intervensi tumbuh kembang dan terapi berkelanjutan sepanjang tahun.
                            </p>
                        </div>
                    </div>

                    <!-- Tabel Layanan Intervensi 9 Kolom Sesuai Gambar 2 -->
                    <div class="overflow-x-auto rounded-2xl border border-sand/40 dark:border-white/10 shadow-xs">
                        <table class="w-full text-left text-xs border-collapse">
                            <thead>
                                <tr class="bg-[#F8F4EA] dark:bg-[#071D37] text-navy dark:text-sand-light font-extrabold border-b border-sand/30 dark:border-white/10 text-2xs">
                                    <th class="py-3 px-2 text-center w-8">No</th>
                                    <th class="py-3 px-3 w-28">Bulan</th>
                                    <th class="py-3 px-2.5 text-center">Psikolog</th>
                                    <th class="py-3 px-2.5 text-center">Applied Behavior Analysis (ABA)</th>
                                    <th class="py-3 px-2.5 text-center">Terapi Okupasi (OT)</th>
                                    <th class="py-3 px-2.5 text-center">Terapi Wicara (TW)</th>
                                    <th class="py-3 px-2.5 text-center font-black text-teal-dark dark:text-teal-light">Terapi Lain-lain (Sensori Integrasi)</th>
                                    <th class="py-3 px-2.5 text-center">Fisioterapi</th>
                                    <th class="py-3 px-2.5 text-center">Perawatan Medis</th>
                                    <th class="py-3 px-2.5 text-center">Konseling</th>
                                    <th class="py-3 px-2.5 text-center">Rehabilitasi</th>
                                    <th class="py-3 px-3 text-center font-black bg-[#ECE4D0] dark:bg-[#071D37] text-navy dark:text-white">Total</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-sand/20 dark:divide-white/5 font-semibold">
                                <tr
                                    v-for="row in annualReports.interventionsReport?.rows"
                                    :key="row.month"
                                    :class="[
                                        'transition-colors hover:bg-teal/5 dark:hover:bg-white/5',
                                        row.month === selectedMonth ? 'bg-teal/10 dark:bg-teal/20 font-bold' : ''
                                    ]"
                                >
                                    <td class="py-2 px-2 text-center text-gray-500 dark:text-gray-400 text-3xs">{{ row.no }}</td>
                                    <td class="py-2 px-3 font-bold text-navy dark:text-white">{{ row.name }}</td>
                                    <td class="py-2 px-2.5 text-center">{{ row.psikolog || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center text-blue-700 dark:text-blue-300 font-bold">{{ row.aba || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center">{{ row.ot || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center">{{ row.tw || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center font-black text-teal-dark dark:text-teal-light">{{ row.si || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center">{{ row.fisioterapi || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center">{{ row.perawatan_medis || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center text-purple-700 dark:text-purple-300 font-bold">{{ row.konseling || '-' }}</td>
                                    <td class="py-2 px-2.5 text-center">{{ row.rehabilitasi || '-' }}</td>
                                    <td class="py-2 px-3 text-center font-black text-navy dark:text-white bg-sand-light/30 dark:bg-white/5">
                                        {{ row.total || '-' }}
                                    </td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr class="bg-[#ECE4D0] dark:bg-[#071D37] text-navy dark:text-white font-black border-t-2 border-sand dark:border-white/20">
                                    <td colspan="2" class="py-3 px-3 text-left uppercase text-3xs">Total</td>
                                    <td class="py-3 px-2.5 text-center">{{ annualReports.interventionsReport?.totals?.psikolog ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center text-blue-800 dark:text-blue-300">{{ annualReports.interventionsReport?.totals?.aba ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center">{{ annualReports.interventionsReport?.totals?.ot ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center">{{ annualReports.interventionsReport?.totals?.tw ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center text-teal-dark dark:text-teal-light font-black text-sm">{{ annualReports.interventionsReport?.totals?.si ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center">{{ annualReports.interventionsReport?.totals?.fisioterapi ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center">{{ annualReports.interventionsReport?.totals?.perawatan_medis ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center text-purple-800 dark:text-purple-300">{{ annualReports.interventionsReport?.totals?.konseling ?? 0 }}</td>
                                    <td class="py-3 px-2.5 text-center">{{ annualReports.interventionsReport?.totals?.rehabilitasi ?? 0 }}</td>
                                    <td class="py-3 px-3 text-center text-base text-navy dark:text-ochre">
                                        {{ annualReports.interventionsReport?.grand_total ?? 0 }}
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>

                    <!-- Kotak Narasi Analitis Layanan Intervensi -->
                    <div class="rounded-2xl bg-gradient-to-br from-[#FFFDF7] to-[#F7F2E6] dark:from-[#09223F] dark:to-[#071D37] border-2 border-dashed border-purple-400/40 dark:border-purple-400/30 p-5 shadow-xs">
                        <div class="flex items-center gap-2 text-purple-700 dark:text-purple-400 font-extrabold text-xs uppercase tracking-wider mb-2">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                            </svg>
                            Deskripsi Analisis Layanan Kesehatan &amp; Intervensi Tahunan
                        </div>
                        <p class="text-xs text-gray-700 dark:text-gray-200 leading-relaxed font-medium text-justify">
                            {{ annualReports.interventionsReport?.narrative }}
                        </p>
                    </div>
                </section>
            </div>

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
@media print {
    body {
        background: #ffffff !important;
        color: #000000 !important;
    }
    .print\:hidden {
        display: none !important;
    }
}
</style>
