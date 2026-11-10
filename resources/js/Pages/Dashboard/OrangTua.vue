<script setup>
import { computed } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    patients: {
        type: Array,
        default: () => [],
    },
});

const user = computed(() => usePage().props.auth.user);

// Ambil seluruh kuesioner yang butuh diisi orang tua
const pendingTasks = computed(() => {
    const tasks = [];
    props.patients.forEach((patient) => {
        if (patient.pending_instruments && patient.pending_instruments.length > 0) {
            patient.pending_instruments.forEach((inst) => {
                tasks.push({
                    childName: patient.name,
                    childRm: patient.medical_record_number,
                    childAge: patient.age_display_id,
                    ...inst,
                });
            });
        }
    });
    return tasks;
});
</script>

<template>
    <Head title="Beranda Orang Tua - SPK Skrining Anak" />

    <AuthenticatedLayout>
        <div class="mx-auto max-w-6xl space-y-6 pb-12">
            <!-- Header Banner -->
            <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-navy via-navy-light to-teal p-6 text-white shadow-xl sm:p-8">
                <div class="absolute inset-0 bg-batik-pattern opacity-10 bg-cover bg-center pointer-events-none"></div>
                <div class="relative z-10 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div>
                        <span class="inline-flex items-center gap-1.5 rounded-full bg-white/20 px-3 py-1 text-2xs font-extrabold uppercase tracking-wider text-sand backdrop-blur-xs">
                            Portal Orang Tua / Wali
                        </span>
                        <h1 class="mt-2 text-2xl font-black tracking-tight sm:text-3xl text-white">
                            Selamat Datang, {{ user.name }}
                        </h1>
                        <p class="mt-1 text-xs sm:text-sm text-sand-light max-w-2xl font-medium">
                            UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus &bull; Dinas Kesehatan Kota Balikpapan
                        </p>
                    </div>
                    <div class="rounded-2xl bg-white/10 dark:bg-black/20 backdrop-blur-md border border-white/20 p-4 text-center shrink-0">
                        <span class="block text-2xs uppercase tracking-wider text-sand font-bold">Total Anak Terdaftar</span>
                        <span class="text-3xl font-black text-white">{{ patients.length }}</span>
                        <span class="block text-2xs text-sand-light">Profil Anak Aktif</span>
                    </div>
                </div>
            </div>

            <!-- Task Alert: Pending Parent Questionnaires -->
            <div v-if="pendingTasks.length > 0" class="space-y-3">
                <div class="flex items-center gap-2">
                    <span class="flex h-3 w-3 rounded-full bg-amber-500 animate-pulse"></span>
                    <h2 class="text-base font-extrabold text-navy dark:text-sand tracking-tight">
                        Kuesioner Menunggu Pengisian ({{ pendingTasks.length }})
                    </h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div
                        v-for="(task, idx) in pendingTasks"
                        :key="idx"
                        class="relative rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-sm border-2 border-amber-400/80 dark:border-amber-500/50 flex flex-col justify-between hover:shadow-md transition"
                    >
                        <div>
                            <div class="flex items-center justify-between gap-2 mb-2">
                                <span class="inline-flex items-center rounded-lg bg-amber-100 dark:bg-amber-950/80 px-2.5 py-1 text-xs font-black text-amber-800 dark:text-amber-300">
                                    {{ task.code }}
                                </span>
                                <span class="text-xs font-semibold text-gray-500 dark:text-gray-400">
                                    {{ task.childRm }}
                                </span>
                            </div>

                            <h3 class="text-sm font-bold text-navy dark:text-white leading-snug">
                                {{ task.title }}
                            </h3>
                            <p class="mt-1 text-xs text-gray-600 dark:text-gray-300">
                                Untuk: <span class="font-extrabold text-teal dark:text-teal-light">{{ task.childName }}</span> ({{ task.childAge }})
                            </p>
                            <p class="mt-1.5 text-2xs text-gray-500 dark:text-gray-400 leading-relaxed">
                                {{ task.description }}
                            </p>
                        </div>

                        <div class="mt-4 pt-3 border-t border-sand/30 dark:border-white/10 flex justify-end">
                            <Link
                                :href="task.url"
                                class="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal to-forest px-4 py-2 text-xs font-bold text-white shadow-sm hover:from-teal-dark hover:to-forest-dark transition"
                            >
                                <span>Isi Kuesioner Sekarang</span>
                                <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                                </svg>
                            </Link>
                        </div>
                    </div>
                </div>
            </div>

            <div v-else class="rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 border border-emerald-200 dark:border-emerald-800/50 p-4 sm:p-5 flex items-center gap-3">
                <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-100 dark:bg-emerald-900 text-emerald-600 dark:text-emerald-400">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                </div>
                <div>
                    <h3 class="text-xs sm:text-sm font-bold text-emerald-900 dark:text-emerald-200">
                        Seluruh Kuesioner Orang Tua Telah Lengkap
                    </h3>
                    <p class="text-2xs sm:text-xs text-emerald-750 dark:text-emerald-300">
                        Saat ini tidak ada instrumen skrining yang menunggu pengisian dari orang tua. Jika perawat memulai sesi skrining baru yang membutuhkan SDQ atau SRQ-20, kuesioner akan muncul di sini.
                    </p>
                </div>
            </div>

            <!-- Children Directory Section -->
            <div class="space-y-3">
                <div class="flex items-center justify-between">
                    <h2 class="text-base font-extrabold text-navy dark:text-sand tracking-tight">
                        Profil Anak Terdaftar
                    </h2>
                    <span class="text-xs font-semibold text-gray-500 dark:text-gray-400">
                        Standar SDIDTK Kemenkes RI
                    </span>
                </div>

                <div v-if="patients.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    <div
                        v-for="child in patients"
                        :key="child.id"
                        class="rounded-2xl bg-white dark:bg-[#0C2038] p-5 shadow-sm border border-sand/40 dark:border-white/10 hover:border-teal/40 transition flex flex-col justify-between"
                    >
                        <div>
                            <div class="flex items-center justify-between gap-2">
                                <span class="rounded-lg bg-sand/30 dark:bg-white/10 px-2 py-0.5 text-2xs font-extrabold text-earth dark:text-sand">
                                    {{ child.medical_record_number }}
                                </span>
                                <span
                                    class="inline-flex items-center rounded-md px-2 py-0.5 text-2xs font-bold"
                                    :class="child.gender === 'L' ? 'bg-blue-100 text-blue-800 dark:bg-blue-950/70 dark:text-blue-300' : 'bg-pink-100 text-pink-800 dark:bg-pink-950/70 dark:text-pink-300'"
                                >
                                    {{ child.gender === 'L' ? 'Laki-laki' : 'Perempuan' }}
                                </span>
                            </div>

                            <h3 class="mt-3 text-base font-bold text-navy dark:text-white leading-tight">
                                {{ child.name }}
                            </h3>
                            <p class="text-xs font-semibold text-teal dark:text-teal-light mt-0.5">
                                Usia: {{ child.age_display_id }}
                            </p>
                            <p class="text-2xs text-gray-500 dark:text-gray-400 mt-1">
                                Lahir: {{ child.birth_date }}
                            </p>
                        </div>

                        <div class="mt-4 pt-3 border-t border-sand/30 dark:border-white/10">
                            <div class="flex items-center justify-between text-2xs">
                                <span class="text-gray-500 dark:text-gray-400">Status Sesi Terakhir:</span>
                                <span
                                    v-if="child.latest_session"
                                    class="font-bold uppercase tracking-wider"
                                    :class="{
                                        'text-emerald-600 dark:text-emerald-400': child.latest_session.status === 'reviewed',
                                        'text-amber-600 dark:text-amber-400': child.latest_session.status === 'in_progress' || child.latest_session.status === 'pending_doctor_review',
                                        'text-gray-500': child.latest_session.status === 'draft',
                                    }"
                                >
                                    {{ child.latest_session.status === 'reviewed' ? 'Selesai Ditinjau' : (child.latest_session.status === 'pending_doctor_review' ? 'Menunggu Dokter' : 'Sedang Berjalan') }}
                                </span>
                                <span v-else class="text-gray-400 italic">
                                    Belum ada sesi
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div v-else class="rounded-2xl bg-white dark:bg-[#0C2038] p-8 text-center border border-sand/40 dark:border-white/10">
                    <p class="text-sm text-gray-500 dark:text-gray-400">
                        Belum ada anak yang terdaftar di akun ini.
                    </p>
                </div>
            </div>

            <!-- Role Responsibility Guide Card -->
            <div class="rounded-2xl bg-[#F5F2EB] dark:bg-[#08182B] p-5 sm:p-6 border border-sand/40 dark:border-white/10">
                <h3 class="text-xs font-extrabold uppercase tracking-wider text-earth dark:text-sand mb-2">
                    Petunjuk Peran & Kuasa Fitur (Orang Tua / Pengasuh)
                </h3>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 text-2xs sm:text-xs text-gray-600 dark:text-gray-300">
                    <div class="rounded-xl bg-white dark:bg-[#0C2038] p-3.5 border border-sand/30 dark:border-white/10">
                        <span class="font-bold text-navy dark:text-white block mb-1">1. Pengisian Mandiri</span>
                        Orang tua bertanggung jawab mengisi <strong>SDQ</strong> (kekuatan dan kesulitan emosi perilaku anak) dan <strong>SRQ-20</strong> (kesehatan mental pengasuh) jika dibuka oleh perawat.
                    </div>
                    <div class="rounded-xl bg-white dark:bg-[#0C2038] p-3.5 border border-sand/30 dark:border-white/10">
                        <span class="font-bold text-navy dark:text-white block mb-1">2. Pemeriksaan Klinis</span>
                        Pemeriksaan fisik, antropometri (BB, TB, LK), KPSP, M-CHAT, dan GPPH dilakukan langsung oleh Perawat di fasilitas layanan.
                    </div>
                    <div class="rounded-xl bg-white dark:bg-[#0C2038] p-3.5 border border-sand/30 dark:border-white/10">
                        <span class="font-bold text-navy dark:text-white block mb-1">3. Hasil & Rekomendasi</span>
                        Seluruh sintesis SPK dan kesimpulan klinis serta surat rujukan diverifikasi dan disahkan oleh Dokter Spesialis Anak.
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
