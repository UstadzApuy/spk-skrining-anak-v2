<script setup>
import { computed, ref, watch } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    sessions: {
        type: Object,
        required: true,
    },
    selectedPatient: {
        type: Object,
        default: null,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    statusCounts: {
        type: Object,
        default: () => ({
            all: 0,
            reviewed: 0,
            pending_doctor_review: 0,
            in_progress: 0,
            draft: 0,
        }),
    },
});

const page = usePage();
const authUser = page.props.auth?.user;
const isNurse = authUser?.role === 'perawat';
const isDoctor = authUser?.role === 'dokter';

// Filter & Search states
const search = ref(props.filters?.search || '');
const currentStatus = ref(props.filters?.status || '');
const currentInstrument = ref(props.filters?.instrument || '');
const startDate = ref(props.filters?.start_date || '');
const endDate = ref(props.filters?.end_date || '');
const showAdvancedFilters = ref(Boolean(props.filters?.instrument || props.filters?.start_date || props.filters?.end_date));

const sessionToDelete = ref(null);
const isDeleting = ref(false);
const copiedMrn = ref(null);

// Debounced search
let searchTimer = null;
watch(search, (newVal) => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(() => {
        applyFilters();
    }, 400);
});

function applyFilters(overrides = {}) {
    const params = {
        patient_id: props.selectedPatient?.id,
        search: overrides.search !== undefined ? overrides.search : search.value,
        status: overrides.status !== undefined ? overrides.status : currentStatus.value,
        instrument: overrides.instrument !== undefined ? overrides.instrument : currentInstrument.value,
        start_date: overrides.start_date !== undefined ? overrides.start_date : startDate.value,
        end_date: overrides.end_date !== undefined ? overrides.end_date : endDate.value,
    };

    Object.keys(params).forEach((k) => {
        if (params[k] === null || params[k] === undefined || params[k] === '') {
            delete params[k];
        }
    });

    router.get('/spk/screening-sessions', params, {
        preserveState: true,
        preserveScroll: true,
    });
}

function setStatusFilter(status) {
    currentStatus.value = status;
    applyFilters({ status });
}

function setInstrumentFilter(e) {
    currentInstrument.value = e.target.value;
    applyFilters({ instrument: e.target.value });
}

function onDateChange() {
    applyFilters();
}

function setQuickDatePreset(preset) {
    const today = new Date();
    const fmt = (d) => d.toISOString().slice(0, 10);

    if (preset === 'today') {
        startDate.value = fmt(today);
        endDate.value = fmt(today);
    } else if (preset === '7days') {
        const last7 = new Date();
        last7.setDate(today.getDate() - 7);
        startDate.value = fmt(last7);
        endDate.value = fmt(today);
    } else if (preset === 'month') {
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        startDate.value = fmt(firstDay);
        endDate.value = fmt(today);
    }
    applyFilters();
}

function resetAllFilters() {
    search.value = '';
    currentStatus.value = '';
    currentInstrument.value = '';
    startDate.value = '';
    endDate.value = '';
    applyFilters({
        search: '',
        status: '',
        instrument: '',
        start_date: '',
        end_date: '',
    });
}

const hasActiveFilters = computed(() => {
    return Boolean(
        search.value ||
        currentStatus.value ||
        currentInstrument.value ||
        startDate.value ||
        endDate.value
    );
});

function copyMrn(mrn) {
    if (!mrn) return;
    navigator.clipboard.writeText(mrn);
    copiedMrn.value = mrn;
    setTimeout(() => {
        copiedMrn.value = null;
    }, 2000);
}

function confirmDelete(session) {
    sessionToDelete.value = session;
}

function executeDelete() {
    if (!sessionToDelete.value) return;
    isDeleting.value = true;
    router.delete(`/spk/screening-sessions/${sessionToDelete.value.id}`, {
        preserveScroll: true,
        onFinish: () => {
            isDeleting.value = false;
            sessionToDelete.value = null;
        },
    });
}

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

function statusLabel(status) {
    const labels = {
        draft: 'Draf',
        in_progress: 'Sedang Berlangsung',
        pending_parent: 'Menunggu Orang Tua',
        pending_doctor_review: 'Menunggu Dokter',
        reviewed: 'Selesai Ditinjau',
        cancelled: 'Dibatalkan',
    };
    return labels[status] ?? status;
}

function statusClass(status) {
    const classes = {
        draft: 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10 font-semibold',
        in_progress: 'bg-blue-100 dark:bg-blue-950/70 text-blue-800 dark:text-blue-300 border-blue-300 dark:border-blue-800 font-semibold',
        pending_parent: 'bg-purple-100 dark:bg-purple-950/70 text-purple-800 dark:text-purple-300 border-purple-200 dark:border-purple-800 font-semibold',
        pending_doctor_review: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-300 border-amber-300 dark:border-amber-800 font-semibold',
        reviewed: 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold',
        cancelled: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-300 border-rose-300 dark:border-rose-800 font-semibold',
    };
    return classes[status] ?? 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10';
}

function instrumentStatusLabel(status) {
    const labels = {
        pending: 'Belum Selesai',
        in_progress: 'Sedang Diisi',
        completed: 'Selesai',
        cancelled: 'Batal',
    };
    return labels[status] ?? status;
}

// Format badge untuk setiap instrumen: abu-abu jika belum selesai, warna kategori jika sudah selesai
function getInstrumentBadge(session, inst) {
    const code = inst.instrument_code;
    const status = inst.status;

    // Jika belum selesai -> Abu-abu
    if (status !== 'completed') {
        return {
            code,
            statusLabel: status === 'in_progress' ? 'Sedang Diisi' : 'Belum Diisi',
            displayText: `${code} (Belum)`,
            classes: 'bg-gray-100 dark:bg-white/10 text-gray-500 dark:text-gray-400 border-gray-300 dark:border-white/15',
            isAlert: false,
        };
    }

    // Instrumen sudah selesai -> ikuti kategori hasil
    if (code === 'KPSP') {
        const cat = session.kpsp_screening?.category;
        if (['penyimpangan', 'kemungkinan_penyimpangan'].includes(cat)) {
            return {
                code,
                statusLabel: 'Penyimpangan',
                displayText: 'KPSP: Penyimpangan',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        if (cat === 'meragukan') {
            return {
                code,
                statusLabel: 'Meragukan',
                displayText: 'KPSP: Meragukan',
                classes: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border-amber-300 dark:border-amber-800 font-bold',
                isAlert: true,
            };
        }
        return {
            code,
            statusLabel: 'Sesuai',
            displayText: 'KPSP: Sesuai',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'MCHAT' || code === 'M-CHAT') {
        const cat = session.mchat_screening?.category;
        if (cat === 'risiko_sedang_tinggi') {
            return {
                code,
                statusLabel: 'Risiko Tinggi',
                displayText: 'M-CHAT: Risiko Tinggi',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        return {
            code,
            statusLabel: 'Risiko Rendah',
            displayText: 'M-CHAT: Risiko Rendah',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'GPPH') {
        const cat = session.gpph_screening?.category;
        const doubtful = session.gpph_screening?.examiner_doubtful;
        if (cat === 'kemungkinan_gpph') {
            return {
                code,
                statusLabel: 'Kemungkinan GPPH',
                displayText: 'GPPH: Kemungkinan GPPH',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        if (doubtful) {
            return {
                code,
                statusLabel: 'Pemeriksa Ragu',
                displayText: 'GPPH: Pemeriksa Ragu',
                classes: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border-amber-300 dark:border-amber-800 font-bold',
                isAlert: true,
            };
        }
        return {
            code,
            statusLabel: 'Normal',
            displayText: 'GPPH: Normal',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'SDQ') {
        const cat = session.sdq_screening?.total_difficulties_category;
        if (cat === 'abnormal') {
            return {
                code,
                statusLabel: 'Abnormal',
                displayText: 'SDQ: Abnormal',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        if (cat === 'ambang_borderline') {
            return {
                code,
                statusLabel: 'Ambang',
                displayText: 'SDQ: Ambang',
                classes: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border-amber-300 dark:border-amber-800 font-bold',
                isAlert: true,
            };
        }
        return {
            code,
            statusLabel: 'Normal',
            displayText: 'SDQ: Normal',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    if (code === 'SRQ') {
        const cat = session.srq_screening?.category;
        const answers = session.srq_screening?.answers;
        const item17 = Array.isArray(answers) && (answers[16] === true || answers[16] === 1 || answers[16] === '1');
        if (item17) {
            return {
                code,
                statusLabel: 'Butir 17',
                displayText: 'SRQ: Butir 17 (Waspada)',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        if (cat === 'gangguan_mental_emosional_distres') {
            return {
                code,
                statusLabel: 'Distres',
                displayText: 'SRQ: Distres Pengasuh',
                classes: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-800 font-bold',
                isAlert: true,
            };
        }
        return {
            code,
            statusLabel: 'Normal',
            displayText: 'SRQ: Normal',
            classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold',
            isAlert: false,
        };
    }

    return {
        code,
        statusLabel: 'Selesai',
        displayText: `${code}: Selesai`,
        classes: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border-emerald-300 dark:border-emerald-800 font-bold',
        isAlert: false,
    };
}

function sessionHasAlert(session) {
    if (!session.screening_session_instruments) return false;
    return session.screening_session_instruments.some(inst => getInstrumentBadge(session, inst).isAlert);
}
</script>

<template>
    <Head :title="selectedPatient ? `Sesi Skrining - ${selectedPatient.name}` : 'Daftar Sesi Skrining'" />

    <AuthenticatedLayout>
        <template #header>
            <div class="space-y-3">
                <!-- Back Link to Patient Selection Dashboard if filtering per patient -->
                <div v-if="selectedPatient">
                    <Link
                        href="/spk/screening-sessions"
                        class="inline-flex items-center gap-1.5 text-xs font-bold text-teal dark:text-teal-400 hover:text-navy dark:hover:text-white transition"
                    >
                        <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7" />
                        </svg>
                        Lihat Semua Pasien (Hapus Filter Pasien Ini)
                    </Link>
                </div>

                <div class="flex flex-wrap items-center justify-between gap-4">
                    <div>
                        <h2 class="text-xl font-extrabold text-navy dark:text-white flex items-center gap-2">
                            <svg class="h-6 w-6 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            </svg>
                            <span v-if="selectedPatient">Riwayat Skrining: {{ selectedPatient.name }}</span>
                            <span v-else>Daftar Riwayat Sesi Skrining</span>
                        </h2>
                        <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                            Pencatatan pemeriksaan tumbuh kembang anak, peninjauan dokter, dan penelusuran hasil evaluasi.
                        </p>
                    </div>

                    <!-- Actions -->
                    <div class="flex items-center gap-2.5">
                        <Link
                            href="/spk/rekapitulasi"
                            class="inline-flex items-center gap-1.5 rounded-xl border border-sand/60 dark:border-white/10 bg-white dark:bg-white/10 px-3.5 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand-light dark:hover:bg-white/15 transition shadow-2xs"
                        >
                            <svg class="h-4 w-4 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                            Buka Rekapitulasi &rarr;
                        </Link>

                        <Link
                            v-if="isNurse && selectedPatient"
                            :href="`/spk/screening-sessions/create?patient_id=${selectedPatient.id}`"
                            class="inline-flex items-center gap-2 rounded-xl bg-teal px-4 py-2 text-xs font-bold text-white hover:bg-navy transition shadow-xs"
                        >
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                            </svg>
                            + Mulai Sesi Baru
                        </Link>

                        <Link
                            v-else-if="isNurse"
                            href="/spk/dashboard"
                            class="inline-flex items-center gap-2 rounded-xl bg-teal px-4 py-2 text-xs font-bold text-white hover:bg-navy transition shadow-xs"
                        >
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                            </svg>
                            Pilih Pasien untuk Skrining
                        </Link>
                    </div>
                </div>
            </div>
        </template>

        <div class="space-y-5">
            <!-- Flash Alert -->
            <div
                v-if="page.props.flash?.success"
                role="status"
                aria-live="polite"
                class="rounded-xl border border-forest/30 bg-forest/10 px-4 py-3 text-sm font-semibold text-forest shadow-xs"
            >
                {{ page.props.flash.success }}
            </div>

            <!-- SELECTED PATIENT IDENTITY BANNER (When filtering per patient) -->
            <section
                v-if="selectedPatient"
                class="relative overflow-hidden rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-xs border border-sand/40 dark:border-white/10"
            >
                <div class="flex flex-wrap items-center justify-between gap-4">
                    <div class="flex items-center gap-4">
                        <div
                            class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-tr from-navy to-teal text-base font-black text-white shadow-xs"
                        >
                            {{ getInitials(selectedPatient.name) }}
                        </div>

                        <div>
                            <div class="flex items-center gap-2">
                                <h3 class="text-base font-extrabold text-navy dark:text-white">
                                    {{ selectedPatient.name }}
                                </h3>
                                <span
                                    class="rounded-full px-2 py-0.5 text-3xs font-extrabold uppercase border"
                                    :class="selectedPatient.gender === 'L' ? 'bg-blue-50 dark:bg-blue-950/60 text-blue-700 dark:text-blue-300 border-blue-200 dark:border-blue-800' : 'bg-pink-50 dark:bg-pink-950/60 text-pink-700 dark:text-pink-300 border-pink-200 dark:border-pink-800'"
                                >
                                    {{ selectedPatient.gender === 'L' ? 'Laki-laki' : 'Perempuan' }}
                                </span>
                                <span
                                    v-if="selectedPatient.is_premature"
                                    class="rounded-full bg-ochre/15 px-2 py-0.5 text-3xs font-bold text-earth dark:text-amber-300 border border-ochre/30"
                                >
                                    Prematur ({{ selectedPatient.gestational_age_weeks }} mgg)
                                </span>
                            </div>

                            <div class="mt-1 flex flex-wrap items-center gap-3 text-xs text-gray-500 dark:text-gray-400">
                                <span class="flex items-center gap-1">
                                    No. RM:
                                    <strong class="text-navy dark:text-white font-mono">{{ selectedPatient.medical_record_number }}</strong>
                                    <button
                                        type="button"
                                        @click="copyMrn(selectedPatient.medical_record_number)"
                                        class="text-gray-400 hover:text-teal ml-0.5"
                                        title="Salin No. RM"
                                    >
                                        📋
                                    </button>
                                </span>
                                <span>&bull;</span>
                                <span>Tgl Lahir: <strong class="text-navy dark:text-white">{{ formatDate(selectedPatient.birth_date) }}</strong></span>
                                <span>&bull;</span>
                                <span>Wali: <strong class="text-navy dark:text-white">{{ selectedPatient.parent_guardian?.user?.name ?? '-' }}</strong></span>
                            </div>
                        </div>
                    </div>

                    <div class="flex items-center gap-2">
                        <span class="rounded-xl bg-sand/30 dark:bg-white/10 px-3 py-1.5 text-xs font-bold text-navy dark:text-white border border-sand/40 dark:border-white/10">
                            Total: <strong class="text-teal font-extrabold">{{ sessions.total ?? sessions.data.length }}</strong> Sesi
                        </span>
                    </div>
                </div>
            </section>

            <!-- ========================================================== -->
            <!-- QUALITY OF LIFE: SEARCH & QUICK STATUS FILTER BAR           -->
            <!-- ========================================================== -->
            <section class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 sm:p-5 shadow-xs space-y-3.5">
                <!-- Baris 1: Search Input & Toggle Filter Lanjutan -->
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <!-- Search Input -->
                    <div class="relative flex-1 min-w-[260px] max-w-md">
                        <input
                            v-model="search"
                            type="text"
                            placeholder="Cari nama pasien, No. RM, perawat, atau dokter..."
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] pl-9 pr-8 py-2 text-xs text-navy dark:text-white placeholder:text-gray-400 focus:border-teal focus:ring-teal"
                        />
                        <!-- Search Icon -->
                        <svg
                            class="absolute left-3 top-2.5 h-4 w-4 text-gray-400"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                        <!-- Clear Search Button -->
                        <button
                            v-if="search"
                            type="button"
                            @click="search = ''; applyFilters({ search: '' })"
                            class="absolute right-2.5 top-2 text-gray-400 hover:text-gray-600 dark:hover:text-white text-xs font-bold px-1"
                            title="Hapus pencarian"
                        >
                            ✕
                        </button>
                    </div>

                    <!-- Right Controls: Toggle Filter & Reset -->
                    <div class="flex items-center gap-2">
                        <button
                            type="button"
                            @click="showAdvancedFilters = !showAdvancedFilters"
                            class="inline-flex items-center gap-1.5 rounded-xl border px-3 py-2 text-xs font-bold transition cursor-pointer"
                            :class="showAdvancedFilters || (currentInstrument || startDate || endDate)
                                ? 'bg-teal/10 border-teal text-teal dark:bg-teal-950/60 dark:text-teal-300'
                                : 'border-sand/60 dark:border-white/15 bg-white dark:bg-[#071D37] text-gray-700 dark:text-gray-300 hover:bg-sand/30'"
                        >
                            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
                            </svg>
                            <span>Filter Tambahan</span>
                            <span v-if="currentInstrument || startDate || endDate" class="h-2 w-2 rounded-full bg-teal"></span>
                        </button>

                        <button
                            v-if="hasActiveFilters"
                            type="button"
                            @click="resetAllFilters"
                            class="inline-flex items-center gap-1 rounded-xl border border-rose-200 dark:border-rose-900/60 bg-rose-50 dark:bg-rose-950/40 px-3 py-2 text-xs font-bold text-rose-700 dark:text-rose-300 hover:bg-rose-100 transition cursor-pointer"
                            title="Bersihkan semua filter"
                        >
                            <span>✕ Atur Ulang</span>
                        </button>
                    </div>
                </div>

                <!-- Baris 2: Quick Status Pills -->
                <div class="flex flex-wrap items-center gap-1.5 pt-2 border-t border-sand/20 dark:border-white/10">
                    <span class="text-2xs font-extrabold uppercase tracking-wider text-gray-400 dark:text-gray-500 mr-1">Status:</span>

                    <!-- Semua -->
                    <button
                        type="button"
                        @click="setStatusFilter('')"
                        class="rounded-xl px-3 py-1 text-2xs font-bold transition cursor-pointer"
                        :class="!currentStatus
                            ? 'bg-navy text-white dark:bg-white dark:text-navy shadow-xs'
                            : 'bg-[#FAF7F0] dark:bg-white/5 text-gray-700 dark:text-gray-300 hover:bg-sand/30 dark:hover:bg-white/10 border border-sand/30 dark:border-white/5'"
                    >
                        Semua Sesi ({{ statusCounts.all ?? 0 }})
                    </button>

                    <!-- Selesai Ditinjau Dokter -->
                    <button
                        type="button"
                        @click="setStatusFilter('reviewed')"
                        class="rounded-xl px-3 py-1 text-2xs font-bold transition cursor-pointer flex items-center gap-1"
                        :class="currentStatus === 'reviewed'
                            ? 'bg-emerald-600 text-white shadow-xs'
                            : 'bg-emerald-50 dark:bg-emerald-950/30 text-emerald-800 dark:text-emerald-300 hover:bg-emerald-100 border border-emerald-200 dark:border-emerald-900/50'"
                    >
                        <span>✓ Selesai Ditinjau</span>
                        <span class="rounded-full bg-white/20 dark:bg-black/20 px-1.5 py-0.2 text-3xs font-black">{{ statusCounts.reviewed ?? 0 }}</span>
                    </button>

                    <!-- Menunggu Tinjauan Dokter -->
                    <button
                        type="button"
                        @click="setStatusFilter('pending_doctor_review')"
                        class="rounded-xl px-3 py-1 text-2xs font-bold transition cursor-pointer flex items-center gap-1"
                        :class="currentStatus === 'pending_doctor_review'
                            ? 'bg-amber-600 text-white shadow-xs'
                            : 'bg-amber-50 dark:bg-amber-950/30 text-amber-800 dark:text-amber-300 hover:bg-amber-100 border border-amber-200 dark:border-amber-900/50'"
                    >
                        <span>⏳ Menunggu Dokter</span>
                        <span class="rounded-full bg-white/20 dark:bg-black/20 px-1.5 py-0.2 text-3xs font-black">{{ statusCounts.pending_doctor_review ?? 0 }}</span>
                    </button>

                    <!-- Sedang Berlangsung -->
                    <button
                        type="button"
                        @click="setStatusFilter('in_progress')"
                        class="rounded-xl px-3 py-1 text-2xs font-bold transition cursor-pointer flex items-center gap-1"
                        :class="currentStatus === 'in_progress'
                            ? 'bg-blue-600 text-white shadow-xs'
                            : 'bg-blue-50 dark:bg-blue-950/30 text-blue-800 dark:text-blue-300 hover:bg-blue-100 border border-blue-200 dark:border-blue-900/50'"
                    >
                        <span>Sedang Berlangsung</span>
                        <span class="rounded-full bg-white/20 dark:bg-black/20 px-1.5 py-0.2 text-3xs font-black">{{ statusCounts.in_progress ?? 0 }}</span>
                    </button>

                    <!-- Draf -->
                    <button
                        type="button"
                        @click="setStatusFilter('draft')"
                        class="rounded-xl px-3 py-1 text-2xs font-bold transition cursor-pointer flex items-center gap-1"
                        :class="currentStatus === 'draft'
                            ? 'bg-gray-700 text-white shadow-xs'
                            : 'bg-gray-100 dark:bg-white/5 text-gray-700 dark:text-gray-400 hover:bg-gray-200 border border-gray-200 dark:border-white/10'"
                    >
                        <span>Draf</span>
                        <span class="rounded-full bg-white/20 dark:bg-black/20 px-1.5 py-0.2 text-3xs font-black">{{ statusCounts.draft ?? 0 }}</span>
                    </button>
                </div>

                <!-- Baris 3: Collapsible Advanced Filters (Instrumen & Rentang Tanggal) -->
                <div
                    v-if="showAdvancedFilters"
                    class="pt-3 border-t border-sand/20 dark:border-white/10 grid grid-cols-1 sm:grid-cols-3 gap-3"
                >
                    <!-- Filter Instrumen -->
                    <div>
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">
                            Filter Instrumen
                        </label>
                        <select
                            :value="currentInstrument"
                            @change="setInstrumentFilter"
                            class="w-full rounded-xl border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal"
                        >
                            <option value="">Semua Instrumen</option>
                            <option value="KPSP">KPSP (Perkembangan)</option>
                            <option value="MCHAT">M-CHAT-R (Autisme)</option>
                            <option value="GPPH">GPPH (Perilaku/Hiperaktif)</option>
                            <option value="SDQ">SDQ (Kekuatan & Kesulitan)</option>
                            <option value="SRQ">SRQ-20 (Kesehatan Emosional)</option>
                        </select>
                    </div>

                    <!-- Rentang Tanggal Dari & Sampai -->
                    <div class="sm:col-span-2 space-y-1">
                        <label class="block text-2xs font-extrabold uppercase tracking-wider text-gray-500 dark:text-gray-400">
                            Rentang Tanggal Pemeriksaan
                        </label>
                        <div class="flex flex-wrap items-center gap-2">
                            <input
                                v-model="startDate"
                                @change="onDateChange"
                                type="date"
                                class="rounded-xl border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal px-3 py-1.5"
                                placeholder="Dari tanggal"
                            />
                            <span class="text-xs text-gray-400">s/d</span>
                            <input
                                v-model="endDate"
                                @change="onDateChange"
                                type="date"
                                class="rounded-xl border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] text-xs font-semibold text-navy dark:text-white focus:border-teal focus:ring-teal px-3 py-1.5"
                                placeholder="Sampai tanggal"
                            />

                            <!-- Preset Buttons -->
                            <div class="flex items-center gap-1 ml-auto">
                                <button
                                    type="button"
                                    @click="setQuickDatePreset('today')"
                                    class="rounded-lg bg-sand/30 dark:bg-white/10 px-2 py-1 text-3xs font-bold text-navy dark:text-white hover:bg-sand transition"
                                >
                                    Hari Ini
                                </button>
                                <button
                                    type="button"
                                    @click="setQuickDatePreset('7days')"
                                    class="rounded-lg bg-sand/30 dark:bg-white/10 px-2 py-1 text-3xs font-bold text-navy dark:text-white hover:bg-sand transition"
                                >
                                    7 Hari
                                </button>
                                <button
                                    type="button"
                                    @click="setQuickDatePreset('month')"
                                    class="rounded-lg bg-sand/30 dark:bg-white/10 px-2 py-1 text-3xs font-bold text-navy dark:text-white hover:bg-sand transition"
                                >
                                    Bulan Ini
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================================== -->
            <!-- SESSIONS TABLE CARD                                        -->
            <!-- ========================================================== -->
            <div class="overflow-hidden rounded-2xl bg-white dark:bg-[#0C2038] shadow-xs border border-sand/40 dark:border-white/10">
                <div class="border-b border-sand/30 dark:border-white/10 bg-[#FAF7F0] dark:bg-[#071D37] px-6 py-4 flex flex-wrap items-center justify-between gap-3">
                    <h3 class="text-sm font-bold text-navy dark:text-white flex items-center gap-2">
                        <span>📋</span>
                        <span v-if="selectedPatient">Riwayat Sesi Skrining {{ selectedPatient.name }}</span>
                        <span v-else>Daftar Riwayat Sesi Skrining</span>
                    </h3>

                    <div class="text-xs font-semibold text-gray-500 dark:text-gray-400">
                        Menampilkan <strong class="text-navy dark:text-white">{{ sessions.data.length }}</strong> dari <strong class="text-navy dark:text-white">{{ sessions.total ?? sessions.data.length }}</strong> total sesi
                    </div>
                </div>

                <div v-if="sessions.data.length" class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-white/10 text-left text-xs">
                        <thead class="bg-[#F5F1E6] dark:bg-[#071D37]">
                            <tr class="border-b border-gray-200 dark:border-white/10">
                                <th class="px-5 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Tanggal
                                </th>
                                <th class="px-5 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Pasien Anak
                                </th>
                                <th class="px-5 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Paket Instrumen & Hasil
                                </th>
                                <th class="px-5 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Tenaga Medis
                                </th>
                                <th class="px-5 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Status Sesi
                                </th>
                                <th class="px-5 py-3 text-right text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Aksi
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                            <tr
                                v-for="session in sessions.data"
                                :key="session.id"
                                class="hover:bg-[#FAF6EE] dark:hover:bg-white/5 transition"
                                :class="sessionHasAlert(session) ? 'bg-rose-50/20 dark:bg-rose-950/10' : ''"
                            >
                                <!-- Tanggal Skrining -->
                                <td class="whitespace-nowrap px-5 py-3.5 font-bold font-mono text-navy dark:text-white">
                                    {{ formatDate(session.screening_date) }}
                                </td>

                                <!-- Pasien Anak -->
                                <td class="px-5 py-3.5">
                                    <div class="font-bold text-navy dark:text-white text-xs">
                                        {{ session.patient?.name ?? 'Anak Tanpa Nama' }}
                                    </div>
                                    <div class="mt-0.5 flex flex-wrap items-center gap-1.5 text-2xs text-gray-500 dark:text-gray-400">
                                        <span class="font-mono text-teal dark:text-teal-300 font-bold">
                                            {{ session.patient?.medical_record_number }}
                                        </span>
                                        <button
                                            type="button"
                                            @click="copyMrn(session.patient?.medical_record_number)"
                                            class="text-gray-400 hover:text-teal transition"
                                            title="Salin No. RM"
                                        >
                                            <span v-if="copiedMrn === session.patient?.medical_record_number" class="text-emerald-600 font-bold">Tersalin!</span>
                                            <span v-else>📋</span>
                                        </button>
                                        <span>&bull;</span>
                                        <span class="font-bold text-teal dark:text-teal-300">{{ session.age_months }} Bulan</span>
                                        <span>({{ session.patient?.gender === 'L' ? 'L' : 'P' }})</span>
                                        <span
                                            v-if="session.patient?.is_premature"
                                            class="rounded bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-amber-300 px-1 py-0.2 text-3xs font-bold"
                                        >
                                            Prematur
                                        </span>
                                    </div>
                                </td>

                                <!-- Paket Instrumen Dilakukan & Hasil Kategori -->
                                <td class="px-5 py-3.5">
                                    <div
                                        v-if="session.screening_session_instruments?.length"
                                        class="flex flex-wrap gap-1.5"
                                    >
                                        <span
                                            v-for="inst in session.screening_session_instruments"
                                            :key="inst.id"
                                            class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-3xs border transition shadow-2xs"
                                            :class="getInstrumentBadge(session, inst).classes"
                                            :title="inst.status === 'completed' ? `Hasil: ${getInstrumentBadge(session, inst).statusLabel}` : 'Instrumen belum selesai diisi'"
                                        >
                                            <span v-if="getInstrumentBadge(session, inst).isAlert" class="text-3xs">⚠️</span>
                                            <span>{{ getInstrumentBadge(session, inst).displayText }}</span>
                                        </span>
                                    </div>
                                    <span v-else class="text-2xs text-gray-400 italic">
                                        Belum ada instrumen
                                    </span>
                                </td>

                                <!-- Tenaga Medis (Perawat & Dokter) -->
                                <td class="whitespace-nowrap px-5 py-3.5 text-2xs text-gray-600 dark:text-gray-300">
                                    <div>
                                        <span class="text-gray-400">Perawat:</span>
                                        <strong class="text-navy dark:text-white ml-1">{{ session.nurse?.user?.name ?? '-' }}</strong>
                                    </div>
                                    <div class="mt-0.5">
                                        <span class="text-gray-400">Dokter:</span>
                                        <strong class="ml-1" :class="session.doctor ? 'text-navy dark:text-white' : 'text-amber-600 italic'">
                                            {{ session.doctor?.user?.name ?? 'Belum ditinjau' }}
                                        </strong>
                                    </div>
                                </td>

                                <!-- Status Sesi -->
                                <td class="whitespace-nowrap px-5 py-3.5">
                                    <span
                                        class="rounded-full px-2.5 py-0.5 text-2xs font-semibold border"
                                        :class="statusClass(session.status)"
                                    >
                                        {{ statusLabel(session.status) }}
                                    </span>
                                </td>

                                <!-- Aksi -->
                                <td class="whitespace-nowrap px-5 py-3.5 text-right">
                                    <div class="flex items-center justify-end gap-1.5">
                                        <Link
                                            :href="`/spk/screening-sessions/${session.id}`"
                                            class="inline-flex items-center gap-1 rounded-lg bg-teal hover:bg-navy px-3 py-1.5 text-xs font-bold text-white transition shadow-2xs"
                                        >
                                            Buka Hasil &rarr;
                                        </Link>

                                        <button
                                            v-if="isDoctor"
                                            type="button"
                                            @click="confirmDelete(session)"
                                            class="inline-flex items-center gap-1 rounded-lg border border-red-200 dark:border-red-900/60 bg-red-50 dark:bg-red-950/40 px-2 py-1.5 text-xs font-semibold text-red-700 dark:text-red-300 hover:bg-red-100 transition shadow-2xs"
                                            title="Hapus Sesi Skrining"
                                        >
                                            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                            </svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Empty State -->
                <div v-else class="px-6 py-12 text-center">
                    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-sand/20 text-teal mb-3">
                        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                        </svg>
                    </div>

                    <h4 class="text-sm font-bold text-navy dark:text-white">
                        <span v-if="hasActiveFilters">Tidak ditemukan sesi skrining yang cocok</span>
                        <span v-else-if="selectedPatient">Belum ada sesi skrining untuk {{ selectedPatient.name }}</span>
                        <span v-else>Belum ada data sesi skrining</span>
                    </h4>

                    <p class="mt-1 text-xs text-gray-500 dark:text-gray-400 max-w-md mx-auto">
                        <span v-if="hasActiveFilters">
                            Coba ubah kata kunci pencarian atau bersihkan filter yang sedang aktif.
                        </span>
                        <span v-else-if="selectedPatient">
                            Pasien ini belum pernah melakukan pemeriksaan skrining. Klik tombol di bawah untuk memulai sesi skrining.
                        </span>
                        <span v-else>
                            Mulai sesi skrining baru melalui direktori pasien.
                        </span>
                    </p>

                    <div v-if="hasActiveFilters" class="mt-4">
                        <button
                            type="button"
                            @click="resetAllFilters"
                            class="inline-flex items-center gap-1.5 rounded-xl border border-sand/60 dark:border-white/10 bg-white dark:bg-white/10 px-4 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand-light transition"
                        >
                            Reset Semua Filter
                        </button>
                    </div>

                    <div v-else-if="isNurse && selectedPatient" class="mt-5">
                        <Link
                            :href="`/spk/screening-sessions/create?patient_id=${selectedPatient.id}`"
                            class="inline-flex items-center gap-2 rounded-xl bg-teal px-5 py-2.5 text-xs font-bold text-white hover:bg-navy transition shadow-sm"
                        >
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                            </svg>
                            Mulai Sesi Skrining Sekarang
                        </Link>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
            <div
                v-if="sessions.links?.length > 3"
                class="flex flex-wrap items-center justify-between gap-3 pt-2"
            >
                <div class="text-xs text-gray-500 dark:text-gray-400">
                    Menampilkan data ke-{{ sessions.from ?? 0 }} sampai {{ sessions.to ?? 0 }} dari {{ sessions.total ?? 0 }} data
                </div>

                <div class="flex flex-wrap justify-center gap-1">
                    <template
                        v-for="(link, index) in sessions.links"
                        :key="index"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            class="rounded-lg border px-3 py-1.5 text-xs font-medium transition cursor-pointer"
                            :class="
                                link.active
                                    ? 'border-teal bg-teal text-white font-bold'
                                    : 'border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] text-navy dark:text-white hover:bg-sand-light dark:hover:bg-white/10'
                            "
                        >
                            <span v-html="link.label" />
                        </Link>

                        <span
                            v-else
                            class="rounded-lg border border-sand/20 dark:border-white/5 px-3 py-1.5 text-xs text-gray-400"
                        >
                            <span v-html="link.label" />
                        </span>
                    </template>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal (Doctors only) -->
        <div
            v-if="sessionToDelete"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-xs"
        >
            <div class="w-full max-w-md rounded-2xl bg-white dark:bg-[#0C2038] p-6 shadow-xl border border-sand/40 dark:border-white/10 space-y-4">
                <div class="flex items-center gap-3 text-red-600">
                    <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-red-100 dark:bg-red-950/60 text-red-600">
                        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-gray-900 dark:text-white">Hapus Sesi Skrining?</h3>
                        <p class="text-xs text-gray-500 dark:text-gray-400">Tindakan ini tidak dapat dibatalkan.</p>
                    </div>
                </div>

                <p class="text-xs text-gray-600 dark:text-gray-300 leading-relaxed">
                    Apakah Anda yakin ingin menghapus sesi skrining untuk pasien
                    <strong class="text-navy dark:text-white">{{ sessionToDelete.patient?.name }}</strong>
                    tanggal {{ formatDate(sessionToDelete.screening_date) }}? Semua jawaban instrumen yang terkait akan dihapus secara permanen.
                </p>

                <div class="flex items-center justify-end gap-2 pt-2">
                    <button
                        type="button"
                        @click="sessionToDelete = null"
                        class="rounded-xl border border-sand/60 dark:border-white/10 bg-white dark:bg-white/10 px-4 py-2 text-xs font-bold text-gray-700 dark:text-gray-300 hover:bg-sand/30 transition"
                        :disabled="isDeleting"
                    >
                        Batal
                    </button>
                    <button
                        type="button"
                        @click="executeDelete"
                        class="rounded-xl bg-red-600 px-4 py-2 text-xs font-bold text-white hover:bg-red-700 transition shadow-xs"
                        :disabled="isDeleting"
                    >
                        <span v-if="isDeleting">Menghapus...</span>
                        <span v-else>Ya, Hapus Sesi</span>
                    </button>
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
</style>
