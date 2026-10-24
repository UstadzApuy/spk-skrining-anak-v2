<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

defineProps({
    parentGuardians: {
        type: Array,
        required: true,
    },
});

const form = useForm({
    parent_guardian_id: '',
    medical_record_number: '',
    name: '',
    birth_date: '',
    gender: '',
    guardian_relationship: '',
    is_premature: false,
    gestational_age_weeks: '',
});

const submit = () => {
    form.post('/patients');
};
</script>

<template>
    <Head title="Tambah Pasien" />

    <AuthenticatedLayout>
        <template #header>
            <div class="space-y-3">
                <div>
                    <Link
                        href="/dashboard"
                        class="inline-flex items-center gap-1.5 text-xs font-bold text-teal hover:text-navy transition"
                    >
                        <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7" />
                        </svg>
                        Back to Patient Directory (Patient Selection)
                    </Link>
                </div>
                <div>
                    <h2 class="text-xl font-extrabold text-navy">
                        Tambah Pasien Baru
                    </h2>
                    <p class="mt-0.5 text-xs text-gray-500">
                        Tambahkan data identitas anak baru untuk proses skrining tumbuh kembang UPTD BLK-ABK.
                    </p>
                </div>
            </div>
        </template>

        <div class="max-w-3xl">
            <form
                class="space-y-6 rounded-2xl bg-white p-8 shadow-xs border border-sand/40"
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

                <div class="flex items-center justify-end gap-3 border-t border-sand/40 pt-6">
                    <Link
                        href="/dashboard"
                        class="rounded-xl border border-sand/60 px-4 py-2 text-xs font-bold text-navy hover:bg-sand-light transition shadow-2xs"
                    >
                        Batal
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="rounded-xl bg-blue-600 px-5 py-2.5 text-xs font-bold text-white hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-50 transition shadow-sm"
                    >
                        {{ form.processing ? 'Menyimpan...' : 'Simpan Pasien' }}
                    </button>
                </div>
            </form>
        </div>
    </AuthenticatedLayout>
</template>