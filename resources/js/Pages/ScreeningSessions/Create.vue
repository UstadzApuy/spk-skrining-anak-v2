<script setup>
import { computed, watch } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    patients: {
        type: Array,
        required: true,
    },
    preselectedPatientId: {
        type: Number,
        default: null,
    },
});

const instrumentsList = [
    {
        code: 'KPSP',
        name: 'KPSP',
        title: 'Kuesioner Pra Skrining Perkembangan',
        description: 'Deteksi dini 4 sektor perkembangan: gerak kasar, gerak halus, bicara-bahasa, sosialisasi & kemandirian.',
        ageRange: '3 – 72 Bulan',
        targetRespondent: 'Pemeriksaan / Orang Tua',
    },
    {
        code: 'MCHAT',
        name: 'M-CHAT-R',
        title: 'Modified Checklist for Autism in Toddlers, Revised',
        description: 'Skrining risiko gangguan spektrum autisme (ASD) pada balita.',
        ageRange: '16 – 30 Bulan',
        targetRespondent: 'Orang Tua / Pengasuh',
    },
    {
        code: 'GPPH',
        name: 'GPPH / ACTRS',
        title: 'Abbreviated Conners Teacher Rating Scale',
        description: 'Deteksi dini gangguan pemusatan perhatian dan hiperaktivitas pada anak prasekolah.',
        ageRange: '36 – 72 Bulan (3–6 Tahun)',
        targetRespondent: 'Pemeriksa / Pengasuh',
    },
    {
        code: 'SDQ',
        name: 'SDQ',
        title: 'Strengths and Difficulties Questionnaire',
        description: 'Skrining masalah perilaku, emosi, hiperaktivitas, hubungan teman sebaya, dan prososial.',
        ageRange: '4 – 11 Tahun (48–131 Bulan)',
        targetRespondent: 'Orang Tua / Guru',
    },
    {
        code: 'SRQ',
        name: 'SRQ-20',
        title: 'Self Reporting Questionnaire',
        description: 'Penilaian kesehatan mental dan tingkat stres orang tua/pengasuh yang mendampingi anak.',
        ageRange: 'Semua Usia Anak',
        targetRespondent: 'Ibu / Pengasuh Utama',
    },
];

const form = useForm({
    patient_id: props.preselectedPatientId ? String(props.preselectedPatientId) : '',
    screening_date: new Date().toISOString().slice(0, 10),
    instruments: ['KPSP'],
    notes: '',
});

function calculateAgeMonths(birthDate, screeningDate) {
    if (!birthDate || !screeningDate) {
        return null;
    }

    const birth = String(birthDate).slice(0, 10);
    const screening = String(screeningDate).slice(0, 10);

    if (screening < birth) {
        return null;
    }

    const [birthYear, birthMonth, birthDay] = birth.split('-').map(Number);
    const [screeningYear, screeningMonth, screeningDay] = screening.split('-').map(Number);

    let months = (screeningYear - birthYear) * 12 + screeningMonth - birthMonth;

    if (screeningDay < birthDay) {
        months--;
    }

    return months;
}

function formatDate(value) {
    if (!value) return '-';
    const [year, month, day] = String(value).slice(0, 10).split('-');
    return `${day}/${month}/${year}`;
}

const selectedPatient = computed(() => {
    return props.patients.find(
        (p) => String(p.id) === String(form.patient_id)
    ) ?? null;
});

const selectedPatientAgeMonths = computed(() => {
    return calculateAgeMonths(
        selectedPatient.value?.birth_date,
        form.screening_date
    );
});

const selectedPatientAgeDisplay = computed(() => {
    const months = selectedPatientAgeMonths.value;
    if (months === null) return null;
    const years = Math.floor(months / 12);
    const remainingMonths = months % 12;
    return `${years} tahun ${remainingMonths} bulan (${months} bulan)`;
});

function isInstrumentAllowed(code) {
    const age = selectedPatientAgeMonths.value;
    if (age === null) return false;

    switch (code) {
        case 'KPSP':
            return age >= 3 && age <= 72;
        case 'MCHAT':
            return age >= 16 && age <= 30;
        case 'GPPH':
            return age >= 36 && age <= 72;
        case 'SDQ':
            return age >= 48 && age < 132;
        case 'SRQ':
            return true;
        default:
            return false;
    }
}

function getInstrumentIneligibilityReason(code) {
    const age = selectedPatientAgeMonths.value;
    if (!form.patient_id || !form.screening_date) {
        return 'Pilih pasien dan tanggal pemeriksaan terlebih dahulu.';
    }
    if (age === null) {
        return 'Tanggal pemeriksaan tidak boleh sebelum tanggal lahir.';
    }

    switch (code) {
        case 'KPSP':
            if (age < 3) return 'KPSP baru dapat digunakan mulai usia 3 bulan.';
            if (age > 72) return 'KPSP hanya digunakan untuk anak hingga usia 72 bulan (6 tahun).';
            return '';
        case 'MCHAT':
            if (age < 16) return 'M-CHAT-R hanya untuk balita berusia minimal 16 bulan.';
            if (age > 30) return 'M-CHAT-R hanya untuk balita hingga usia 30 bulan.';
            return '';
        case 'GPPH':
            if (age < 36) return 'GPPH/ACTRS hanya digunakan untuk anak prasekolah usia 36 bulan ke atas.';
            if (age > 72) return 'GPPH/ACTRS hanya digunakan untuk anak prasekolah hingga 72 bulan.';
            return '';
        case 'SDQ':
            if (age < 48) return 'SDQ hanya dapat digunakan untuk anak berusia 4 tahun (48 bulan) ke atas.';
            if (age >= 132) return 'SDQ versi 4–11 tahun hanya berlaku hingga sebelum 11 tahun (131 bulan).';
            return '';
        default:
            return '';
    }
}

// Watch age changes and prune ineligible instruments
watch(selectedPatientAgeMonths, (newAge) => {
    if (newAge !== null) {
        form.instruments = form.instruments.filter((code) => isInstrumentAllowed(code));
    }
});

function toggleInstrument(code) {
    if (!isInstrumentAllowed(code)) return;
    const index = form.instruments.indexOf(code);
    if (index > -1) {
        form.instruments.splice(index, 1);
    } else {
        form.instruments.push(code);
    }
}

const submit = () => {
    form.post('/screening-sessions');
};
</script>

<template>
    <Head title="Buat Sesi Skrining" />

    <AuthenticatedLayout>
        <template #header>
            <div>
                <h2 class="text-xl font-semibold text-gray-900">
                    Konfigurasi Sesi Skrining Anak
                </h2>
                <p class="mt-1 text-sm text-gray-500">
                    Tentukan data pasien, tanggal pemeriksaan, catatan pra-skrining, dan paket instrumen yang memenuhi kriteria usia.
                </p>
            </div>
        </template>

        <div class="mx-auto max-w-5xl space-y-6">
            <div class="flex items-center gap-2 text-xs font-bold text-teal">
                <Link
                    v-if="form.patient_id"
                    :href="`/screening-sessions?patient_id=${form.patient_id}`"
                    class="inline-flex items-center gap-1.5 hover:text-navy transition"
                >
                    &larr; Kembali ke Daftar Sesi Pasien
                </Link>
                <span v-if="form.patient_id" class="text-sand/60">|</span>
                <Link
                    href="/dashboard"
                    class="inline-flex items-center gap-1.5 text-gray-500 hover:text-navy transition"
                >
                    Patient Directory (Dashboard)
                </Link>
            </div>

            <div
                v-if="!patients.length"
                class="rounded-2xl border border-ochre/30 bg-ochre/10 p-5 text-sm text-earth font-semibold"
            >
                Belum ada data pasien aktif. Daftarkan pasien terlebih dahulu sebelum membuat sesi skrining.
            </div>

            <form class="space-y-6" @submit.prevent="submit">
                <!-- Section 1: Patient and Date -->
                <section class="rounded-2xl bg-white p-6 shadow-xs border border-sand/40 space-y-6">
                    <h3 class="text-base font-bold text-navy border-b border-sand/30 pb-3 flex items-center gap-2">
                        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-teal text-white text-xs font-bold">1</span>
                        Identitas Pasien & Jadwal Skrining
                    </h3>

                    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                        <div>
                            <label for="patient_id" class="block text-sm font-bold text-navy">
                                Pilih Anak / Pasien <span class="text-rose-600">*</span>
                            </label>
                            <select
                                id="patient_id"
                                v-model="form.patient_id"
                                required
                                class="mt-1.5 w-full rounded-xl border border-sand/60 text-sm shadow-2xs focus:border-teal focus:ring-1 focus:ring-teal"
                            >
                                <option value="" disabled>-- Pilih nama anak --</option>
                                <option
                                    v-for="p in patients"
                                    :key="p.id"
                                    :value="p.id"
                                >
                                    {{ p.name }} (RM: {{ p.medical_record_number }})
                                </option>
                            </select>
                            <p v-if="form.errors.patient_id" class="mt-1 text-xs text-rose-600 font-medium">
                                {{ form.errors.patient_id }}
                            </p>
                        </div>

                        <div>
                            <label for="screening_date" class="block text-sm font-bold text-navy">
                                Tanggal Pemeriksaan <span class="text-rose-600">*</span>
                            </label>
                            <input
                                id="screening_date"
                                v-model="form.screening_date"
                                type="date"
                                required
                                class="mt-1.5 w-full rounded-xl border border-sand/60 text-sm shadow-2xs focus:border-teal focus:ring-1 focus:ring-teal"
                            />
                            <p v-if="form.errors.screening_date" class="mt-1 text-xs text-rose-600 font-medium">
                                {{ form.errors.screening_date }}
                            </p>
                        </div>
                    </div>

                    <!-- Selected Patient Card -->
                    <div
                        v-if="selectedPatient"
                        class="rounded-xl bg-[#FAF7F0] border border-sand/40 p-4"
                    >
                        <div class="grid grid-cols-2 gap-4 sm:grid-cols-4 text-xs">
                            <div>
                                <span class="text-gray-500 block uppercase font-bold text-3xs">No. RM</span>
                                <span class="font-extrabold text-navy">{{ selectedPatient.medical_record_number }}</span>
                            </div>
                            <div>
                                <span class="text-gray-500 block uppercase font-bold text-3xs">Tgl Lahir</span>
                                <span class="font-bold text-navy">{{ formatDate(selectedPatient.birth_date) }}</span>
                            </div>
                            <div>
                                <span class="text-gray-500 block uppercase font-bold text-3xs">Jenis Kelamin</span>
                                <span class="font-bold text-navy">{{ selectedPatient.gender === 'L' ? 'Laki-laki' : 'Perempuan' }}</span>
                            </div>
                            <div>
                                <span class="text-gray-500 block uppercase font-bold text-3xs">Usia Terhitung</span>
                                <span class="font-extrabold text-teal">
                                    {{ selectedPatientAgeDisplay ?? 'Menghitung...' }}
                                </span>
                            </div>
                        </div>
                        <div v-if="selectedPatient.is_premature" class="mt-2.5 text-xs text-earth font-medium border-t border-sand/30 pt-2">
                            Catatan Prematur: Riwayat kelahiran prematur pada usia gestasi {{ selectedPatient.gestational_age_weeks }} minggu. Koreksi usia otomatis diperhitungkan sistem untuk formulir KPSP.
                        </div>
                    </div>

                    <!-- Pre-screening notes -->
                    <div>
                        <label for="notes" class="block text-sm font-bold text-navy">
                            Catatan Pra-Skrining / Keluhan Awal (Opsional)
                        </label>
                        <textarea
                            id="notes"
                            v-model="form.notes"
                            rows="2"
                            placeholder="Tuliskan keluhan orang tua, indikasi rujukan, atau observasi awal jika ada..."
                            class="mt-1.5 w-full rounded-xl border border-sand/60 text-sm shadow-2xs focus:border-teal focus:ring-1 focus:ring-teal"
                        />
                        <p v-if="form.errors.notes" class="mt-1 text-xs text-rose-600 font-medium">
                            {{ form.errors.notes }}
                        </p>
                    </div>
                </section>

                <!-- Section 2: Instrument Selection -->
                <section class="rounded-2xl bg-white p-6 shadow-xs border border-sand/40 space-y-4">
                    <div class="flex flex-wrap items-center justify-between gap-2 border-b border-sand/30 pb-3">
                        <h3 class="text-base font-bold text-navy flex items-center gap-2">
                            <span class="flex h-6 w-6 items-center justify-center rounded-full bg-teal text-white text-xs font-bold">2</span>
                            Pilih Paket Instrumen Skrining
                            <span class="text-rose-600">*</span>
                        </h3>
                        <span class="text-xs font-bold text-teal">
                            {{ form.instruments.length }} instrumen dipilih
                        </span>
                    </div>

                    <p class="text-sm text-gray-600 leading-relaxed">
                        Sistem memverifikasi kelayakan usia secara otomatis. Instrumen yang tidak memenuhi rentang usia anak akan dinonaktifkan sesuai pedoman klinis Kemenkes RI.
                    </p>

                    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
                        <div
                            v-for="inst in instrumentsList"
                            :key="inst.code"
                            class="relative flex flex-col justify-between rounded-2xl border p-4 transition"
                            :class="[
                                isInstrumentAllowed(inst.code)
                                    ? form.instruments.includes(inst.code)
                                        ? 'border-teal bg-teal/5 ring-2 ring-teal/30'
                                        : 'border-sand/40 bg-white hover:border-teal/60 hover:bg-sand-light/30 cursor-pointer'
                                    : 'border-sand/20 bg-slate-50 opacity-60 cursor-not-allowed'
                            ]"
                            @click="toggleInstrument(inst.code)"
                        >
                            <div class="flex items-start gap-3">
                                <input
                                    type="checkbox"
                                    :checked="form.instruments.includes(inst.code)"
                                    :disabled="!isInstrumentAllowed(inst.code)"
                                    class="mt-1 rounded border-sand/60 text-teal focus:ring-teal disabled:cursor-not-allowed"
                                    @click.stop
                                    @change="toggleInstrument(inst.code)"
                                />
                                <div class="flex-1">
                                    <div class="flex items-center justify-between gap-2">
                                        <span class="font-extrabold text-navy text-sm">
                                            {{ inst.name }}
                                        </span>
                                        <span class="rounded-full bg-sand-light px-2 py-0.5 text-3xs font-bold text-navy border border-sand/30">
                                            {{ inst.ageRange }}
                                        </span>
                                    </div>
                                    <p class="text-xs font-bold text-teal mt-0.5">
                                        {{ inst.title }}
                                    </p>
                                    <p class="text-xs text-gray-500 mt-1 leading-relaxed">
                                        {{ inst.description }}
                                    </p>
                                </div>
                            </div>

                            <!-- Ineligible reason callout -->
                            <div
                                v-if="!isInstrumentAllowed(inst.code)"
                                class="mt-3 rounded-xl bg-ochre/10 p-2.5 text-2xs font-semibold text-earth border border-ochre/20"
                            >
                                <span>{{ getInstrumentIneligibilityReason(inst.code) }}</span>
                            </div>
                        </div>
                    </div>

                    <p v-if="form.errors.instruments" class="text-xs text-rose-600 font-medium">
                        {{ form.errors.instruments }}
                    </p>
                </section>

                <!-- Actions -->
                <div class="flex flex-wrap items-center justify-between gap-3 rounded-2xl bg-white p-5 shadow-xs border border-sand/40">
                    <Link
                        :href="form.patient_id ? `/screening-sessions?patient_id=${form.patient_id}` : '/dashboard'"
                        class="rounded-xl border border-sand/60 px-4 py-2 text-xs font-bold text-navy hover:bg-sand-light transition shadow-2xs"
                    >
                        Batal
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing || !patients.length || !form.instruments.length"
                        class="rounded-xl bg-blue-600 px-6 py-2.5 text-xs font-bold text-white hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-50 transition shadow-sm"
                    >
                        {{ form.processing ? 'Menyimpan Sesi...' : 'Simpan & Mulai Sesi Skrining' }}
                    </button>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
.text-2xs {
    font-size: 0.6875rem;
    line-height: 0.95rem;
}
</style>
