<script setup>
import { computed, ref } from 'vue';
import { Head, Link, router } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    filters: {
        type: Object,
        required: true,
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
    prevDate: {
        type: String,
        default: null,
    },
    nextDate: {
        type: String,
        default: null,
    },
    prevWeek: {
        type: Number,
        default: null,
    },
    nextWeek: {
        type: Number,
        default: null,
    },
    weekStartDate: {
        type: String,
        default: null,
    },
    weekEndDate: {
        type: String,
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
    periodLabel: {
        type: String,
        default: '',
    },
});

// Tab tampilan konten agar tidak menumpuk dalam 1 halaman:
// 'rekap' = Tabel rekapitulasi utama sesuai periode
// 'klinis' = Temuan klinis instrumen & demografi
// 'sesi' = Daftar sesi pasien individual
const activeViewTab = ref('rekap');

const searchQuery = ref('');
const onlyAttention = ref(false);
const showMonthlyDays = ref(false); // Toggle rincian hari 1-31 di mode bulanan

const currentGranularity = computed(() => props.filters.granularity || 'bulanan');
const selectedYear = computed(() => props.filters.year);
const selectedMonth = computed(() => props.filters.month);
const selectedDate = computed(() => props.filters.date || '');
const selectedWeek = computed(() => props.filters.week || 1);

function setGranularity(g) {
    applyFilter({ granularity: g });
}

function onYearChange(e) {
    applyFilter({ year: parseInt(e.target.value, 10) });
}

function onMonthChange(monthNum) {
    applyFilter({ month: monthNum });
}

function onDateChange(e) {
    applyFilter({ date: e.target.value });
}

function goToPrevDate() {
    if (props.prevDate) {
        applyFilter({ date: props.prevDate });
    }
}

function goToNextDate() {
    if (props.nextDate) {
        applyFilter({ date: props.nextDate });
    }
}

function goToToday() {
    const today = new Date().toISOString().slice(0, 10);
    applyFilter({ date: today });
}

function goToDate(d) {
    applyFilter({ granularity: 'harian', date: d });
}

function onWeekChange(e) {
    applyFilter({ week: parseInt(e.target.value, 10) });
}

function goToPrevWeek() {
    if (props.prevWeek) {
        applyFilter({ week: props.prevWeek });
    }
}

function goToNextWeek() {
    if (props.nextWeek) {
        applyFilter({ week: props.nextWeek });
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
        granularity: override.granularity ?? props.filters.granularity ?? 'bulanan',
        year: override.year ?? props.filters.year,
        month: override.month ?? props.filters.month,
        date: override.date !== undefined ? override.date : props.filters.date,
        week: override.week !== undefined ? override.week : props.filters.week,
        nurse_id: override.nurse_id !== undefined ? override.nurse_id : props.filters.nurse_id,
        status: override.status !== undefined ? override.status : props.filters.status,
    };

    Object.keys(params).forEach((key) => {
        if (params[key] === null || params[key] === undefined || params[key] === '') {
            delete params[key];
        }
    });

    router.get('/rekapitulasi', params, {
        preserveState: true,
        preserveScroll: true,
    });
}

function printReport() {
    window.print();
}

function formatDate(val) {
    if (!val) return '-';
    const [y, m, d] = String(val).slice(0, 10).split('-');
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    const idx = parseInt(m, 10) - 1;
    return `${d} ${months[idx] ?? m} ${y}`;
}

const filteredSessions = computed(() => {
    let list = props.sessions || [];

    if (onlyAttention.value) {
        list = list.filter((s) => s.has_attention);
    }

    if (searchQuery.value.trim()) {
        const q = searchQuery.value.toLowerCase().trim();
        list = list.filter((s) => {
            const name = s.patient?.name?.toLowerCase() || '';
            const mrn = s.patient?.medical_record_number?.toLowerCase() || '';
            const nurse = s.nurse_name?.toLowerCase() || '';
            return name.includes(q) || mrn.includes(q) || nurse.includes(q);
        });
    }

    return list;
});

const statusLabels = {
    draft: 'Draft',
    in_progress: 'Sedang Berlangsung',
    pending_parent: 'Menunggu Orang Tua',
    pending_doctor_review: 'Menunggu Dokter',
    reviewed: 'Selesai Ditinjau',
    cancelled: 'Dibatalkan',
};

const statusClasses = {
    draft: 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10',
    in_progress: 'bg-blue-100 dark:bg-blue-950/70 text-blue-800 dark:text-blue-300 border-blue-200 dark:border-blue-800',
    pending_doctor_review: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-300 border-amber-200 dark:border-amber-800',
    reviewed: 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800 font-bold',
    cancelled: 'bg-rose-100 dark:bg-rose-950/70 text-rose-700 dark:text-rose-300 border-rose-200 dark:border-rose-800',
};

// Format badge instrumen pada rekapitulasi: abu-abu jika belum selesai, warna kategori jika sudah selesai
function getRecapInstrumentBadge(inst) {
    const code = inst.code;
    const status = inst.status;
    const cat = inst.category;
    const hasAlert = inst.has_alert;

    if (status !== 'completed') {
        return {
            displayText: `${code} (Belum)`,
            classes: 'bg-gray-100 dark:bg-white/10 text-gray-500 dark:text-gray-400 border border-gray-300 dark:border-white/15',
            isAlert: false,
        };
    }

    if (code === 'KPSP') {
        if (['penyimpangan', 'kemungkinan_penyimpangan'].includes(cat)) {
            return {
                displayText: 'KPSP: Penyimpangan',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        if (cat === 'meragukan') {
            return {
                displayText: 'KPSP: Meragukan',
                classes: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border border-amber-300 dark:border-amber-800 font-bold',
                isAlert: true,
            };
        }
        return {
            displayText: 'KPSP: Sesuai',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'M-CHAT') {
        if (cat === 'risiko_sedang_tinggi') {
            return {
                displayText: 'M-CHAT: R. Tinggi',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        return {
            displayText: 'M-CHAT: R. Rendah',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'GPPH') {
        if (cat === 'kemungkinan_gpph') {
            return {
                displayText: 'GPPH: Positif',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        if (hasAlert) {
            return {
                displayText: 'GPPH: Ragu-ragu',
                classes: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border border-amber-300 dark:border-amber-800 font-bold',
                isAlert: true,
            };
        }
        return {
            displayText: 'GPPH: Normal',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'SDQ') {
        if (cat === 'abnormal') {
            return {
                displayText: 'SDQ: Abnormal',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        if (cat === 'ambang_borderline') {
            return {
                displayText: 'SDQ: Ambang',
                classes: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border border-amber-300 dark:border-amber-800 font-bold',
                isAlert: true,
            };
        }
        return {
            displayText: 'SDQ: Normal',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'SRQ') {
        if (hasAlert || cat === 'gangguan_mental_emosional_distres') {
            return {
                displayText: hasAlert ? 'SRQ: Waspada' : 'SRQ: Distres',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        return {
            displayText: 'SRQ: Normal',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    return {
        displayText: `${code}: Selesai`,
        classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold',
        isAlert: false,
    };
}
</script>

<template>
    <Head :title="`Rekapitulasi Skrining - ${periodLabel}`" />

    <AuthenticatedLayout>
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4 print:hidden">
                <div>
                    <h2 class="text-xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                        <svg class="h-6 w-6 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                        Rekapitulasi Skrining Tumbuh Kembang
                    </h2>
                    <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                        Pilih periode (Harian, Mingguan, Bulanan, Tahunan) untuk melihat rekapitulasi data skrining.
                    </p>
                </div>

                <div class="flex items-center gap-3">
                    <button
                        type="button"
                        @click="printReport"
                        class="inline-flex items-center gap-2 rounded-xl border border-sand/60 dark:border-white/10 bg-white dark:bg-white/10 px-4 py-2 text-xs font-bold text-navy dark:text-white shadow-2xs hover:bg-sand-light dark:hover:bg-white/15 transition cursor-pointer"
                    >
                        <svg class="h-4 w-4 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4H9v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        Cetak Laporan
                    </button>
                </div>
            </div>
        </template>

        <div class="space-y-6">
            <!-- PRINT HEADER BANNER (Only visible on paper / PDF print) -->
            <div class="hidden print:block border-b-2 border-gray-900 pb-4 mb-6 text-center">
                <div class="flex items-center justify-center gap-3 mb-1">
                    <div class="h-10 w-10 rounded-lg bg-teal text-white flex items-center justify-center font-black text-sm">
                        UPTD
                    </div>
                    <div>
                        <h1 class="text-base font-black uppercase tracking-wider text-gray-900">
                            UPTD PUSAT LAYANAN AUTIS & ANAK BERKEBUTUHAN KHUSUS
                        </h1>
                        <p class="text-xs text-gray-600">
                            Sistem Pendukung Keputusan Skrining Tumbuh Kembang Anak (SPK-STKA)
                        </p>
                    </div>
                </div>
                <div class="mt-3 inline-block rounded-md bg-gray-100 px-4 py-1 text-xs font-bold text-gray-800 uppercase tracking-wider">
                    Laporan {{ periodLabel }}
                </div>
            </div>

            <!-- ====================================================================== -->
            <!-- 1. KONTROL PERIODE UTAMA (Satu Bar Ringkas & Tenang)                   -->
            <!-- ====================================================================== -->
            <section class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 sm:p-5 shadow-xs space-y-4 print:hidden">
                <!-- Granularity Tabs -->
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-sand/30 dark:border-white/10 pb-3">
                    <div class="flex items-center gap-1 p-1 rounded-xl bg-[#FAF7F0] dark:bg-white/5 border border-sand/40 dark:border-white/10">
                        <button
                            type="button"
                            @click="setGranularity('harian')"
                            class="rounded-lg px-3.5 py-1.5 text-xs font-bold transition cursor-pointer"
                            :class="currentGranularity === 'harian'
                                ? 'bg-teal text-white shadow-xs'
                                : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white hover:bg-sand/30 dark:hover:bg-white/10'"
                        >
                            📆 Harian
                        </button>

                        <button
                            type="button"
                            @click="setGranularity('mingguan')"
                            class="rounded-lg px-3.5 py-1.5 text-xs font-bold transition cursor-pointer"
                            :class="currentGranularity === 'mingguan'
                                ? 'bg-teal text-white shadow-xs'
                                : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white hover:bg-sand/30 dark:hover:bg-white/10'"
                        >
                            📊 Mingguan
                        </button>

                        <button
                            type="button"
                            @click="setGranularity('bulanan')"
                            class="rounded-lg px-3.5 py-1.5 text-xs font-bold transition cursor-pointer"
                            :class="currentGranularity === 'bulanan'
                                ? 'bg-teal text-white shadow-xs'
                                : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white hover:bg-sand/30 dark:hover:bg-white/10'"
                        >
                            📅 Bulanan
                        </button>

                        <button
                            type="button"
                            @click="setGranularity('tahunan')"
                            class="rounded-lg px-3.5 py-1.5 text-xs font-bold transition cursor-pointer"
                            :class="currentGranularity === 'tahunan'
                                ? 'bg-teal text-white shadow-xs'
                                : 'text-gray-600 dark:text-gray-300 hover:text-navy dark:hover:text-white hover:bg-sand/30 dark:hover:bg-white/10'"
                        >
                            📈 Tahunan
                        </button>
                    </div>

                    <!-- Label Periode Aktif -->
                    <div class="flex items-center gap-2">
                        <span class="rounded-lg bg-teal/10 dark:bg-teal-950/40 border border-teal/30 px-3 py-1.5 text-xs font-black text-teal dark:text-teal-300">
                            {{ periodLabel }}
                        </span>
                    </div>
                </div>

                <!-- Kontrol Pemilih Periode Spesifik -->
                <!-- 1. MODE HARIAN -->
                <div v-if="currentGranularity === 'harian'" class="flex flex-wrap items-end gap-3">
                    <div class="w-48">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Pilih Tanggal
                        </label>
                        <input
                            type="date"
                            :value="selectedDate"
                            @change="onDateChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-bold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        />
                    </div>

                    <div class="flex items-center gap-1.5">
                        <button
                            type="button"
                            @click="goToPrevDate"
                            class="rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] px-3 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand/30 dark:hover:bg-white/10 transition cursor-pointer"
                            title="Hari Sebelumnya"
                        >
                            &larr; H-1
                        </button>
                        <button
                            type="button"
                            @click="goToToday"
                            class="rounded-xl bg-teal px-3 py-2 text-xs font-bold text-white shadow-2xs hover:bg-teal-dark transition cursor-pointer"
                        >
                            Hari Ini
                        </button>
                        <button
                            type="button"
                            @click="goToNextDate"
                            class="rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] px-3 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand/30 dark:hover:bg-white/10 transition cursor-pointer"
                            title="Hari Berikutnya"
                        >
                            H+1 &rarr;
                        </button>
                    </div>

                    <!-- Filter Perawat -->
                    <div class="w-48">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Perawat
                        </label>
                        <select
                            :value="filters.nurse_id || ''"
                            @change="onNurseChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Perawat</option>
                            <option v-for="n in nurses" :key="n.id" :value="n.id">{{ n.name }}</option>
                        </select>
                    </div>

                    <!-- Filter Status -->
                    <div class="w-44">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Status
                        </label>
                        <select
                            :value="filters.status || ''"
                            @change="onStatusChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Status</option>
                            <option value="reviewed">Selesai Ditinjau</option>
                            <option value="pending_doctor_review">Menunggu Dokter</option>
                            <option value="in_progress">Sedang Berlangsung</option>
                            <option value="draft">Draft</option>
                        </select>
                    </div>
                </div>

                <!-- 2. MODE MINGGUAN -->
                <div v-else-if="currentGranularity === 'mingguan'" class="flex flex-wrap items-end gap-3">
                    <div class="w-32">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Tahun
                        </label>
                        <select
                            :value="selectedYear"
                            @change="onYearChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option v-for="y in availableYears" :key="y" :value="y">Tahun {{ y }}</option>
                        </select>
                    </div>

                    <div class="w-64">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Pilih Minggu
                        </label>
                        <select
                            :value="selectedWeek"
                            @change="onWeekChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option v-for="w in availableWeeks" :key="w.week_number" :value="w.week_number">
                                {{ w.label }} <template v-if="w.total_sessions > 0">({{ w.total_sessions }} sesi)</template>
                            </option>
                        </select>
                    </div>

                    <div class="flex items-center gap-1.5">
                        <button
                            type="button"
                            @click="goToPrevWeek"
                            class="rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] px-3 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand/30 dark:hover:bg-white/10 transition cursor-pointer"
                        >
                            &larr; M-1
                        </button>
                        <button
                            type="button"
                            @click="goToNextWeek"
                            class="rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] px-3 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand/30 dark:hover:bg-white/10 transition cursor-pointer"
                        >
                            M+1 &rarr;
                        </button>
                    </div>

                    <div class="w-48">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Perawat
                        </label>
                        <select
                            :value="filters.nurse_id || ''"
                            @change="onNurseChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Perawat</option>
                            <option v-for="n in nurses" :key="n.id" :value="n.id">{{ n.name }}</option>
                        </select>
                    </div>
                </div>

                <!-- 3. MODE BULANAN -->
                <div v-else-if="currentGranularity === 'bulanan'" class="space-y-3">
                    <div class="flex flex-wrap items-end gap-3">
                        <div class="w-32">
                            <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                                Tahun
                            </label>
                            <select
                                :value="selectedYear"
                                @change="onYearChange"
                                class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                            >
                                <option v-for="y in availableYears" :key="y" :value="y">Tahun {{ y }}</option>
                            </select>
                        </div>

                        <div class="w-48">
                            <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                                Bulan
                            </label>
                            <select
                                :value="selectedMonth"
                                @change="(e) => onMonthChange(parseInt(e.target.value, 10))"
                                class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                            >
                                <option v-for="m in availableMonths" :key="m.value" :value="m.value">
                                    {{ m.label }}
                                </option>
                            </select>
                        </div>

                        <div class="w-48">
                            <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                                Perawat
                            </label>
                            <select
                                :value="filters.nurse_id || ''"
                                @change="onNurseChange"
                                class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                            >
                                <option value="">Semua Perawat</option>
                                <option v-for="n in nurses" :key="n.id" :value="n.id">{{ n.name }}</option>
                            </select>
                        </div>

                        <div class="w-44">
                            <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                                Status
                            </label>
                            <select
                                :value="filters.status || ''"
                                @change="onStatusChange"
                                class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                            >
                                <option value="">Semua Status</option>
                                <option value="reviewed">Selesai Ditinjau</option>
                                <option value="pending_doctor_review">Menunggu Dokter</option>
                                <option value="in_progress">Sedang Berlangsung</option>
                                <option value="draft">Draft</option>
                            </select>
                        </div>
                    </div>

                    <!-- Quick Month Selector Pills -->
                    <div class="pt-2 border-t border-sand/20 dark:border-white/10 flex flex-wrap gap-1 items-center">
                        <span class="text-2xs font-bold text-gray-400 uppercase tracking-wider mr-1">Bulan Cepat:</span>
                        <button
                            v-for="m in availableMonths"
                            :key="m.value"
                            type="button"
                            @click="onMonthChange(m.value)"
                            class="rounded-lg px-2.5 py-1 text-2xs font-bold transition cursor-pointer"
                            :class="selectedMonth === m.value
                                ? 'bg-ochre text-white shadow-2xs'
                                : 'bg-[#FAF7F0] dark:bg-white/5 text-gray-700 dark:text-gray-300 hover:bg-sand/30 dark:hover:bg-white/10 border border-sand/30 dark:border-white/5'"
                        >
                            {{ m.short }}
                        </button>
                    </div>
                </div>

                <!-- 4. MODE TAHUNAN -->
                <div v-else class="flex flex-wrap items-end gap-3">
                    <div class="w-36">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Pilih Tahun
                        </label>
                        <select
                            :value="selectedYear"
                            @change="onYearChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option v-for="y in availableYears" :key="y" :value="y">Tahun {{ y }}</option>
                        </select>
                    </div>

                    <div class="w-48">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Perawat
                        </label>
                        <select
                            :value="filters.nurse_id || ''"
                            @change="onNurseChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Perawat</option>
                            <option v-for="n in nurses" :key="n.id" :value="n.id">{{ n.name }}</option>
                        </select>
                    </div>

                    <div class="w-44">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Status
                        </label>
                        <select
                            :value="filters.status || ''"
                            @change="onStatusChange"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Status</option>
                            <option value="reviewed">Selesai Ditinjau</option>
                            <option value="pending_doctor_review">Menunggu Dokter</option>
                            <option value="in_progress">Sedang Berlangsung</option>
                            <option value="draft">Draft</option>
                        </select>
                    </div>
                </div>
            </section>

            <!-- ====================================================================== -->
            <!-- 2. EXECUTIVE SUMMARY (4 Angka Kunci Ramping)                           -->
            <!-- ====================================================================== -->
            <section class="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
                <!-- Total Sesi -->
                <div class="rounded-xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 shadow-2xs">
                    <span class="text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400">Total Skrining</span>
                    <div class="mt-1 flex items-baseline justify-between">
                        <span class="text-2xl font-black text-navy dark:text-white">{{ summary.total_sessions }}</span>
                        <span class="text-2xs text-gray-400">sesi</span>
                    </div>
                </div>

                <!-- Anak Unik -->
                <div class="rounded-xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 shadow-2xs">
                    <span class="text-2xs font-extrabold uppercase tracking-wider text-forest dark:text-emerald-400">Anak Diperiksa</span>
                    <div class="mt-1 flex items-baseline justify-between">
                        <span class="text-2xl font-black text-forest dark:text-emerald-400">{{ summary.unique_patients }}</span>
                        <span class="text-2xs text-gray-400">pasien</span>
                    </div>
                </div>

                <!-- Selesai Ditinjau -->
                <div class="rounded-xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 shadow-2xs">
                    <span class="text-2xs font-extrabold uppercase tracking-wider text-indigo-700 dark:text-indigo-400">Selesai Ditinjau</span>
                    <div class="mt-1 flex items-baseline justify-between">
                        <span class="text-2xl font-black text-indigo-700 dark:text-indigo-400">{{ summary.reviewed_sessions }}</span>
                        <span class="text-2xs font-bold text-emerald-600">({{ summary.completion_rate }}%)</span>
                    </div>
                </div>

                <!-- Perhatian / Rujukan -->
                <div class="rounded-xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 shadow-2xs" :class="summary.attention_cases > 0 ? 'border-rose-300 dark:border-rose-900/60 bg-rose-50/20' : ''">
                    <span class="text-2xs font-extrabold uppercase tracking-wider text-rose-700 dark:text-rose-400">Kasus Perhatian</span>
                    <div class="mt-1 flex items-baseline justify-between">
                        <span class="text-2xl font-black" :class="summary.attention_cases > 0 ? 'text-rose-600' : 'text-gray-400'">{{ summary.attention_cases }}</span>
                        <span class="text-2xs text-gray-400">kasus</span>
                    </div>
                </div>
            </section>

            <!-- ====================================================================== -->
            <!-- 3. SUB-TABS KONTEN (Pilih Mana yang Ingin Dilihat)                     -->
            <!-- ====================================================================== -->
            <div class="flex items-center gap-2 border-b border-sand/40 dark:border-white/10 pb-2 print:hidden">
                <button
                    type="button"
                    @click="activeViewTab = 'rekap'"
                    class="rounded-xl px-4 py-2 text-xs font-bold transition cursor-pointer flex items-center gap-2"
                    :class="activeViewTab === 'rekap'
                        ? 'bg-navy text-white dark:bg-white dark:text-navy shadow-xs'
                        : 'text-gray-600 dark:text-gray-300 hover:bg-sand/30 dark:hover:bg-white/10'"
                >
                    <span>📊</span> Tabel Rekapitulasi
                </button>

                <button
                    type="button"
                    @click="activeViewTab = 'klinis'"
                    class="rounded-xl px-4 py-2 text-xs font-bold transition cursor-pointer flex items-center gap-2"
                    :class="activeViewTab === 'klinis'
                        ? 'bg-navy text-white dark:bg-white dark:text-navy shadow-xs'
                        : 'text-gray-600 dark:text-gray-300 hover:bg-sand/30 dark:hover:bg-white/10'"
                >
                    <span>🩺</span> Temuan Instrumen & Demografi
                </button>

                <button
                    type="button"
                    @click="activeViewTab = 'sesi'"
                    class="rounded-xl px-4 py-2 text-xs font-bold transition cursor-pointer flex items-center gap-2"
                    :class="activeViewTab === 'sesi'
                        ? 'bg-navy text-white dark:bg-white dark:text-navy shadow-xs'
                        : 'text-gray-600 dark:text-gray-300 hover:bg-sand/30 dark:hover:bg-white/10'"
                >
                    <span>📋</span> Daftar Sesi Pasien ({{ filteredSessions.length }})
                </button>
            </div>

            <!-- ====================================================================== -->
            <!-- TAB 1: TABEL REKAPITULASI SESUAI GRANULARITAS                          -->
            <!-- ====================================================================== -->
            <div
                class="recap-tab-section space-y-6"
                :class="{ 'hidden print:block': activeViewTab !== 'rekap' }"
            >
                <!-- PRINT SECTION TITLE -->
                <div class="hidden print:block border-b-2 border-gray-800 pb-1.5 mb-3">
                    <h3 class="text-xs font-black uppercase tracking-wider text-gray-900">
                        BAGIAN I: TABEL REKAPITULASI ({{ periodLabel }})
                    </h3>
                </div>

                <!-- 1.1 REKAP HARIAN (Langsung tampilkan sesi hari itu) -->
                <section v-if="currentGranularity === 'harian'" class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-5 shadow-xs space-y-4">
                    <div class="flex items-center justify-between border-b border-sand/30 dark:border-white/10 pb-3">
                        <h3 class="text-sm font-extrabold uppercase tracking-wide text-navy dark:text-white flex items-center gap-2">
                            <span>📆</span> Sesi Skrining pada {{ periodLabel }}
                        </h3>
                        <span class="text-xs text-gray-500 font-semibold">{{ filteredSessions.length }} sesi tercatat</span>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="border-b border-sand/30 dark:border-white/10 text-gray-500 dark:text-gray-400 font-extrabold text-2xs uppercase tracking-wider bg-[#FAF7F0] dark:bg-white/5">
                                    <th class="py-2.5 px-3">Nama Pasien</th>
                                    <th class="py-2.5 px-3">No. RM</th>
                                    <th class="py-2.5 px-3">Usia / JK</th>
                                    <th class="py-2.5 px-3">Perawat</th>
                                    <th class="py-2.5 px-3">Paket Instrumen & Hasil</th>
                                    <th class="py-2.5 px-3">Status</th>
                                    <th class="py-2.5 px-3 text-center print:hidden">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                <tr v-for="s in filteredSessions" :key="s.id" class="hover:bg-sand/10 dark:hover:bg-white/5">
                                    <td class="py-2.5 px-3 font-bold text-navy dark:text-white">{{ s.patient?.name }}</td>
                                    <td class="py-2.5 px-3 font-mono text-teal">{{ s.patient?.medical_record_number }}</td>
                                    <td class="py-2.5 px-3 text-gray-600 dark:text-gray-300">{{ s.age_months }} bln ({{ s.patient?.gender }})</td>
                                    <td class="py-2.5 px-3 text-gray-600 dark:text-gray-300">{{ s.nurse_name }}</td>
                                    <td class="py-2.5 px-3">
                                        <div class="flex flex-wrap gap-1">
                                            <span
                                                v-for="inst in s.instruments"
                                                :key="inst.code"
                                                class="rounded px-1.5 py-0.5 text-3xs border"
                                                :class="getRecapInstrumentBadge(inst).classes"
                                            >
                                                <span v-if="getRecapInstrumentBadge(inst).isAlert" class="mr-0.5">⚠️</span>
                                                <span>{{ getRecapInstrumentBadge(inst).displayText }}</span>
                                            </span>
                                        </div>
                                    </td>
                                    <td class="py-2.5 px-3">
                                        <span class="rounded-full px-2 py-0.5 text-2xs font-semibold" :class="statusClasses[s.status]">
                                            {{ statusLabels[s.status] ?? s.status }}
                                        </span>
                                    </td>
                                    <td class="py-2.5 px-3 text-center print:hidden">
                                        <Link :href="`/screening-sessions/${s.id}`" class="rounded-lg bg-teal px-2 py-1 text-2xs font-bold text-white hover:bg-teal-dark">
                                            Lihat &rarr;
                                        </Link>
                                    </td>
                                </tr>
                                <tr v-if="filteredSessions.length === 0">
                                    <td colspan="7" class="py-6 text-center text-xs text-gray-400 italic">
                                        Tidak ada sesi skrining yang tercatat pada tanggal {{ selectedDate }}.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- 1.2 REKAP MINGGUAN (Tabel 7 Hari Senin - Minggu) -->
                <section v-else-if="currentGranularity === 'mingguan'" class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-5 shadow-xs space-y-4">
                    <div class="flex items-center justify-between border-b border-sand/30 dark:border-white/10 pb-3">
                        <h3 class="text-sm font-extrabold uppercase tracking-wide text-navy dark:text-white flex items-center gap-2">
                            <span>📊</span> Rincian 7 Hari dalam {{ periodLabel }}
                        </h3>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="border-b border-sand/30 dark:border-white/10 text-gray-500 dark:text-gray-400 font-extrabold text-2xs uppercase tracking-wider bg-[#FAF7F0] dark:bg-white/5">
                                    <th class="py-2.5 px-3">Hari</th>
                                    <th class="py-2.5 px-3">Tanggal</th>
                                    <th class="py-2.5 px-3 text-center">Total Sesi</th>
                                    <th class="py-2.5 px-3 text-center">Anak Unik</th>
                                    <th class="py-2.5 px-3 text-center">Selesai</th>
                                    <th class="py-2.5 px-3 text-center">Perhatian</th>
                                    <th class="py-2.5 px-3 text-center print:hidden">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                <tr v-for="d in weeklyDaysData" :key="d.date" class="hover:bg-sand/10 dark:hover:bg-white/5">
                                    <td class="py-2.5 px-3 font-bold text-navy dark:text-white">{{ d.day_name }}</td>
                                    <td class="py-2.5 px-3 font-mono text-gray-500">{{ formatDate(d.date) }}</td>
                                    <td class="py-2.5 px-3 text-center font-black" :class="d.total_sessions > 0 ? 'text-teal' : 'text-gray-300'">{{ d.total_sessions }}</td>
                                    <td class="py-2.5 px-3 text-center font-bold text-forest dark:text-emerald-400">{{ d.unique_patients || '-' }}</td>
                                    <td class="py-2.5 px-3 text-center text-emerald-600 font-semibold">{{ d.reviewed_count }}</td>
                                    <td class="py-2.5 px-3 text-center">
                                        <span v-if="d.attention_count > 0" class="rounded px-1.5 py-0.5 text-2xs font-bold bg-rose-100 text-rose-800">
                                            {{ d.attention_count }} kasus
                                        </span>
                                        <span v-else-if="d.total_sessions > 0" class="text-emerald-600 text-2xs">0</span>
                                        <span v-else class="text-gray-300">-</span>
                                    </td>
                                    <td class="py-2.5 px-3 text-center print:hidden">
                                        <button v-if="d.total_sessions > 0" type="button" @click="goToDate(d.date)" class="text-2xs font-bold text-teal hover:underline">
                                            Buka Harian &rarr;
                                        </button>
                                        <span v-else class="text-gray-300 text-2xs">-</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- 1.3 REKAP BULANAN (Tabel Minggu 1-5 + Opsional Rincian Tanggal) -->
                <section v-else-if="currentGranularity === 'bulanan'" class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-5 shadow-xs space-y-4">
                    <div class="flex items-center justify-between border-b border-sand/30 dark:border-white/10 pb-3">
                        <h3 class="text-sm font-extrabold uppercase tracking-wide text-navy dark:text-white flex items-center gap-2">
                            <span>📅</span> Rincian per Minggu (Bulan {{ availableMonths.find(m => m.value === selectedMonth)?.label }} {{ selectedYear }})
                        </h3>
                        <button
                            type="button"
                            @click="showMonthlyDays = !showMonthlyDays"
                            class="text-2xs font-bold text-teal hover:underline print:hidden cursor-pointer"
                        >
                            {{ showMonthlyDays ? 'Sembunyikan Rincian Hari' : 'Tampilkan Rincian Tanggal 1–31' }}
                        </button>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="border-b border-sand/30 dark:border-white/10 text-gray-500 dark:text-gray-400 font-extrabold text-2xs uppercase tracking-wider bg-[#FAF7F0] dark:bg-white/5">
                                    <th class="py-2.5 px-3">Pekan</th>
                                    <th class="py-2.5 px-3">Rentang Tanggal</th>
                                    <th class="py-2.5 px-3 text-center">Total Sesi</th>
                                    <th class="py-2.5 px-3 text-center">Anak Unik</th>
                                    <th class="py-2.5 px-3 text-center">Selesai</th>
                                    <th class="py-2.5 px-3 text-center">Perhatian</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                <tr v-for="w in weeklyData" :key="w.week_number" class="hover:bg-sand/10 dark:hover:bg-white/5">
                                    <td class="py-2.5 px-3 font-bold text-navy dark:text-white">{{ w.week_label }}</td>
                                    <td class="py-2.5 px-3 text-gray-600 dark:text-gray-300">{{ w.date_range }}</td>
                                    <td class="py-2.5 px-3 text-center font-black" :class="w.total_sessions > 0 ? 'text-teal' : 'text-gray-300'">{{ w.total_sessions }}</td>
                                    <td class="py-2.5 px-3 text-center font-bold text-forest dark:text-emerald-400">{{ w.unique_patients || '-' }}</td>
                                    <td class="py-2.5 px-3 text-center text-emerald-600 font-semibold">{{ w.reviewed_count }}</td>
                                    <td class="py-2.5 px-3 text-center">
                                        <span v-if="w.attention_count > 0" class="rounded px-1.5 py-0.5 text-2xs font-bold bg-rose-100 text-rose-800">
                                            {{ w.attention_count }} kasus
                                        </span>
                                        <span v-else-if="w.total_sessions > 0" class="text-emerald-600 text-2xs">0</span>
                                        <span v-else class="text-gray-300">-</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Collapsible Hari 1 - 31 -->
                    <div v-if="showMonthlyDays" class="pt-4 border-t border-sand/30 dark:border-white/10 space-y-3">
                        <span class="text-2xs font-bold uppercase tracking-wider text-gray-500">Rincian Tanggal 1 s/d {{ dailyData.length }}:</span>
                        <div class="overflow-x-auto max-h-72 overflow-y-auto">
                            <table class="w-full text-left text-xs">
                                <thead class="sticky top-0 bg-[#FAF7F0] dark:bg-[#071D37]">
                                    <tr class="border-b border-sand/30 text-gray-500 text-2xs uppercase">
                                        <th class="py-2 px-3">Tgl</th>
                                        <th class="py-2 px-3">Hari</th>
                                        <th class="py-2 px-3 text-center">Sesi</th>
                                        <th class="py-2 px-3 text-center">Anak</th>
                                        <th class="py-2 px-3 text-center">Selesai</th>
                                        <th class="py-2 px-3 text-center">Perhatian</th>
                                        <th class="py-2 px-3 text-center">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-sand/20">
                                    <tr v-for="d in dailyData" :key="d.date" :class="d.total_sessions > 0 ? 'bg-teal/5 font-semibold' : ''">
                                        <td class="py-2 px-3 font-mono font-bold">{{ d.day }}</td>
                                        <td class="py-2 px-3">{{ d.day_name }}</td>
                                        <td class="py-2 px-3 text-center font-bold">{{ d.total_sessions || '-' }}</td>
                                        <td class="py-2 px-3 text-center">{{ d.unique_patients || '-' }}</td>
                                        <td class="py-2 px-3 text-center text-emerald-600">{{ d.reviewed_count }}</td>
                                        <td class="py-2 px-3 text-center">
                                            <span v-if="d.attention_count > 0" class="text-rose-600 font-bold">{{ d.attention_count }}</span>
                                            <span v-else>-</span>
                                        </td>
                                        <td class="py-2 px-3 text-center">
                                            <button v-if="d.total_sessions > 0" type="button" @click="goToDate(d.date)" class="text-2xs text-teal font-bold hover:underline">
                                                Buka &rarr;
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- 1.4 REKAP TAHUNAN (Tabel 12 Bulan Januari - Desember) -->
                <section v-else class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-5 shadow-xs space-y-4">
                    <div class="flex items-center justify-between border-b border-sand/30 dark:border-white/10 pb-3">
                        <h3 class="text-sm font-extrabold uppercase tracking-wide text-navy dark:text-white flex items-center gap-2">
                            <span>📈</span> Rekapitulasi 12 Bulan - Tahun {{ selectedYear }}
                        </h3>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="border-b border-sand/30 dark:border-white/10 text-gray-500 dark:text-gray-400 font-extrabold text-2xs uppercase tracking-wider bg-[#FAF7F0] dark:bg-white/5">
                                    <th class="py-2.5 px-3">Bulan</th>
                                    <th class="py-2.5 px-3 text-center">Total Sesi</th>
                                    <th class="py-2.5 px-3 text-center">Anak Unik</th>
                                    <th class="py-2.5 px-3 text-center">Selesai Ditinjau</th>
                                    <th class="py-2.5 px-3 text-center">% Selesai</th>
                                    <th class="py-2.5 px-3 text-center">Perhatian</th>
                                    <th class="py-2.5 px-3 text-center print:hidden">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                <tr v-for="m in monthlyData" :key="m.month" class="hover:bg-sand/10 dark:hover:bg-white/5">
                                    <td class="py-2.5 px-3 font-bold text-navy dark:text-white">{{ m.month_name }}</td>
                                    <td class="py-2.5 px-3 text-center font-black" :class="m.total_sessions > 0 ? 'text-teal' : 'text-gray-300'">{{ m.total_sessions }}</td>
                                    <td class="py-2.5 px-3 text-center font-bold text-forest dark:text-emerald-400">{{ m.unique_patients || '-' }}</td>
                                    <td class="py-2.5 px-3 text-center text-emerald-600 font-semibold">{{ m.reviewed_count }}</td>
                                    <td class="py-2.5 px-3 text-center">
                                        <span v-if="m.total_sessions > 0" class="text-2xs font-bold">{{ m.completion_rate }}%</span>
                                        <span v-else class="text-gray-300">-</span>
                                    </td>
                                    <td class="py-2.5 px-3 text-center">
                                        <span v-if="m.attention_count > 0" class="rounded px-1.5 py-0.5 text-2xs font-bold bg-rose-100 text-rose-800">
                                            {{ m.attention_count }}
                                        </span>
                                        <span v-else-if="m.total_sessions > 0" class="text-emerald-600 text-2xs">0</span>
                                        <span v-else class="text-gray-300">-</span>
                                    </td>
                                    <td class="py-2.5 px-3 text-center print:hidden">
                                        <button v-if="m.total_sessions > 0" type="button" @click="applyFilter({ granularity: 'bulanan', month: m.month, year: selectedYear })" class="text-2xs font-bold text-teal hover:underline">
                                            Buka Bulan &rarr;
                                        </button>
                                        <span v-else class="text-gray-300 text-2xs">-</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>

            <!-- ====================================================================== -->
            <!-- TAB 2: TEMUAN KLINIS INSTRUMEN & DEMOGRAFI                             -->
            <!-- ====================================================================== -->
            <div
                class="recap-tab-section space-y-6 print:mt-6 print:break-before-page"
                :class="{ 'hidden print:block': activeViewTab !== 'klinis' }"
            >
                <!-- PRINT SECTION TITLE -->
                <div class="hidden print:block border-b-2 border-gray-800 pb-1.5 mb-3">
                    <h3 class="text-xs font-black uppercase tracking-wider text-gray-900">
                        BAGIAN II: DISTRIBUSI TEMUAN INSTRUMEN & PROFIL DEMOGRAFI
                    </h3>
                </div>
                <!-- 5 Instrumen Cards -->
                <section class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-5 shadow-xs space-y-4">
                    <h3 class="text-sm font-extrabold uppercase tracking-wide text-navy dark:text-white flex items-center gap-2 border-b border-sand/30 dark:border-white/10 pb-3">
                        <span>🩺</span> Distribusi Temuan per Instrumen ({{ periodLabel }})
                    </h3>

                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3.5">
                        <!-- KPSP -->
                        <div class="rounded-xl border border-teal/30 dark:border-teal-700/40 bg-teal/5 p-4 space-y-2.5">
                            <div class="flex justify-between items-center">
                                <span class="rounded px-2 py-0.5 text-2xs font-extrabold bg-teal text-white">KPSP</span>
                                <span class="text-xs font-black text-teal">{{ instrumentBreakdown.kpsp.total }} tes</span>
                            </div>
                            <div class="text-xs space-y-1">
                                <div class="flex justify-between text-emerald-800 dark:text-emerald-300">
                                    <span>Sesuai Umur:</span>
                                    <strong>{{ instrumentBreakdown.kpsp.sesuai }}</strong>
                                </div>
                                <div class="flex justify-between text-amber-800 dark:text-amber-300">
                                    <span>Meragukan:</span>
                                    <strong>{{ instrumentBreakdown.kpsp.meragukan }}</strong>
                                </div>
                                <div class="flex justify-between text-rose-800 dark:text-rose-300">
                                    <span>Penyimpangan:</span>
                                    <strong>{{ instrumentBreakdown.kpsp.penyimpangan }}</strong>
                                </div>
                            </div>
                        </div>

                        <!-- M-CHAT -->
                        <div class="rounded-xl border border-blue-200 dark:border-blue-800/50 bg-blue-50/40 p-4 space-y-2.5">
                            <div class="flex justify-between items-center">
                                <span class="rounded px-2 py-0.5 text-2xs font-extrabold bg-blue-700 text-white">M-CHAT-R</span>
                                <span class="text-xs font-black text-blue-900 dark:text-blue-300">{{ instrumentBreakdown.mchat.total }} tes</span>
                            </div>
                            <div class="text-xs space-y-1">
                                <div class="flex justify-between text-emerald-800 dark:text-emerald-300">
                                    <span>Risiko Rendah:</span>
                                    <strong>{{ instrumentBreakdown.mchat.risiko_rendah }}</strong>
                                </div>
                                <div class="flex justify-between text-rose-800 dark:text-rose-300">
                                    <span>Risiko Sedang/Tinggi:</span>
                                    <strong>{{ instrumentBreakdown.mchat.risiko_sedang_tinggi }}</strong>
                                </div>
                            </div>
                        </div>

                        <!-- GPPH -->
                        <div class="rounded-xl border border-amber-200 dark:border-amber-800/50 bg-amber-50/40 p-4 space-y-2.5">
                            <div class="flex justify-between items-center">
                                <span class="rounded px-2 py-0.5 text-2xs font-extrabold bg-amber-700 text-white">GPPH</span>
                                <span class="text-xs font-black text-amber-900 dark:text-amber-300">{{ instrumentBreakdown.gpph.total }} tes</span>
                            </div>
                            <div class="text-xs space-y-1">
                                <div class="flex justify-between text-emerald-800 dark:text-emerald-300">
                                    <span>Bukan GPPH:</span>
                                    <strong>{{ instrumentBreakdown.gpph.tidak_menunjukkan_gpph }}</strong>
                                </div>
                                <div class="flex justify-between text-rose-800 dark:text-rose-300">
                                    <span>Kemungkinan GPPH:</span>
                                    <strong>{{ instrumentBreakdown.gpph.kemungkinan_gpph }}</strong>
                                </div>
                            </div>
                        </div>

                        <!-- SDQ -->
                        <div class="rounded-xl border border-indigo-200 dark:border-indigo-800/50 bg-indigo-50/40 p-4 space-y-2.5">
                            <div class="flex justify-between items-center">
                                <span class="rounded px-2 py-0.5 text-2xs font-extrabold bg-indigo-700 text-white">SDQ</span>
                                <span class="text-xs font-black text-indigo-900 dark:text-indigo-300">{{ instrumentBreakdown.sdq.total }} tes</span>
                            </div>
                            <div class="text-xs space-y-1">
                                <div class="flex justify-between text-emerald-800 dark:text-emerald-300">
                                    <span>Normal:</span>
                                    <strong>{{ instrumentBreakdown.sdq.normal }}</strong>
                                </div>
                                <div class="flex justify-between text-amber-800 dark:text-amber-300">
                                    <span>Ambang:</span>
                                    <strong>{{ instrumentBreakdown.sdq.ambang_borderline }}</strong>
                                </div>
                                <div class="flex justify-between text-rose-800 dark:text-rose-300">
                                    <span>Abnormal:</span>
                                    <strong>{{ instrumentBreakdown.sdq.abnormal }}</strong>
                                </div>
                            </div>
                        </div>

                        <!-- SRQ-20 -->
                        <div class="rounded-xl border border-purple-200 dark:border-purple-800/50 bg-purple-50/40 p-4 space-y-2.5">
                            <div class="flex justify-between items-center">
                                <span class="rounded px-2 py-0.5 text-2xs font-extrabold bg-purple-700 text-white">SRQ-20</span>
                                <span class="text-xs font-black text-purple-900 dark:text-purple-300">{{ instrumentBreakdown.srq.total }} tes</span>
                            </div>
                            <div class="text-xs space-y-1">
                                <div class="flex justify-between text-emerald-800 dark:text-emerald-300">
                                    <span>Normal:</span>
                                    <strong>{{ instrumentBreakdown.srq.di_bawah_nilai_pisah }}</strong>
                                </div>
                                <div class="flex justify-between text-rose-800 dark:text-rose-300">
                                    <span>Distres:</span>
                                    <strong>{{ instrumentBreakdown.srq.gangguan_mental_emosional_distres }}</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Demografi Pasien -->
                <section class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-5 shadow-xs space-y-4">
                    <h3 class="text-sm font-extrabold uppercase tracking-wide text-navy dark:text-white flex items-center gap-2 border-b border-sand/30 dark:border-white/10 pb-3">
                        <span>👥</span> Profil Demografi Pasien ({{ periodLabel }})
                    </h3>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
                        <div class="rounded-xl bg-[#FAF7F0] dark:bg-white/5 p-3.5 border border-sand/30 space-y-2">
                            <span class="text-2xs font-bold uppercase text-gray-500">Jenis Kelamin</span>
                            <div class="flex justify-between items-center">
                                <span>👦 Laki-laki: <strong class="font-bold text-navy dark:text-white">{{ demographics.gender.laki_laki }}</strong></span>
                                <span>👧 Perempuan: <strong class="font-bold text-navy dark:text-white">{{ demographics.gender.perempuan }}</strong></span>
                            </div>
                        </div>

                        <div class="rounded-xl bg-[#FAF7F0] dark:bg-white/5 p-3.5 border border-sand/30 space-y-2">
                            <span class="text-2xs font-bold uppercase text-gray-500">Distribusi Usia</span>
                            <div class="space-y-1 text-2xs">
                                <div class="flex justify-between"><span>&lt; 12 bulan:</span><strong>{{ demographics.age_groups.bayi }}</strong></div>
                                <div class="flex justify-between"><span>1–3 tahun:</span><strong>{{ demographics.age_groups.batita }}</strong></div>
                                <div class="flex justify-between"><span>3–5 tahun:</span><strong>{{ demographics.age_groups.prasekolah }}</strong></div>
                                <div class="flex justify-between"><span>5–11 tahun:</span><strong>{{ demographics.age_groups.sekolah }}</strong></div>
                            </div>
                        </div>

                        <div class="rounded-xl bg-[#FAF7F0] dark:bg-white/5 p-3.5 border border-sand/30 space-y-2">
                            <span class="text-2xs font-bold uppercase text-gray-500">Riwayat Kelahiran</span>
                            <div class="space-y-1">
                                <div class="flex justify-between"><span>Prematur:</span><strong class="text-amber-600 font-bold">{{ demographics.prematurity.prematur }}</strong></div>
                                <div class="flex justify-between"><span>Cukup Bulan:</span><strong class="text-emerald-600 font-bold">{{ demographics.prematurity.cukup_bulan }}</strong></div>
                            </div>
                        </div>
                    </div>
                </section>
            </div>

            <!-- ====================================================================== -->
            <!-- TAB 3: DAFTAR SEMUA SESI PASIEN (Eksplorasi Detail)                   -->
            <!-- ====================================================================== -->
            <div
                class="recap-tab-section space-y-4 print:mt-6 print:break-before-page"
                :class="{ 'hidden print:block': activeViewTab !== 'sesi' }"
            >
                <!-- PRINT SECTION TITLE -->
                <div class="hidden print:block border-b-2 border-gray-800 pb-1.5 mb-3">
                    <h3 class="text-xs font-black uppercase tracking-wider text-gray-900">
                        BAGIAN III: DAFTAR RINCIAN SESI PASIEN ({{ filteredSessions.length }} SESI)
                    </h3>
                </div>

                <section class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] shadow-xs overflow-hidden">
                    <div class="p-4 border-b border-sand/30 dark:border-white/10 bg-[#FAF7F0] dark:bg-[#071D37] flex flex-wrap items-center justify-between gap-3">
                        <span class="text-xs font-bold text-navy dark:text-white">
                            Total: {{ filteredSessions.length }} sesi tercatat dalam {{ periodLabel.toLowerCase() }}
                        </span>

                        <div class="flex flex-wrap items-center gap-3 print:hidden">
                            <label class="inline-flex items-center gap-1.5 text-xs text-rose-700 dark:text-rose-400 font-bold cursor-pointer">
                                <input type="checkbox" v-model="onlyAttention" class="rounded border-rose-300 text-rose-600 focus:ring-rose-500" />
                                <span>Hanya Kasus Perhatian</span>
                            </label>

                            <input
                                type="text"
                                v-model="searchQuery"
                                placeholder="Cari nama pasien, no. RM..."
                                class="rounded-xl border-sand/60 dark:border-white/15 bg-white dark:bg-[#0C2038] px-3 py-1.5 text-xs placeholder:text-gray-400 focus:border-teal focus:ring-teal w-52 sm:w-60"
                            />
                        </div>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="border-b border-sand/30 dark:border-white/10 text-gray-500 dark:text-gray-400 font-extrabold text-2xs uppercase tracking-wider bg-[#FAF7F0] dark:bg-white/5">
                                    <th class="py-2.5 px-3">Tgl</th>
                                    <th class="py-2.5 px-3">Nama Pasien</th>
                                    <th class="py-2.5 px-3">No. RM</th>
                                    <th class="py-2.5 px-3">Usia/JK</th>
                                    <th class="py-2.5 px-3">Perawat</th>
                                    <th class="py-2.5 px-3">Paket Instrumen & Hasil</th>
                                    <th class="py-2.5 px-3">Status</th>
                                    <th class="py-2.5 px-3 text-center print:hidden">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-sand/20 dark:divide-white/5">
                                <tr v-for="s in filteredSessions" :key="s.id" class="hover:bg-sand/10 dark:hover:bg-white/5" :class="s.has_attention ? 'bg-rose-50/20' : ''">
                                    <td class="py-2.5 px-3 font-mono text-gray-500">{{ formatDate(s.screening_date) }}</td>
                                    <td class="py-2.5 px-3 font-bold text-navy dark:text-white">{{ s.patient?.name }}</td>
                                    <td class="py-2.5 px-3 font-mono text-teal">{{ s.patient?.medical_record_number }}</td>
                                    <td class="py-2.5 px-3 text-gray-600 dark:text-gray-300">{{ s.age_months }} bln ({{ s.patient?.gender }})</td>
                                    <td class="py-2.5 px-3 text-gray-600 dark:text-gray-300">{{ s.nurse_name }}</td>
                                    <td class="py-2.5 px-3">
                                        <div class="flex flex-wrap gap-1">
                                            <span
                                                v-for="inst in s.instruments"
                                                :key="inst.code"
                                                class="rounded px-1.5 py-0.5 text-3xs border"
                                                :class="getRecapInstrumentBadge(inst).classes"
                                            >
                                                <span v-if="getRecapInstrumentBadge(inst).isAlert" class="mr-0.5">⚠️</span>
                                                <span>{{ getRecapInstrumentBadge(inst).displayText }}</span>
                                            </span>
                                        </div>
                                    </td>
                                    <td class="py-2.5 px-3">
                                        <span class="rounded-full px-2 py-0.5 text-2xs font-semibold" :class="statusClasses[s.status]">
                                            {{ statusLabels[s.status] ?? s.status }}
                                        </span>
                                    </td>
                                    <td class="py-2.5 px-3 text-center print:hidden">
                                        <Link :href="`/screening-sessions/${s.id}`" class="rounded-lg bg-teal px-2 py-1 text-2xs font-bold text-white hover:bg-teal-dark">
                                            Lihat &rarr;
                                        </Link>
                                    </td>
                                </tr>
                                <tr v-if="filteredSessions.length === 0">
                                    <td colspan="8" class="py-6 text-center text-xs text-gray-400 italic">
                                        Tidak ada data sesi skrining pada periode ini.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>

            <!-- PRINT SIGNATURE SECTION (Only visible on paper / PDF print) -->
            <div class="hidden print:block pt-8 text-xs text-gray-800 print:break-inside-avoid">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="font-bold">Keterangan:</p>
                        <p class="text-3xs text-gray-600 mt-1 max-w-sm leading-relaxed">
                            Rekapitulasi ini dihasilkan secara otomatis oleh Sistem Pendukung Keputusan Skrining Tumbuh Kembang Anak (SPK-STKA) UPTD BLK-ABK berdasarkan pedoman Kemenkes RI.
                        </p>
                    </div>

                    <div class="text-center min-w-[200px]">
                        <p>Balikpapan, {{ formatDate(new Date()) }}</p>
                        <p class="font-bold mt-1">Kepala UPTD / Penanggung Jawab Medis</p>
                        <div class="h-16"></div>
                        <p class="font-bold underline">(........................................................)</p>
                        <p class="text-3xs text-gray-600">NIP. ...................................................</p>
                    </div>
                </div>
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
        background-color: white !important;
        color: #111827 !important;
        font-size: 9.5pt;
    }

    /* Pastikan SEMUA 3 tab rekapitulasi tercetak lengkap tanpa memandang tab aktif di layar */
    .recap-tab-section {
        display: block !important;
        visibility: visible !important;
    }

    /* Hilangkan efek bayangan / shadow saat dicetak */
    .recap-tab-section,
    .recap-tab-section section {
        box-shadow: none !important;
    }

    table {
        border-collapse: collapse !important;
        width: 100% !important;
    }

    th, td {
        padding: 4px 6px !important;
    }
}
</style>
