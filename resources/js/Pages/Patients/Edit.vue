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
    address: props.patient.address ?? '',
    education: props.patient.education ?? 'tidak_sekolah',
    school_name: props.patient.school_name ?? '',
    guardian_relationship: props.patient.guardian_relationship ?? '',
    is_premature: props.patient.is_premature,
    gestational_age_weeks: props.patient.gestational_age_weeks ?? '',
    is_active: props.patient.is_active ?? true,
});

const submit = () => {
    form.put(`/spk/patients/${props.patient.id}`);
};
</script>

<template>
    <Head :title="`Ubah Data Pasien - ${patient.name}`" />

    <AuthenticatedLayout>
        <template #header>
            <div class="space-y-2">
                <div class="flex items-center gap-2 text-2xs font-bold text-gray-500 mb-1">
                    <Link href="/spk/dashboard" class="hover:text-teal transition">Dashboard</Link>
                    <span>/</span>
                    <Link href="/spk/patients" class="hover:text-teal transition">Data Pasien &amp; Wali</Link>
                    <span>/</span>
                    <span class="text-teal font-extrabold">Ubah Pasien</span>
                </div>
                <div>
                    <h2 class="text-xl font-extrabold text-navy">
                        Ubah Data Pasien: {{ patient.name }}
                    </h2>
                    <p class="text-xs text-gray-500">
                        Perbarui data identitas anak, alamat tempat tinggal, jenjang pendidikan, atau wali penanggung jawab.
                    </p>
                </div>
            </div>
        </template>

        <div class="max-w-3xl">
            <form
                class="space-y-6 rounded-2xl bg-white p-6 sm:p-8 shadow-xs border border-sand/40"
                @submit.prevent="submit"
            >
                <!-- BAGIAN 1: IDENTITAS PASIEN ANAK -->
                <div class="border-b border-sand/30 pb-4">
                    <h3 class="text-sm font-extrabold text-navy uppercase tracking-wider flex items-center gap-2 mb-4">
                        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-teal text-white text-xs">1</span>
                        Identitas Pasien Anak
                    </h3>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label
                                for="medical_record_number"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Nomor Rekam Medis (No. RM) <span class="text-rose-600">*</span>
                            </label>

                            <input
                                id="medical_record_number"
                                v-model="form.medical_record_number"
                                type="text"
                                maxlength="100"
                                required
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal font-mono font-bold"
                            />

                            <p
                                v-if="form.errors.medical_record_number"
                                class="mt-1 text-2xs text-rose-600 font-semibold"
                            >
                                {{ form.errors.medical_record_number }}
                            </p>
                        </div>

                        <div>
                            <label
                                for="name"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Nama Lengkap Anak <span class="text-rose-600">*</span>
                            </label>

                            <input
                                id="name"
                                v-model="form.name"
                                type="text"
                                maxlength="150"
                                required
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                            />

                            <p
                                v-if="form.errors.name"
                                class="mt-1 text-2xs text-rose-600 font-semibold"
                            >
                                {{ form.errors.name }}
                            </p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
                        <div>
                            <label
                                for="birth_date"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Tanggal Lahir <span class="text-rose-600">*</span>
                            </label>

                            <input
                                id="birth_date"
                                v-model="form.birth_date"
                                type="date"
                                required
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                            />

                            <p
                                v-if="form.errors.birth_date"
                                class="mt-1 text-2xs text-rose-600 font-semibold"
                            >
                                {{ form.errors.birth_date }}
                            </p>
                        </div>

                        <div>
                            <label
                                for="gender"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Jenis Kelamin <span class="text-rose-600">*</span>
                            </label>

                            <select
                                id="gender"
                                v-model="form.gender"
                                required
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                            >
                                <option value="L">Laki-laki (L)</option>
                                <option value="P">Perempuan (P)</option>
                            </select>

                            <p
                                v-if="form.errors.gender"
                                class="mt-1 text-2xs text-rose-600 font-semibold"
                            >
                                {{ form.errors.gender }}
                            </p>
                        </div>
                    </div>

                    <!-- Alamat Domisili -->
                    <div class="mt-4">
                        <label
                            for="address"
                            class="mb-1.5 block text-xs font-bold text-navy"
                        >
                            Alamat Tempat Tinggal (Domisili Anak)
                        </label>
                        <input
                            id="address"
                            v-model="form.address"
                            type="text"
                            maxlength="500"
                            placeholder="Contoh: Jl. Impres IV No. 62, Balikpapan Utara"
                            class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                        />
                    </div>

                    <!-- Riwayat Prematur -->
                    <div class="rounded-xl border border-sand/40 bg-[#FAF7F0] p-4 mt-4">
                        <label class="flex items-center cursor-pointer select-none">
                            <input
                                v-model="form.is_premature"
                                type="checkbox"
                                class="h-4 w-4 rounded border-sand/60 text-teal focus:ring-teal"
                            />
                            <span class="ml-2.5 text-xs font-bold text-navy">
                                Riwayat Lahir Prematur (Usia Kehamilan &lt; 37 Minggu)
                            </span>
                        </label>

                        <div v-if="form.is_premature" class="mt-3 pt-3 border-t border-sand/30">
                            <label
                                for="gestational_age_weeks"
                                class="mb-1 block text-xs font-semibold text-earth"
                            >
                                Usia Gestasi Saat Lahir (Minggu) <span class="text-rose-600">*</span>
                            </label>
                            <div class="flex items-center gap-2">
                                <input
                                    id="gestational_age_weeks"
                                    v-model="form.gestational_age_weeks"
                                    type="number"
                                    min="20"
                                    max="45"
                                    class="w-32 rounded-xl border border-sand/60 px-3 py-1.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                                />
                                <span class="text-xs text-gray-500">minggu</span>
                            </div>
                        </div>
                    </div>

                    <!-- Status Aktif Pasien -->
                    <div class="mt-4 flex items-center gap-2">
                        <input
                            id="is_active"
                            v-model="form.is_active"
                            type="checkbox"
                            class="h-4 w-4 rounded border-sand/60 text-teal focus:ring-teal"
                        />
                        <label for="is_active" class="text-xs font-bold text-navy cursor-pointer">
                            Status Pasien Aktif (Dapat dipilih untuk sesi skrining baru)
                        </label>
                    </div>
                </div>

                <!-- BAGIAN 2: PENDIDIKAN & SEKOLAH -->
                <div class="border-b border-sand/30 pb-4">
                    <h3 class="text-sm font-extrabold text-navy uppercase tracking-wider flex items-center gap-2 mb-4">
                        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-teal text-white text-xs">2</span>
                        Pendidikan &amp; Sekolah Anak
                    </h3>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label
                                for="education"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Jenjang / Jalur Pendidikan <span class="text-rose-600">*</span>
                            </label>
                            <select
                                id="education"
                                v-model="form.education"
                                required
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                            >
                                <option value="tidak_sekolah">Belum Sekolah / Tidak Sekolah</option>
                                <option value="reguler">Sekolah Reguler (PAUD/TK/SD/SMP)</option>
                                <option value="inklusi">Sekolah Inklusi</option>
                                <option value="slb">SLB (Sekolah Luar Biasa)</option>
                                <option value="panti">Panti Asuhan / Lembaga Kesejahteraan</option>
                            </select>
                            <p class="mt-0.5 text-3xs text-gray-400">
                                Masuk ke kolom 29 s/d 33 pada Laporan Register Bulanan UPTD BLK-ABK.
                            </p>
                        </div>

                        <div>
                            <label
                                for="school_name"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Nama Sekolah / Institusi
                            </label>
                            <input
                                id="school_name"
                                v-model="form.school_name"
                                type="text"
                                maxlength="200"
                                :disabled="form.education === 'tidak_sekolah'"
                                :placeholder="form.education === 'tidak_sekolah' ? 'Tidak perlu diisi (Belum Sekolah)' : 'Contoh: SD 012 Balikpapan Kota, TK Tunas Karya'"
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal disabled:bg-gray-100 disabled:opacity-60"
                            />
                            <p class="mt-0.5 text-3xs text-gray-400">
                                Masuk ke kolom 34: Keterangan (Nama Sekolah) pada Rekapitulasi SDIDTK.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- BAGIAN 3: ORANG TUA / WALI -->
                <div>
                    <h3 class="text-sm font-extrabold text-navy uppercase tracking-wider flex items-center gap-2 mb-4">
                        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-teal text-white text-xs">3</span>
                        Orang Tua / Wali Penanggung Jawab
                    </h3>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label
                                for="parent_guardian_id"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Akun Orang Tua/Wali <span class="text-rose-600">*</span>
                            </label>

                            <select
                                id="parent_guardian_id"
                                v-model="form.parent_guardian_id"
                                required
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                            >
                                <option
                                    v-for="parentGuardian in parentGuardians"
                                    :key="parentGuardian.id"
                                    :value="parentGuardian.id"
                                >
                                    {{ parentGuardian.user?.name ?? 'Tanpa Nama' }} ({{ parentGuardian.user?.email }})
                                </option>
                            </select>

                            <p
                                v-if="form.errors.parent_guardian_id"
                                class="mt-1 text-2xs text-rose-600 font-semibold"
                            >
                                {{ form.errors.parent_guardian_id }}
                            </p>
                        </div>

                        <div>
                            <label
                                for="guardian_relationship"
                                class="mb-1.5 block text-xs font-bold text-navy"
                            >
                                Hubungan Keluarga dengan Anak
                            </label>

                            <input
                                id="guardian_relationship"
                                v-model="form.guardian_relationship"
                                type="text"
                                maxlength="50"
                                class="w-full rounded-xl border border-sand/60 px-3.5 py-2.5 text-xs text-navy outline-none focus:border-teal focus:ring-1 focus:ring-teal"
                                placeholder="Contoh: Ibu Kandung, Ayah, Wali"
                            />
                        </div>
                    </div>
                </div>

                <!-- Tombol Aksi -->
                <div class="flex items-center justify-between gap-3 border-t border-sand/40 pt-6">
                    <Link
                        href="/spk/patients"
                        class="rounded-xl border border-sand/60 px-4 py-2.5 text-xs font-bold text-navy hover:bg-sand-light transition shadow-2xs"
                    >
                        Batal
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="rounded-xl bg-teal hover:bg-navy px-6 py-2.5 text-xs font-bold text-white disabled:cursor-not-allowed disabled:opacity-50 transition shadow-sm"
                    >
                        {{ form.processing ? 'Menyimpan...' : 'Perbarui Data Pasien' }}
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
.text-3xs {
    font-size: 0.625rem;
    line-height: 0.85rem;
}
</style>
