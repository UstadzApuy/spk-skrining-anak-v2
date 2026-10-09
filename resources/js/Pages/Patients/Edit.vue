<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    patient: {
        type: Object,
        required: true,
    },
    parentGuardians: {
        type: Array,
        required: true,
    },
});

const form = useForm({
    parent_guardian_id: props.patient.parent_guardian_id,
    medical_record_number: props.patient.medical_record_number,
    name: props.patient.name,
    birth_date: props.patient.birth_date,
    gender: props.patient.gender,
    guardian_relationship: props.patient.guardian_relationship ?? '',
    is_premature: props.patient.is_premature,
    gestational_age_weeks: props.patient.gestational_age_weeks ?? '',
});

const submit = () => {
    form.put(`/patients/${props.patient.id}`);
};
</script>

<template>
    <Head title="Ubah Pasien" />

    <AuthenticatedLayout>
        <template #header>
            <div>
                <h2 class="text-xl font-semibold text-gray-900">
                    Ubah Pasien
                </h2>

                <p class="mt-1 text-sm text-gray-500">
                    Perbarui data pasien yang telah terdaftar.
                </p>
            </div>
        </template>

        <div class="max-w-3xl">
            <form
                class="space-y-6 rounded-xl bg-white p-6 shadow-sm"
                @submit.prevent="submit"
            >
                <div>
                    <label
                        for="parent_guardian_id"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Orang Tua/Wali
                    </label>

                    <select
                        id="parent_guardian_id"
                        v-model="form.parent_guardian_id"
                        class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                    >
                        <option value="" disabled>
                            Pilih orang tua/wali
                        </option>

                        <option
                            v-for="parentGuardian in parentGuardians"
                            :key="parentGuardian.id"
                            :value="parentGuardian.id"
                        >
                            {{ parentGuardian.user?.name ?? '-' }}
                            — {{ parentGuardian.user?.email ?? '-' }}
                        </option>
                    </select>

                    <p
                        v-if="form.errors.parent_guardian_id"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.parent_guardian_id }}
                    </p>
                </div>

                <div>
                    <label
                        for="medical_record_number"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Nomor Rekam Medis
                    </label>

                    <input
                        id="medical_record_number"
                        v-model="form.medical_record_number"
                        type="text"
                        maxlength="100"
                        class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                        placeholder="Contoh: RM-001"
                    />

                    <p
                        v-if="form.errors.medical_record_number"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.medical_record_number }}
                    </p>
                </div>

                <div>
                    <label
                        for="name"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Nama Anak
                    </label>

                    <input
                        id="name"
                        v-model="form.name"
                        type="text"
                        maxlength="150"
                        class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                        placeholder="Masukkan nama anak"
                    />

                    <p
                        v-if="form.errors.name"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.name }}
                    </p>
                </div>

                <div class="grid gap-6 md:grid-cols-2">
                    <div>
                        <label
                            for="birth_date"
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Tanggal Lahir
                        </label>

                        <input
                            id="birth_date"
                            v-model="form.birth_date"
                            type="date"
                            class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                        />

                        <p
                            v-if="form.errors.birth_date"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.birth_date }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="gender"
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Jenis Kelamin
                        </label>

                        <select
                            id="gender"
                            v-model="form.gender"
                            class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                        >
                            <option value="" disabled>
                                Pilih jenis kelamin
                            </option>

                            <option value="L">
                                Laki-laki
                            </option>

                            <option value="P">
                                Perempuan
                            </option>
                        </select>

                        <p
                            v-if="form.errors.gender"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.gender }}
                        </p>
                    </div>
                </div>

                <div>
                    <label
                        for="guardian_relationship"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Hubungan dengan Anak
                    </label>

                    <input
                        id="guardian_relationship"
                        v-model="form.guardian_relationship"
                        type="text"
                        maxlength="50"
                        class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                        placeholder="Contoh: Ibu, Ayah, Wali"
                    />

                    <p
                        v-if="form.errors.guardian_relationship"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.guardian_relationship }}
                    </p>
                </div>

                <div class="rounded-lg border border-gray-200 p-4">
                    <label class="flex items-center">
                        <input
                            v-model="form.is_premature"
                            type="checkbox"
                            class="h-4 w-4 rounded border-gray-300"
                        />

                        <span class="ml-3 text-sm font-medium text-gray-700">
                            Anak lahir prematur
                        </span>
                    </label>

                    <div
                        v-if="form.is_premature"
                        class="mt-4"
                    >
                        <label
                            for="gestational_age_weeks"
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Usia Kehamilan Saat Lahir (Minggu)
                        </label>

                        <input
                            id="gestational_age_weeks"
                            v-model="form.gestational_age_weeks"
                            type="number"
                            min="20"
                            max="45"
                            class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                            placeholder="20–45 minggu"
                        />

                        <p class="mt-1 text-xs text-gray-500">
                            Isi antara 20 sampai 45 minggu.
                        </p>

                        <p
                            v-if="form.errors.gestational_age_weeks"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.gestational_age_weeks }}
                        </p>
                    </div>
                </div>

                <div class="flex items-center justify-end gap-3 border-t border-gray-200 pt-6">
                    <Link
                        href="/patients"
                        class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                    >
                        Batal
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-semibold text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                        {{ form.processing ? 'Menyimpan...' : 'Simpan Perubahan' }}
                    </button>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>