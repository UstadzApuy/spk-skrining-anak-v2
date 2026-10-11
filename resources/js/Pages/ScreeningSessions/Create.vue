
<script setup>
import { computed, watch } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    patients: {
        type: Array,
        required: true,
    },
});

const instruments = [
    {
        code: 'KPSP',
        name: 'KPSP',
        description: 'Kuesioner Pra Skrining Perkembangan',
    },
    {
        code: 'MCHAT',
        name: 'M-CHAT-R',
        description: 'Skrining risiko autisme pada anak',
    },
    {
        code: 'GPPH',
        name: 'GPPH',
        description: 'Gangguan Pemusatan Perhatian dan Hiperaktivitas',
    },
    {
        code: 'SDQ',
        name: 'SDQ',
        description: 'Strengths and Difficulties Questionnaire',
    },
    {
        code: 'SRQ',
        name: 'SRQ-20',
        description: 'Self Reporting Questionnaire',
    },
];

const form = useForm({
    patient_id: '',
    screening_date: '',
    instruments: [],
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

    const [birthYear, birthMonth, birthDay] = birth
        .split('-')
        .map(Number);

    const [screeningYear, screeningMonth, screeningDay] = screening
        .split('-')
        .map(Number);

    let months =
        (screeningYear - birthYear) * 12
        + screeningMonth
        - birthMonth;

    if (screeningDay < birthDay) {
        months--;
    }

    return months;
}

function formatDate(value) {
    if (!value) {
        return '-';
    }

    const [year, month, day] = String(value)
        .slice(0, 10)
        .split('-');

    return `${day}/${month}/${year}`;
}

const selectedPatientAgeDisplay = computed(() => {
    const months = selectedPatientAgeMonths.value;

    if (months === null) {
        return null;
    }

    const years = Math.floor(months / 12);
    const remainingMonths = months % 12;

    return `${years} tahun ${remainingMonths} bulan (${months} bulan)`;
});

const selectedPatient = computed(() => {
    return props.patients.find(
        (patient) => String(patient.id) === String(form.patient_id)
    ) ?? null;
});

const selectedPatientAgeMonths = computed(() => {
    return calculateAgeMonths(
        selectedPatient.value?.birth_date,
        form.screening_date
    );
});

const isSdqAgeAllowed = computed(() => {
    const age = selectedPatientAgeMonths.value;

    return age !== null && age >= 48 && age < 132;
});

const sdqAvailabilityMessage = computed(() => {
    if (!form.patient_id || !form.screening_date) {
        return 'Pilih pasien dan tanggal pemeriksaan untuk memeriksa kelayakan SDQ.';
    }

    const age = selectedPatientAgeMonths.value;

    if (age === null) {
        return 'Periksa kembali tanggal pemeriksaan dan tanggal lahir pasien.';
    }

    if (age < 48) {
        return 'SDQ tidak tersedia untuk anak di bawah 4 tahun.';
    }

    if (age >= 132) {
        return 'SDQ hanya tersedia untuk anak berusia 4 tahun sampai sebelum 11 tahun.';
    }

    return '';
});

watch(isSdqAgeAllowed, (allowed) => {
    if (!allowed && form.instruments.includes('SDQ')) {
        form.instruments = form.instruments.filter(
            (code) => code !== 'SDQ'
        );
    }
});


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
                    Buat Sesi Skrining
                </h2>

                <p class="mt-1 text-sm text-gray-500">
                    Tentukan pasien, tanggal pemeriksaan, dan instrumen
                    yang akan digunakan.
                </p>
            </div>
        </template>

        <div class="max-w-3xl space-y-6">
            <div
                v-if="!patients.length"
                class="rounded-lg border border-yellow-200 bg-yellow-50 p-4 text-sm text-yellow-800"
            >
                Belum ada pasien aktif. Tambahkan data pasien terlebih dahulu
                sebelum membuat sesi skrining.
            </div>

            <form
                class="space-y-6 rounded-xl bg-white p-6 shadow-sm"
                @submit.prevent="submit"
            >
                <div>
                    <label
                        for="patient_id"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Pasien <span class="text-red-600">*</span>
                    </label>

                    <select
                        id="patient_id"
                        v-model="form.patient_id"
                        required
                        class="w-full rounded-lg border-gray-300 text-sm shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    >
                        <option value="" disabled>
                            Pilih pasien
                        </option>

                        <option
                            v-for="patient in patients"
                            :key="patient.id"
                            :value="patient.id"
                        >
                            {{ patient.name }} — No. RM:
                            {{ patient.medical_record_number }} — Tanggal lahir:
                            {{ formatDate(patient.birth_date) }}
                        </option>
                    </select>

                    <div
                        v-if="selectedPatient"
                        class="mt-3 rounded-lg bg-gray-50 p-3 text-sm"
                    >
                        <p class="text-gray-600">
                            Tanggal lahir:
                            <span class="font-medium text-gray-900">
                                {{ formatDate(selectedPatient.birth_date) }}
                            </span>
                        </p>

                        <p class="mt-1 text-gray-600">
                            Umur saat pemeriksaan:
                            <span class="font-semibold text-gray-900">
                                {{
                                    selectedPatientAgeDisplay
                                    ?? 'Pilih tanggal pemeriksaan terlebih dahulu'
                                }}
                            </span>
                        </p>
                    </div>

                    <p
                        v-if="form.errors.patient_id"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.patient_id }}
                    </p>
                </div>

                <div>
                    <label
                        for="screening_date"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Tanggal Pemeriksaan
                        <span class="text-red-600">*</span>
                    </label>

                    <input
                        id="screening_date"
                        v-model="form.screening_date"
                        type="date"
                        required
                        class="w-full rounded-lg border-gray-300 text-sm shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    />

                    <p class="mt-1 text-xs text-gray-500">
                        Umur anak akan dihitung oleh sistem berdasarkan
                        tanggal lahir dan tanggal pemeriksaan.
                    </p>

                    <p
                        v-if="form.errors.screening_date"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.screening_date }}
                    </p>
                </div>

                <div>
                    <h3 class="text-sm font-semibold text-gray-900">
                        Instrumen Skrining
                        <span class="text-red-600">*</span>
                    </h3>

                    <p class="mt-1 text-sm text-gray-500">
                        Pilih minimal satu instrumen yang akan digunakan
                        dalam sesi ini.
                    </p>

                    <div class="mt-4 space-y-3">
                       <label
                            v-for="instrument in instruments"
                            :key="instrument.code"
                            class="flex gap-3 rounded-lg border border-gray-200 p-4"
                            :class="
                                instrument.code === 'SDQ' && !isSdqAgeAllowed
                                    ? 'cursor-not-allowed bg-gray-50 opacity-70'
                                    : 'cursor-pointer hover:bg-gray-50'
                            "
                        >
                            <input
                                v-model="form.instruments"
                                type="checkbox"
                                :value="instrument.code"
                                :disabled="instrument.code === 'SDQ' && !isSdqAgeAllowed"
                                class="mt-1 rounded border-gray-300 text-gray-900 focus:ring-gray-500 disabled:cursor-not-allowed"
                            />

                            <span class="flex-1">
                                <span
                                    class="block text-sm font-semibold text-gray-900"
                                >
                                    {{ instrument.name }}
                                </span>

                                <span
                                    class="mt-1 block text-sm text-gray-500"
                                >
                                    {{ instrument.description }}
                                </span>
                                <span
                                    v-if="instrument.code === 'SDQ' && !isSdqAgeAllowed"
                                    class="mt-2 block text-xs text-amber-700"
                                >
                                    {{ sdqAvailabilityMessage }}
                                </span>
                            </span>
                        </label>
                    </div>

                    <p
                        v-if="form.errors.instruments"
                        class="mt-2 text-sm text-red-600"
                    >
                        {{ form.errors.instruments }}
                    </p>

                    <p
                        v-if="form.errors['instruments.0']"
                        class="mt-2 text-sm text-red-600"
                    >
                        {{ form.errors['instruments.0'] }}
                    </p>
                </div>

                <div class="flex flex-wrap justify-end gap-3 border-t border-gray-100 pt-5">
                    <Link
                        href="/screening-sessions"
                        class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50"
                    >
                        Batal
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing || !patients.length"
                        class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-semibold text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                        {{
                            form.processing
                                ? 'Menyimpan...'
                                : 'Buat Sesi Skrining'
                        }}
                    </button>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>
