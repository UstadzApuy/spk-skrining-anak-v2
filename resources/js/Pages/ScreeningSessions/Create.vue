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
        category: 'routine',
        categoryLabel: 'Pemeriksaan Rutin Sesuai Jadwal',
        title: 'Kuesioner Pra Skrining Perkembangan',
        description: 'Deteksi dini 4 sektor perkembangan: gerak kasar, gerak halus, bicara-bahasa, sosialisasi & kemandirian.',
        ageRange: '3 – 72 Bulan',
        targetRespondent: 'Pemeriksaan / Orang Tua',
    },
    {
        code: 'MCHAT',
        name: 'M-CHAT-R',
        category: 'indication',
        categoryLabel: 'Pemeriksaan Atas Indikasi',
        title: 'Modified Checklist for Autism in Toddlers, Revised',
        description: 'Skrining risiko gangguan spektrum autisme (ASD) pada balita.',
        ageRange: '16 – 30 Bulan',
        targetRespondent: 'Orang Tua / Pengasuh',
    },
    {
        code: 'GPPH',
        name: 'GPPH / ACTRS',
        category: 'indication',
        categoryLabel: 'Pemeriksaan Atas Indikasi',
        title: 'Abbreviated Conners Teacher Rating Scale',
        description: 'Deteksi dini gangguan pemusatan perhatian dan hiperaktivitas pada anak prasekolah.',
        ageRange: '36 – 72 Bulan (3–6 Tahun)',
        targetRespondent: 'Pemeriksa / Pengasuh',
    },
    {
        code: 'SDQ',
        name: 'SDQ',
        category: 'indication',
        categoryLabel: 'Pemeriksaan Atas Indikasi',
        title: 'Strengths and Difficulties Questionnaire',
        description: 'Skrining masalah perilaku, emosi, hiperaktivitas, hubungan teman sebaya, dan prososial.',
        ageRange: '4 – 11 Tahun (48–131 Bulan)',
        targetRespondent: 'Orang Tua / Guru',
    },
    {
        code: 'SRQ',
        name: 'SRQ-20',
        category: 'indication',
        categoryLabel: 'Pemeriksaan Atas Indikasi',
        title: 'Self Reporting Questionnaire',
        description: 'Penilaian kesehatan mental dan tingkat stres orang tua/pengasuh yang mendampingi anak.',
        ageRange: 'Semua Usia Anak',
        targetRespondent: 'Ibu / Pengasuh Utama',
    },
];

const routineInstruments = computed(() => instrumentsList.filter(i => i.category === 'routine'));
const indicationInstruments = computed(() => instrumentsList.filter(i => i.category === 'indication'));

const form = useForm({
    patient_id: props.preselectedPatientId ? String(props.preselectedPatientId) : '',
    screening_date: new Date().toISOString().slice(0, 10),
    instruments: ['KPSP'],
    case_type: 'baru',
    referral_source: '',
    notes: '',
});

const KPSP_FORM_AGES = [3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60, 66, 72];

function subtractAge(age, correctionMonths, correctionDays) {
    let years = age.years;
    let months = age.months;
    let days = age.days - correctionDays;

    if (days < 0) {
        days += 30;
        months--;
    }

    months -= correctionMonths;

    if (months < 0) {
        months += 12;
        years--;
    }

    if (years < 0) {
        return { years: 0, months: 0, days: 0 };
    }

    return { years, months, days };
}

function selectKpspFormAge(ageMonths) {
    if (ageMonths < 3 || ageMonths > 72) {
        return null;
    }

    let selectedAge = null;
    for (const formAge of KPSP_FORM_AGES) {
        if (formAge > ageMonths) {
            break;
        }
        selectedAge = formAge;
    }

    return selectedAge;
}

function calculateAgeDetails(birthDate, screeningDate, isPremature = false, gestationalAgeWeeks = null) {
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

    let years = screeningYear - birthYear;
    let months = screeningMonth - birthMonth;
    let days = screeningDay - birthDay;

    if (days < 0) {
        days += 30;
        months--;
    }

    if (months < 0) {
        months += 12;
        years--;
    }

    let age = { years, months, days };
    let isPrematureCorrected = false;

    if (isPremature && age.years < 2 && gestationalAgeWeeks !== null && gestationalAgeWeeks !== undefined) {
        const weeks = Number(gestationalAgeWeeks);
        if (weeks >= 1 && weeks < 38) {
            const correctionWeeks = 40 - weeks;
            const correctionMonths = Math.floor(correctionWeeks / 4);
            const correctionDays = (correctionWeeks % 4) * 7;
            age = subtractAge(age, correctionMonths, correctionDays);
            isPrematureCorrected = true;
        }
    }

    const ageMonths = age.years * 12 + age.months;
    const formSelectionMonths = ageMonths + (age.days > 16 ? 1 : 0);
    const kpspFormAgeMonths = selectKpspFormAge(formSelectionMonths);

    return {
        age,
        ageMonths,
        kpspFormAgeMonths,
        isPrematureCorrected,
    };
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

// Update otomatis case_type saat pasien dipilih (termasuk saat preselected via URL)
watch(
    selectedPatient,
    (p) => {
        if (p) {
            form.case_type = (p.sessions_count ?? 0) > 0 ? 'lama' : 'baru';
        }
    },
    { immediate: true }
);

const selectedPatientAgeDetails = computed(() => {
    return calculateAgeDetails(
        selectedPatient.value?.birth_date,
        form.screening_date,
        Boolean(selectedPatient.value?.is_premature),
        selectedPatient.value?.gestational_age_weeks
    );
});

const selectedPatientAgeMonths = computed(() => {
    return selectedPatientAgeDetails.value?.ageMonths ?? null;
});

const selectedPatientAgeDisplay = computed(() => {
    const details = selectedPatientAgeDetails.value;
    if (!details) return null;
    const { age, ageMonths, isPrematureCorrected } = details;
    const suffix = isPrematureCorrected ? ' - terkoreksi' : '';
    return `${age.years} tahun ${age.months} bulan ${age.days} hari (${ageMonths} bulan${suffix})`;
});

function isInstrumentAllowed(code) {
    const details = selectedPatientAgeDetails.value;
    if (!details) return false;
    const age = details.ageMonths;

    switch (code) {
        case 'KPSP':
            return details.kpspFormAgeMonths !== null;
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
    const details = selectedPatientAgeDetails.value;
    if (!form.patient_id || !form.screening_date) {
        return 'Pilih pasien dan tanggal pemeriksaan terlebih dahulu.';
    }
    if (!details) {
        return 'Tanggal pemeriksaan tidak boleh sebelum tanggal lahir.';
    }

    const age = details.ageMonths;

    switch (code) {
        case 'KPSP':
            if (details.kpspFormAgeMonths === null) {
                return age < 3
                    ? 'KPSP baru dapat digunakan mulai usia formulir 3 bulan.'
                    : 'KPSP hanya digunakan untuk anak hingga usia formulir 72 bulan (6 tahun).';
            }
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
watch(
    selectedPatientAgeMonths,
    (newAge) => {
        if (newAge !== null) {
            form.instruments = form.instruments.filter((code) => isInstrumentAllowed(code));
        }
    },
    { immediate: true }
);

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
    form.post('/spk/screening-sessions');
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
            <div class="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs font-bold text-teal">
                <Link
                    v-if="form.patient_id"
                    :href="`/spk/screening-sessions?patient_id=${form.patient_id}`"
                    class="inline-flex items-center gap-1.5 hover:text-navy transition"
                >
                    &larr; Kembali ke Daftar Sesi Pasien
                </Link>
                <span v-if="form.patient_id" class="text-sand/60">|</span>
                <Link
                    href="/spk/dashboard"
                    class="inline-flex items-center gap-1.5 text-gray-500 hover:text-navy transition"
                >
                    Daftar Pasien (Dashboard)
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
                <section class="rounded-2xl bg-white p-4 shadow-xs border border-sand/40 space-y-6 sm:p-6">
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
                                    :value="String(p.id)"
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

                    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                        <!-- Jenis Kasus (Baru / Lama) -->
                        <div>
                            <label class="block text-sm font-bold text-navy mb-1.5">
                                Status Kasus Kunjungan <span class="text-rose-600">*</span>
                            </label>
                            <div class="grid grid-cols-2 gap-2">
                                <label
                                    class="flex items-center gap-2 rounded-xl border p-2.5 cursor-pointer text-xs font-bold transition"
                                    :class="form.case_type === 'baru' ? 'border-teal bg-teal/10 text-teal' : 'border-sand/60 bg-white text-navy hover:bg-sand-light'"
                                >
                                    <input
                                        type="radio"
                                        v-model="form.case_type"
                                        value="baru"
                                        class="text-teal focus:ring-teal"
                                    />
                                    <span>Kasus Baru</span>
                                </label>

                                <label
                                    class="flex items-center gap-2 rounded-xl border p-2.5 cursor-pointer text-xs font-bold transition"
                                    :class="form.case_type === 'lama' ? 'border-teal bg-teal/10 text-teal' : 'border-sand/60 bg-white text-navy hover:bg-sand-light'"
                                >
                                    <input
                                        type="radio"
                                        v-model="form.case_type"
                                        value="lama"
                                        class="text-teal focus:ring-teal"
                                    />
                                    <span>Kasus Lama</span>
                                </label>
                            </div>
                            <p class="mt-1 text-3xs text-gray-400">
                                Mengisi kolom Kasus Baru (kolom 5) atau Lama (kolom 6) di Rekapitulasi SDIDTK.
                            </p>
                        </div>

                        <!-- Rujukan Dari -->
                        <div>
                            <label for="referral_source" class="block text-sm font-bold text-navy mb-1.5">
                                Rujukan Dari (Asal Pasien)
                            </label>
                            <input
                                id="referral_source"
                                v-model="form.referral_source"
                                type="text"
                                maxlength="150"
                                placeholder="Contoh: Datang Sendiri, Puskesmas Damai, PAUD Melati"
                                class="w-full rounded-xl border border-sand/60 text-sm shadow-2xs focus:border-teal focus:ring-1 focus:ring-teal"
                            />
                            <p class="mt-1 text-3xs text-gray-400">
                                Mengisi kolom Rujukan Dari (kolom 7) di Rekapitulasi SDIDTK.
                            </p>
                        </div>
                    </div>
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
                        <div v-if="selectedPatient.is_premature || selectedPatientAgeDetails?.kpspFormAgeMonths" class="mt-2.5 text-xs text-earth font-medium border-t border-sand/30 pt-2 space-y-1">
                            <p v-if="selectedPatient.is_premature">
                                Catatan Prematur: Riwayat kelahiran prematur pada usia gestasi {{ selectedPatient.gestational_age_weeks }} minggu. Koreksi usia di bawah 2 tahun otomatis diterapkan sistem.
                            </p>
                            <p v-if="selectedPatientAgeDetails?.kpspFormAgeMonths" class="text-teal font-semibold">
                                Kelompok Formulir KPSP Terpilih: {{ selectedPatientAgeDetails.kpspFormAgeMonths }} Bulan (aturan pembulatan SDIDTK &gt; 16 hari diterapkan otomatis).
                            </p>
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
                <section class="rounded-2xl bg-white p-4 shadow-xs border border-sand/40 space-y-4 sm:p-6">
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

                    <!-- Kategori III: Pemeriksaan Rutin Sesuai Jadwal -->
                    <div class="space-y-2.5">
                        <div class="flex items-center gap-2">
                            <span class="inline-flex h-5 items-center rounded-md bg-emerald-100 px-2 text-2xs font-extrabold uppercase text-emerald-800 border border-emerald-300">
                                Kategori III
                            </span>
                            <h4 class="text-xs font-extrabold text-navy uppercase tracking-wider">
                                Pemeriksaan Rutin Sesuai Jadwal
                            </h4>
                        </div>

                        <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
                            <div
                                v-for="inst in routineInstruments"
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
                    </div>

                    <!-- Kategori IV: Pemeriksaan Atas Indikasi -->
                    <div class="space-y-2.5 pt-2">
                        <div class="flex items-center gap-2">
                            <span class="inline-flex h-5 items-center rounded-md bg-amber-100 px-2 text-2xs font-extrabold uppercase text-amber-800 border border-amber-300">
                                Kategori IV
                            </span>
                            <h4 class="text-xs font-extrabold text-navy uppercase tracking-wider">
                                Pemeriksaan Atas Indikasi
                            </h4>
                        </div>

                        <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
                            <div
                                v-for="inst in indicationInstruments"
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
                    </div>

                    <p v-if="form.errors.instruments" class="text-xs text-rose-600 font-medium">
                        {{ form.errors.instruments }}
                    </p>
                </section>

                <!-- Actions -->
                <div class="flex flex-col-reverse items-stretch justify-between gap-3 rounded-2xl bg-white p-4 shadow-xs border border-sand/40 sm:flex-row sm:items-center sm:p-5">
                    <Link
                        :href="form.patient_id ? `/spk/screening-sessions?patient_id=${form.patient_id}` : '/spk/dashboard'"
                        class="rounded-xl border border-sand/60 px-4 py-2.5 text-xs font-bold text-navy hover:bg-sand-light transition shadow-2xs text-center sm:py-2"
                    >
                        Batal
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing || !patients.length || !form.instruments.length"
                        class="rounded-xl bg-blue-600 px-6 py-3 text-xs font-bold text-white hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-50 transition shadow-sm sm:py-2.5"
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
