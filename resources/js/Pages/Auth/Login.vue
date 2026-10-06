<script setup>
import { Head, useForm } from '@inertiajs/vue3';

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post('/login');
};
</script>

<template>
    <Head title="Login" />

    <main class="flex min-h-screen items-center justify-center bg-gray-100 px-4">
        <div class="w-full max-w-md rounded-xl bg-white p-8 shadow">
            <div class="mb-8 text-center">
                <h1 class="text-2xl font-bold text-gray-900">
                    SPK Skrining Anak
                </h1>

                <p class="mt-2 text-sm text-gray-600">
                    Silakan masuk untuk melanjutkan.
                </p>
            </div>

            <form @submit.prevent="submit" class="space-y-5">
                <div>
                    <label
                        for="email"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Email
                    </label>

                    <input
                        id="email"
                        v-model="form.email"
                        type="email"
                        autocomplete="email"
                        class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                        placeholder="Masukkan email"
                    />

                    <p
                        v-if="form.errors.email"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.email }}
                    </p>
                </div>

                <div>
                    <label
                        for="password"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Password
                    </label>

                    <input
                        id="password"
                        v-model="form.password"
                        type="password"
                        autocomplete="current-password"
                        class="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200"
                        placeholder="Masukkan password"
                    />

                    <p
                        v-if="form.errors.password"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.password }}
                    </p>
                </div>

                <div class="flex items-center">
                    <input
                        id="remember"
                        v-model="form.remember"
                        type="checkbox"
                        class="h-4 w-4 rounded border-gray-300"
                    />

                    <label
                        for="remember"
                        class="ml-2 text-sm text-gray-600"
                    >
                        Ingat saya
                    </label>
                </div>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="w-full rounded-lg bg-gray-900 px-4 py-3 text-sm font-semibold text-white transition hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{ form.processing ? 'Memproses...' : 'Masuk' }}
                </button>
            </form>
        </div>
    </main>
</template>