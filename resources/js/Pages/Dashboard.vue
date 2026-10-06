<script setup>
import { Head, usePage } from '@inertiajs/vue3';

const page = usePage();

const user = page.props.auth.user;
</script>

<template>
    <Head title="Dashboard" />

    <main class="flex min-h-screen items-center justify-center bg-gray-100 px-4">
        <div class="w-full max-w-lg rounded-xl bg-white p-8 text-center shadow">
            <h1 class="text-2xl font-bold text-gray-900">
                Dashboard
            </h1>

            <div class="mt-6 space-y-2 text-sm text-gray-600">
                <p>
                    <span class="font-medium text-gray-900">Nama:</span>
                    {{ user.name }}
                </p>

                <p>
                    <span class="font-medium text-gray-900">Email:</span>
                    {{ user.email }}
                </p>

                <p>
                    <span class="font-medium text-gray-900">Role:</span>
                    {{ user.role }}
                </p>
            </div>
        </div>
    </main>
</template>