<script setup>
import { ref, computed } from 'vue';
import { Head, Link, useForm, usePage, router } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    patients: {
        type: Array,
        required: true,
    },
    parentGuardians: {
        type: Array,
        default: () => [],
    },
    canDeletePatient: {
        type: Boolean,
        default: false,
    },
});

const page = usePage();
const user = page.props.auth.user;
const isDoctor = computed(() => user?.role === 'dokter');
const isNurse = computed(() => user?.role === 'perawat');
const isAdmin = computed(() => user?.role === 'administrator');
const isStaff = computed(() => isNurse.value || isDoctor.value || isAdmin.value);

const activeTab = ref('patients'); // 'patients' | 'guardians'
const searchQuery = ref('');

// State Modal Hapus Pasien (Khusus Dokter)
const patientToDelete = ref(null);
const isDeleting = ref(false);

function confirmDeletePatient(patient) {
    patientToDelete.value = patient;
}

function executeDeletePatient() {
    if (!patientToDelete.value) return;
    isDeleting.value = true;
    router.delete(`/patients/${patientToDelete.value.id}`, {
        preserveScroll: true,
        onFinish: () => {
            isDeleting.value = false;
            patientToDelete.value = null;
        },
    });
}

// State Modal Tambah Wali / Guardian Baru
const showGuardianModal = ref(false);
const guardianForm = useForm({
    name: '',
    email: '',
    phone: '',
    address: '',
    password: '',
});

function submitGuardian() {
    guardianForm.post('/parent-guardians', {
        preserveScroll: true,
        onSuccess: () => {
            guardianForm.reset();
            showGuardianModal.value = false;
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

const educationLabels = {
    tidak_sekolah: 'Belum / Tidak Sekolah',
    reguler: 'Sekolah Reguler',
    inklusi: 'Sekolah Inklusi',
    slb: 'SLB',
    panti: 'Panti Asuhan',
};

const filteredPatients = computed(() => {
    if (!searchQuery.value.trim()) {
        return props.patients;
    }
    const q = searchQuery.value.toLowerCase().trim();
    return props.patients.filter((p) =>
        p.name?.toLowerCase().includes(q) ||
        p.medical_record_number?.toLowerCase().includes(q) ||
        p.parent_guardian?.user?.name?.toLowerCase().includes(q) ||
        p.school_name?.toLowerCase().includes(q) ||
        p.address?.toLowerCase().includes(q)
    );
});

const filteredGuardians = computed(() => {
    if (!searchQuery.value.trim()) {
        return props.parentGuardians;
    }
    const q = searchQuery.value.toLowerCase().trim();
    return props.parentGuardians.filter((g) =>
        g.name?.toLowerCase().includes(q) ||
        g.email?.toLowerCase().includes(q) ||
        g.phone?.toLowerCase().includes(q) ||
        g.children_names?.toLowerCase().includes(q) ||
        g.address?.toLowerCase().includes(q)
    );
});
</script>

<template>
    <Head title="Manajemen Data Pasien & Wali" />

    <AuthenticatedLayout>
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4">
                <div>
                    <div class="flex items-center gap-2 text-2xs font-bold text-gray-500 dark:text-gray-400 mb-1">
                        <Link href="/dashboard" class="hover:text-teal transition">Dashboard</Link>
                        <span>/</span>
                        <span class="text-teal font-extrabold">Data Pasien &amp; Wali</span>
                    </div>
                    <h2 class="text-xl font-extrabold text-navy dark:text-white flex items-center gap-2.5">
                        <div class="flex h-8 w-8 items-center justify-center rounded-xl bg-teal/10 text-teal border border-teal/20 dark:bg-teal/20 dark:text-teal-light">
                            <svg class="h-4.5 w-4.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                            </svg>
                        </div>
                        <span>Manajemen Data Pasien &amp; Wali</span>
                    </h2>
                </div>

                <!-- Action Buttons -->
                <div class="flex flex-wrap items-center gap-2.5">
                    <button
                        type="button"
                        @click="showGuardianModal = true"
                        class="inline-flex items-center gap-2 rounded-xl border border-sand/60 dark:border-white/15 bg-white dark:bg-white/10 hover:bg-sand-light dark:hover:bg-white/15 text-navy dark:text-white font-extrabold px-3.5 py-2 text-xs shadow-2xs transition active:scale-95"
                    >
                        <svg class="h-4 w-4 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                        </svg>
                        + Tambah Wali Baru
                    </button>

                    <Link
                        v-if="isStaff"
                        href="/patients/create"
                        class="inline-flex items-center gap-2 rounded-xl bg-teal hover:bg-navy text-white font-extrabold px-4 py-2 text-xs shadow-xs transition active:scale-95"
                    >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4" />
                        </svg>
                        + Tambah Pasien Baru
                    </Link>
                </div>
            </div>
        </template>

        <div class="space-y-6">
            <!-- Flash Message -->
            <div
                v-if="page.props.flash?.success"
                role="status"
                aria-live="polite"
                class="rounded-xl border border-forest/30 bg-forest/10 px-4 py-3 text-xs font-semibold text-forest shadow-xs flex items-center justify-between"
            >
                <div class="flex items-center gap-2">
                    <span class="text-sm">✓</span>
                    <span>{{ page.props.flash.success }}</span>
                </div>
            </div>

            <!-- Tab Navigation & Search Bar -->
            <div class="rounded-2xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-4 sm:p-5 shadow-xs space-y-4">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <!-- Tab Pills -->
                    <div class="flex items-center gap-2">
                        <button
                            type="button"
                            @click="activeTab = 'patients'"
                            class="inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-extrabold transition shadow-2xs cursor-pointer"
                            :class="activeTab === 'patients'
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre'
                                : 'bg-[#FAF7F0] dark:bg-[#071D37] text-gray-600 dark:text-sand/80 hover:bg-sand/30 hover:text-navy dark:hover:text-white border border-sand/40 dark:border-white/10'"
                        >
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                            </svg>
                            <span>Daftar Pasien Anak</span>
                            <span class="rounded-full bg-white/20 px-2 py-0.5 text-2xs font-black">
                                {{ filteredPatients.length }}
                            </span>
                        </button>

                        <button
                            type="button"
                            @click="activeTab = 'guardians'"
                            class="inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-extrabold transition shadow-2xs cursor-pointer"
                            :class="activeTab === 'guardians'
                                ? 'bg-gradient-to-r from-teal to-teal-dark text-white border-l-4 border-ochre'
                                : 'bg-[#FAF7F0] dark:bg-[#071D37] text-gray-600 dark:text-sand/80 hover:bg-sand/30 hover:text-navy dark:hover:text-white border border-sand/40 dark:border-white/10'"
                        >
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                            <span>Daftar Orang Tua / Wali</span>
                            <span class="rounded-full bg-white/20 px-2 py-0.5 text-2xs font-black">
                                {{ filteredGuardians.length }}
                            </span>
                        </button>
                    </div>

                    <!-- Search Input -->
                    <div class="relative w-full sm:max-w-xs">
                        <input
                            v-model="searchQuery"
                            type="text"
                            :placeholder="activeTab === 'patients' ? 'Cari nama, No. RM, sekolah...' : 'Cari nama wali, email, telp...'"
                            class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] pl-9 pr-8 py-2 text-xs text-navy dark:text-white placeholder:text-gray-400 focus:border-teal focus:ring-teal"
                        />
                        <svg class="absolute left-3 top-2.5 h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                        <button
                            v-if="searchQuery"
                            type="button"
                            @click="searchQuery = ''"
                            class="absolute right-2.5 top-2 text-gray-400 hover:text-gray-600 dark:hover:text-white text-xs font-bold"
                        >
                            ✕
                        </button>
                    </div>
                </div>
            </div>

            <!-- ================================================================= -->
            <!-- TAB 1: DAFTAR PASIEN ANAK                                         -->
            <!-- ================================================================= -->
            <div v-if="activeTab === 'patients'" class="overflow-hidden rounded-2xl bg-white dark:bg-[#0C2038] shadow-xs border border-sand/40 dark:border-white/10">
                <div class="p-4 border-b border-sand/30 dark:border-white/10 bg-[#FAF7F0] dark:bg-[#071D37] flex items-center justify-between text-xs">
                    <span class="font-bold text-navy dark:text-white">
                        Menampilkan {{ filteredPatients.length }} dari total {{ patients.length }} pasien terdaftar
                    </span>
                    <span v-if="canDeletePatient" class="text-2xs text-rose-600 dark:text-rose-400 font-bold">
                        * Anda login sebagai Dokter: Memiliki wewenang menghapus data pasien.
                    </span>
                </div>

                <div v-if="filteredPatients.length" class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-white/10 text-left text-xs">
                        <thead class="bg-[#F5F1E6] dark:bg-[#071D37]">
                            <tr class="border-b border-gray-200 dark:border-white/10">
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    No. RM
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Nama Anak
                                </th>
                                <th class="px-3 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand text-center">
                                    L/P
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Tgl Lahir
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Pendidikan &amp; Sekolah
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Alamat
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Orang Tua / Wali
                                </th>
                                <th class="px-3 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand text-center">
                                    Sesi
                                </th>
                                <th class="px-4 py-3 text-right text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Aksi
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                            <tr
                                v-for="patient in filteredPatients"
                                :key="patient.id"
                                class="hover:bg-[#FAF6EE] dark:hover:bg-white/5 transition"
                            >
                                <td class="whitespace-nowrap px-4 py-3 font-mono font-bold text-teal dark:text-teal-300">
                                    {{ patient.medical_record_number }}
                                </td>

                                <td class="px-4 py-3">
                                    <div class="font-bold text-navy dark:text-white">
                                        {{ patient.name }}
                                    </div>
                                    <span v-if="patient.is_premature" class="inline-flex items-center rounded-md bg-amber-50 dark:bg-amber-950/40 px-1.5 py-0.2 text-3xs font-bold text-amber-800 dark:text-amber-300 border border-amber-200 dark:border-amber-800/40 mt-0.5">
                                        Prematur ({{ patient.gestational_age_weeks }} mgg)
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-3 py-3 text-center">
                                    <span
                                        class="inline-block rounded-md px-1.5 py-0.5 text-3xs font-black uppercase text-white shadow-2xs"
                                        :class="patient.gender === 'L' ? 'bg-blue-600' : 'bg-pink-500'"
                                    >
                                        {{ patient.gender }}
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-4 py-3 text-gray-600 dark:text-gray-300 font-mono text-2xs">
                                    {{ formatDate(patient.birth_date) }}
                                </td>

                                <td class="px-4 py-3">
                                    <span class="inline-block text-2xs font-bold text-navy dark:text-sand-light">
                                        {{ educationLabels[patient.education] || 'Belum Sekolah' }}
                                    </span>
                                    <p v-if="patient.school_name" class="text-3xs text-gray-500 dark:text-gray-400 font-semibold truncate max-w-[160px]" :title="patient.school_name">
                                        🏫 {{ patient.school_name }}
                                    </p>
                                </td>

                                <td class="px-4 py-3 text-2xs text-gray-600 dark:text-gray-300 max-w-[160px] truncate" :title="patient.address">
                                    {{ patient.address || '-' }}
                                </td>

                                <td class="px-4 py-3">
                                    <div class="font-bold text-navy dark:text-white text-2xs">
                                        {{ patient.parent_guardian?.user?.name ?? '-' }}
                                    </div>
                                    <span v-if="patient.guardian_relationship" class="text-3xs text-gray-400">
                                        ({{ patient.guardian_relationship }})
                                    </span>
                                </td>

                                <td class="whitespace-nowrap px-3 py-3 text-center">
                                    <Link
                                        :href="`/screening-sessions?patient_id=${patient.id}`"
                                        class="inline-flex items-center gap-1 text-2xs font-extrabold text-teal hover:underline"
                                        title="Buka daftar riwayat sesi anak ini"
                                    >
                                        {{ patient.screening_sessions_count ?? 0 }} sesi
                                    </Link>
                                </td>

                                <td class="whitespace-nowrap px-4 py-3 text-right">
                                    <div class="flex items-center justify-end gap-1.5">
                                        <Link
                                            :href="`/screening-sessions/create?patient_id=${patient.id}`"
                                            class="inline-flex items-center rounded-lg bg-teal-50 dark:bg-teal-950/40 px-2.5 py-1 text-2xs font-bold text-teal dark:text-teal-300 hover:bg-teal-100 border border-teal-200 dark:border-teal-900/50 transition"
                                            title="Mulai sesi skrining untuk pasien ini"
                                        >
                                            + Skrining
                                        </Link>

                                        <Link
                                            :href="`/patients/${patient.id}/edit`"
                                            class="inline-flex items-center rounded-lg border border-sand/60 dark:border-white/15 bg-white dark:bg-white/10 px-2.5 py-1 text-2xs font-bold text-navy dark:text-white hover:bg-sand-light transition"
                                            title="Ubah identitas, alamat, pendidikan"
                                        >
                                            Ubah
                                        </Link>

                                        <!-- HANYA DOKTER YANG BISA HAPUS PASIEN -->
                                        <button
                                            v-if="canDeletePatient"
                                            type="button"
                                            @click="confirmDeletePatient(patient)"
                                            class="inline-flex items-center rounded-lg border border-rose-200 dark:border-rose-900/60 bg-rose-50 dark:bg-rose-950/40 px-2 py-1 text-2xs font-bold text-rose-700 dark:text-rose-300 hover:bg-rose-100 transition"
                                            title="Hapus data pasien sepenuhnya"
                                        >
                                            Hapus
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div v-else class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                    <p class="font-bold text-sm">Tidak ada data pasien yang cocok dengan pencarian.</p>
                    <p class="text-xs mt-1">Gunakan tombol "+ Tambah Pasien Baru" di atas untuk mendaftarkan anak baru.</p>
                </div>
            </div>

            <!-- ================================================================= -->
            <!-- TAB 2: DAFTAR ORANG TUA / WALI (GUARDIAN)                         -->
            <!-- ================================================================= -->
            <div v-if="activeTab === 'guardians'" class="overflow-hidden rounded-2xl bg-white dark:bg-[#0C2038] shadow-xs border border-sand/40 dark:border-white/10">
                <div class="p-4 border-b border-sand/30 dark:border-white/10 bg-[#FAF7F0] dark:bg-[#071D37] flex items-center justify-between text-xs">
                    <span class="font-bold text-navy dark:text-white">
                        Menampilkan {{ filteredGuardians.length }} dari total {{ parentGuardians.length }} orang tua/wali terdaftar
                    </span>
                    <button
                        type="button"
                        @click="showGuardianModal = true"
                        class="text-xs font-bold text-teal hover:underline cursor-pointer"
                    >
                        + Daftarkan Akun Orang Tua Baru
                    </button>
                </div>

                <div v-if="filteredGuardians.length" class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-white/10 text-left text-xs">
                        <thead class="bg-[#F5F1E6] dark:bg-[#071D37]">
                            <tr class="border-b border-gray-200 dark:border-white/10">
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Nama Orang Tua / Wali
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Email Akun
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    No. Telepon / WhatsApp
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Alamat Rumah
                                </th>
                                <th class="px-4 py-3 text-2xs font-extrabold uppercase tracking-wide text-navy dark:text-sand">
                                    Anak Terdaftar
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                            <tr
                                v-for="g in filteredGuardians"
                                :key="g.id"
                                class="hover:bg-[#FAF6EE] dark:hover:bg-white/5 transition"
                            >
                                <td class="px-4 py-3 font-bold text-navy dark:text-white">
                                    {{ g.name }}
                                </td>
                                <td class="px-4 py-3 font-mono text-2xs text-gray-600 dark:text-gray-300">
                                    {{ g.email }}
                                </td>
                                <td class="px-4 py-3 font-mono text-2xs text-gray-600 dark:text-gray-300">
                                    {{ g.phone }}
                                </td>
                                <td class="px-4 py-3 text-2xs text-gray-600 dark:text-gray-300 max-w-[200px] truncate" :title="g.address">
                                    {{ g.address }}
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-1.5">
                                        <span class="rounded-full bg-teal/15 text-teal px-2 py-0.5 text-3xs font-extrabold">
                                            {{ g.children_count }} anak
                                        </span>
                                        <span v-if="g.children_names" class="text-3xs text-gray-500 dark:text-gray-400 truncate max-w-[180px]" :title="g.children_names">
                                            ({{ g.children_names }})
                                        </span>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div v-else class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                    <p class="font-bold text-sm">Tidak ada data orang tua/wali yang cocok.</p>
                </div>
            </div>
        </div>

        <!-- ================================================================= -->
        <!-- MODAL 1: KONFIRMASI HAPUS PASIEN (HANYA DOKTER)                   -->
        <!-- ================================================================= -->
        <Teleport to="body">
            <div
                v-if="patientToDelete"
                class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-navy/60 backdrop-blur-xs"
                @click.self="patientToDelete = null"
            >
                <div class="w-full max-w-md rounded-2xl bg-white dark:bg-[#0C2038] p-6 shadow-2xl border border-rose-200 dark:border-rose-900/50 space-y-4">
                    <div class="flex items-center gap-3 text-rose-600 dark:text-rose-400">
                        <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-rose-100 dark:bg-rose-950/60 border border-rose-200 dark:border-rose-800">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-base font-extrabold text-navy dark:text-white">
                                Hapus Data Pasien?
                            </h3>
                            <p class="text-2xs text-gray-500 dark:text-gray-400">
                                Tindakan ini hanya dapat dilakukan oleh Dokter.
                            </p>
                        </div>
                    </div>

                    <div class="rounded-xl bg-rose-50/60 dark:bg-rose-950/20 p-3.5 border border-rose-200/60 dark:border-rose-900/40 text-xs text-rose-900 dark:text-rose-200 space-y-1">
                        <p>
                            Apakah Anda yakin ingin menghapus data pasien <strong>{{ patientToDelete.name }}</strong> (No. RM: <code>{{ patientToDelete.medical_record_number }}</code>)?
                        </p>
                        <p class="text-2xs text-rose-700 dark:text-rose-300">
                            Peringatan: Seluruh riwayat sesi skrining, kuesioner, dan catatan klinis anak ini akan dihapus secara permanen dari sistem.
                        </p>
                    </div>

                    <div class="flex justify-end gap-2.5 pt-2">
                        <button
                            type="button"
                            @click="patientToDelete = null"
                            class="rounded-xl border border-sand/60 dark:border-white/15 px-4 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand-light transition"
                        >
                            Batal
                        </button>
                        <button
                            type="button"
                            :disabled="isDeleting"
                            @click="executeDeletePatient"
                            class="rounded-xl bg-rose-600 hover:bg-rose-700 px-5 py-2 text-xs font-bold text-white transition disabled:opacity-50"
                        >
                            {{ isDeleting ? 'Menghapus...' : 'Ya, Hapus Pasien Ini' }}
                        </button>
                    </div>
                </div>
            </div>
        </Teleport>

        <!-- ================================================================= -->
        <!-- MODAL 2: PENDAFTARAN WALI / ORANG TUA BARU                        -->
        <!-- ================================================================= -->
        <Teleport to="body">
            <div
                v-if="showGuardianModal"
                class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-navy/60 backdrop-blur-xs"
                @click.self="showGuardianModal = false"
            >
                <div class="w-full max-w-lg rounded-2xl bg-white dark:bg-[#0C2038] p-6 shadow-2xl border border-sand/40 dark:border-white/10 space-y-5">
                    <div class="flex items-center justify-between border-b border-sand/30 dark:border-white/10 pb-3">
                        <div>
                            <h3 class="text-base font-extrabold text-navy dark:text-white">
                                Tambah Akun Orang Tua / Wali Baru
                            </h3>
                            <p class="text-2xs text-gray-500 dark:text-gray-400">
                                Mendaftarkan wali agar dapat dihubungkan dengan data pasien anak.
                            </p>
                        </div>
                        <button
                            type="button"
                            @click="showGuardianModal = false"
                            class="text-gray-400 hover:text-navy dark:hover:text-white text-sm font-bold"
                        >
                            ✕
                        </button>
                    </div>

                    <form @submit.prevent="submitGuardian" class="space-y-4">
                        <div>
                            <label class="block text-xs font-bold text-navy dark:text-white mb-1">
                                Nama Lengkap Wali <span class="text-rose-600">*</span>
                            </label>
                            <input
                                v-model="guardianForm.name"
                                type="text"
                                required
                                placeholder="Contoh: Ibu Siti Rahayu"
                                class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] px-3.5 py-2 text-xs text-navy dark:text-white focus:border-teal focus:ring-teal"
                            />
                            <p v-if="guardianForm.errors.name" class="mt-1 text-2xs text-rose-600">{{ guardianForm.errors.name }}</p>
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-bold text-navy dark:text-white mb-1">
                                    Email Akun <span class="text-rose-600">*</span>
                                </label>
                                <input
                                    v-model="guardianForm.email"
                                    type="email"
                                    required
                                    placeholder="contoh: siti@gmail.com"
                                    class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] px-3.5 py-2 text-xs text-navy dark:text-white focus:border-teal focus:ring-teal"
                                />
                                <p v-if="guardianForm.errors.email" class="mt-1 text-2xs text-rose-600">{{ guardianForm.errors.email }}</p>
                            </div>

                            <div>
                                <label class="block text-xs font-bold text-navy dark:text-white mb-1">
                                    Nomor Telepon / WA
                                </label>
                                <input
                                    v-model="guardianForm.phone"
                                    type="text"
                                    placeholder="Contoh: 081234567890"
                                    class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] px-3.5 py-2 text-xs text-navy dark:text-white focus:border-teal focus:ring-teal"
                                />
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-navy dark:text-white mb-1">
                                Alamat Tempat Tinggal
                            </label>
                            <textarea
                                v-model="guardianForm.address"
                                rows="2"
                                placeholder="Contoh: Jl. Marsma Iswahyudi No. 12, Balikpapan Selatan"
                                class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] px-3.5 py-2 text-xs text-navy dark:text-white focus:border-teal focus:ring-teal"
                            ></textarea>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-navy dark:text-white mb-1">
                                Kata Sandi Login (Opsional)
                            </label>
                            <input
                                v-model="guardianForm.password"
                                type="text"
                                placeholder="Kosongkan jika menggunakan bawaan: 'password'"
                                class="w-full rounded-xl border border-sand/60 dark:border-white/15 bg-[#FAF7F0] dark:bg-[#071D37] px-3.5 py-2 text-xs text-navy dark:text-white focus:border-teal focus:ring-teal"
                            />
                            <p class="text-3xs text-gray-400 mt-0.5">Orang tua dapat login untuk mengisi kuesioner mandiri yang ditugaskan.</p>
                        </div>

                        <div class="flex justify-end gap-2.5 pt-3 border-t border-sand/30 dark:border-white/10">
                            <button
                                type="button"
                                @click="showGuardianModal = false"
                                class="rounded-xl border border-sand/60 dark:border-white/15 px-4 py-2 text-xs font-bold text-navy dark:text-white hover:bg-sand-light transition"
                            >
                                Batal
                            </button>
                            <button
                                type="submit"
                                :disabled="guardianForm.processing"
                                class="rounded-xl bg-teal hover:bg-navy px-5 py-2 text-xs font-bold text-white transition disabled:opacity-50 shadow-xs"
                            >
                                {{ guardianForm.processing ? 'Menyimpan...' : 'Simpan Akun Wali' }}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </Teleport>
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
